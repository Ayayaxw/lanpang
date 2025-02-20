function Main:Cleanup_Courier800()

end

function Main:Init_Courier800(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentcourierIndex = 1
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印
    local ability_modifiers = {
    }
    -- 设置英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})
                hero:AddNewModifier(hero, nil, "modifier_truesight_vision", {})
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
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)


    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)


    self:UpdateAbilityModifiers(ability_modifiers)

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 5         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        -- 限定时间为准备时间结束后的一分钟
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
        ["剩余时间"] = self.limitTime,
        ["击杀数量"] = "0"  -- 添加击杀数初始值
    }
    local order = {"挑战英雄", "剩余时间", "击杀数量"}
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

    -- 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.rightTeam = {self.rightTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = 3 })
        end
    end)

    -- 给英雄添加小礼物
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        -- 给双方英雄添加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
        end
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
        self:PreSpawncouriers()
    end)

    -- 比赛开始后才开始传送拍拍熊
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --self:StartcourierDeployment()
    end)

    -- 限定时间结束后的操作
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
        end

        -- 添加时间到时的成绩播报
        -- 记录结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战完成]击杀数:" .. hero_duel.killCount
        )

        -- 结束决斗并更新UI，显示胜利和击杀数
        CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
            result = "victory",
            survivalTime = "01:00.00",  -- 满时间
            killCount = hero_duel.killCount
        })

        -- 可以添加胜利特效
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            -- 播放胜利音效
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)
            self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
            -- 添加胜利特效
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self.leftTeamHero1)
            ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            
            -- 添加聚光灯特效
            local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, self.leftTeamHero1)
            ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)
            
            -- 胜利动画
            self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
        end
    end)
end

