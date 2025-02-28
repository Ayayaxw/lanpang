
function Main:Init_Level7Dazzle(event, playerID)
    -- 技能修改器

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_rooted", {duration = 5})
                -- 升到7级
                for i = 1, 6 do
                    hero:HeroLevelUp(true)
                end
        
                -- 如果是戴泽才进行技能加点
                if hero:GetUnitName() == "npc_dota_hero_dazzle" then
                    -- 获取技能
                    local ability1 = hero:GetAbilityByIndex(0)
                    local ability2 = hero:GetAbilityByIndex(1) 
                    local ability3 = hero:GetAbilityByIndex(2)
                    local ability4 = hero:GetAbilityByIndex(5)
                
                    -- 清空所有技能点
                    hero:SetAbilityPoints(7)
                
                    if CommonAI:containsStrategy(self:getDefaultIfEmpty(event.opponentHeroStrategies), "主学治疗波") then
                        -- 主学3技能的情况
                        -- 三技能升4级
                        for i = 1, 4 do
                            hero:UpgradeAbility(ability3)
                        end
                        -- 一技能升1级
                        hero:UpgradeAbility(ability1)
                        -- 如果不是不学薄葬，二技能升1级，否则主技能多加1级
                        if not CommonAI:containsStrategy(self:getDefaultIfEmpty(event.opponentHeroStrategies), "不学薄葬") then
                            hero:UpgradeAbility(ability2)
                        else
                            hero:UpgradeAbility(ability3)
                        end
                    else
                        -- 默认主学1技能的情况
                        -- 一技能升4级
                        for i = 1, 4 do
                            hero:UpgradeAbility(ability1)
                        end
                        -- 三技能升1级
                        hero:UpgradeAbility(ability3)
                        -- 如果不是不学薄葬，二技能升1级，否则主技能多加1级
                        if not CommonAI:containsStrategy(self:getDefaultIfEmpty(event.opponentHeroStrategies), "不学薄葬") then
                            hero:UpgradeAbility(ability2)
                        else
                            hero:UpgradeAbility(ability1)
                        end
                    end
                
                    -- 大招升1级
                    hero:UpgradeAbility(ability4)
                end
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
        }
        ,
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
    local timerId = self.currentTimer
    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        -- 限定时间为准备时间结束后的一分钟


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
    --self:UpdateAbilityModifiers(ability_modifiers)
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
                return nil
            end)
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


    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
        -- 设置小兵的AI和仇恨机制
        local function SetCreepAI(creep)
            creep:SetAcquisitionRange(1600)
        end
        
        -- 天辉小兵
        local leftPos = self.smallDuelAreaLeft
        local rightOffset = Vector(500, 0, 0)
        local meleeSpacing = Vector(0, 100, 0)  -- Y轴间距
        
        -- 基础位置(往右500码)
        local basePos = leftPos + rightOffset
        
        -- 计算近战兵中心位置(向上偏移150码,向下偏移150码,总共300码)
        local centerPos = basePos + Vector(0, -100, 0)
        
        -- 生成4个天辉近战兵(竖着一排,居中)
        for i = 1, 3 do
            local position = centerPos + meleeSpacing * (i-1)
            local creep = CreateUnitByName("npc_dota_creep_goodguys_melee", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
            SetCreepAI(creep)
        end
        
        -- 生成1个天辉远程兵(在近战兵左侧)
        local rangedPos = basePos + Vector(-300, 0, 0)  -- 在近战兵左边300码
        local rangedCreep = CreateUnitByName("npc_dota_creep_goodguys_ranged", rangedPos, true, nil, nil, DOTA_TEAM_GOODGUYS)
        SetCreepAI(rangedCreep)
        
        -- 夜魇小兵
        local rightPos = self.smallDuelAreaRight
        local leftOffset = Vector(-500, 0, 0)
        
        -- 基础位置(往左500码)
        basePos = rightPos + leftOffset
        
        -- 计算近战兵中心位置
        centerPos = basePos + Vector(0, -100, 0)
        
        -- 生成4个夜魇近战兵(竖着一排,居中)
        for i = 1, 3 do
            local position = centerPos + meleeSpacing * (i-1)
            local creep = CreateUnitByName("npc_dota_creep_badguys_melee", position, true, nil, nil, DOTA_TEAM_BADGUYS)
            SetCreepAI(creep)
        end
        
        -- 生成1个夜魇远程兵(在近战兵右侧)
        rangedPos = basePos + Vector(300, 0, 0)  -- 在近战兵右边300码
        local rangedCreep = CreateUnitByName("npc_dota_creep_badguys_ranged", rangedPos, true, nil, nil, DOTA_TEAM_BADGUYS)
        SetCreepAI(rangedCreep)
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        -- 给双方英雄添加禁用效果
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

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.smallDuelArea, 1)


    -- 监视战斗状态并开始计时
    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        Timers:CreateTimer(0.01, function()
            self:MonitorUnitsStatus()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
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


function Main:OnUnitKilled_Level7Dazzle(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        return
    end

    -- 检查是否有人阵亡
    local leftTeamAlive = false
    local rightTeamAlive = false

    -- 检查左方英雄
    if not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
        leftTeamAlive = true
    end

    -- 检查右方英雄
    if not self.rightTeamHero1:IsNull() and self.rightTeamHero1:IsAlive() then
        rightTeamAlive = true
    end

    -- 判断胜负
    if not leftTeamAlive or not rightTeamAlive then
        hero_duel.EndDuel = true
        
        -- 获取获胜方和最后一击英雄
        local winningTeam = leftTeamAlive and "成功" or "失败"
        local killerName = killer:GetUnitName()
        
        -- 记录比赛结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[比赛结束]挑战".. winningTeam
        )

        -- 对获胜的英雄播放胜利特效
        local winningHero = leftTeamAlive and self.leftTeamHero1 or self.rightTeamHero1
        if not winningHero:IsNull() and winningHero:IsAlive() then
            self:PlayVictoryEffects(winningHero)
        end

        -- 禁用幸存的英雄
        if not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
            self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        end
        if not self.rightTeamHero1:IsNull() and self.rightTeamHero1:IsAlive() then
            self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)
        end
    end
end


function Main:OnNPCSpawned_Level7Dazzle(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end