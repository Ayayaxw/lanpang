
function IsHeroTrulyDead(killedUnit, callback)
    local unitName = killedUnit:GetUnitName()


    -- 骷髅王判断简化为使用 IsReincarnating
    if killedUnit:IsReincarnating() then
        print(unitName .. " 将会重生")
        return callback(false)
    end

    -- 复仇之魂特殊处理
    if unitName == "npc_dota_hero_vengefulspirit" then
        local teamNumber = killedUnit:GetTeamNumber()
        local origin = killedUnit:GetAbsOrigin()
        local illusionFound = false
        local aiApplied = false

        local function checkIllusion()
            local nearbyIllusions = FindUnitsInRadius(
                teamNumber,
                origin,
                nil,
                1000,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )

            for _, illusion in pairs(nearbyIllusions) do
                if illusion:GetUnitName() == unitName and illusion:HasModifier("modifier_vengefulspirit_hybrid_special") then
                    if not illusionFound then
                        print("复仇之魂变成幻象了")
                        illusionFound = true
                        
                        if Main.currentChallenge == Main.Challenges.CD0_2skill then
                            illusion:AddNewModifier(illusion, nil, "modifier_no_cooldown_SecondSkill", {}) 
                        end

                        -- 检查原单位是否在 AIs 列表中，如果是，则为幻象添加 AI
                        if AIs and AIs[killedUnit] and not aiApplied then
                            if CreateAIForHero then
                                CreateAIForHero(illusion)
                                aiApplied = true
                                print("为复仇之魂幻象添加了 AI")
                            else
                                print("CreateAIForHero 函数不存在，无法为幻象添加 AI")
                            end
                        end
                    end
                    return true
                end
            end
            return false
        end

        Timers:CreateTimer(0.2, function()
            if checkIllusion() then
                -- 如果立即找到幻象，开始监视
                Timers:CreateTimer(0.1, function()
                    if checkIllusion() then
                        return 0.03  -- 继续检查
                    else
                        print(unitName .. " 确认死亡")
                        callback(true)
                        return nil  -- 停止定时器
                    end
                end)
            else
                -- 如果没有立即找到幻象，英雄已经死亡
                print(unitName .. " 确认死亡")
                callback(true)
            end
        end)
    else
        -- 对于其他所有英雄，直接返回 true
        print(unitName .. " 确认死亡")
        callback(true)
    end
end

function RotateHero(hero)
    if not hero or hero:IsNull() then return end

    local heroPosition = hero:GetAbsOrigin()
    local southDirection = Vector(0, -1, 0)  -- 南方向量
    local targetPosition = heroPosition + southDirection * 1  -- 略微偏移以改变面向

    local order = {
        UnitIndex = hero:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = targetPosition
    }

    ExecuteOrderFromTable(order)
end

function RotateHeroToSouth(hero)
    local rotationSpeed = 5 -- 旋转速度，每次更新的角度（度数）
    local targetAngle = 270 -- 南方对应的角度（270度）
    
    -- 获取英雄当前的朝向角度
    local startDirection = hero:GetForwardVector()
    local startAngle = math.deg(math.atan2(startDirection.y, startDirection.x))
    if startAngle < 0 then
        startAngle = startAngle + 360
    end
    
    local currentAngle = startAngle

    Timers:CreateTimer(function()
        if not hero or hero:IsNull() then return nil end

        -- 计算最短旋转方向
        local angleDiff = (targetAngle - currentAngle + 360) % 360
        if angleDiff > 180 then
            angleDiff = angleDiff - 360
        end

        -- 如果已经到达目标角度或者非常接近，则停止旋转
        if math.abs(angleDiff) < rotationSpeed then
            local finalDirection = Vector(0, -1, 0) -- 正南方向
            hero:SetForwardVector(finalDirection)
            return nil -- 停止计时器
        end

        -- 更新当前角度
        if angleDiff > 0 then
            currentAngle = (currentAngle + rotationSpeed) % 360
        else
            currentAngle = (currentAngle - rotationSpeed + 360) % 360
        end

        local radianAngle = math.rad(currentAngle)
        local direction = Vector(math.cos(radianAngle), math.sin(radianAngle), 0)

        hero:SetForwardVector(direction)
        return 0.03 -- 每 0.03 秒更新一次
    end)
