function Main:Cleanup_HeroChallenge_illusion()

end


function Main:Init_HeroChallenge_illusion(event, playerID)
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    hero_duel.EndDuel = false  
    _G.totalKills = 0
    _G.endduel = false

    -- 获取当前的游戏时间（以秒为单位）
    local currentTime = Time()

    -- 格式化时间，只保留两位小数
    local formattedTime = string.format("%.2f", currentTime)

    -- 打印包含格式化时间戳的记录
    print("[DOTA_RECORD] "  .. heroChineseName .. ": 更换英雄：" .. selfFacetId)
    enemyChineseName = self:GetHeroChineseName(Main.AIheroName)
    print("[DOTA_RECORD] "  .. enemyChineseName .. ": 创建对手：" .. tostring(FacetsNum))

    PlayerResource:SetGold(playerID, 0, false)
    self.duration = 10 -- 保存 duration 以便在 OnUnitKilled 中使用
    self.endduration = 6  -- 保存 duration 以便在 OnUnitKilled 中使用

    -- 设置当前计时器标志
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    CreateHero(0, heroName, selfFacetId, Main.smallDuelArea, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        playerHero:SetForwardVector(Vector(1,0, 0))
        playerHero:AddItemByName("item_ultimate_scepter_2")
        playerHero:AddItemByName("item_aghanims_shard")
        --playerHero:AddNewModifier(playerHero, nil, "modifier_phased", {})
        --playerHero:AddNewModifier(playerHero, nil, "modifier_full_restore", {}) -- 给英雄添加修饰器

        HeroMaxLevel(playerHero)
        -- playerHero:AddNewModifier(playerHero, nil, "modifier_no_cooldown_FirstSkill", {}
        self.leftTeamHero1 = playerHero
        local player = PlayerResource:GetPlayer(0)
        playerHero:SetControllableByPlayer(0, true)
        player:SetAssignedHeroEntity(playerHero)
        Main.currentArenaHeroes[1] = playerHero
        -- 如果启用了AI，为玩家英雄创建AI
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy)
                return nil
            end)
        end
    end)
    -- 设置金币和经验
    Timers:CreateTimer(2, function()
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        end
    end)

    Timers:CreateTimer(5, function()
        local heroes = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, hero in ipairs(heroes) do
            if hero and not hero:IsNull() then
                local duration = self.duration - 5
                hero:AddNewModifier(hero, nil, "modifier_disarmed", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_silence", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_rooted", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_muted", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_break", { duration = duration })
                --hero:AddNewModifier(hero, nil, "modifier_damage_attribute_transfer", {})
                print("添加修饰成功")
            end
        end
    end)
    


    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);


    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0"
    }
    
    -- 准备要发送的顺序信息
    local order = {"挑战英雄", "击杀数量"}

    SendInitializationMessage(data,order)

    setCameraPosition(Main.smallDuelArea)

    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then
            print("Timer cancelled or duel ended")
            return
        end
    
        local heroPosition = self.leftTeamHero1:GetAbsOrigin()
        print("Hero position:", heroPosition)
    

        -- 检查 caipan 的状态
        if self.caipan and self.caipan:IsAlive() then
            print("Caipan 仍然存在且存活")
        else
            print("Caipan 不存在或已被移除，重新创建")
            self.caipan = CreateUnitByName("caipan", Vector(5000, 5000, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
        end


        local illusionDuration = 999.0
        local outgoingDamage = 100
        local incomingDamage = 100
    
        local enemyTeam = DOTA_TEAM_BADGUYS
        print("Enemy team:", enemyTeam)
    
        print("Creating illusion for:", self.leftTeamHero1:GetUnitName())
        print("Main.caipan:", self.caipan:GetUnitName())
    
        -- 生成幻象
        local illusions = CreateIllusions(self.caipan, self.leftTeamHero1, {
            duration = illusionDuration,
            outgoing_damage = outgoingDamage,
            incoming_damage = incomingDamage,
        }, 1, 64, true, true)
    
        if illusions then
            print("Illusions created, count:", #illusions)
        else
            print("Failed to create illusions, illusions is nil")
        end
    
        -- 确保幻象数组不为空，并且取第一个幻象进行操作
        if illusions and #illusions > 0 then
            local illusion = illusions[1]
            Main.illusion = illusions[1]
            print("Illusion created successfully:", illusion:GetUnitName())
    
            illusion:AddNewModifier(illusion, nil, "modifier_illusion_death_listener", {})
            print("Added death listener modifier to illusion")
        else
            print("No illusions created or illusions array is empty")
        end
    end)

        



    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    -- 倒计时3秒，在最后一秒喊话“开始”
    Timers:CreateTimer(self.duration - 4, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_countdown", {})
    end)

    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --GameRules:SendCustomMessage("开始！", 0, 0)
        --CreateAIForHero(dianhun)



        
        -- 获取当前的游戏时间（以秒为单位）

        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        local currentTime = Time()
        local formattedTime = string.format("%.2f", currentTime)
        print("[DOTA_RECORD] " .. heroChineseName .. ": 开始战斗")
    end)
    -- 限定时间结束后执行的操作
    -- Timers:CreateTimer(self.duration + limitTime, function()
    --     if self.currentTimer ~= timerId or hero_duel.EndDuel then return end


        
    --     -- 停止计时并精确设置前端计时器的时间
    --     CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})

    --     -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
    --     hero_duel.EndDuel = true
    --     self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = self.endduration })
    --     self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = self.endduration })
    --     self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
    --     self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = self.endduration })

    -- end)
