function Main:Init_Escape_Bandits(event, playerID)
    -- 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)
    local teams = {DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 定义时间参数
    self.duration = 10         
    self.endduration = 10      
    self.limitTime = 60       
    hero_duel.EndDuel = false  
    hero_duel.killCount = 0    
    
    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.Forest_Left, 1)

    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 8})


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
    local selfSkillThresholds = event.selfSkillThresholds or {}
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
        "[逃离强盗开始]"
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
        ["剩余金钱"] = "3900",
        ["剩余时间"] = self.limitTime,
        ["最终得分"] = "0",
    }
    local order = {"挑战英雄", "剩余金钱", "剩余时间", "最终得分"}
    hero_duel.creepCount = 0
    hero_duel.survivalTime = 0
    SendInitializationMessage(data, order)

    local ability_modifiers = {
        npc_dota_hero_faceless_void = {
            faceless_void_time_zone = {
                AbilityCastRange = 9999,
                AbilityValues = {
                    duration = {
                        value = 9999999
                    },
                    radius = {
                        value = 3000
                    }
                }
            }
        },
    }
    self:UpdateAbilityModifiers(ability_modifiers)
    -- 设置查找标志
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
                DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
                DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS

    -- 查找所有带有modifier_caipan的虚空假面
    local existingVoids = FindUnitsInRadius(
        DOTA_TEAM_NOTEAM,
        Vector(0, 0, 0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_HERO,
        flags,
        FIND_ANY_ORDER,
        false
    )

    local hasExistingVoid = false
    for _, unit in pairs(existingVoids) do
        if unit:GetUnitName() == "npc_dota_hero_faceless_void" and unit:HasModifier("modifier_caipan") then
            unit:Stop()
            unit:SetForwardVector(Vector(0, -1, 0))
            hasExistingVoid = true
            break
        end
    end

    if not hasExistingVoid then
        local faceless_void = CreateUnitByName("npc_dota_hero_faceless_void", self.waterFall_Center, false, nil, nil, DOTA_TEAM_BADGUYS)
        if faceless_void then
            -- Set the player ID if needed (though for neutral/badguys it might not matter)
            faceless_void:SetPlayerID(playerID)
            
            -- Add modifiers and items
            faceless_void:AddNewModifier(faceless_void, nil, "modifier_item_aghanims_shard", {})
            faceless_void:AddNewModifier(faceless_void, nil, "modifier_kv_editor", {})
            HeroMaxLevel(faceless_void)
            
            -- Add and level up the time zone ability
            local ultimateAbility = faceless_void:AddAbility("faceless_void_time_zone")
            if ultimateAbility then
                ultimateAbility:SetLevel(3)
            end
            
            -- Add refresher orb
            local refresher = CreateItem("item_refresher", faceless_void, faceless_void)
            faceless_void:AddItem(refresher)
            
            -- Perform the ability sequence using SetCursorPosition and OnSpellStart
            if ultimateAbility then
                -- First cast - north position
                Timers:CreateTimer(1, function()
                    local targetPoint = Vector(-7318.49, -3816.20, 128.00)
                    faceless_void:SetCursorPosition(targetPoint)
                    ultimateAbility:OnSpellStart()

                end)
            end
            
            -- Set facing and movement (delayed to not interfere with spells)
            Timers:CreateTimer(3, function()

                faceless_void:AddNewModifier(faceless_void, nil, "modifier_caipan", {})
                faceless_void:AddNewModifier(faceless_void, nil, "modifier_wearable", {})
                -- Move void
                FindClearSpaceForUnit(faceless_void, Main.waterFall_Caipan + Vector(100, 0, 0), true)
                --朝南
                faceless_void:SetForwardVector(Vector(0, -1, 0))
            end)
        end
    end






    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.Forest_Left, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        
        self.leftTeamHero1 = playerHero

        -- 给予玩家10000不可靠金钱
        playerHero:SetGold(3900, false)
        
        -- 初始显示金钱
        self:StartTextMonitor(self.leftTeamHero1, "剩余金钱:"..playerHero:GetGold(), 20,"hero_score")
        
        -- 实时更新金钱显示
        Timers:CreateTimer(0.1, function()
            if hero_duel.EndDuel then return end
            local gold = self.leftTeamHero1:GetGold()
            self:StartTextMonitor(self.leftTeamHero1, "剩余金钱:"..gold, 20,"hero_score")
            local data = {
                ["剩余金钱"] = gold,
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)
            -- 监控英雄位置，判定挑战胜利
            local heroPosition = self.leftTeamHero1:GetAbsOrigin()
            if heroPosition.x > -5050 then
                hero_duel.EndDuel = true
                
                -- 给周围500码内的单位施加disarmed效果
                local units = FindUnitsInRadius(
                    self.leftTeamHero1:GetTeamNumber(),
                    heroPosition,
                    nil,
                    9999,  -- 500码半径
                    DOTA_UNIT_TARGET_TEAM_BOTH,  -- 双方队伍
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  -- 英雄和基本单位
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                for _, unit in pairs(units) do
                    if unit ~= self.leftTeamHero1 then  -- 不给玩家英雄自己施加
                        unit:AddNewModifier(unit, nil, "modifier_disarmed", {})
                    end
                end
                
                self:PlayVictoryEffects(self.leftTeamHero1)

                --如果剩余金钱大于等于3900，才计算时间
                local finalScore = 0
                if gold >= 3900 then
                    local elapsedTime = GameRules:GetGameTime() - hero_duel.startTime
                    local remainingTime = math.max(0, self.limitTime - elapsedTime)
                    finalScore = math.floor(remainingTime * 10 )  + gold

                else
                    finalScore = gold
                end
                    local data = {--得分=剩余时间+金钱
                        ["最终得分"] = finalScore,
                    }

                CustomGameEventManager:Send_ServerToAllClients("update_score", data)
                -- 创建胜利消息
                self:createLocalizedMessage(
                    "[LanPang_RECORD][",
                    self.currentMatchID,
                    "]",
                    "[挑战成功]",
                    "最终得分:" .. finalScore
                )
                
                return nil -- 停止定时器
            end

            return 0.01  -- 每0.1秒更新一次
        end)

        
        self.currentArenaHeroes[1] = playerHero
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

                local otherSettings = {skillThresholds = selfSkillThresholds}
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1",0.01, otherSettings)


                return nil
            end)
        end

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
        self:StartSpawning_Escape_Bandits(timerId)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)
    

    Timers:CreateTimer(self.duration-5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        FindClearSpaceForUnit(self.leftTeamHero1, Main.Forest_Left, true)
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
    
        self:PlayDefeatAnimation(self.leftTeamHero1)
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败]",
            "最终得分:0"
        )

    end)
