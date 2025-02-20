function Main:Init_SuperCreepChallenge90CD(event, playerID)
    -- 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         
    self.endduration = 10      
    self.limitTime = 99999       
    hero_duel.EndDuel = false  
    hero_duel.killCount = 0    
    
    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    -- local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    -- self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})
                hero:AddNewModifier(hero, nil, "modifier_reduced_ability_cost", {})
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

    -- 获取玩家数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)

    -- 获取英雄名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    -- 播报初始化
    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[90%减CD超级兵挑战开始]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择英雄]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}
    )

    -- 前端显示初始化
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",
        ["存活时间"] = "00:00.00",
        ["场上数量"] = "0",
        ["当前生命值"] = 1270,
        ["当前攻击力"] = 105
    }
    local order = {"挑战英雄", "击杀数量", "存活时间", "场上数量", "当前生命值", "当前攻击力"}
    hero_duel.creepCount = 0
    hero_duel.survivalTime = 0
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")
                return nil
            end)
        end
        -- 给予90%减CD
        playerHero:AddNewModifier(playerHero, nil, "modifier_cooldown_reduction_90", {})
    end)

    -- 赛前准备时间
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
    end)


    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)
    

    Timers:CreateTimer(self.duration-5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        FindClearSpaceForUnit(self.leftTeamHero1, Main.largeSpawnCenter, true)
        self:DisableHeroWithModifiers(self.leftTeamHero1, 5)
        self:ResetUnit(self.leftTeamHero1)
    end)


    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
        self:SendLeftHeroData(heroName, selfFacetId)
        
        -- 慢动作效果
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)


    -- 开始信号
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 正式开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        -- 开始生成超级兵定时器
        self:StartCreepSpawning(timerId)

        -- 添加存活时间计时器
        Timers:CreateTimer(0, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            
            local currentTime = GameRules:GetGameTime() - hero_duel.startTime
            hero_duel.survivalTime = currentTime
            
            local formattedTime = string.format("%02d:%02d.%02d",
                math.floor(currentTime / 60),
                math.floor(currentTime % 60),
                math.floor((currentTime * 100) % 100))
            
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["存活时间"] = formattedTime
            })
            
            return 0.03  -- 约30FPS更新率
        end)

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 时间结束判定
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
    
        if hero_duel.killCount >= 1000 then
            self:PlayVictoryEffects(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]",
                "最终得分:" .. hero_duel.killCount
            )
        else
            self:PlayDefeatAnimation(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]",
                "最终得分:" .. hero_duel.killCount
            )
        end
    end)
end

-- 超级兵生成函数
function Main:StartCreepSpawning(timerId)
    Timers:CreateTimer(0, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 检查超级兵数量
        if hero_duel.creepCount >= 300 then
            if not hero_duel.EndDuel then
                hero_duel.EndDuel = true
                
                -- 禁止英雄行动
                self:DisableHeroWithModifiers(self.leftTeamHero1, 10)
                
                -- 根据击杀数判断胜负
                if hero_duel.killCount >= 1000 then
                    self:PlayVictoryEffects(self.leftTeamHero1)
                    self:createLocalizedMessage(
                        "[LanPang_RECORD][",
                        self.currentMatchID,
                        "]",
                        "[挑战成功]",
                        "最终得分:" .. hero_duel.killCount
                    )
                else
                    self:PlayDefeatAnimation(self.leftTeamHero1)
                    self:createLocalizedMessage(
                        "[LanPang_RECORD][",
                        self.currentMatchID,
                        "]",
                        "[挑战失败]",
                        "最终得分:" .. hero_duel.killCount
                    )
                end
            end
            return
        end
        
        local angle = RandomFloat(0, 360)
        local radius = 800
        local spawnPos = Vector(
            Main.largeSpawnCenter.x + radius * math.cos(angle * math.pi / 180),
            Main.largeSpawnCenter.y + radius * math.sin(angle * math.pi / 180),
            Main.largeSpawnCenter.z
        )
        
        local creep = CreateUnitByName(
            "npc_dota_creep_badguys_melee_upgraded_mega",
            spawnPos,
            true,
            nil,
            nil,
            DOTA_TEAM_BADGUYS
        )
        
        -- 计算当前增强百分比
        local timeElapsed = math.floor(hero_duel.survivalTime)
        local strengthMultiplier
        
        if timeElapsed <= 60 then
            strengthMultiplier = 1 + (timeElapsed * 0.01) -- 1分钟内每秒1%
        elseif timeElapsed <= 120 then
            strengthMultiplier = 1.6 + ((timeElapsed - 60) * 0.02) -- 1-2分钟每秒2%
        else
            strengthMultiplier = 2.8 + ((timeElapsed - 120) * 0.05) -- 2分钟后每秒5%
        end
        
        -- 设置增强后的属性
        local baseHealth = creep:GetBaseMaxHealth()
        local baseAttack = creep:GetBaseDamageMin()
        
        local currentHealth = math.floor(baseHealth * strengthMultiplier)
        local currentAttack = math.floor(baseAttack * strengthMultiplier)
        creep:AddNewModifier(creep, nil, "modifier_phased", {})
        creep:SetBaseMaxHealth(currentHealth)
        creep:SetMaxHealth(currentHealth)
        creep:SetMaxHealth(currentHealth)
        creep:Heal(creep:GetMaxHealth(), nil)  -- 第二个参数是造成治疗的技能，这里不需要所以传nil
        creep:SetBaseDamageMin(currentAttack)
        creep:SetBaseDamageMax(currentAttack)
        local direction = (Main.largeSpawnCenter - spawnPos):Normalized()
        creep:SetForwardVector(direction)
        
        hero_duel.creepCount = hero_duel.creepCount + 1
        -- 更新前端显示，显示实际数值
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["场上数量"] = tostring(hero_duel.creepCount),
            ["当前生命值"] = tostring(currentHealth),
            ["当前攻击力"] = tostring(currentAttack)
        })
        
        return 0.05
    end)
end

-- 单位死亡判定
-- 单位死亡判定
function Main:OnUnitKilled_SuperCreepChallenge90CD(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    if not killedUnit or killedUnit:IsNull() or hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        hero_duel.EndDuel = true  -- 在发送消息前先设置结束标志
        
        if hero_duel.killCount >= 1000 then
            self:PlayVictoryEffects(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]",
                "最终得分:" .. hero_duel.killCount
            )
        else
            self:PlayDefeatAnimation(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]",
                "最终得分:" .. hero_duel.killCount
            )
        end
        
        return
    end

    -- 超级兵死亡判定
    if killedUnit:GetUnitName() == "npc_dota_creep_badguys_melee_upgraded_mega" then
        -- 再次检查游戏是否已结束（以防在处理过程中游戏结束）
        if hero_duel.EndDuel then return end
        
        local killer = EntIndexToHScript(args.entindex_attacker)
        local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
        ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
        EmitSoundOn("General.Coins", killer)

        hero_duel.killCount = hero_duel.killCount + 1
        hero_duel.creepCount = hero_duel.creepCount - 1
        
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["场上数量"] = tostring(hero_duel.creepCount)
        })
    end
end