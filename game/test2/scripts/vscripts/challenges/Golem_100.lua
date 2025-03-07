function Main:Init_Golem_100(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印
    local ability_modifiers = {
    }
    -- 设置英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)

    
    self:SetDamagePanelEnabled(true)

    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                local heroName = hero:GetUnitName()

                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
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
    self.limitTime = 100        
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
        ["击杀数量"] = "0",
        ["当前总分"] = "0"  -- 添加当前总分
    }
    local order = {"挑战英雄", "剩余时间", "击杀数量", "当前总分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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
        else
            -- 处理非 AI 情况
        end
    end)


    -- 给英雄添加小礼物
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)

    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            self.largeSpawnCenter,      -- 左侧决斗区域坐标
            self.duration - 5,                      -- 限制效果持续20秒
            Vector(0, 1, 0)          -- 朝向北侧
        )
    end)

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

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnGolem()
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
    
        -- 计算最终得分
        local finalScore = hero_duel.killCount

        -- 记录结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战完成]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

    
        -- 播放胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self:PlayDefeatAnimation(self.leftTeamHero1)
        end
    end)
end

function Main:PreSpawnGolem()
    -- 获取矩形区域中心点
    local left = self.largeSpawnArea_northWest.x
    local right = self.largeSpawnArea_northEast.x
    local top = self.largeSpawnArea_northWest.y
    local bottom = self.largeSpawnArea_southWest.y
    local centerX = (left + right) / 2
    local centerY = (top + bottom) / 2
    local centerPos = Vector(centerX, centerY, self.largeSpawnArea_northWest.z)
    
    -- 创建术士英雄
    CreateHero(0, "warlock", 1, centerPos+Vector(0,400,0), DOTA_TEAM_BADGUYS, false, 
        function(warlock)
            -- 添加魔晶、神杖和编辑器修饰器
            warlock:AddNewModifier(warlock, nil, "modifier_item_aghanims_shard", {})
            warlock:AddNewModifier(warlock, nil, "modifier_kv_editor", {})
            HeroMaxLevel(warlock)
            
            -- 获取术士大招技能
            local ultimateAbility = warlock:FindAbilityByName("warlock_rain_of_chaos")
            if ultimateAbility then
                -- 连续释放10次大招
                for i = 1, 100 do

                    warlock:SetCursorPosition(Main.waterFall_Center)
                    ultimateAbility:OnSpellStart()
                                        -- 不再移除术士，而是添加modifier_wearable修饰器
                    warlock:AddNewModifier(warlock, nil, "modifier_wearable", {})
                    --朝南
                    warlock:SetForwardVector(Vector(0, -1, 0))
                end
                
                -- 2秒后收集所有魔像到池子里
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
                    
                    -- 添加缴械效果并重新分布地狱火
                    self:DisarmAndRepositionGolems()
                end)
            else
                print("错误：未找到术士大招技能")
            end

        end)
end