end

-- 精灵单位生成函数
function Main:StartSpawning_Escape_Bandits(timerId)

    local spawnPos = Vector(-9500,-3808,128)

    for i = 1, 10 do
        local angle = RandomFloat(0, 360)
        local radius = 300

        
        -- 创建赏金猎人
        local bountyHunter = CreateUnitByName(
            "npc_dota_hero_bounty_hunter",
            spawnPos,
            true,
            nil,
            nil,
            DOTA_TEAM_BADGUYS
        )
        
        -- 给予最大等级
        HeroMaxLevel(bountyHunter)
        bountyHunter:SetControllableByPlayer(0, true)

        bountyHunter:SetAcquisitionRange(0)
        bountyHunter:AddNewModifier(bountyHunter, nil, "modifier_disarmed", {duration = 8})
        local direction = (Main.Forest_Left - spawnPos):Normalized()
        bountyHunter:SetForwardVector(direction)
        bountyHunter:AddItemByName("item_heart")
        bountyHunter:AddItemByName("item_heart")
        bountyHunter:AddItemByName("item_heart")
        bountyHunter:AddItemByName("item_heart")
        bountyHunter:AddItemByName("item_heart")
        bountyHunter:AddItemByName("item_heart")
        bountyHunter:SetAcquisitionRange(99999)

        -- 添加100%降低攻击力的修饰器
        local attackDamageModifier = bountyHunter:AddNewModifier(
            bountyHunter,  -- 源单位
            nil,  -- 技能来源
            "modifier_attack_damage_percentage",  -- 修饰器名称
            {damage_bonus_pct = -100}  -- 参数
        )
        Timers:CreateTimer(8, function()
            bountyHunter:CastAbilityOnTarget(self.leftTeamHero1, bountyHunter:FindAbilityByName("bounty_hunter_track"), 0)
            Timers:CreateTimer(0.2, function()
                CreateAIForHero(bountyHunter, {"禁用一技能","禁用二技能","禁用三技能","禁用大招","谁近打谁","攻击无敌单位"}, nil,"bountyHunter",0.1)
            end)
        end)
    end
end

-- 单位死亡判定
function Main:OnUnitKilled_Escape_Bandits(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    if not killedUnit or killedUnit:IsNull() or hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        hero_duel.EndDuel = true  -- 在发送消息前先设置结束标志
        

        self:PlayDefeatAnimation(self.leftTeamHero1)
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败]",
            "最终得分:0"
        )

        
        return
    end

end