function Main:Init_mode_5v5(event, playerID)
    -- 1. 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.kv_modified = false
    self.duration = 10         
    self.endduration = 10      
    self.limitTime = 60       -- 设置5分钟的比赛时间
    hero_duel.EndDuel = false
    
    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.largeSpawnCenter + Vector(0, 500, 0), 1)

    -- 击杀计数初始化
    hero_duel.killCount = 0

    -- 2. 英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
    self:CreateTrueSightWards(teams)
    
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                local ability = hero:AddAbility("attribute_amplifier_passive")
                Timers:CreateTimer(0.2, function()
                    if ability then
                        print("给与技能")
                        ability:SetLevel(1)  -- 因为这是一个最大等级为1的被动技能
                    end
                end)

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
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})
                if hero:IsTempestDouble() or hero:IsIllusion() then
                    
                    local ability = hero:AddAbility("attribute_amplifier_passive")
                    Timers:CreateTimer(0, function()
                        if ability then  -- 再判断添加是否成功
                            ability:SetLevel(1)
                        end
                    end)
                end
            end,
        }
    }

    -- 3. 数据获取
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

    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local opponentHeroName, opponentChineseName = self:GetHeroNames(opponentHeroId)

    -- 4. 播报系统
    -- 4.1 裁判控制台播报
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

    -- 4.2 观众前端播报
    local data = {
        ["左方英雄"] = heroChineseName,
        ["右方英雄"] = opponentChineseName,
        ["剩余时间"] = self.limitTime,
    }
    local order = {"左方英雄", "右方英雄", "剩余时间"}
    SendInitializationMessage(data, order)

    -- 5. 英雄创建
    -- 创建数组存储双方英雄
    self.leftTeamHeroes = {}
    self.rightTeamHeroes = {}
    
    -- 计算英雄间距
    local heroSpacing = 200
    local startY = 200  -- 从最下面开始往上排

    -- 创建左方10个英雄
    for i = 1, 5 do
        local spawnPos = Vector(-550, startY + (i-1) * heroSpacing, 128)
        CreateHero(playerID, heroName, selfFacetId, spawnPos, DOTA_TEAM_GOODGUYS, false, function(hero)
            if hero then
                self:ConfigureHero(hero, true, playerID)
                self:EquipHeroItems(hero, selfEquipment)
                table.insert(self.leftTeamHeroes, hero)
                
                if selfAIEnabled then
                    Timers:CreateTimer(self.duration - 0.7, function()
                        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                        CreateAIForHero(hero, selfOverallStrategy, selfHeroStrategy, "leftTeamHero"..#self.leftTeamHeroes)
                        return nil
                    end)
                end
            end
        end)
    end

    -- 创建右方10个英雄
    for i = 1, 5 do
        local spawnPos = Vector(850, startY + (i-1) * heroSpacing, 128)
        CreateHero(playerID, opponentHeroName, opponentFacetId, spawnPos, DOTA_TEAM_BADGUYS, false, function(hero)
            if hero then
                self:ConfigureHero(hero, false, playerID)
                self:EquipHeroItems(hero, opponentEquipment)
                table.insert(self.rightTeamHeroes, hero)
                self:ListenHeroHealth(hero)
                
                if opponentAIEnabled then
                    Timers:CreateTimer(self.duration - 0.7, function()
                        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                        CreateAIForHero(hero, opponentOverallStrategy, opponentHeroStrategy, "rightTeamHero"..#self.rightTeamHeroes)
                        return nil
                    end)
                end
            end
        end)
    end

    -- 6. 赛前准备阶段
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = self.leftTeamHeroes
        self.rightTeam = self.rightTeamHeroes
        
        -- 给所有英雄添加无冷却
        for _, hero in pairs(self.leftTeamHeroes) do
            if hero and not hero:IsNull() then
                hero:AddNewModifier(hero, nil, "modifier_no_cooldown_all", { duration = 3 })
            end
        end
        for _, hero in pairs(self.rightTeamHeroes) do
            if hero and not hero:IsNull() then
                hero:AddNewModifier(hero, nil, "modifier_no_cooldown_all", { duration = 3 })
            end
        end
    end)

    -- 英雄特殊加成
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 给左方所有英雄添加特殊加成
        for _, hero in pairs(self.leftTeamHeroes) do
            if hero and not hero:IsNull() then
                print("[Left Team] Hero name:", hero:GetUnitName())  -- 打印左方英雄名字
                self:HeroPreparation(heroName, hero, selfOverallStrategy, selfHeroStrategy)
            end
        end
    
        -- 给右方所有英雄添加特殊加成 
        for _, hero in pairs(self.rightTeamHeroes) do
            if hero and not hero:IsNull() then
                print("[Right Team] Hero name:", hero:GetUnitName())  -- 打印右方英雄名字
                self:HeroPreparation(opponentHeroName, hero, opponentOverallStrategy, opponentHeroStrategy)
            end
        end
    end)

    -- 给英雄添加小礼物
    Timers:CreateTimer(self.duration - 0.1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        -- 给左方所有英雄添加礼物
        for _, hero in pairs(self.leftTeamHeroes) do
            if hero and not hero:IsNull() then
                self:HeroBenefits(heroName, hero, selfOverallStrategy, selfHeroStrategy)
            end
        end

        -- 给右方所有英雄添加礼物
        for _, hero in pairs(self.rightTeamHeroes) do
            if hero and not hero:IsNull() then
                self:HeroBenefits(opponentHeroName, hero, opponentOverallStrategy, opponentHeroStrategy)
            end
        end
    end)

    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 让左方所有英雄回到原位
        for i, hero in pairs(self.leftTeamHeroes) do
            if hero and not hero:IsNull() then
                local spawnPos = Vector(-550, 200 + (i-1) * heroSpacing, 128)
                self:PrepareHeroForDuel(
                    hero,                    -- 英雄单位
                    spawnPos,               -- 原始召唤位置
                    self.duration - 5,       -- 限制效果持续时间
                    Vector(1, 0, 0)         -- 朝向右侧
                )
            end
        end
    
        -- 让右方所有英雄回到原位
        for i, hero in pairs(self.rightTeamHeroes) do
            if hero and not hero:IsNull() then
                local spawnPos = Vector(850, 200 + (i-1) * heroSpacing, 128)
                self:PrepareHeroForDuel(
                    hero,                    -- 英雄单位
                    spawnPos,               -- 原始召唤位置
                    self.duration - 5,       -- 限制效果持续时间
                    Vector(-1, 0, 0)        -- 朝向左侧
                )
            end
        end
    end)

    -- 7. 入场动画和比赛开始
    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        Timers:CreateTimer(0.1, function()
            
            self:MonitorUnitsStatus()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            return 0.01
        end)
        -- 只使用第一个英雄的数据来显示入场动画
        if self.leftTeamHeroes[1] and self.rightTeamHeroes[1] then
            self:SendHeroAndFacetData(heroName, opponentHeroName, selfFacetId, opponentFacetId, self.limitTime)
        end
        
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

    -- 8. 比赛开始信号
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 正式开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)
end

