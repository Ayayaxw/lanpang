function Main:Init_Damage_Trigger_Punch(event, playerID)
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
    self:SendCameraPositionToJS(Main.smallDuelCenter, 1)
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
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 6})

                Timers:CreateTimer(0.2, function()
                    hero:AddNewModifier(hero, nil, "modifier_auto_walrus_punch_custom", {})
                end)


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
        ["超级兵等级"] = "1",
        ["超级兵生命值"] = "1000",
        ["超级兵攻击力"] = "100",
        ["场上数量"] = "0",
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "击杀数量", "超级兵等级", "超级兵生命值", "超级兵攻击力", "场上数量", "剩余时间"}
    hero_duel.creepCount = 0
    hero_duel.survivalTime = 0
    hero_duel.lizardLevel = 1
    hero_duel.totalCreepsSpawned = 0  -- 新增变量：记录总共生成的超级兵数量
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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
        FindClearSpaceForUnit(self.leftTeamHero1, Main.smallDuelAreaLeft, true)
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
        self:StartSpawning_Damage_Trigger_Punch(timerId)
        hero_duel.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        -- 开始生成超级兵定时器

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


-- 超级兵单位生成函数
function Main:StartSpawning_Damage_Trigger_Punch(timerId)
    -- 设置单位名称为超级兵
    local creepUnit = "npc_dota_creep_badguys_melee_upgraded_mega"
    
    -- 初始化等级计数器
    hero_duel.lizardLevel = 1
    hero_duel.creepCount = 0
    
    -- 设置生成计时器
    Timers:CreateTimer(0, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 检查场上单位数量上限
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
        
        -- 当场上超级兵数量超过200个时，暂时停止刷新
        if hero_duel.creepCount >= 100 then
            return 0.1  -- 每0.1秒检查一次是否可以继续刷新
        end
        
        -- 计算刷新点：从中心点往东500码，再在南北方向随机偏移
        local centerPoint = Vector(
            Main.smallDuelAreaRight.x,
            Main.smallDuelAreaRight.y,
            Main.smallDuelAreaRight.z
        )
        
        -- 生成第一只超级兵
        local randomYOffset = RandomFloat(-250, 250)
        local spawnPos1 = Vector(
            centerPoint.x,
            centerPoint.y + randomYOffset,
            centerPoint.z
        )
        
        -- -- 生成第二只超级兵
        -- local randomYOffset2 = RandomFloat(-250, 250)
        -- local spawnPos2 = Vector(
        --     centerPoint.x,
        --     centerPoint.y + randomYOffset2,
        --     centerPoint.z
        -- )
        
        -- -- 生成两只超级兵
        local unit1 = self:SpawnCreep(creepUnit, spawnPos1, timerId)
        -- local unit2 = self:SpawnCreep(creepUnit, spawnPos2, timerId)
        
        -- 更新前端显示当前超级兵数量
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["场上数量"] = tostring(hero_duel.creepCount)
        })
        
        -- 每生成10个单位，提升等级（使用总生成数而不是当前存活数）
        hero_duel.totalCreepsSpawned = hero_duel.totalCreepsSpawned + 1
        if hero_duel.totalCreepsSpawned % 10 == 0 then
            -- 根据击杀数决定每次提升的等级
            local levelIncrease = 1
            if hero_duel.killCount >= 500 then
                -- 每500击杀数增加1级提升
                levelIncrease = 1 + math.floor(hero_duel.killCount / 500)
            end
            
            hero_duel.lizardLevel = hero_duel.lizardLevel + levelIncrease
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["超级兵等级"] = tostring(hero_duel.lizardLevel)
            })
        end
        
        -- 0.01秒后继续生成
        return 0.01
    end)
end

-- 生成单个超级兵的函数
function Main:SpawnCreep(unitName, spawnPos, timerId)
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
    local unit = CreateUnitByName(
        unitName,
        spawnPos,
        true,
        nil,
        nil,
        DOTA_TEAM_BADGUYS
    )
    
    -- 根据当前等级增强属性
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
        ["超级兵生命值"] = tostring(currentHealth),
        ["超级兵攻击力"] = tostring(currentAttack)
    })
    
    -- 添加属性文本显示
    self:StartTextMonitor(unit, "等级：" .. tostring(hero_duel.lizardLevel), 18, "#FF0000")
    FindClearSpaceForUnit(unit, spawnPos, true)
    
    local direction = (Main.smallDuelAreaRight - spawnPos):Normalized()
    unit:SetForwardVector(direction)
    
    hero_duel.creepCount = hero_duel.creepCount + 1
    return unit
end

-- 单位死亡判定
function Main:OnUnitKilled_Damage_Trigger_Punch(killedUnit, args)
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

    -- 超级兵死亡判定
    local unitName = killedUnit:GetUnitName()
    if unitName == "npc_dota_creep_badguys_melee_upgraded_mega" then
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

        -- 更新前端显示击杀数量，不再更新场上数量
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount)
        })
    end
end


function Main:OnNPCSpawned_Damage_Trigger_Punch(spawnedUnit, event)
    spawnedUnit:AddNewModifier(spawnedUnit, nil,"modifier_death_check_enchant", {})
end