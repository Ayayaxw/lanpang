function Main:Init_Duel_1VS30(event, playerID)
    -- 技能修改器
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    local ability_modifiers = {
        npc_dota_hero_morphling = {
            morphling_replicate = {
                duration = 	1	
            },
        },
    }
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 设置英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
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
                HeroMaxLevel(hero)

                -- 可以在这里添加敌方英雄特定的操作
            end,
        },
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
            end,
        }
    }

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local opponentHeroId = event.opponentHeroId or -1
    local opponentFacetId = event.opponentFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local opponentAIEnabled = (event.opponentAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local opponentEquipment = event.opponentEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local opponentOverallStrategy = self:getDefaultIfEmpty(event.opponentOverallStrategies)
    local opponentHeroStrategy = self:getDefaultIfEmpty(event.opponentHeroStrategies)

    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local opponentHeroName, opponentChineseName = self:GetHeroNames(opponentHeroId)

    -- 设置AI英雄信息
    self.AIheroName = opponentHeroName
    self.FacetId = opponentFacetId

    self:UpdateAbilityModifiers(ability_modifiers)

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 120        -- 限定时间为准备时间结束后的一分钟
    hero_duel.EndDuel = false  -- 标记战斗是否结束

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[新挑战]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择绿方]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择红方]",
        {localize = true, text = opponentHeroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(opponentHeroName, opponentFacetId)}
    )


    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["对手英雄"] = opponentChineseName,
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "对手英雄", "剩余时间"}
    SendInitializationMessage(data, order)




    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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

    -- 创建对手英雄
    CreateHero(playerID, opponentHeroName, opponentFacetId, self.smallDuelAreaRight, DOTA_TEAM_BADGUYS, false, function(opponentHero)
        self:ConfigureHero(opponentHero, false, playerID)
        self:EquipHeroItems(opponentHero, opponentEquipment)
        self.rightTeamHero1 = opponentHero
        self:ListenHeroHealth(self.rightTeamHero1)
        self.currentArenaHeroes[2] = self.rightTeamHero1
        -- 如果启用了AI，为对手英雄创建AI
        if opponentAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.rightTeamHero1, opponentOverallStrategy, opponentHeroStrategy,"rightTeamHero1")
                
                -- 检查是否为米波，如果是，为克隆体也创建AI
                if opponentHeroName == "npc_dota_hero_meepo" then
                    Timers:CreateTimer(0.1, function()
                        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                        local meepos = FindUnitsInRadius(
                            DOTA_TEAM_BADGUYS,
                            opponentHero:GetAbsOrigin(),
                            nil,
                            FIND_UNITS_EVERYWHERE,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO,
                            DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                            FIND_ANY_ORDER,
                            false
                        )
                        for _, meepo in pairs(meepos) do
                            if meepo:HasModifier("modifier_meepo_divided_we_stand") and meepo:IsRealHero() and meepo ~= opponentHero then
                                CreateAIForHero(meepo, opponentOverallStrategy, opponentHeroStrategy, "rightTeamHero1_clone")
                            end
                        end
                    end)
                end
                return nil
            end)
        else
            -- 处理非 AI 情况
        end
    end)

    -- 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.rightTeam = {self.rightTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        end
    end)

    -- 给英雄添加小礼物
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentHeroStrategy)
    end)


    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        local ability_modifiers = {
            npc_dota_hero_morphling = {
                morphling_replicate = {
                    duration = 	40	
                },
            },
        }
        self:UpdateAbilityModifiers(ability_modifiers)
        -- 给双方英雄添加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        
        -- 处理左边英雄
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            -- 添加限制效果
            for _, modifier in ipairs(modifiers) do
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
            -- 移动到指定位置
            FindClearSpaceForUnit(self.leftTeamHero1, self.smallDuelAreaLeft, true)
            -- 设置朝向右边
            self.leftTeamHero1:SetForwardVector(Vector(1, 0, 0))
            
            -- 恢复生命值和法力值
            self.leftTeamHero1:SetHealth(self.leftTeamHero1:GetMaxHealth())
            self.leftTeamHero1:SetMana(self.leftTeamHero1:GetMaxMana())
            
            -- 重置所有技能冷却和充能
            for i = 0, self.leftTeamHero1:GetAbilityCount() - 1 do
                local ability = self.leftTeamHero1:GetAbilityByIndex(i)
                if ability then
                    ability:EndCooldown()
                    -- 恢复充能点数
                    local maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel())
                    if maxCharges > 0 then
                        ability:SetCurrentAbilityCharges(maxCharges)
                    end
                end
            end
        end

        -- 处理右边英雄  
        if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
            -- 添加限制效果
            for _, modifier in ipairs(modifiers) do
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
            -- 移动到指定位置
            FindClearSpaceForUnit(self.rightTeamHero1, self.smallDuelAreaRight, true)
            -- 设置朝向左边
            self.rightTeamHero1:SetForwardVector(Vector(-1, 0, 0))
            
            -- 恢复生命值和法力值
            self.rightTeamHero1:SetHealth(self.rightTeamHero1:GetMaxHealth())
            self.rightTeamHero1:SetMana(self.rightTeamHero1:GetMaxMana())
            
            -- 重置所有技能冷却和充能
            for i = 0, self.rightTeamHero1:GetAbilityCount() - 1 do
                local ability = self.rightTeamHero1:GetAbilityByIndex(i)
                if ability then
                    ability:EndCooldown()
                    -- 恢复充能点数
                    local maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel())
                    if maxCharges > 0 then
                        ability:SetCurrentAbilityCharges(maxCharges)
                    end
                end
            end
        end
    end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.smallDuelArea, 1)

    -- 重置计时器并发送信息
    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = self.limitTime - self.duration, heroChineseName = heroChineseName, challengedHeroChineseName = opponentChineseName})

    -- 监视战斗状态并开始计时
    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        Timers:CreateTimer(0.1, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            self:MonitorUnitsStatus()
            return 0.01
        end)

        self:SendHeroAndFacetData(heroName, opponentHeroName, selfFacetId, opponentFacetId, self.limitTime)
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        self:MonitorUnitsStatus()
        self:StartAbilitiesMonitor(self.rightTeamHero1)
        self:StartAbilitiesMonitor(self.leftTeamHero1)
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 限定时间结束后的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
    end)
end


function Main:OnUnitKilled_Duel_1VS30(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        print("Unit killed: " .. killedUnit:GetUnitName() .. " (not processed)")
        return
    end

    self:ProcessHeroDeath(killedUnit)
end


function Main:OnNPCSpawned_Duel_1VS30(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end