function Main:PreSpawncouriers()
    self.courierPool = {}
    local totalcouriers = 100
    local courierCollisionSize = 64
    local spacing = courierCollisionSize * 1.5  -- 信使之间的间距
    local center = Main.largeSpawnCenter

    -- 定义三个圈的半径
    local innerRadius = 600  -- 最内圈
    local middleRadius = 700 -- 中间圈
    local outerRadius = 800  -- 最外圈

    -- 计算每个圈可以放置的信使数量
    local function getUnitsInCircle(radius)
        local circumference = 2 * math.pi * radius
        return math.floor(circumference / spacing)
    end

    local innerCircleUnits = getUnitsInCircle(innerRadius)
    local middleCircleUnits = getUnitsInCircle(middleRadius)
    local outerCircleUnits = totalcouriers - innerCircleUnits - middleCircleUnits
    
    -- 定义矩形边界
    local bounds = {
        left = -1588,
        right = 1833,
        top = 1338,
        bottom = -810
    }
    

    local function isPositionInBounds(pos)
        return pos.x >= bounds.left and pos.x <= bounds.right and 
               pos.y >= bounds.bottom and pos.y <= bounds.top
    end

    local function findEscapeDirection(courierPos, enemyPos)
        local distToLeft = courierPos.x - bounds.left
        local distToRight = bounds.right - courierPos.x
        local distToTop = bounds.top - courierPos.y
        local distToBottom = courierPos.y - bounds.bottom
        
        -- 找出最近的边界距离和方向
        local minDist = math.min(distToLeft, distToRight, distToTop, distToBottom)
        local nearBorder = minDist < 200
        
        if not nearBorder then
            -- 不在边界附近，直接远离敌人
            return (courierPos - enemyPos):Normalized()
        end
        
        -- 确定当前在哪个边界附近
        local possibleDirections = {}
        
        -- 根据边界情况添加可能的逃跑方向
        if distToLeft < 200 then
            table.insert(possibleDirections, Vector(0, 1, 0))  -- 向上
            table.insert(possibleDirections, Vector(0, -1, 0)) -- 向下
            table.insert(possibleDirections, Vector(1, 0, 0))  -- 向右
        end
        if distToRight < 200 then
            table.insert(possibleDirections, Vector(0, 1, 0))  -- 向上
            table.insert(possibleDirections, Vector(0, -1, 0)) -- 向下
            table.insert(possibleDirections, Vector(-1, 0, 0)) -- 向左
        end
        if distToTop < 200 then
            table.insert(possibleDirections, Vector(-1, 0, 0)) -- 向左
            table.insert(possibleDirections, Vector(1, 0, 0))  -- 向右
            table.insert(possibleDirections, Vector(0, -1, 0)) -- 向下
        end
        if distToBottom < 200 then
            table.insert(possibleDirections, Vector(-1, 0, 0)) -- 向左
            table.insert(possibleDirections, Vector(1, 0, 0))  -- 向右
            table.insert(possibleDirections, Vector(0, 1, 0))  -- 向上
        end
        
        -- 计算每个方向与敌人的夹角，选择最适合的方向
        local enemyDir = (enemyPos - courierPos):Normalized()
        local bestDir = nil
        local bestScore = -1
        
        for _, dir in ipairs(possibleDirections) do
            -- 检查这个方向移动500单位后是否会超出边界
            local testPos = courierPos + dir * 500
            if isPositionInBounds(testPos) then
                -- 计算与敌人方向的夹角（点积越小越好）
                local dot = dir:Dot(enemyDir)
                local score = -dot  -- 负点积，使方向尽量与敌人相反
                if score > bestScore then
                    bestScore = score
                    bestDir = dir
                end
            end
        end
        
        return bestDir or (courierPos - enemyPos):Normalized()
    end

    -- 生成信使的函数
    local function spawnCouriersInCircle(radius, count)
        for i = 1, count do
            local angle = (i * 2 * math.pi) / count
            local spawnX = center.x + radius * math.cos(angle)
            local spawnY = center.y + radius * math.sin(angle)
            local spawnPos = Vector(spawnX, spawnY, center.z)
            
            local courierUnit = CreateUnitByName(
                "npc_dota_courier",
                spawnPos,
                true,
                nil,
                nil,
                DOTA_TEAM_BADGUYS
            )
            
            if courierUnit then
                -- 设置朝向中心
                local direction = (center - spawnPos):Normalized()
                courierUnit:SetForwardVector(direction)
                courierUnit:AddNewModifier(courierUnit, nil, "modifier_truesight_vision", {})

                table.insert(self.courierPool, courierUnit)
                
                courierUnit:SetContextThink("FleeAI", function()
                    if not courierUnit or courierUnit:IsNull() or not courierUnit:IsAlive() then
                        return nil
                    end
                    
                    local nearbyUnits = FindUnitsInRadius(
                        DOTA_TEAM_BADGUYS,
                        courierUnit:GetAbsOrigin(),
                        nil,
                        500,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false
                    )
                    
                    local validEnemies = {}
                    for _, unit in pairs(nearbyUnits) do
                        if not unit:IsInvisible() and not unit:IsInvulnerable() then
                            table.insert(validEnemies, unit)
                        end
                    end
                    
                    if #validEnemies > 0 then
                        local courierPos = courierUnit:GetAbsOrigin()
                        local enemyPos = validEnemies[1]:GetAbsOrigin()
                        
                        if not courierUnit.escapeDir or
                           (courierUnit.lastEscapePos and (courierUnit.lastEscapePos - courierPos):Length2D() > 200) then
                            courierUnit.escapeDir = findEscapeDirection(courierPos, enemyPos)
                            courierUnit.lastEscapePos = courierPos
                        end
                        
                        local targetPos = courierPos + courierUnit.escapeDir * 500
                        
                        targetPos.x = math.max(bounds.left, math.min(bounds.right, targetPos.x))
                        targetPos.y = math.max(bounds.bottom, math.min(bounds.top, targetPos.y))
                        
                        courierUnit:MoveToPosition(targetPos)
                    end
                    
                    return 0.2
                end, 0)
            end
        end
    end

    -- 生成三个圈的信使
    spawnCouriersInCircle(innerRadius, innerCircleUnits)
    spawnCouriersInCircle(middleRadius, middleCircleUnits)
    spawnCouriersInCircle(outerRadius, outerCircleUnits)


    
end


function Main:OnUnitKilled_Courier800(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)
    print("死了")
    -- 修改判断条件，只检查游戏是否结束
    if hero_duel.EndDuel then
        return
    end

    -- 判断是否为信使
    if killedUnit:GetUnitName() == "npc_dota_courier" then
        self:ProcessHeroDeath_Courier800(killedUnit, killer)
    end
end





