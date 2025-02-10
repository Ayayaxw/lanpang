

function Main:Cleanup_CreepChallenge_100Creeps()
end


function Main:Init_CreepChallenge_100Creeps(event, playerID)
    -- 从 event 中获取英雄数据
    hero_duel.killCount = 0 
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_damage_reduction_100", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})
                hero:AddNewModifier(hero, nil, "modifier_phased", {})
                hero:AddNewModifier(hero, nil, "modifier_full_restore", {}) -- 给英雄添加修饰器
                HeroMaxLevel(hero)
            end,
        },
        FRIENDLY = {
            function(hero)
                hero:SetForwardVector(Vector(1, 0, 0))
                -- 可以在这里添加更多友方英雄特定的操作
            end,
        },
        ENEMY = {
            function(hero)
                hero:SetForwardVector(Vector(-1, 0, 0))
                -- 可以在这里添加敌方英雄特定的操作
            end,
        },
        BATTLEFIELD = {
            function(hero)
            end,
        }
    }

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)


    local currentTime = Time()
    local formattedTime = string.format("%.2f", currentTime)
    print("[DOTA_RECORD] " .. heroChineseName .. ": 更换英雄：".. selfFacetId )

    PlayerResource:SetGold(playerID, 0, false)
    self.duration = 10 -- 保存 duration 以便在 OnUnitKilled 中使用
    self.endduration = 6  -- 保存 duration 以便在 OnUnitKilled 中使用
    local limitTime = 60  -- 限定时间
    -- 设置当前计时器标志
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    -- 准备要发送的数据
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["剩余时间"] = limitTime,
        ["击杀数量"] = "0"
    }
    -- 准备要发送的顺序信息
    local order = {"挑战英雄", "剩余时间", "击杀数量"}

    SendInitializationMessage(data, order)

    setCameraPosition(Vector(100, 500, 0))

    CreateHero(playerID, heroName, selfFacetId, Vector(100, 500, 0), DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        -- 如果启用了AI，为玩家英雄创建AI
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")

                return nil
            end)
        else
            -- 处理非 AI 情况
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
    
    hero_duel.EndDuel = false  -- 新增的标志
    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);

    


    for i = 1, 100 do
        local creep = CreateUnitByName("npc_dota_creep_goodguys_ranged", Vector(100, 500, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
        creep:AddNewModifier(creep, nil, "modifier_disarmed", { duration = self.duration })
        -- 添加无敌 modifier
        creep:AddNewModifier(creep, nil, "modifier_invulnerable", { duration = self.duration })
    end

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
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        print("[DOTA_RECORD] " .. heroChineseName .. ": 开始战斗")
    end)
    -- 限定时间结束后执行的操作
    Timers:CreateTimer(self.duration + limitTime, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        Main:ClearAllUnitByName("npc_dota_creep_goodguys_ranged")

        
        -- 停止计时并精确设置前端计时器的时间
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})

        print("[DOTA_RECORD] " .. heroChineseName .. ": 最终得分：".. tostring(hero_duel.killCount))
        print("[DOTA_RECORD] " .. heroChineseName .. ": 结束挑战")
        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        hero_duel.EndDuel = true
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = self.endduration })

    end)
end


function Main:OnUnitKilled_CreepChallenge_100Creeps(killedUnit, args)
    if not hero_duel.EndDuel then
        if killedUnit:GetUnitName() == "npc_dota_creep_goodguys_ranged" then
            -- 增加总击杀数
            hero_duel.killCount = hero_duel.killCount + 1

            -- 发送分数更新事件

            local data = {
                ["击杀数量"] = hero_duel.killCount
            }
            
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)
            -- 获取死亡单位的位置
            local deathPosition = killedUnit:GetAbsOrigin()


            -- 重新生成一个远程小兵在死亡单位的位置
            local newCreep = CreateUnitByName("npc_dota_creep_goodguys_ranged", deathPosition, true, nil, nil, DOTA_TEAM_BADGUYS)

            -- 播放金币掉落的粒子效果在击杀者头上显示
            local killerEntity = args.entindex_attacker and EntIndexToHScript(args.entindex_attacker)
            --print(killerEntity:GetName())
            if killerEntity then
                        -- 在英雄头上播放决斗胜利的动画和音效
                local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)

                -- 设置粒子控件，控制点0为小兵的位置
                ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)

                -- 播放金币音效
                EmitSoundOn("General.Coins", killerEntity)
                if killerEntity:GetUnitName() == "npc_dota_warlock_minor_imp" then
                    
                    
                    killerEntity:RemoveSelf()
                end
                killedUnit:RemoveSelf()
            end 
        end
    end
end

function Main:OnNPCSpawned_CreepChallenge_100Creeps(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
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
--         hero_duel:UpdateShadowShamanHealth(newHero,totalHealthPercentage)

--         -- 继续监听
--         return 0.1
--     end)
-- end



