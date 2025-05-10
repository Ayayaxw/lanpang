function Main:Init_Attack_Trigger_Ulti(event, playerID)
    -- 基础参数初始化

    self.currentMatchID = self:GenerateUniqueID()    
    print("当前匹配ID:" .. self.currentMatchID)
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 定义时间参数
    self.duration = 10         
    self.endduration = 10      
    self.limitTime = 100       
    hero_duel.EndDuel = false  

    hero_duel.killCount = 0    
    Main:SetDamagePanelEnabled(true)
    
    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)
    -- CameraControl:Initialize()
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
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 6})
                -- hero:AddNewModifier(hero, nil, "modifier_reduced_ability_cost", {})
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
                if hero:GetUnitName() ~= "ward" then
                    Timers:CreateTimer(0.1, function()
                        hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                    end)
                end
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
    local selfSkillThresholds = self:getDefaultIfEmpty(event.selfSkillThresholds)
    local otherSettings = {skillThresholds = selfSkillThresholds}
    -- 获取英雄名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    local ability_modifiers = {
    }
    self:UpdateAbilityModifiers(ability_modifiers)
    -- 播报初始化
    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[挑战开始]"
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
        ["雷兽等级"] = "1",
        ["雷兽生命值"] = "1000",
        ["雷兽攻击力"] = "100",
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "击杀数量", "雷兽等级", "雷兽生命值", "雷兽攻击力", "剩余时间"}
    hero_duel.creepCount = 0
    hero_duel.survivalTime = 0
    hero_duel.lizardLevel = 1
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        
        self.leftTeamHero1 = playerHero

        self:StartTextMonitor(self.leftTeamHero1, "击杀数:0", 20, "#FFFFFF")
        self.currentArenaHeroes[1] = playerHero
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

                
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1",0.01, otherSettings)
                return nil
            end)
        end
        -- 移除90%减CD的modifier
        -- playerHero:AddNewModifier(playerHero, nil, "modifier_cooldown_reduction_90", {})

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
    
        self:StartSpawning_Attack_Trigger_Ulti(timerId)

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

        -- 开始生成雷兽定时器

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
    
        if hero_duel.killCount >= 100 then
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

-- 雷兽单位生成函数
function Main:StartSpawning_Attack_Trigger_Ulti(timerId)
    -- 设置雷兽单位名称
    local lizardUnit = "npc_dota_neutral_big_thunder_lizard"
    
    -- 初始化雷兽的等级计数器
    hero_duel.lizardLevel = 1
    
    -- 初始生成若干个雷兽单位
    for i = 1, 50 do
        local angle = RandomFloat(0, 360)
        local radius = 800
        local spawnPos = Vector(
            Main.largeSpawnCenter.x + radius * math.cos(angle * math.pi / 180),
            Main.largeSpawnCenter.y + radius * math.sin(angle * math.pi / 180),
            Main.largeSpawnCenter.z
        )
        
        local unit = self:SpawnLizard(lizardUnit, spawnPos, timerId)
        unit:AddNewModifier(unit, nil, "modifier_disarmed", {duration = 6})
    end
end

-- 生成单个雷兽单位的函数
function Main:SpawnLizard(unitName, spawnPos, timerId)
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
    -- 检查场上单位数量上限
    if hero_duel.creepCount >= 100 then
        return
    end
    
    local unit = CreateUnitByName(
        unitName,
        spawnPos,
        true,
        nil,
        nil,
        DOTA_TEAM_BADGUYS
    )
    unit:RemoveAbility("neutral_upgrade")
    -- 根据当前雷兽等级增强属性
    unit:SetControllableByPlayer(1, true)
    unit:SetAcquisitionRange(9999)
    local levelMultiplier = hero_duel.lizardLevel * 0.05
    local baseHealth = 1000
    local baseAttack = 100
    local baseMoveSpeed = 300
    
    local currentHealth = baseHealth + baseHealth * levelMultiplier
    local currentAttack = baseAttack + baseAttack * levelMultiplier
    local currentMoveSpeed = baseMoveSpeed + (hero_duel.lizardLevel * 5)
    
    unit:SetBaseMaxHealth(currentHealth)
    unit:SetMaxHealth(currentHealth)
    unit:Heal(currentHealth, nil)
    unit:SetBaseDamageMin(currentAttack)
    unit:SetBaseDamageMax(currentAttack)
    unit:SetBaseMoveSpeed(currentMoveSpeed)
    
    -- 更新前端显示
    CustomGameEventManager:Send_ServerToAllClients("update_score", {
        ["雷兽生命值"] = tostring(currentHealth),
        ["雷兽攻击力"] = tostring(currentAttack)
    })
    
    -- 添加属性文本显示
    self:StartTextMonitor(unit, "等级：" .. tostring(hero_duel.lizardLevel), 18, "#FF0000")
    
    unit:AddNewModifier(unit, nil, "modifier_phased", {})
    
    local direction = (Main.largeSpawnCenter - spawnPos):Normalized()
    unit:SetForwardVector(direction)
    
    hero_duel.creepCount = hero_duel.creepCount + 1
    return unit
end

-- 单位死亡判定
function Main:OnUnitKilled_Attack_Trigger_Ulti(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    if not killedUnit or killedUnit:IsNull() or hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not killedUnit:IsTempestDouble() then
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

    -- 雷兽单位死亡判定
    local unitName = killedUnit:GetUnitName()
    if unitName == "npc_dota_neutral_big_thunder_lizard" then
        -- 再次检查游戏是否已结束（以防在处理过程中游戏结束）
        if hero_duel.EndDuel then return end
        
        local killer = EntIndexToHScript(args.entindex_attacker)
        local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
        ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
        EmitSoundOn("General.Coins", killer)

        hero_duel.killCount = hero_duel.killCount + 1
        hero_duel.creepCount = hero_duel.creepCount - 1
        self:StartTextMonitor(self.leftTeamHero1, "击杀数:" .. hero_duel.killCount, 20, "#FFFFFF")

        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
        })
        
        -- 每击杀10个雷兽，提升雷兽等级
        if hero_duel.killCount % 10 == 0 then
            hero_duel.lizardLevel = hero_duel.lizardLevel + 1
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["雷兽等级"] = tostring(hero_duel.lizardLevel)
            })
        end
        
        -- 立即生成一个新的雷兽
        Timers:CreateTimer(0.2, function()
            local angle = RandomFloat(0, 360)
            local radius = 800
            local spawnPos = Vector(
                Main.largeSpawnCenter.x + radius * math.cos(angle * math.pi / 180),
                Main.largeSpawnCenter.y + radius * math.sin(angle * math.pi / 180),
                Main.largeSpawnCenter.z
            )
            
            self:SpawnLizard("npc_dota_neutral_big_thunder_lizard", spawnPos, self.currentTimer)
        end)
    end
end


function Main:OnNPCSpawned_Attack_Trigger_Ulti(spawnedUnit, event)

    spawnedUnit:AddNewModifier(spawnedUnit, nil,"modifier_death_check_enchant", {})

    if spawnedUnit:IsRealHero() then
        spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_attack_cast_ability_Ult", {})
    end

end