function Main:OnUnitKilled(args)
    -- 获取被杀死的单位的entindex
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killerUnit = EntIndexToHScript(args.entindex_attacker)

    -- 记录死亡事件，供modifier_death_check_enchant检查使用
    if not Main.DeathEventTracking then
        Main.DeathEventTracking = {}
    end
    
    -- 使用单位的实体索引作为表的键，记录已处理的死亡事件
    if killedUnit and not killedUnit:IsNull() then
        local unitIndex = killedUnit:GetEntityIndex()
        Main.DeathEventTracking[unitIndex] = {
            handled = true,
            attackerIndex = args.entindex_attacker
        }
    end

    -- 如果是米波克隆体，找到本体
    if killedUnit:GetUnitName() == "npc_dota_hero_meepo" and killedUnit:IsClone() then
        local mainMeepo = killedUnit:GetRealOwner()
        if mainMeepo then
            local playerID = killedUnit:GetPlayerOwnerID()
            -- 使用playerID作为key来存储每个玩家的米波死亡时间
            if not self.meepoDeathTimes then
                self.meepoDeathTimes = {}
            end
            
            local currentTime = GameRules:GetGameTime()
            -- 检查这个玩家的米波是否在短时间内死亡过
            if self.meepoDeathTimes[playerID] and (currentTime - self.meepoDeathTimes[playerID]) < 0.1 then
                print("这个玩家的米波刚刚死过，跳过此次处理")
                return
            end
            
            -- 记录这个玩家的米波死亡时间
            self.meepoDeathTimes[playerID] = currentTime
            
            print("米波死啦，找到了本体")
            -- 更新 args 中的 entindex_killed
            args.entindex_killed = mainMeepo:GetEntityIndex()
            killedUnit = mainMeepo
            
            -- 更新死亡事件跟踪信息
            Main.DeathEventTracking[mainMeepo:GetEntityIndex()] = {
                handled = true,
                attackerIndex = args.entindex_attacker
            }
        end
    end

    -- 获取当前的挑战模式ID
    local challengeId = self.currentChallenge

    -- 查找对应的挑战模式名称
    local challengeName
    for name, id in pairs(Main.Challenges) do
        if id == challengeId then
            challengeName = name
            break
        end
    end
    --打印死亡的单位名字
    --print("死亡的单位名字: " .. killedUnit:GetUnitName())

    if challengeName then
        -- 构建处理函数的名称
        local challengeFunctionName = "OnUnitKilled_" .. challengeName
        if self[challengeFunctionName] then
            -- 先检查英雄是否真正死亡
            IsHeroTrulyDead(killedUnit, function(isDead)
                if not isDead then return end

                if Main.currentMatchID then
                    -- 初始化击杀消息队列
                    if not Main.killMessageQueue then
                        Main.killMessageQueue = {}
                    end
                    
                    -- 初始化击杀者的最后广播时间表
                    if not Main.lastBroadcastTimes then
                        Main.lastBroadcastTimes = {}
                    end
                    
                    local killerID = killerUnit:GetEntityIndex()
                    local killedUnitName = killedUnit:GetUnitName()
                    
                    -- 检查此击杀者是否已有记录
                    if not Main.killMessageQueue[killerID] then
                        Main.killMessageQueue[killerID] = {
                            killerName = {localize = true, text = killedUnitName},
                            victims = {}
                        }
                    end
                    
                    -- 更新被击杀单位的计数
                    if not Main.killMessageQueue[killerID].victims[killedUnitName] then
                        Main.killMessageQueue[killerID].victims[killedUnitName] = {
                            count = 1,
                            name = {localize = true, text = killedUnitName}
                        }
                    else
                        Main.killMessageQueue[killerID].victims[killedUnitName].count = Main.killMessageQueue[killerID].victims[killedUnitName].count + 1
                    end
                    
                    -- 为每个击杀者单独控制广播时间（每秒一次）
                    local currentTime = GameRules:GetGameTime()
                    if not Main.lastBroadcastTimes[killerID] or (currentTime - Main.lastBroadcastTimes[killerID] >= 1.0) then
                        self:BroadcastKillMessagesByKiller(killerID)
                        Main.lastBroadcastTimes[killerID] = currentTime
                    end
                end

                -- 英雄确实死亡后，调用对应的处理函数
                self[challengeFunctionName](self, killedUnit, args)
            end)
        else
            --print("没有找到对应挑战模式的处理函数: " .. challengeName)
        end
    else
        --print("未知的挑战模式ID: " .. tostring(challengeId))
    end
