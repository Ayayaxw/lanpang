function Main:OnUnitKilled(args)
    -- 获取被杀死的单位的entindex
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    
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

    if challengeName then
        -- 构建处理函数的名称
        local challengeFunctionName = "OnUnitKilled_" .. challengeName
        if self[challengeFunctionName] then
            -- 先检查英雄是否真正死亡
            IsHeroTrulyDead(killedUnit, function(isDead)
                if not isDead then return end
                -- 英雄确实死亡后，调用对应的处理函数
                self[challengeFunctionName](self, killedUnit, args)
            end)
        else
            print("没有找到对应挑战模式的处理函数: " .. challengeName)
        end
    else
        print("未知的挑战模式ID: " .. tostring(challengeId))
    end
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
