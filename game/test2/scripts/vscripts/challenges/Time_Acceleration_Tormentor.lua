function Main:Init_Time_Acceleration_Tormentor(event, playerID)
    -- 1. 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)
    
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
    self:CreateTrueSightWards(teams)

    self.duration = 10
    self.endduration = 10
    self.limitTime = 60
    self.leftTeamHeroes = {}
    self.rightTeamHeroes = {}
    hero_duel.EndDuel = false
    hero_duel.killCount = 0
    hero_duel.deathCount = 0  -- 新增：死亡次数计数
    self:SendCameraPositionToJS(Main.waterFall_Center, 1)
    hero_duel.finalScore = 0
    -- 修改前端观众播报，添加得分显示

    self.HERO_CONFIG = {
        ALL = {
            function(hero)

                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
            end,
        },
        FRIENDLY = {
            function(hero)
                hero:SetForwardVector(Vector(1, 0, 0))
            end,
        },
        ENEMY = {
            function(hero)
                hero:SetForwardVector(Vector(-1, 0, 0))
            end,
        },
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_waterfall", {})
            end,
        }
    }
    local ability_modifiers = {
        npc_dota_hero_faceless_void = {
            faceless_void_time_zone = {
                AbilityCastRange = 1200,
                AbilityValues = {
                    duration = {
                        value = 9999999
                    },
                    radius = {
                        value = 1200
                    }
                }
            }
        },
    }
    self:UpdateAbilityModifiers(ability_modifiers)
    -- 3. 获取双方数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",
        ["死亡次数"] = "0",  -- 新增：死亡次数显示
        ["剩余时间"] = self.limitTime,
        ["当前得分"] = "0",
    }
    local order = {"挑战英雄", "击杀数量", "死亡次数", "剩余时间", "当前得分"}  -- 更新顺序包含死亡次数
    SendInitializationMessage(data, order)
    -- 2. 英雄配置
    -- 4. 播报系统
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
        local faceless_void = CreateUnitByName("npc_dota_hero_faceless_void", self.waterFall_Center, false, nil, nil, DOTA_TEAM_GOODGUYS)
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
                    local northPosition = Main.waterFall_Center + Vector(0, 200, 0)
                    faceless_void:SetCursorPosition(northPosition)
                    ultimateAbility:OnSpellStart()
                    
                    -- Second cast - south position
                    Timers:CreateTimer(0.3, function()
                        local southPosition = Main.waterFall_Center + Vector(0, -200, 0)
                        faceless_void:SetCursorPosition(southPosition)
                        ultimateAbility:OnSpellStart()
                    end)
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

    CreateHero(playerID, heroName, selfFacetId, self.waterFall_Left, DOTA_TEAM_GOODGUYS, true, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        self.leftTeam = {self.leftTeamHero1}
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                -- 为主Meepo启用AI
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")
                return nil
            end)
        end
    end)



    self.rightTeam = {}


    

    hero_duel.miniboss = CreateUnitByName("npc_dota_miniboss_custom", self.waterFall_Center, true, nil, nil, DOTA_TEAM_NEUTRALS)

    
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        -- 准备一个英雄进入左侧决斗区域
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            self.waterFall_Left,      -- 左侧决斗区域坐标
            self.duration - 5,                      -- 限制效果持续20秒
            Vector(1, 0, 0)          -- 朝向右侧
        )
    
    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)
    -- 6. 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })

    end)



    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

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


    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["剩余时间"] = "0",
            ["当前得分"] = tostring(hero_duel.finalScore)
        })
    
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. hero_duel.finalScore
        )
        self:PlayVictoryEffects(self.leftTeamHero1)


        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)


    end)
end


function Main:OnUnitKilled_Time_Acceleration_Tormentor(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then
        return
    end

    -- 如果绿方英雄死亡
    if killedUnit == self.leftTeamHero1 then
        -- 不再结束游戏，改为增加死亡计数并扣分
        hero_duel.deathCount = hero_duel.deathCount + 1
        hero_duel.finalScore = hero_duel.killCount - 2 * hero_duel.deathCount  -- 每死亡一次扣2分
        
        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["死亡次数"] = tostring(hero_duel.deathCount),
            ["当前得分"] = tostring(hero_duel.finalScore)
        })
        
        -- 原地复活
        Timers:CreateTimer(0.05, function()
            local spawnPosition = killedUnit:GetAbsOrigin()
            killedUnit:RespawnHero(true, false)
            FindClearSpaceForUnit(killedUnit, spawnPosition, true)
            killedUnit:RemoveModifierByName("modifier_fountain_invulnerability")
        end)


    -- 检查红方单位死亡情况
    elseif killedUnit == hero_duel.miniboss then
        -- 判断是否击杀的是king
        local pointsToAdd = 1
        -- 增加击杀计数
        hero_duel.killCount = hero_duel.killCount + 1
        -- 基础得分等于击杀数加上额外的king分数
        hero_duel.finalScore = hero_duel.killCount -  2 * hero_duel.deathCount

        hero_duel.miniboss = CreateUnitByName("npc_dota_miniboss_custom", self.waterFall_Center, true, nil, nil, DOTA_TEAM_NEUTRALS)
        hero_duel.miniboss:AddNewModifier(hero_duel.miniboss, nil, "modifier_invulnerable", {duration = 0.1})

        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["死亡次数"] = tostring(hero_duel.deathCount),
            ["当前得分"] = tostring(hero_duel.finalScore)
        })

    
    end
end

-- NPC生成时应用战场配置
function Main:OnNPCSpawned_Time_Acceleration_Tormentor(spawnedUnit, event)

end