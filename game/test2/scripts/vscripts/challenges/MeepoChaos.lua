function Main:Init_MeepoChaos(event, playerID)
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
    self.limitTime = 999
    self.leftTeamHeroes = {}
    self.rightTeamHeroes = {}
    hero_duel.EndDuel = false

    self:SendCameraPositionToJS(Main.smallDuelArea, 1)

    -- 2. 英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                
                -- 移除所有非隐藏技能
                for i = 0, 6 do
                    local ability = hero:GetAbilityByIndex(i)
                    if ability and not ability:IsHidden() then
                        hero:RemoveAbility(ability:GetName())
                    end
                end
        
                -- 添加stack_heroes技能并升级
                hero:AddAbility("stack_heroes")
                local stackAbility = hero:FindAbilityByName("stack_heroes")
                if stackAbility then
                    stackAbility:SetLevel(1)
                end
                
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
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
            end,
        }
    }

    -- 3. 获取双方数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)

    local opponentHeroId = event.opponentHeroId or -1
    local opponentFacetId = event.opponentFacetId or -1
    local opponentAIEnabled = (event.opponentAIEnabled == 1)
    local opponentEquipment = event.opponentEquipment or {}
    local opponentOverallStrategy = self:getDefaultIfEmpty(event.opponentOverallStrategies)
    local opponentHeroStrategy = self:getDefaultIfEmpty(event.opponentHeroStrategies)

    -- 获取英雄名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local opponentHeroName, opponentChineseName = self:GetHeroNames(opponentHeroId)

    -- 4. 播报系统
    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[新挑战]"
    )

    -- 前端播报
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["对手英雄"] = opponentChineseName,
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "对手英雄", "剩余时间"}
    SendInitializationMessage(data, order)

    -- 5. 英雄创建
    -- 创建主要Meepo
    CreateHero(playerID, "npc_dota_hero_meepo", selfFacetId, self.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, true, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero

        -- 获取选择英雄的类型并创建同类型英雄
        local heroType = self:GetHeroType(selfHeroId)
        for _, heroData in pairs(heroes_precache) do
            if heroData.type == heroType and heroData.name ~= "npc_dota_hero_meepo" then
                CreateHeroHeroChaos(playerID, heroData.name, -1, self.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, false, playerHero, function(hero)
                    table.insert(self.leftTeamHeroes, hero)
                    HeroMaxLevel(hero)
                end)
            end
        end
        
        -- 为所有英雄启用AI
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                -- 为主Meepo启用AI
                CreateAIForHero(self.leftTeamHero1, {"禁用一技能"}, selfHeroStrategy,"leftTeamHero1")
                -- -- 为同类型英雄启用AI
                for _, hero in ipairs(self.leftTeamHeroes) do
                    if IsValidEntity(hero) and not hero:IsNull() then
                        CreateAIForHero(hero, selfOverallStrategy, selfHeroStrategy, "hero_ai_" .. hero:entindex())
                    end
                end
                return nil
            end)
        end
    end)

    -- 创建对手Meepo
    CreateHero(playerID, "npc_dota_hero_meepo", opponentFacetId, self.smallDuelAreaRight, DOTA_TEAM_BADGUYS, false, function(opponentHero)
        self:ConfigureHero(opponentHero, false, playerID)
        self:EquipHeroItems(opponentHero, opponentEquipment)
        self.rightTeamHero1 = opponentHero
        self:ListenHeroHealth(self.rightTeamHero1)
        self.currentArenaHeroes[2] = opponentHero

        -- 获取选择英雄的类型并创建同类型英雄
        local heroType = self:GetHeroType(opponentHeroId)
        for _, heroData in pairs(heroes_precache) do
            if heroData.type == heroType and heroData.name ~= "npc_dota_hero_meepo" then
                CreateHeroHeroChaos(playerID, heroData.name, -1, self.smallDuelAreaRight, DOTA_TEAM_BADGUYS, false, opponentHero, function(hero)
                    table.insert(self.rightTeamHeroes, hero)
                    HeroMaxLevel(hero)
                end)
            end
        end
        
        -- 为所有英雄启用AI
        if opponentAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                -- 为主Meepo启用AI
                CreateAIForHero(self.rightTeamHero1, {"禁用一技能"}, opponentHeroStrategy,"rightTeamHero1")
                --为同类型英雄启用AI
                for _, hero in ipairs(self.rightTeamHeroes) do
                    if IsValidEntity(hero) and not hero:IsNull() then
                        CreateAIForHero(hero, opponentOverallStrategy, opponentHeroStrategy, "hero_ai_" .. hero:entindex())
                    end
                end
                return nil
            end)
        end
    end)

    
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
        -- 让左边的米波释放技能
        if self.leftTeamHero1 and IsValidEntity(self.leftTeamHero1) then
            local stackAbility = self.leftTeamHero1:FindAbilityByName("stack_heroes")
            if stackAbility then
                stackAbility:OnSpellStart()
            end
        end
    
        -- 让右边的米波释放技能
        if self.rightTeamHero1 and IsValidEntity(self.rightTeamHero1) then
            local stackAbility = self.rightTeamHero1:FindAbilityByName("stack_heroes")
            if stackAbility then
                stackAbility:OnSpellStart()
            end
        end
    
        -- 准备一个英雄进入左侧决斗区域
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            self.smallDuelAreaLeft,      -- 左侧决斗区域坐标
            self.duration - 5,                      -- 限制效果持续20秒
            Vector(1, 0, 0)          -- 朝向右侧
        )
    
        self:PrepareHeroForDuel(
            self.rightTeamHero1,        
            self.smallDuelAreaRight,     
            self.duration - 5,           
            Vector(-1, 0, 0)         
        )
    end)
    -- 6. 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.rightTeam = {self.rightTeamHero1}
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
    end)



    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        self:MonitorUnitsStatus()

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
        
        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)

    end)
end


-- 获取英雄类型
function Main:GetHeroType(heroId)
    for _, heroData in pairs(heroes_precache) do
        if heroData.id == heroId then
            return heroData.type
        end
    end
    return 1 -- 默认类型
end


function Main:OnUnitKilled_MeepoChaos(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        return
    end

    -- 只判断主要Meepo的死亡
    if killedUnit == self.leftTeamHero1 then
        -- 绿方主Meepo死亡，比赛结束
        hero_duel.EndDuel = true
        
        -- 停止所有定时器
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
        
        -- 播放失败动画
        self:PlayVictoryEffects(self.rightTeamHero1)
        
        -- 记录比赛结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[红方胜利]"
        )

        -- 禁用所有英雄
        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)

    elseif killedUnit == self.rightTeamHero1 then
        -- 红方主Meepo死亡，比赛结束
        hero_duel.EndDuel = true
        
        -- 停止所有定时器
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
        
        -- 播放胜利动画
        self:PlayVictoryEffects(self.leftTeamHero1)
        
        -- 记录比赛结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[绿方胜利]"
        )

        -- 禁用所有英雄
        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)
    end
end

-- NPC生成时应用战场配置
function Main:OnNPCSpawned_MeepoChaos(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end