end


function Main:isMeepoClone(unit)
    return unit:GetUnitName() == "npc_dota_hero_meepo"
end



function Main:ProcessHeroDeath(killedUnit)
    -- IsHeroTrulyDead(killedUnit, function(isDead)
    --     if not isDead then
    --         print("没死呢")
    --         -- 英雄未真正死亡，不执行后续逻辑
    --         return
    --     end

        local winningHero, losingHero, isLeftTeamWin
        local killedTeam = killedUnit:GetTeam()
        if killedUnit == self.rightTeamHero1 or (self:isMeepoClone(killedUnit) and killedTeam == DOTA_TEAM_BADGUYS) then
            -- 如果被击杀的是右方英雄或者是属于右方的米波克隆体
            winningHero = self.leftTeamHero1
            losingHero = self.rightTeamHero1
            isLeftTeamWin = true
        elseif killedUnit == self.leftTeamHero1 or (self:isMeepoClone(killedUnit) and killedTeam == DOTA_TEAM_GOODGUYS) then
            -- 如果被击杀的是左方英雄或者是属于左方的米波克隆体
            winningHero = self.rightTeamHero1
            losingHero = self.leftTeamHero1
            isLeftTeamWin = false
        else
            -- 如果被击杀的单位不属于任何一方，则不处理
            return
        end

        -- 计算时间和得分
        local endTime = GameRules:GetGameTime()
        local timeSpent = endTime - self.startTime
        local remainingTime = self.limitTime - timeSpent
        local formattedTime = string.format("%02d:%02d.%02d", 
            math.floor(remainingTime / 60),
            math.floor(remainingTime % 60),
            math.floor((remainingTime * 100) % 100))

        local finalScore
        local winnerSide
        if isLeftTeamWin then
            finalScore = math.floor(remainingTime) + 100
            winnerSide = "绿方"
        else
            finalScore = math.floor((1 - winningHero:GetHealth() / winningHero:GetMaxHealth()) * 100)
            winnerSide = "红方"
        end

        -- 打印结果和成绩
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[比赛结束]获胜者:" .. winnerSide .. ",",
            {localize = true, text = winningHero:GetUnitName()}
        )

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[玩家得分]",
            tostring(finalScore)
        )

        -- 砍伐获胜英雄周围的树木
        local treeRadius = 500
        GridNav:DestroyTreesAroundPoint(winningHero:GetOrigin(), treeRadius, false)

        winningHero:SetForwardVector(Vector(0, -1, 0))
        local modifiers = {"modifier_damage_reduction_100", "modifier_rooted", "modifier_disable_healing"}
        for _, modifier in ipairs(modifiers) do
            winningHero:AddNewModifier(winningHero, nil, modifier, {duration = self.endduration})
        end

        winningHero:StartGesture(ACT_DOTA_VICTORY)
        self:MonitorUnitsStatus()
        self:gradual_slow_down(losingHero:GetOrigin(), winningHero:GetOrigin())
        RotateHero(winningHero)
        EmitSoundOn("Hero_LegionCommander.Duel.Victory", winningHero)

        -- 创建粒子效果
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, winningHero)
        ParticleManager:SetParticleControl(particle, 0, winningHero:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)

        local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, winningHero)
        ParticleManager:SetParticleControl(particle1, 0, winningHero:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle1)

        -- 结束决斗并更新UI
        hero_duel.EndDuel = true
        CustomGameEventManager:Send_ServerToAllClients("update_score", {["剩余时间"] = formattedTime})
        print("剩余时间", formattedTime)
        
    -- end)
end