end

-- 新增函数：广播指定击杀者的击杀消息
function Main:BroadcastKillMessagesByKiller(killerID)
    if not Main.killMessageQueue or not Main.currentMatchID or not Main.killMessageQueue[killerID] then return end
    
    local killerData = Main.killMessageQueue[killerID]
    
    local messageElements = {
        "[LanPang_RECORD][",
        Main.currentMatchID,
        "]",
        "[击杀信息]",
        killerData.killerName,
        "击杀了"
    }
    
    -- 构建被击杀单位列表
    local isFirst = true
    for unitName, victimData in pairs(killerData.victims) do
        if not isFirst then
            table.insert(messageElements, "、")
        end
        
        table.insert(messageElements, victimData.name)
        if victimData.count > 1 then
            table.insert(messageElements, " X" .. victimData.count)
        end
        
        isFirst = false
    end
    
    -- 发送本次消息
    Main:createLocalizedMessage(unpack(messageElements))
    
    -- 仅清空当前击杀者的队列
    Main.killMessageQueue[killerID] = nil
end

-- 保留原有函数以兼容其他可能调用的地方
function Main:BroadcastKillMessages()
    if not Main.killMessageQueue or not Main.currentMatchID then return end
    
    -- 遍历每个击杀者
    for killerID, _ in pairs(Main.killMessageQueue) do
        self:BroadcastKillMessagesByKiller(killerID)
    end
    
    -- 清空整个队列
    Main.killMessageQueue = {}
end

-- function Main:OnUnitKilled(args)
--     -- 通过args中的entindex_killed获取被杀死的单位
--     if self.currentChallenge == Main.Challenges.HeroChallenge_ShadowShaman and not hero_duel.EndDuel then
--         local killedUnit = EntIndexToHScript(args.entindex_killed)

--         if killedUnit:GetUnitName() == "npc_dota_hero_shadow_shaman" then
--             hero_duel:UpdateShadowShamanHealth(self.newHero,0)
--             killedUnit:RemoveSelf()
--             hero_duel.EndDuel = true
--             print("Shadow Shaman has died. Health set to 0.")
--         end

--         if killedUnit:IsRealHero() then
--             if killedUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
--                 local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
--                 if ability then
--                     local cooldownTime = ability:GetCooldownTimeRemaining()
--                     local fullCooldown = ability:GetCooldown(ability:GetLevel() - 1)
--                     if fullCooldown - cooldownTime < 1 then
--                         print("Skeleton King has used Reincarnation and will resurrect.")
--                     else
--                         hero_duel.EndDuel = true
--                         CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
--                         print("Skeleton King has died permanently. Timer stopped.")
--                     end
--                 end
--             else
--                 hero_duel.EndDuel = true
--                 CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
--                 print("A player-controlled hero has died. Timer stopped.")
--             end
--         end
--     end  -- 结束 HeroChallenge_ShadowShaman 分支






--     if self.currentChallenge == Main.Challenges.CD0_1skill then

--         local killedUnit = EntIndexToHScript(args.entindex_killed)
    
--         if not hero_duel.EndDuel then
--             if killedUnit:GetUnitName() == Main.AIheroName then
--                 -- 调用 hero_duel:UpdateShadowShamanHealth 方法，将暗影萨满的健康值设为 0
--                 hero_duel:UpdateShadowShamanHealth(self.newHero, 0)
            
--                 hero_duel.EndDuel = true
--                 print("Shadow Shaman has died. Health set to 0.")
--             end
    