function Main:ProcessHeroDeath_Courier800(killedUnit, killer)
    print("ProcessHeroDeath_Courier800 called for unit: ", killedUnit:GetUnitName())
    

        local isPlayerHero = (killedUnit == self.leftTeamHero1 or (self:isMeepoClone(killedUnit) and killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS))
        print("Is player hero killed: ", isPlayerHero)
        print("Current EndDuel status: ", hero_duel.EndDuel)
        print("Current Timer: ", self.currentTimer)

        if isPlayerHero then
            if killer then
                -- 给击杀者播放胜利特效
                GridNav:DestroyTreesAroundPoint(killer:GetOrigin(), 500, false)
                killer:SetForwardVector(Vector(0, -1, 0))
                
                -- 添加胜利动画
                killer:StartGesture(ACT_DOTA_VICTORY)
                
                -- 播放胜利音效
                EmitSoundOn("Hero_LegionCommander.Duel.Victory", killer)
                
                -- 添加胜利特效
                self:gradual_slow_down(killedUnit:GetOrigin(), killer:GetOrigin())
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, killer)
                ParticleManager:SetParticleControl(particle, 0, killer:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 添加聚光灯特效
                local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/courier/courier_unicycle/courier_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, killer)
                ParticleManager:SetParticleControl(particle1, 0, killer:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle1)
            end

            print("Player hero died, processing game end")
            
            -- 计算剩余时间
            local totalTime = 60
            local currentTime = GameRules:GetGameTime() - self.startTime
            local remainingTime = math.max(0, totalTime - currentTime)
            
            local formattedTime = string.format("%02d:%02d.%02d", 
                math.floor(remainingTime / 60),
                math.floor(remainingTime % 60),
                math.floor((remainingTime * 100) % 100))
            
            print("Remaining time: ", remainingTime)
            print("Formatted remaining time: ", formattedTime)
            print("Kill count: ", hero_duel.killCount)

            -- 设置结束标志
            print("Setting EndDuel to true")
            hero_duel.EndDuel = true
            print("Incrementing currentTimer")
            self.currentTimer = self.currentTimer + 1

            -- 发送更新分数事件，使用剩余时间
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["剩余时间"] = formattedTime
            })

            -- 记录结果
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]剩余时间:" .. formattedTime .. ",击杀数:" .. hero_duel.killCount
            )

            -- 结束决斗并更新UI
            print("Sending final score update to clients")
            CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
                result = "defeat",
                survivalTime = formattedTime,
                killCount = hero_duel.killCount
            })
        else
            print("courier died, updating kill count")
            if killer then
                -- 播放金币特效
                local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
                ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                -- 播放金币音效
                EmitSoundOn("General.Coins", killer)
            end
            -- 一秒后清理AI和实体
            Timers:CreateTimer(1.0, function()
                -- 停止实体的AI思考
                if killedUnit and not killedUnit:IsNull() then
                    killedUnit:SetContextThink("AIThink", nil, 0)
                end
                
                -- 移除AI引用
                if killedUnit.ai then
                    killedUnit.ai = nil
                end
                
                -- 从AIs表中移除
                if AIs[killedUnit] then
                    AIs[killedUnit] = nil
                end
                
                -- 移除实体
                if killedUnit and not killedUnit:IsNull() then
                    killedUnit:RemoveSelf()
                end
            end)
            
            -- 更新击杀数并发送给前端
            hero_duel.killCount = hero_duel.killCount + 1
            local data = {
                ["击杀数量"] = hero_duel.killCount
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)

            -- 检查是否完成全部击杀
            if hero_duel.killCount >= 100 and not hero_duel.EndDuel then
                hero_duel.EndDuel = true
                
                -- 停止计时
                CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

                -- 计算剩余时间
                local currentTime = GameRules:GetGameTime() - self.startTime
                local remainingTime = math.max(0, self.limitTime - currentTime)
                local formattedTime = string.format("%02d:%02d.%02d", 
                    math.floor(remainingTime / 60),
                    math.floor(remainingTime % 60),
                    math.floor((remainingTime * 100) % 100))

                -- 计算总得分：击杀数 + 剩余时间取整
                local totalScore = hero_duel.killCount + math.floor(remainingTime)

                -- 记录结果（修改这里，使用总得分替代击杀数）
                self:createLocalizedMessage(
                    "[LanPang_RECORD][",
                    self.currentMatchID,
                    "]",
                    "[挑战成功]剩余时间:" .. formattedTime .. ",总得分:" .. totalScore
                )

                -- 发送胜利消息给前端
                CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
                    result = "victory",
                    survivalTime = formattedTime,
                    killCount = hero_duel.killCount,
                    totalScore = totalScore
                })

                -- 为玩家英雄播放胜利效果
                if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                    -- 播放胜利音效
                    EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)
                    
                    -- 添加胜利特效
                    self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
                    local particle = ParticleManager:CreateParticle(
                        "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                        PATTACH_OVERHEAD_FOLLOW, 
                        self.leftTeamHero1
                    )
                    ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle)
                    
                    -- 添加聚光灯特效
                    local particle1 = ParticleManager:CreateParticle(
                        "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                        PATTACH_ABSORIGIN, 
                        self.leftTeamHero1
                    )
                    ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle1)
                    
                    -- 胜利动画
                    self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
                end
            end
        end
end

function Main:OnNPCSpawned_Courier800(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end