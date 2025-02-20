function Main:Cleanup_Double_on_death()

end

function Main:Init_Double_on_death(event, playerID)
    -- 技能修改器
    self.ursaPool = {}
    self.currentUrsaIndex = 1
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    local ability_modifiers = {
    }
    self:UpdateAbilityModifiers(ability_modifiers)
    -- 设置英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_maximum_attack", {})
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
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})

            end,
        }
    }
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)


    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)


    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)




    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 100        -- 限定时间为准备时间结束后的一分钟
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


    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",
        ["最高僵尸攻击"] = "1",
        ["最高僵尸生命"] = "100",
        ["剩余时间"] = self.limitTime,
        ["当前得分"] = "0",
    }
    local order = {"挑战英雄", "击杀数量", "最高僵尸攻击","最高僵尸生命","剩余时间", "当前得分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        -- 给双方英雄添加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
        end
    end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        self:SendLeftHeroData(heroName, selfFacetId)
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)

    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)


    -- 比赛开始后才开始传送拍拍熊
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:StartmegaDeployment()
    end)

    -- 限定时间结束后的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("update_score", {["剩余时间"] = "0"})

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)
            self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
            
            local particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                PATTACH_OVERHEAD_FOLLOW, 
                self.leftTeamHero1
            )
            ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            
            local particle1 = ParticleManager:CreateParticle(
                "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                PATTACH_ABSORIGIN, 
                self.leftTeamHero1
            )
            ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)
            
            self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
            self.leftTeamHero1:AddNewModifier(hero, nil, "modifier_damage_reduction_100", {duration = self.endduration})
        end
        local finalScore = math.floor(hero_duel.currentScore)
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战成功]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
    end)
end

function Main:StartmegaDeployment()
    -- 初始化所有统计数据

    hero_duel.highestMultiplier = 1
    hero_duel.currentScore = 0
    hero_duel.highestScore = 0  -- 记录单次击杀最高得分
    hero_duel.highestAttack = 10 -- 初始化最高攻击力
    hero_duel.highestHealth = 100 -- 初始化最高生命值
    hero_duel.killCount = 0     -- 初始化击杀计数
    
    -- Get the player hero's position
    local hero = self.leftTeamHero1
    if not hero or hero:IsNull() then return end
    local centerPos = hero:GetAbsOrigin()
    
    -- Number of units to spawn
    local numUnits = 10
    -- Radius of the circle
    local radius = 800
    
    -- Spawn units in a circle
    for i = 1, numUnits do
        -- Calculate position on the circle
        local angle = i * (360 / numUnits)
        local x = centerPos.x + radius * math.cos(math.rad(angle))
        local y = centerPos.y + radius * math.sin(math.rad(angle))
        local spawnPos = Vector(x, y, centerPos.z)
        
        -- Create the mega unit
        local mega_unit = CreateUnitByName("double_on_death_mega", spawnPos, true, nil, nil, DOTA_TEAM_BADGUYS)
        
        if mega_unit then
            -- 初始化僵尸的独立属性
            mega_unit.death_count = 0
            mega_unit.initial_attack = 10
            mega_unit.initial_health = 100  -- 设置初始生命值
            
            -- 设置初始属性
            mega_unit:SetBaseMaxHealth(mega_unit.initial_health)
            mega_unit:SetBaseDamageMin(mega_unit.initial_attack)
            mega_unit:SetBaseDamageMax(mega_unit.initial_attack)
            mega_unit:SetHealth(mega_unit.initial_health)
            mega_unit:Heal(mega_unit:GetMaxHealth(), nil)
            mega_unit:AddNewModifier(mega_unit, nil, "modifier_phased", {})
            mega_unit:AddNewModifier(mega_unit, nil, "modifier_truesight_vision", {})
            -- Add double_on_death modifier
            mega_unit:AddNewModifier(mega_unit, nil, "modifier_double_on_death", {})
            
            -- Make the unit face the center (hero)
            local direction = (centerPos - spawnPos):Normalized()
            mega_unit:SetForwardVector(direction)
            
            -- Save AI name
            mega_unit.aiName = "mega_unit_" .. i
            
            -- Create AI
            CreateAIForHero(
                mega_unit,
                {},
                {""},
                "mega_unit_" .. i,
                0.5
            )
        end
    end
end

function Main:OnUnitKilled_Double_on_death(killedUnit, args)

    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)
    
    if not killedUnit or killedUnit:IsNull() then return end


    -- 判断是否是玩家英雄死亡
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        -- 计算最终得分 (使用当前累积的分数，取整)
        local finalScore = math.floor(hero_duel.currentScore)
        
        -- 发送记录消息
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
        -- 发送最终结果给前端

        -- 计算并格式化剩余时间
        local endTime = GameRules:GetGameTime()
        local timeSpent = endTime - hero_duel.startTime
        local remainingTime = self.limitTime - timeSpent
        local formattedTime = string.format("%02d:%02d.%02d", 
            math.floor(remainingTime / 60),
            math.floor(remainingTime % 60),
            math.floor((remainingTime * 100) % 100))
        CustomGameEventManager:Send_ServerToAllClients("update_score", {["剩余时间"] = formattedTime})
        hero_duel.EndDuel = true
        return
    end
    
    -- 判断是否是 double_on_death_mega 单位
    if killedUnit:GetUnitName() == "double_on_death_mega" then
        -- 更新这个僵尸的独立death_count
        killedUnit.death_count = (killedUnit.death_count or 0) + 1
        
        -- 更新击杀数
        hero_duel.killCount = hero_duel.killCount + 1
        
        -- 计算此单位的倍率
        local currentMultiplier = math.pow(1.1, killedUnit.death_count)
        currentMultiplier = math.floor(currentMultiplier * 100 + 0.5) / 100
        
        -- 计算攻击力和生命值
        local attackValue = killedUnit.initial_attack * currentMultiplier
        local healthValue = attackValue * 10
        
        -- 更新最高数值
        if attackValue > hero_duel.highestAttack then 
            hero_duel.highestAttack = attackValue 
        end
        if healthValue > hero_duel.highestHealth then 
            hero_duel.highestHealth = healthValue 
        end
        
        -- 更新最高倍率
        if currentMultiplier > hero_duel.highestMultiplier then
            hero_duel.highestMultiplier = currentMultiplier
        end
        
        -- 计算得分：使用这个僵尸的独立death_count
        local killScore = killedUnit.death_count
        
        -- 更新最高单次得分
        if killScore > hero_duel.highestScore then
            hero_duel.highestScore = killScore
        end
        
        hero_duel.currentScore = hero_duel.currentScore + killScore
        
        -- 发送数据给前端
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["最高僵尸攻击"] = string.format("%.0f", hero_duel.highestAttack),
            ["最高僵尸生命"] = string.format("%.0f", hero_duel.highestHealth),
            ["当前得分"] = tostring(math.floor(hero_duel.currentScore)),
            ["最高倍率"] = string.format("%.2f", hero_duel.highestMultiplier)
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

    end
end

function Main:OnNPCSpawned_Double_on_death(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end