-- 修改函数：添加缴械效果并重新分布地狱火
function Main:DisarmAndRepositionGolems()
    if not self.golemPool or #self.golemPool == 0 then
        print("错误：地狱火池为空")
        return
    end
    
    print("开始处理" .. #self.golemPool .. "个地狱火")
    
    -- 给所有地狱火添加6秒缴械效果
    for _, golem in pairs(self.golemPool) do
        if golem and not golem:IsNull() then
            golem:AddNewModifier(golem, nil, "modifier_disarmed", { duration = 6.0 })
            golem:AddNewModifier(golem, nil, "modifier_damage_reduction_100", { duration = 6.0 })
            golem:SetAcquisitionRange(2000)
        end
    end
    
    -- 设置三个圆的半径，可以根据地狱火数量动态调整
    local golemCount = #self.golemPool
    
    -- 根据总数动态分配三个圆的半径和每个圆的地狱火数量
    local smallRadius = 600
    local mediumRadius = 800
    local largeRadius = 1000
    
    -- 根据地狱火总数动态分配到三个圆上的数量
    local smallCircleCount = math.floor(golemCount * 0.2)  -- 小圈20%
    local mediumCircleCount = math.floor(golemCount * 0.3) -- 中圈30%
    local largeCircleCount = golemCount - smallCircleCount - mediumCircleCount -- 大圈剩余的
    
    print("小圈地狱火数量: " .. smallCircleCount)
    print("中圈地狱火数量: " .. mediumCircleCount)
    print("大圈地狱火数量: " .. largeCircleCount)
    
    -- 地狱火中心位置
    local center = Main.largeSpawnCenter
    
    -- 分布小圈地狱火
    for i = 1, smallCircleCount do
        local angle = (i-1) * (360 / smallCircleCount)
        local x = center.x + smallRadius * math.cos(angle * math.pi / 180)
        local y = center.y + smallRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local golem = self.golemPool[i]
        if golem and not golem:IsNull() then
            FindClearSpaceForUnit(golem, newPos, true)
            
            -- 让地狱火面朝圆心
            local direction = (center - newPos):Normalized()
            golem:SetForwardVector(direction)
        end
    end
    
    -- 分布中圈地狱火
    for i = 1, mediumCircleCount do
        local angle = (i-1) * (360 / mediumCircleCount)
        local x = center.x + mediumRadius * math.cos(angle * math.pi / 180)
        local y = center.y + mediumRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local golem = self.golemPool[smallCircleCount + i]
        if golem and not golem:IsNull() then
            FindClearSpaceForUnit(golem, newPos, true)
            
            -- 让地狱火面朝圆心
            local direction = (center - newPos):Normalized()
            golem:SetForwardVector(direction)
        end
    end
    
    -- 分布大圈地狱火
    for i = 1, largeCircleCount do
        local angle = (i-1) * (360 / largeCircleCount)
        local x = center.x + largeRadius * math.cos(angle * math.pi / 180)
        local y = center.y + largeRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local golem = self.golemPool[smallCircleCount + mediumCircleCount + i]
        if golem and not golem:IsNull() then
            FindClearSpaceForUnit(golem, newPos, true)
            
            -- 让地狱火面朝圆心
            local direction = (center - newPos):Normalized()
            golem:SetForwardVector(direction)
        end
    end
    
    print("地狱火分布完成")
end

function Main:OnUnitKilled_Golem_100(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then return end

    -- 先检查是否是玩家英雄死亡
    if killedUnit == self.leftTeamHero1 then
        hero_duel.EndDuel = true
        
        -- 停止所有定时器
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["当前总分"] = tostring(hero_duel.killCount)
        })
        
        -- 播放失败动画
        self:PlayDefeatAnimation(self.leftTeamHero1)
        
        -- 记录比赛结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. hero_duel.killCount
        )

        -- 禁用所有英雄
        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
    end

    if killedUnit:GetUnitName() == "npc_dota_warlock_golem" then
        local function CalculateCurrentScore()
            return hero_duel.killCount
        end

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

        -- 更新击杀数和得分
        hero_duel.killCount = hero_duel.killCount + 1
        local currentScore = CalculateCurrentScore() -- 只计算击杀得分
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["当前总分"] = currentScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        -- 检查是否击败了所有地狱火
        if hero_duel.killCount >= #self.golemPool and not hero_duel.EndDuel then
            hero_duel.EndDuel = true
            

            
            -- 计算剩余时间并加入总分
            local elapsedTime = GameRules:GetGameTime() - self.startTime
            local remainingTime = math.max(0, self.limitTime - elapsedTime)
            local timeBonus = math.floor(remainingTime) -- 剩余的每秒1分
            local killScore = hero_duel.killCount
            local finalScore = killScore + timeBonus
            
            self:PlayVictoryEffects(self.leftTeamHero1)
            
            -- 记录结果
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功],最终得分:" .. finalScore
            )
            
            -- 更新前端显示
            data = {
                ["击杀数量"] = hero_duel.killCount,
                ["当前总分"] = finalScore
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        end
    end
end

function Main:OnNPCSpawned_Golem_100(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        --打印单位名字
        print("应用战场效果" .. spawnedUnit:GetUnitName())
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end