function Main:OnUnitKilled_mode_5v5(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        return
    end

    -- 检查是否一方全部阵亡
    local leftTeamAlive = false
    local rightTeamAlive = false

    -- 检查左方队伍
    for _, hero in pairs(self.leftTeamHeroes) do
        if not hero:IsNull() and hero:IsAlive() then
            leftTeamAlive = true
            break
        end
    end

    -- 检查右方队伍
    for _, hero in pairs(self.rightTeamHeroes) do
        if not hero:IsNull() and hero:IsAlive() then
            rightTeamAlive = true
            break
        end
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

        -- 只对获胜方的第一个存活英雄播放胜利特效
        local winningHeroes = leftTeamAlive and self.leftTeamHeroes or self.rightTeamHeroes
        for _, hero in pairs(winningHeroes) do
            if not hero:IsNull() and hero:IsAlive() then
                self:PlayVictoryEffects(hero)
                break  -- 只对第一个存活的英雄播放
            end
        end

        -- 禁用所有幸存英雄
        for _, hero in pairs(self.leftTeamHeroes) do
            if not hero:IsNull() and hero:IsAlive() then
                self:DisableHeroWithModifiers(hero, self.endduration)
            end
        end
        for _, hero in pairs(self.rightTeamHeroes) do
            if not hero:IsNull() and hero:IsAlive() then
                self:DisableHeroWithModifiers(hero, self.endduration)
            end
        end
    end
end

function Main:OnNPCSpawned_mode_5v5(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end