end


function Main:OnUnitKilled_HeroChallenge_illusion(killedUnit, args)
    if not hero_duel.EndDuel then

        if killedUnit:IsRealHero() then
            heroChineseName=self:GetHeroChineseName(killedUnit:GetUnitName())
            if killedUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
                local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
                if ability then
                    local cooldownTime = ability:GetCooldownTimeRemaining()
                    local fullCooldown = ability:GetCooldown(ability:GetLevel() - 1)

                    -- 检查重生技能的冷却时间是否在1秒内，这意味着技能刚刚被触发
                    if fullCooldown - cooldownTime < 1 then
                        print("Skeleton King has used Reincarnation and will resurrect.")
                    else
                        -- 如果重生技能冷却时间不在这个范围内，那么认为英雄已彻底死亡
                        hero_duel.EndDuel = true
                        _G.endduel = true
                        local currentTime = Time()
                        local formattedTime = string.format("%.2f", currentTime)
                        print("[DOTA_RECORD] " .. heroChineseName .. ": 最终得分：".. tostring(_G.totalKills))
                        print("[DOTA_RECORD] " .. heroChineseName .. ": 结束挑战")
                        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})
                        print("Skeleton King has died permanently. Timer stopped.")
                    end
                end
            elseif killedUnit:GetUnitName() == "npc_dota_hero_vengefulspirit" then

                Timers:CreateTimer(0.3, function()
                    local nearbyHeroes = FindUnitsInRadius(
                        killedUnit:GetTeamNumber(),
                        killedUnit:GetAbsOrigin(),
                        nil,
                        -1,  -- 搜索范围，按需调整
                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false
                    )
                
                    for _, hero in pairs(nearbyHeroes) do
                       
                        if hero:HasModifier("modifier_vengefulspirit_hybrid_special") then
                            print("找到幻象啦")
                            Timers:CreateTimer(0.1, function()
                                if not hero:IsAlive() then
                                    hero_duel.EndDuel = true
                                    _G.endduel = true
                                    print("触发了")
                                    local currentTime = GameRules:GetGameTime()
                                    local formattedTime = string.format("%.2f", currentTime)
                                    print("[DOTA_RECORD] " .. formattedTime .. "  " .. heroChineseName .. ": 最终得分：" .. tostring(_G.totalKills))
                                    print("[DOTA_RECORD] " .. formattedTime .. "  " .. heroChineseName .. ": 结束挑战")
                                    CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})
                                    return nil  -- 停止定时器
                                end
                                return 0.1  -- 继续每0.1秒检查一次
                            end)
                        end
                    end
                end)
            elseif killedUnit == self.leftTeamHero1 then
                -- 调用 hero_duel:UpdateShadowShamanHealth 方法，将暗影萨满的健康值设为 0
                local currentTime = Time()
                local formattedTime = string.format("%.2f", currentTime)
                print("[DOTA_RECORD] " .. heroChineseName .. ": 最终得分：".. tostring(_G.totalKills))
                print("[DOTA_RECORD] " .. heroChineseName .. ": 结束挑战")
                CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})
                hero_duel.EndDuel = true
                _G.endduel = true
    
            -- 检查是否有实体被杀死，且该实体是一个英雄
            end
        
        end
    end
end


-- function Main:OnHeroHealth_CreepChallenge_100Creeps(heroes)
--     print("当前挑战：MonkeyKing")
--     if not heroes then
--         print("英雄列表为空，终止执行")
--         return
--     end

--     -- 移除之前的监听
--     if self.heroHealthTimer then
--         print("移除已存在的定时器")
--         Timers:RemoveTimer(self.heroHealthTimer)
--     end

--     -- 监听英雄组当前生命值占最大生命值的总百分比
--     self.heroHealthTimer = Timers:CreateTimer(0.1, function()
--         local totalCurrentHealth = 0
--         local totalMaxHealth = 0

--         for _, hero in pairs(heroes) do
--             -- 检查每个英雄是否仍然存在且有效
--             if not hero or hero:IsNull() then
--                 print("检测到无效英雄，终止此轮计算")
--                 return nil
--             elseif hero_duel.EndDuel then
--                 print("对决已结束，终止定时器")
--                 return nil
--             end

--             -- 累计生命值和最大生命值
--             totalCurrentHealth = totalCurrentHealth + hero:GetHealth()
--             totalMaxHealth = totalMaxHealth + hero:GetMaxHealth()
--         end

--         -- 计算总生命值百分比
--         local totalHealthPercentage = (totalCurrentHealth / totalMaxHealth) * 100
--         totalHealthPercentage = math.ceil(totalHealthPercentage)
--         print("总生命值百分比计算结果：", totalHealthPercentage)

--         if totalHealthPercentage > 100 then
--             totalHealthPercentage = 100
--             print("生命百分比超过500，调整为500")
--         end

--         -- 更新Shadow Shaman的血量百分比，假设需要更新
--         hero_duel:UpdateShadowShamanHealth(leftTeamHero1,totalHealthPercentage)

--         -- 继续监听
--         return 0.1
--     end)
-- end



