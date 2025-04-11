function Main:Init_Golem_vs_Heroes(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    -- 定义常量：英雄总数量
    self.TOTAL_HERO_COUNT = 30
    hero_duel.aliveHeroCount = self.TOTAL_HERO_COUNT  -- 初始化存活英雄数量
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印
    local ability_modifiers = {
    }
    -- 设置英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)

    

    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                local heroName = hero:GetUnitName()

                -- hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                -- hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                -- HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
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
                hero:AddNewModifier(hero, nil, "modifier_phased", {})
            end,
        }
    }

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    -- 获取技能等级阈值配置
    local selfSkillThresholds = event.selfSkillThresholds or {}
    -- 获取技能权重配置
    local selfSkillWeights = event.selfSkillWeights or {}
    
    -- 打印权重配置，检查传递情况
    print("[DEBUG] 技能权重配置:")
    for k, v in pairs(selfSkillWeights) do
        print("  " .. k .. " = " .. v)
    end
    
    -- 保存到self对象上，确保在ApplySkillLevels函数中可以访问
    self.selfSkillWeights = selfSkillWeights
    
    local heroName = self:GetHeroNames(selfHeroId)


    self:UpdateAbilityModifiers(ability_modifiers)

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        
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
        ["挑战英雄"] = heroName,
        ["剩余时间"] = self.limitTime,
        ["英雄存活数量"] = self.TOTAL_HERO_COUNT,
        ["当前总分"] = "0",  -- 添加当前总分
        ["已造成伤害"] = "0%" -- 添加已造成伤害百分比
    }
    local order = {"挑战英雄", "剩余时间", "英雄存活数量", "已造成伤害", "当前总分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        -- 不再单独为玩家英雄创建AI，而是等待所有克隆创建完成后统一赋予
    end)
    
    -- 记录AI配置信息供后续使用
    self.selfAIEnabled = selfAIEnabled
    self.selfOverallStrategy = selfOverallStrategy
    self.selfHeroStrategy = selfHeroStrategy
    self.selfSkillThresholds = selfSkillThresholds
    self.selfSkillWeights = selfSkillWeights

    self.selfEquipment = selfEquipment
    self.timerId = timerId

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnGolem_Golem_vs_Heroes()
    end)




    -- Timers:CreateTimer(self.duration - 0.5, function()
    --     if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    --     self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    -- end)

    -- 赛前限制
    -- Timers:CreateTimer(5, function()
    --     if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    --     self:PrepareHeroForDuel(
    --         self.leftTeamHero1,                     -- 英雄单位
    --         self.largeSpawnCenter,      -- 左侧决斗区域坐标
    --         self.duration - 5,                      -- 限制效果持续20秒
    --         Vector(0, 1, 0)          -- 朝向北侧
    --     )
    -- end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeamHero1:CalculateStatBonus(true)
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
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
    
        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
    
        -- 获取地狱火当前生命值百分比
        local golemHealthPercent = 100
        local golemDamageBonus = 0
        if self.golemPool and #self.golemPool > 0 and self.golemPool[1] and not self.golemPool[1]:IsNull() then
            golemHealthPercent = math.floor(self.golemPool[1]:GetHealthPercent())
            golemDamageBonus = 100 - golemHealthPercent  -- 伤害分数 = 100 - 剩余血量百分比
        end

        -- 计算最终得分
        local aliveHeroCount = hero_duel.killCount or 0
        local finalScore = aliveHeroCount + golemDamageBonus  -- 英雄得分 + 伤害得分

        -- 记录结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. finalScore .. "(英雄:" .. aliveHeroCount .. "+伤害:" .. golemDamageBonus .. ")"
        )
        local data = {
            ["英雄存活数量"] = aliveHeroCount,
            ["当前总分"] = finalScore,
            ["已造成伤害"] = (100 - golemHealthPercent) .. "%"
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

    
        -- 播放胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self:PlayDefeatAnimation(self.leftTeamHero1)
        end
    end)
end