--             local killedEntity = EntIndexToHScript(args.entindex_killed)
    
--             -- 检查是否有实体被杀死，且该实体是一个英雄
--             if killedUnit:IsRealHero() then
--                 if killedUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
--                     local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
--                     if ability then
--                         local cooldownTime = ability:GetCooldownTimeRemaining()
--                         local fullCooldown = ability:GetCooldown(ability:GetLevel() - 1)
    
--                         -- 检查重生技能的冷却时间是否在1秒内，这意味着技能刚刚被触发
--                         if fullCooldown - cooldownTime < 1 then
--                             print("Skeleton King has used Reincarnation and will resurrect.")
--                         else
--                             -- 如果重生技能冷却时间不在这个范围内，那么认为英雄已彻底死亡
--                             hero_duel.EndDuel = true
--                             CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
--                             print("Skeleton King has died permanently. Timer stopped.")
--                         end
--                     end
--                 else
--                     -- 其他英雄死亡逻辑
--                     hero_duel.EndDuel = true
--                     CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
--                     print("A player-controlled hero has died. Timer stopped.")
--                 end
--             end
--         end
    
--         -- 如果死亡的是 Razor，无论是否结束决斗，10秒后始终清除该英雄
--         -- if killedUnit:GetUnitName() == Main.AIheroName then
--         --     Timers:CreateTimer(10, function()
--         --         killedUnit:RemoveSelf()
--         --         print("Razor has been removed after 10 seconds.")
--         --     end)
--         -- end
--     end
    
--     if self.currentChallenge == Main.Challenges.CD0_1skill_online then

--         local killedUnit = EntIndexToHScript(args.entindex_killed)
    
--         if not hero_duel.EndDuel then
--             if killedUnit:GetUnitName() == Main.AIheroName then
--                 -- 调用 hero_duel:UpdateShadowShamanHealth 方法，将暗影萨满的健康值设为 0
--                 hero_duel:UpdateShadowShamanHealth(self.newHero0, 0)
            
--                 hero_duel.EndDuel = true
--                 print("Shadow Shaman has died. Health set to 0.")
--             end
    
--             local killedEntity = EntIndexToHScript(args.entindex_killed)
    
--             -- 检查是否有实体被杀死，且该实体是一个英雄
--             if killedUnit:IsRealHero() then
--                 if killedUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
--                     local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
--                     if ability then
--                         local cooldownTime = ability:GetCooldownTimeRemaining()
--                         local fullCooldown = ability:GetCooldown(ability:GetLevel() - 1)
    
--                         -- 检查重生技能的冷却时间是否在1秒内，这意味着技能刚刚被触发
--                         if fullCooldown - cooldownTime < 1 then
--                             print("Skeleton King has used Reincarnation and will resurrect.")
--                         else
--                             -- 如果重生技能冷却时间不在这个范围内，那么认为英雄已彻底死亡
--                             hero_duel.EndDuel = true
--                             CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
--                             print("Skeleton King has died permanently. Timer stopped.")
--                         end
--                     end
--                 else
--                     -- 其他英雄死亡逻辑
--                     hero_duel.EndDuel = true
--                     CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
--                     print("A player-controlled hero has died. Timer stopped.")
--                 end
--             end
--         end
    
--         -- 如果死亡的是 Razor，无论是否结束决斗，10秒后始终清除该英雄
--         -- if killedUnit:GetUnitName() == Main.AIheroName then
--         --     Timers:CreateTimer(10, function()
--         --         killedUnit:RemoveSelf()
--         --         print("Razor has been removed after 10 seconds.")
--         --     end)
--         -- end
--     end

--     if self.currentChallenge == Main.Challenges.CreepChallenge and not spawn_manager.allCreepsKilled then
--         local unit = EntIndexToHScript(args.entindex_killed)

--         if unit then
--             spawn_manager:OnCreepKilled(unit:GetUnitName(), self.newHero, self.duration)
--         end
--     end
-- end
