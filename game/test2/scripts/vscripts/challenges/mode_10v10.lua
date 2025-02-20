function Main:Init_mode_10v10(event, playerID)
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
    self:SendCameraPositionToJS(Main.largeSpawnCenter + Vector(0, 200, 0), 1)

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
        ["绿方英雄"] = heroChineseName,
        ["红方英雄"] = opponentChineseName,
        ["剩余时间"] = self.limitTime,
    }
    local order = {"绿方英雄", "红方英雄", "剩余时间"}
    SendInitializationMessage(data, order)

    -- 5. 英雄创建
    -- 创建数组存储双方英雄
    self.leftTeamHeroes = {}
    self.rightTeamHeroes = {}
    
    -- 计算英雄间距
    local heroSpacing = 200  -- Y轴间距
    local rowSpacing = math.floor(heroSpacing * math.sqrt(3) / 2)  -- Y轴间距
    local startY = 200       -- 起始Y坐标
        
    -- 左方阵营的X坐标（从前到后）
    local leftXPositions = {
        -0,   -- 第一排（靠近中间）
        -200,   -- 第二排
        -600,   -- 第三排
        -1150   -- 第四排（保持不变）
    }

    -- 右方阵营的X坐标（从前到后）
    local rightXPositions = {
        300,    -- 第一排（靠近中间）
        500,   -- 第二排
        900,   -- 第三排
        1450    -- 第四排（保持不变）
    }

    -- 创建左方10个英雄
    local positions = {
        {row = 1, units = {{x = leftXPositions[1], y = 0}}},  -- 第一排1个
        {row = 2, units = {{x = leftXPositions[2], y = -rowSpacing}, {x = leftXPositions[2], y = rowSpacing}}},  -- 第二排2个
        {row = 3, units = {{x = leftXPositions[3], y = -2*rowSpacing}, {x = leftXPositions[3], y = 0}, {x = leftXPositions[3], y = 2*rowSpacing}}},  -- 第三排3个
        {row = 4, units = {{x = leftXPositions[4], y = -3*rowSpacing}, {x = leftXPositions[4], y = -rowSpacing}, 
                        {x = leftXPositions[4], y = rowSpacing}, {x = leftXPositions[4], y = 3*rowSpacing}}}  -- 第四排4个
    }

    local currentHero = 1
    for _, row in ipairs(positions) do
        for _, pos in ipairs(row.units) do
            if currentHero <= 10 then
                local spawnPos = Vector(pos.x, startY + pos.y, 128)
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
                currentHero = currentHero + 1
            end
        end
    end

    -- 创建右方10个英雄
    positions = {
        {row = 1, units = {{x = rightXPositions[1], y = 0}}},  -- 第一排1个
        {row = 2, units = {{x = rightXPositions[2], y = -rowSpacing}, {x = rightXPositions[2], y = rowSpacing}}},  -- 第二排2个
        {row = 3, units = {{x = rightXPositions[3], y = -2*rowSpacing}, {x = rightXPositions[3], y = 0}, {x = rightXPositions[3], y = 2*rowSpacing}}},  -- 第三排3个
        {row = 4, units = {{x = rightXPositions[4], y = -3*rowSpacing}, {x = rightXPositions[4], y = -rowSpacing}, 
                        {x = rightXPositions[4], y = rowSpacing}, {x = rightXPositions[4], y = 3*rowSpacing}}}  -- 第四排4个
    }

    currentHero = 1
    for _, row in ipairs(positions) do
        for _, pos in ipairs(row.units) do
            if currentHero <= 10 then
                local spawnPos = Vector(pos.x, startY + pos.y, 128)
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
                currentHero = currentHero + 1
            end
        end
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
        currentHero = 1
        positions = {
            {row = 1, units = {{x = leftXPositions[1], y = 0}}},
            {row = 2, units = {{x = leftXPositions[2], y = -rowSpacing}, {x = leftXPositions[2], y = rowSpacing}}},
            {row = 3, units = {{x = leftXPositions[3], y = -2*rowSpacing}, {x = leftXPositions[3], y = 0}, {x = leftXPositions[3], y = 2*rowSpacing}}},
            {row = 4, units = {{x = leftXPositions[4], y = -3*rowSpacing}, {x = leftXPositions[4], y = -rowSpacing}, 
                              {x = leftXPositions[4], y = rowSpacing}, {x = leftXPositions[4], y = 3*rowSpacing}}}
        }
        
        for _, row in ipairs(positions) do
            for _, pos in ipairs(row.units) do
                if currentHero <= #self.leftTeamHeroes then
                    local hero = self.leftTeamHeroes[currentHero]
                    if hero and not hero:IsNull() then
                        local spawnPos = Vector(pos.x, startY + pos.y, 128)
                        self:StartAbilitiesMonitor(hero,false)
                        
                        self:PrepareHeroForDuel(
                            hero,
                            spawnPos,
                            self.duration - 5,
                            Vector(1, 0, 0)
                        )
                    end
                    currentHero = currentHero + 1
                end
            end
        end
    
        -- 让右方所有英雄回到原位
        currentHero = 1
        positions = {
            {row = 1, units = {{x = rightXPositions[1], y = 0}}},
            {row = 2, units = {{x = rightXPositions[2], y = -rowSpacing}, {x = rightXPositions[2], y = rowSpacing}}},
            {row = 3, units = {{x = rightXPositions[3], y = -2*rowSpacing}, {x = rightXPositions[3], y = 0}, {x = rightXPositions[3], y = 2*rowSpacing}}},
            {row = 4, units = {{x = rightXPositions[4], y = -3*rowSpacing}, {x = rightXPositions[4], y = -rowSpacing}, 
                              {x = rightXPositions[4], y = rowSpacing}, {x = rightXPositions[4], y = 3*rowSpacing}}}
        }
        
        for _, row in ipairs(positions) do
            for _, pos in ipairs(row.units) do
                if currentHero <= #self.rightTeamHeroes then
                    local hero = self.rightTeamHeroes[currentHero]
                    if hero and not hero:IsNull() then
                        local spawnPos = Vector(pos.x, startY + pos.y, 128)
                        self:StartAbilitiesMonitor(hero,false)
                        self:PrepareHeroForDuel(
                            hero,
                            spawnPos,
                            self.duration - 5,
                            Vector(-1, 0, 0)
                        )
                    end
                    currentHero = currentHero + 1
                end
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

function Main:OnUnitKilled_mode_10v10(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        return
    end

    -- 检查是否一方全部阵亡
    local leftTeamAlive = false
    local rightTeamAlive = false
    self:StopAbilitiesMonitor(killedUnit)
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

function Main:OnNPCSpawned_mode_10v10(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end