function Main:PreSpawnGolem_Golem_vs_Heroes()
    -- 获取矩形区域中心点
    local left = self.largeSpawnArea_northWest.x
    local right = self.largeSpawnArea_northEast.x
    local top = self.largeSpawnArea_northWest.y
    local bottom = self.largeSpawnArea_southWest.y
    local centerX = (left + right) / 2
    local centerY = (top + bottom) / 2
    local centerPos = Vector(centerX, centerY, self.largeSpawnArea_northWest.z)
    
    -- 创建术士英雄（仅创建一个地狱火在中心位置）
    CreateHero(0, "warlock", 1, centerPos, DOTA_TEAM_BADGUYS, false, 
        function(warlock)
            -- 添加魔晶、神杖和编辑器修饰器
            warlock:AddNewModifier(warlock, nil, "modifier_item_aghanims_shard", {})
            warlock:AddNewModifier(warlock, nil, "modifier_kv_editor", {})
            HeroMaxLevel(warlock)
            
            -- 获取术士大招技能
            local ultimateAbility = warlock:FindAbilityByName("warlock_rain_of_chaos")
            if ultimateAbility then
                -- 释放一次大招在地图中心
                warlock:SetCursorPosition(centerPos)
                ultimateAbility:OnSpellStart()
                
                warlock:AddNewModifier(warlock, nil, "modifier_wearable", {})
                warlock:SetForwardVector(Vector(0, -1, 0))
                warlock:RemoveAbility("warlock_eldritch_summoning")
                warlock:SetAbsOrigin(Vector(1.52, 1567.51, 256.00))

                -- 2秒后收集魔像到池子里
                Timers:CreateTimer(2.0, function()
                    local golemPool = {}
                    -- 查找场上所有魔像
                    local entities = Entities:FindAllByClassname("npc_dota_warlock_golem")
                    print("找到魔像数量: " .. #entities)
                    
                    for _, golem in pairs(entities) do
                        -- 移除modifier_kill修饰器，防止地狱火自动消失
                        if golem:HasModifier("modifier_kill") then
                            local modifier = golem:FindModifierByName("modifier_kill")
                            if modifier then
                                modifier:SetDuration(-1, true)
                            end
                        end
                        
                        table.insert(golemPool, golem)
                    end
                    
                    self.golemPool = golemPool
                    print("已将" .. #golemPool .. "个魔像添加到池子中")
                    
                    self.warlock = warlock  -- 保存术士单位的引用
                    
                    -- 添加缴械效果
                    for _, golem in pairs(self.golemPool) do
                        if golem and not golem:IsNull() then
                            golem:AddNewModifier(golem, nil, "modifier_disarmed", { duration = 6.0 })
                            golem:AddNewModifier(golem, nil, "modifier_damage_reduction_100", { duration = 6.0 })
                            golem:SetAcquisitionRange(5000)
                            golem:SetControllableByPlayer(0, false)
                            golem:SetAbsOrigin(centerPos)

                        end
                    end
                    --移动到地图中心
                    
                end)
            else
                print("错误：未找到术士大招技能")
            end
        end)
    
    -- 确保玩家英雄已经创建
    if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
        -- 创建英雄数组，包含原始英雄
        local heroPool = {self.leftTeamHero1}
        local selfFacetId = self.leftTeamHero1:GetHeroFacetID()
        -- 使用原始英雄作为母体创建克隆英雄
        for i = 1, self.TOTAL_HERO_COUNT - 1 do
            local spawnPos = self.largeSpawnCenter + Vector(100, 100, 0) -- 临时位置，之后会重新分布
            CreateHeroHeroChaos(0, self.leftTeamHero1:GetUnitName(), selfFacetId, spawnPos, DOTA_TEAM_GOODGUYS, false, self.leftTeamHero1, function(cloneHero)
                -- 配置克隆英雄
                self:ConfigureHero(cloneHero, false, playerID)
                self:EquipHeroItems(cloneHero, selfEquipment)
                
                -- 应用技能等级设置

                
                -- 将克隆英雄添加到数组
                table.insert(heroPool, cloneHero)
                
                -- 当所有克隆都创建完成后，重新分布它们
                if #heroPool == self.TOTAL_HERO_COUNT then
                    self.heroPool = heroPool
                    print("已创建" .. self.TOTAL_HERO_COUNT .. "个英雄（1个原始 + " .. (self.TOTAL_HERO_COUNT-1) .. "个克隆）")
                    self:RepositionHeroes()
                    
                    -- 为所有英雄添加状态效果
                    -- 一次性处理所有英雄的技能升级
                    if self.selfSkillWeights then
                        -- 如果有技能权重设置，只需要调用一次函数处理所有英雄
                        self:ApplySkillLevels(nil, self.selfSkillThresholds)
                    else
                        -- 如果没有技能权重设置，使用原始方式单独处理每个英雄
                        for _, hero in pairs(self.heroPool) do
                            if hero and not hero:IsNull() then
                                self:ApplySkillLevels(hero, self.selfSkillThresholds)
                            end
                        end
                    end
                    
                    -- 添加其他状态效果
                    for _, hero in pairs(self.heroPool) do
                        if hero and not hero:IsNull() then

                            hero:AddNewModifier(hero, nil, "modifier_disarmed", { duration = 8.0 })
                            hero:AddNewModifier(hero, nil, "modifier_silence", { duration = 8.0 })
                            hero:AddNewModifier(hero, nil, "modifier_rooted", { duration = 8.0 })
                            hero:AddNewModifier(hero, nil, "modifier_break", { duration = 8.0 })
                            hero:AddNewModifier(hero, nil, "modifier_damage_reduction_100", { duration = 8.0 })
                            --给与相位状态

                            self:HeroBenefits(hero:GetUnitName(), hero, self.selfOverallStrategy,self.selfHeroStrategy)
                            Timers:CreateTimer(1, function()
                                self:HeroPreparation(hero:GetUnitName(), hero, self.selfOverallStrategy,self.selfHeroStrategy)
                            end)

                        end
                    end
                    
                    -- 为所有英雄创建相同的AI
                    if self.selfAIEnabled then
                        Timers:CreateTimer(8, function()
                            if self.currentTimer ~= self.timerId or hero_duel.EndDuel then return end
                            
                            for idx, hero in pairs(self.heroPool) do
                                if hero and not hero:IsNull() then
                                    local otherSettings = {skillThresholds = self.selfSkillThresholds}
                                    CreateAIForHero(hero, self.selfOverallStrategy, self.selfHeroStrategy, "heroClone_" .. idx,0.1, otherSettings)
                                end
                            end
                            
                            return nil
                        end)
                    end
                end
            end)
        end
    else
        print("错误：玩家英雄尚未创建或已被销毁")
    end
end

-- 应用技能等级设置函数
function Main:ApplySkillLevels(hero, skillThresholds)
    -- 检查必要参数
    if not self.heroPool or not skillThresholds then
        print("[错误] 缺少必要参数：" ..
            (self.heroPool and "heroPool存在 " or "heroPool不存在 ") ..
            (skillThresholds and "skillThresholds存在" or "skillThresholds不存在"))
        return
    end

    -- 将英雄池转换为数组形式
    local heroArray = {}
    for idx, hero in pairs(self.heroPool) do
        if hero and not hero:IsNull() then
            table.insert(heroArray, hero)
            print("[调试] 添加英雄到数组: 索引 " .. idx .. ", 类型 " .. hero:GetUnitName())
        end
    end
    
    local heroCount = #heroArray
    print("[调试] 转换后的英雄数组大小: " .. heroCount)
    
    if heroCount == 0 then
        print("[错误] 有效英雄数量为0")
        return
    end

    -- 检查selfSkillWeights是否存在或所有权重是否为0
    local shouldUpgradeAllSkills = not self.selfSkillWeights
    if self.selfSkillWeights then
        local allZero = true
        for skillKey, weight in pairs(self.selfSkillWeights) do
            if weight > 0 then
                allZero = false
                break
            end
        end
        shouldUpgradeAllSkills = allZero
    end

    -- 如果selfSkillWeights不存在或所有权重为0，则所有英雄升级所有技能
    if shouldUpgradeAllSkills then
        print("[调试] selfSkillWeights不存在或所有权重为0，所有英雄将升级所有技能")
        
        for _, hero in ipairs(heroArray) do
            -- 处理普通技能 (1-5)
            for i = 0, 4 do
                local skillKey = "skill" .. (i + 1)
                if skillThresholds[skillKey] and skillThresholds[skillKey].level > 0 then
                    local ability = hero:GetAbilityByIndex(i)
                    if ability then
                        -- 先复位技能等级
                        local currentLevel = ability:GetLevel()
                        ability:SetLevel(0)
                        hero:SetAbilityPoints(hero:GetAbilityPoints() + currentLevel)
                        
                        -- 然后升级到目标等级
                        local targetLevel = skillThresholds[skillKey].level
                        for j = 0, targetLevel - 1 do
                            hero:UpgradeAbility(ability)
                        end
                        print("[调试] 升级技能: " .. ability:GetAbilityName() .. " 至 " .. ability:GetLevel() .. " 级")
                    end
                end
            end
            
            -- 处理大招
            if skillThresholds.skill6 and skillThresholds.skill6.level > 0 then
                for i = 0, hero:GetAbilityCount() - 1 do
                    local ability = hero:GetAbilityByIndex(i)
                    if ability and ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
                        -- 先复位技能等级
                        local currentLevel = ability:GetLevel()
                        ability:SetLevel(0)
                        hero:SetAbilityPoints(0)
                        
                        -- 然后升级到目标等级
                        local targetLevel = skillThresholds.skill6.level
                        for j = 0, targetLevel - 1 do
                            hero:UpgradeAbility(ability)
                        end
                        print("[调试] 升级大招: " .. ability:GetAbilityName() .. " 至 " .. ability:GetLevel() .. " 级")
                        break
                    end
                end
            end
        end
        return
    end

    -- 如果代码执行到这里，说明有有效的权重分配，继续执行原有的权重分配逻辑
    print("[调试] 开始根据权重分配技能，技能权重配置:")
    for k, v in pairs(self.selfSkillWeights) do
        print("  " .. k .. " = " .. v)
    end

    -- 统计有效技能及其权重
    local validSkills = {}
    local totalWeight = 0
    
    -- 创建有序技能数组以确保处理顺序
    local orderedSkills = {"skill1", "skill2", "skill3", "skill4", "skill5", "skill6"}
    
    for _, skillKey in ipairs(orderedSkills) do
        if self.selfSkillWeights[skillKey] and self.selfSkillWeights[skillKey] > 0 then
            validSkills[skillKey] = self.selfSkillWeights[skillKey]
            totalWeight = totalWeight + self.selfSkillWeights[skillKey]
            print("[调试] 有效技能: " .. skillKey .. " 权重: " .. self.selfSkillWeights[skillKey])
        end
    end

    -- 根据权重计算每个技能分配的英雄数量
    local allocatedHeroes = {}
    local totalAllocated = 0
    
    -- 按顺序分配英雄数量
    for _, skillKey in ipairs(orderedSkills) do
        if validSkills[skillKey] then
            -- 计算应分配的英雄数量（四舍五入）
            local count = math.floor((validSkills[skillKey] / totalWeight * heroCount) + 0.5)
            allocatedHeroes[skillKey] = count
            totalAllocated = totalAllocated + count
            print("[调试] 初步分配: " .. skillKey .. " = " .. count .. "个英雄")
        end
    end

    -- 调整分配以确保总数正确
    while totalAllocated ~= heroCount do
        if totalAllocated > heroCount then
            -- 需要减少分配
            local maxSkill = nil
            local maxCount = 0
            for _, skillKey in ipairs(orderedSkills) do
                if allocatedHeroes[skillKey] and allocatedHeroes[skillKey] > maxCount then
                    maxCount = allocatedHeroes[skillKey]
                    maxSkill = skillKey
                end
            end
            if maxSkill then
                allocatedHeroes[maxSkill] = allocatedHeroes[maxSkill] - 1
                totalAllocated = totalAllocated - 1
                print("[调试] 调整减少: " .. maxSkill .. " 现在分配 " .. allocatedHeroes[maxSkill] .. "个英雄")
            end
        else
            -- 需要增加分配
            local minSkill = nil
            local minCount = math.huge
            for _, skillKey in ipairs(orderedSkills) do
                if allocatedHeroes[skillKey] and allocatedHeroes[skillKey] < minCount then
                    minCount = allocatedHeroes[skillKey]
                    minSkill = skillKey
                end
            end
            if minSkill then
                allocatedHeroes[minSkill] = allocatedHeroes[minSkill] + 1
                totalAllocated = totalAllocated + 1
                print("[调试] 调整增加: " .. minSkill .. " 现在分配 " .. allocatedHeroes[minSkill] .. "个英雄")
            end
        end
    end

    -- 打印最终分配结果
    print("[调试] 最终技能英雄分配结果:")
    for _, skillKey in ipairs(orderedSkills) do
        if allocatedHeroes[skillKey] then
            print(skillKey .. ": " .. allocatedHeroes[skillKey] .. "个英雄")
        end
    end

    print("[调试] ===== 开始重置所有英雄技能等级 =====")
    
    local allSkillsReset = {}  -- 用于记录每个英雄重置后的技能状态
    
    -- 重置所有英雄的技能点，避免之前可能已经升级过的技能
    for i, hero in ipairs(heroArray) do
        print("[调试] 重置英雄 #" .. i .. " " .. hero:GetUnitName() .. " 的技能等级")
        
        allSkillsReset[i] = {}
        -- 重置所有英雄的技能等级
        for j = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(j)
            if ability then
                -- 记录重置前的等级
                local currentLevel = ability:GetLevel()
                print("[调试]   技能 " .. j .. ": " .. ability:GetAbilityName() .. " 当前等级 " .. currentLevel)
                
                -- 重置技能等级
                ability:SetLevel(0)
                
                -- 恢复技能点
                hero:SetAbilityPoints(hero:GetAbilityPoints() + currentLevel)
                
                -- 记录重置后的状态
                allSkillsReset[i][j] = {
                    name = ability:GetAbilityName(),
                    resetLevel = ability:GetLevel()
                }
                
                print("[调试]   重置后等级: " .. ability:GetLevel() .. ", 当前技能点: " .. hero:GetAbilityPoints())
            end
        end
        print("[调试] 英雄 #" .. i .. " 的技能已重置，当前可用技能点: " .. hero:GetAbilityPoints())
    end
    
    print("[调试] ===== 重置技能后的状态检查 =====")
    -- 确认所有技能是否真的重置为0
    for i, hero in ipairs(heroArray) do
        print("检查英雄 #" .. i .. " " .. hero:GetUnitName() .. ":")
        for j = 0, 5 do
            local ability = hero:GetAbilityByIndex(j)
            if ability then
                print("  技能 " .. j .. ": " .. ability:GetAbilityName() .. " 等级 " .. ability:GetLevel())
                if ability:GetLevel() > 0 then
                    print("  [警告] 技能未正确重置为0!")
                end
            end
        end
    end

    print("[调试] ===== 开始随机分配技能升级 =====")
    
    -- 创建有效技能列表数组（用于随机选择）
    local availableSkills = {}
    for _, skillKey in ipairs(orderedSkills) do
        if allocatedHeroes[skillKey] and allocatedHeroes[skillKey] > 0 then
            -- 根据权重添加多个技能到数组中
            for i = 1, self.selfSkillWeights[skillKey] do
                table.insert(availableSkills, skillKey)
            end
            print("[调试] 添加技能 " .. skillKey .. " 到可用技能池，权重: " .. self.selfSkillWeights[skillKey])
        end
    end
    
    -- 打印可用技能池
    print("[调试] 可用技能池大小: " .. #availableSkills)
    for i, skill in ipairs(availableSkills) do
        print("  [" .. i .. "] = " .. skill)
    end
    
    -- 确保每个英雄都被分配到技能
    local heroSkillAssignment = {}
    for i = 1, heroCount do
        -- 从可用技能中随机选择一个
        local randomIndex = math.random(1, #availableSkills)
        local selectedSkill = availableSkills[randomIndex]
        heroSkillAssignment[i] = selectedSkill
        print("[调试] 英雄 #" .. i .. " 随机分配到技能: " .. selectedSkill)
    end
    
    -- 根据分配结果升级英雄技能
    print("[调试] ===== 开始根据随机分配结果升级技能 =====")
    
    for i, hero in ipairs(heroArray) do
        local assignedSkill = heroSkillAssignment[i]
        if assignedSkill then
            local skillNumber = tonumber(string.match(assignedSkill, "%d+"))
            
            print("[调试] 为英雄 #" .. i .. " " .. hero:GetUnitName() .. " 升级技能 " .. assignedSkill)
            
            -- 明确只升级一种技能
            if skillNumber >= 1 and skillNumber <= 5 then
                -- 处理普通技能
                local ability = hero:GetAbilityByIndex(skillNumber - 1)
                if ability and skillThresholds[assignedSkill] and skillThresholds[assignedSkill].level then
                    local targetLevel = skillThresholds[assignedSkill].level
                    if targetLevel > 0 then
                        print("[调试]   准备升级技能 " .. ability:GetAbilityName() .. " 从 " .. ability:GetLevel() .. " 级到 " .. targetLevel .. " 级")
                        for j = 0, targetLevel - 1 do
                            hero:UpgradeAbility(ability)
                            print("[调试]   升级后等级: " .. ability:GetLevel())
                        end
                        print("[调试]   英雄 #" .. i .. " 随机升级了 " .. assignedSkill .. " 至等级 " .. ability:GetLevel())
                    end
                else
                    print("[警告] 英雄 #" .. i .. " 无法升级技能 " .. assignedSkill .. 
                        (ability and "" or ", 技能不存在") .. 
                        (skillThresholds[assignedSkill] and "" or ", 阈值配置不存在") .. 
                        (skillThresholds[assignedSkill] and skillThresholds[assignedSkill].level and "" or ", 等级配置不存在"))
                end
            elseif skillNumber == 6 then
                -- 处理大招
                local ultimateFound = false
                for j = 0, hero:GetAbilityCount() - 1 do
                    local ability = hero:GetAbilityByIndex(j)
                    if ability and ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
                        ultimateFound = true
                        if skillThresholds[assignedSkill] and skillThresholds[assignedSkill].level then
                            local targetLevel = skillThresholds[assignedSkill].level
                            if targetLevel > 0 then
                                print("[调试]   准备升级大招 " .. ability:GetAbilityName() .. " 从 " .. ability:GetLevel() .. " 级到 " .. targetLevel .. " 级")
                                for k = 0, targetLevel - 1 do
                                    hero:UpgradeAbility(ability)
                                    print("[调试]   升级后等级: " .. ability:GetLevel())
                                end
                                print("[调试]   英雄 #" .. i .. " 随机升级了大招至等级 " .. ability:GetLevel())
                            end
                        end
                        break
                    end
                end
                if not ultimateFound then
                    print("[警告] 英雄 #" .. i .. " 没有找到大招技能")
                end
            end
            
            -- 检查升级后的状态
            print("[调试] 英雄 #" .. i .. " 升级后技能状态:")
            for j = 0, 5 do
                local ability = hero:GetAbilityByIndex(j)
                if ability then
                    print("  技能 " .. j .. ": " .. ability:GetAbilityName() .. " 等级 " .. ability:GetLevel())
                end
            end
        else
            print("[警告] 英雄 #" .. i .. " 没有分配到技能!")
        end
    end
    
    print("[调试] ===== 技能分配完成后的最终状态 =====")
    for i, hero in ipairs(heroArray) do
        print("英雄 #" .. i .. " " .. hero:GetUnitName() .. " 最终技能状态:")
        for j = 0, 5 do
            local ability = hero:GetAbilityByIndex(j)
            if ability then
                print("  技能 " .. j .. ": " .. ability:GetAbilityName() .. " 等级 " .. ability:GetLevel())
            end
        end
    end
    
    print("[调试] 完成所有英雄技能分配")
end

-- 新函数：重新分布英雄到三个圆上
function Main:RepositionHeroes()
    if not self.heroPool or #self.heroPool == 0 then
        print("错误：英雄池为空")
        return
    end
    
    print("开始分布" .. #self.heroPool .. "个英雄")
    
    -- 设置三个圆的半径
    local heroCount = #self.heroPool
    
    local smallRadius = 500
    local mediumRadius = 700
    local largeRadius = 900
    
    -- 根据英雄总数动态分配到三个圆上的数量
    local smallCircleCount = math.floor(heroCount * 0.2)  -- 小圈20%
    local mediumCircleCount = math.floor(heroCount * 0.3) -- 中圈30%
    local largeCircleCount = heroCount - smallCircleCount - mediumCircleCount -- 大圈剩余的
    
    print("小圈英雄数量: " .. smallCircleCount)
    print("中圈英雄数量: " .. mediumCircleCount)
    print("大圈英雄数量: " .. largeCircleCount)
    
    -- 英雄中心位置
    local center = self.largeSpawnCenter
    
    -- 分布小圈英雄
    for i = 1, smallCircleCount do
        local angle = (i-1) * (360 / smallCircleCount)
        local x = center.x + smallRadius * math.cos(angle * math.pi / 180)
        local y = center.y + smallRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local hero = self.heroPool[i]
        if hero and not hero:IsNull() then
            FindClearSpaceForUnit(hero, newPos, true)
            
            -- 让英雄面朝圆心
            local direction = (center - newPos):Normalized()
            hero:SetForwardVector(direction)
        end
    end
    
    -- 分布中圈英雄
    for i = 1, mediumCircleCount do
        local angle = (i-1) * (360 / mediumCircleCount)
        local x = center.x + mediumRadius * math.cos(angle * math.pi / 180)
        local y = center.y + mediumRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local hero = self.heroPool[smallCircleCount + i]
        if hero and not hero:IsNull() then
            FindClearSpaceForUnit(hero, newPos, true)
            
            -- 让英雄面朝圆心
            local direction = (center - newPos):Normalized()
            hero:SetForwardVector(direction)
        end
    end
    
    -- 分布大圈英雄
    for i = 1, largeCircleCount do
        local angle = (i-1) * (360 / largeCircleCount)
        local x = center.x + largeRadius * math.cos(angle * math.pi / 180)
        local y = center.y + largeRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local hero = self.heroPool[smallCircleCount + mediumCircleCount + i]
        if hero and not hero:IsNull() then
            FindClearSpaceForUnit(hero, newPos, true)
            
            -- 让英雄面朝圆心
            local direction = (center - newPos):Normalized()
            hero:SetForwardVector(direction)
        end
    end
    
    print("英雄分布完成")
end

function Main:OnUnitKilled_Golem_vs_Heroes(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then return end

    -- 检查是否有英雄死亡
    if self.heroPool and killedUnit:IsHero() then
        local isHeroInPool = false
        local aliveHeroCount = 0
        
        -- 检查死亡的单位是否是英雄池中的英雄，并统计存活英雄数量
        for i, hero in pairs(self.heroPool) do
            if hero and not hero:IsNull() then
                if killedUnit == hero then
                    -- 标记该英雄已死亡
                    self.heroPool[i] = nil
                    isHeroInPool = true
                    print("英雄死亡: " .. killedUnit:GetUnitName())
                else
                    -- 计算存活的英雄数量
                    aliveHeroCount = aliveHeroCount + 1
                end
            end
        end
        
        -- 更新存活英雄计数
        hero_duel.aliveHeroCount = aliveHeroCount
        
        -- 如果死亡的是英雄池中的英雄，更新前端显示
        if isHeroInPool then
            -- 获取已造成伤害百分比
            local golemHealthPercent = 100
            if self.golemPool and #self.golemPool > 0 and self.golemPool[1] and not self.golemPool[1]:IsNull() then
                golemHealthPercent = math.floor(self.golemPool[1]:GetHealthPercent())
            end
            
            -- 计算地狱火受到的伤害分数
            local golemDamageBonus = 100 - golemHealthPercent
            -- 总分 = 存活英雄数量 + 地狱火伤害奖励
            local totalScore = aliveHeroCount + golemDamageBonus
            
            local data = {
                ["英雄存活数量"] = tostring(aliveHeroCount),
                ["当前总分"] = tostring(totalScore),  -- 总分包含地狱火伤害奖励
                ["已造成伤害"] = (100 - golemHealthPercent) .. "%"
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)
            
            -- 检查是否所有英雄都已死亡
            if aliveHeroCount == 0 then
                hero_duel.EndDuel = true
                
                -- 播放失败动画
                self:PlayDefeatAnimation(self.leftTeamHero1)
                
                -- 记录比赛结果
                self:createLocalizedMessage(
                    "[LanPang_RECORD][",
                    self.currentMatchID,
                    "]",
                    "[挑战失败],最终得分:" .. golemDamageBonus
                )

                -- 禁用所有英雄
                for _, heroUnit in pairs(self.heroPool) do
                    if heroUnit and not heroUnit:IsNull() then
                        self:DisableHeroWithModifiers(heroUnit, self.endduration)
                    end
                end
                
                return
            end
        end
    end

    -- 当任何一个地狱火死亡时，挑战成功
    if killedUnit:GetUnitName() == "npc_dota_warlock_golem" then
        if killer then
            local particle = ParticleManager:CreateParticle(
                "particles/generic_gameplay/lasthit_coins_local.vpcf", 
                PATTACH_ABSORIGIN, 
                killedUnit
            )
            ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            EmitSoundOn("General.Coins", killer)
        end

        -- 计算当前存活的英雄数量（再次确认）
        local aliveHeroCount = 0
        for _, hero in pairs(self.heroPool) do
            if hero and not hero:IsNull() then
                aliveHeroCount = aliveHeroCount + 1
            end
        end
        
        hero_duel.aliveHeroCount = aliveHeroCount
        local survivorScore = aliveHeroCount  -- 存活英雄得分
        
        -- 添加地狱火伤害分数（100 - 剩余血量百分比）
        local golemDamageBonus = 0
        if self.golemPool and #self.golemPool > 0 then
            local golemHealthPercent = math.floor(killedUnit:GetHealthPercent())
            golemDamageBonus = 100 - golemHealthPercent  -- 伤害分数 = 100 - 剩余血量百分比
        end
        
        -- 计算剩余时间并加入总分
        local elapsedTime = GameRules:GetGameTime() - self.startTime
        local remainingTime = math.max(0, self.limitTime - elapsedTime)
        local timeBonus = math.floor(remainingTime) -- 剩余的每秒1分
        
        -- 最终分数 = 存活英雄数量 + 时间奖励 + 地狱火伤害奖励
        local finalScore = survivorScore + timeBonus + golemDamageBonus
        
        -- 一个地狱火死亡就算挑战成功
        if not hero_duel.EndDuel then
            hero_duel.EndDuel = true
            
            self:PlayVictoryEffects(self.leftTeamHero1)
            
            -- 记录结果
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功],最终得分:" .. finalScore
            )
            
            -- 更新前端显示
            local data = {
                ["英雄存活数量"] = tostring(aliveHeroCount),
                ["当前总分"] = tostring(finalScore),
                ["已造成伤害"] = "100%"  -- 地狱火已死亡
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        end
    end
end

function Main:OnNPCSpawned_Golem_vs_Heroes(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        --打印单位名字
        print("应用战场效果" .. spawnedUnit:GetUnitName())
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end