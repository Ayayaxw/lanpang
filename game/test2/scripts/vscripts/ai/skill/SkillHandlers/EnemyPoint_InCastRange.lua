function CommonAI:HandleEnemyPoint_InCastRange(entity,target,abilityInfo,targetInfo)
    self:log(string.format("在castrange施法范围内，准备对敌人脚底下施放技能"))

    -- 统一变量定义
    local entityPos = entity:GetOrigin()
    local entityAbsPos = entity:GetAbsOrigin()
    local targetPos = targetInfo.targetPos
    local targetDirection = targetInfo.targetDirection
    local castRange = abilityInfo.castRange
    local aoeRadius = abilityInfo.aoeRadius
    local heroName = entity:GetUnitName()
    local targetName = target.GetUnitName and target:GetUnitName() or "未知单位"
    
    -- 施法相关变量
    local castPosition = nil
    local skillCasted = false
    local isVectorSkill = false
    local vectorStartPoint = nil
    local vectorEndPoint = nil

    local logMessage = ""

    if abilityInfo.abilityName == "pangolier_swashbuckle" then
        local targetEntityPos = self.target:GetOrigin()
        local directionToTarget = (targetEntityPos - entityPos):Normalized()
        local distanceToTarget = (targetEntityPos - entityPos):Length2D()
        
        local startPoint
        if distanceToTarget > 200 then
            startPoint = targetEntityPos - directionToTarget * 200
        else
            startPoint = targetEntityPos + directionToTarget * 200
        end
        
        vectorStartPoint = startPoint
        vectorEndPoint = targetPos
        isVectorSkill = true
        skillCasted = true


    elseif abilityInfo.abilityName == "tusk_ice_shards" then
        print("敌人的位置" .. tostring(targetPos))
        castPosition = targetPos + targetDirection * 100
        print("新的目标位置" .. tostring(castPosition))
        skillCasted = true

    elseif abilityInfo.abilityName == "lion_impale" then
        castPosition = entityPos + targetDirection * 100
        skillCasted = true

    elseif abilityInfo.abilityName == "tidehunter_gush" then
        castPosition = entityPos + targetDirection * 80
        skillCasted = true
        
    elseif abilityInfo.abilityName == "mirana_leap" and self:containsStrategy(self.hero_strategy, "有人贴脸就跳") then
        self.voidSpiritCastCount = (self.voidSpiritCastCount or 0) + 1
        local directionToTarget = (targetPos - entityAbsPos):Normalized()
        local startPoint = entityAbsPos + directionToTarget * castRange
        
        self:log("开始点: " .. tostring(startPoint))
        
        vectorStartPoint = startPoint
        vectorEndPoint = targetPos
        isVectorSkill = true
        skillCasted = true

    elseif abilityInfo.abilityName == "magnataur_skewer" then
        local directionToTarget = (targetPos - entityAbsPos):Normalized()
        castPosition = entityAbsPos + directionToTarget * castRange
        skillCasted = true

    elseif abilityInfo.abilityName == "juggernaut_healing_ward" then
        castPosition = entityPos + targetDirection * 350
        skillCasted = true

    elseif abilityInfo.abilityName == "morphling_waveform" then
        if self:containsStrategy(self.hero_strategy, "无缝波") then
            if not self.lastCastOrigin then
                self.lastCastOrigin = entityPos
                self.isLastCastSpecial = false
            end

            if targetInfo.distance < 500 and not self.isLastCastSpecial then
                local currentPosition = entityPos
                local distanceToLastCast = (currentPosition - self.lastCastOrigin):Length()
                
                if distanceToLastCast < 500 then
                    local direction = (self.lastCastOrigin - currentPosition):Normalized()
                    local newCastDistance = 500
                    castPosition = currentPosition + direction * newCastDistance
                else
                    castPosition = self.lastCastOrigin
                end
                
                self.isLastCastSpecial = true
            else
                castPosition = entityPos + targetDirection * castRange
                self.isLastCastSpecial = false
            end

            self.lastCastOrigin = entityPos
            skillCasted = true
            
        elseif self:containsStrategy(self.hero_strategy, "波最远") then
            local direction = (targetInfo.target:GetOrigin() - entityPos):Normalized()
            castPosition = entityPos + direction * castRange
            skillCasted = true

        elseif self:containsStrategy(self.hero_strategy, "圆形波") then
            if not self.circleCenter then
                self.circleCenter = entityPos
                self.currentAngle = 0
                self.circleRadius = 500
            end

            local heroPos = entityPos
            local toCenter = self.circleCenter - heroPos
            local distanceToCenter = toCenter:Length2D()

            local tangentAngle
            if distanceToCenter <= self.circleRadius then
                tangentAngle = self.currentAngle
            else
                local angleToCenter = math.atan2(toCenter.y, toCenter.x)
                local tangentOffset = math.asin(self.circleRadius / distanceToCenter)
                tangentAngle = angleToCenter + tangentOffset
            end

            local castDirection = Vector(math.cos(tangentAngle), math.sin(tangentAngle), 0)
            castPosition = entityPos + castDirection * castRange
            self.currentAngle = tangentAngle + math.pi / 6
            skillCasted = true

        elseif self:containsStrategy(self.hero_strategy, "反复横跳波") then
            local centerPoint = Vector(150, 150, 128)
            local heroPos = entityPos
            local radius = castRange * 0.5
            
            local currentAngle = math.atan2(heroPos.y - centerPoint.y, heroPos.x - centerPoint.x)
            local distToCenter = math.sqrt(
                (heroPos.x - centerPoint.x) * (heroPos.x - centerPoint.x) + 
                (heroPos.y - centerPoint.y) * (heroPos.y - centerPoint.y)
            )
            
            local targetAngle = currentAngle + math.rad(5)
            
            if distToCenter < radius * 0.1 then
                castPosition = Vector(
                    centerPoint.x + radius * math.cos(targetAngle),
                    centerPoint.y + radius * math.sin(targetAngle),
                    heroPos.z
                )
            else
                local currentSide = (heroPos.x - centerPoint.x) * math.cos(targetAngle) + 
                                  (heroPos.y - centerPoint.y) * math.sin(targetAngle)
                
                local sideMultiplier = currentSide > 0 and -radius or radius
                castPosition = Vector(
                    centerPoint.x + sideMultiplier * math.cos(targetAngle),
                    centerPoint.y + sideMultiplier * math.sin(targetAngle),
                    heroPos.z
                )
            end
            skillCasted = true

        else
            local direction = (targetInfo.target:GetOrigin() - entityPos):Normalized()
            local distance = (targetInfo.target:GetOrigin() - entityPos):Length2D()
            local attackRange = entity:Script_GetAttackRange()
            local behindTargetPos = targetInfo.target:GetOrigin() + direction * attackRange
            local distanceToBehindPos = (behindTargetPos - entityPos):Length2D()
            
            if distanceToBehindPos <= castRange then
                castPosition = behindTargetPos
            else
                castPosition = entityPos + direction * castRange
            end
            skillCasted = true
        end

    elseif abilityInfo.abilityName == "monkey_king_boundless_strike" then
        local directionToTarget = (targetPos - entityPos):Normalized()
        castPosition = entityPos + directionToTarget * 350
        skillCasted = true

    elseif abilityInfo.abilityName == "muerta_the_calling" then
        if self:containsStrategy(self.hero_strategy, "直线封锁") then
            local casterOrigin = entityPos
            self:log("Castrange范围内直线封锁模式")
            local enemyToCasterDirection = (casterOrigin - targetPos):Normalized()
            local pointOnLine = targetPos - enemyToCasterDirection * 470
            
            local perpendicular1 = Vector(-enemyToCasterDirection.y, enemyToCasterDirection.x, 0):Normalized()
            local perpendicular2 = Vector(enemyToCasterDirection.y, -enemyToCasterDirection.x, 0):Normalized()
            
            local possiblePosition1 = pointOnLine + perpendicular1 * 235
            local possiblePosition2 = pointOnLine + perpendicular2 * 235
            
            local heroForward = entity:GetForwardVector()
            local direction1 = (possiblePosition1 - casterOrigin):Normalized()
            local direction2 = (possiblePosition2 - casterOrigin):Normalized()
            
            local dot1 = heroForward:Dot(direction1)
            local dot2 = heroForward:Dot(direction2)
            
            local finalCastPosition
            if dot1 > dot2 then
                finalCastPosition = possiblePosition1
                self:log("选择垂线1上的施法点")
            else
                finalCastPosition = possiblePosition2
                self:log("选择垂线2上的施法点")
            end
            
            local distanceToCast = (finalCastPosition - casterOrigin):Length2D()
            if distanceToCast > castRange then
                finalCastPosition = casterOrigin + (finalCastPosition - casterOrigin):Normalized() * castRange
                self:log("施法位置超出范围，使用最大施法距离")
            end
            
            self:log(string.format("直线封锁模式: 目标距离: %.2f, 施法距离: %.2f", 
                (targetPos - casterOrigin):Length2D(), (finalCastPosition - casterOrigin):Length2D()))
            self:log(string.format("直线上点位置: %s", tostring(pointOnLine)))
            self:log(string.format("最终施法位置: %s", tostring(finalCastPosition)))
            
            castPosition = finalCastPosition
            skillCasted = true
        else
            local casterOrigin = entityPos
            local targetDirection = (targetPos - casterOrigin):Normalized()
            
            local validAngles = {30, 90, 150, 210, 270, 330}
            local targetAngle = math.deg(math.atan2(targetDirection.y, targetDirection.x))
            if targetAngle < 0 then targetAngle = targetAngle + 360 end
            
            local closestAngle = validAngles[1]
            local minDiff = 360
            for _, angle in ipairs(validAngles) do
                local diff = math.abs(targetAngle - angle)
                if diff > 180 then diff = 360 - diff end
                if diff < minDiff then
                    minDiff = diff
                    closestAngle = angle
                end
            end
        
            local adjustedDirection = Vector(math.cos(math.rad(closestAngle)), math.sin(math.rad(closestAngle)), 0):Normalized()
            local distanceToTarget = (targetPos - casterOrigin):Length2D()
            local idealCastPosition = targetPos - adjustedDirection * aoeRadius
            local idealCastDistance = (idealCastPosition - casterOrigin):Length2D()
            
            local finalCastPosition
            if idealCastDistance <= castRange then
                finalCastPosition = idealCastPosition
                self:log("理想施法位置在施法范围内")
            else
                finalCastPosition = casterOrigin + (idealCastPosition - casterOrigin):Normalized() * castRange
                self:log("理想施法位置超出范围，使用最大施法距离")
            end
        
            self:log(string.format("准备施放技能: %s，目标距离: %.2f，理想施法距离: %.2f，最终施法距离: %.2f，作用范围: %.2f", 
                abilityInfo.abilityName, distanceToTarget, idealCastDistance, (finalCastPosition - casterOrigin):Length2D(), aoeRadius))
            self:log(string.format("原始目标方向角度: %.2f，调整后角度: %.2f", targetAngle, closestAngle))
            self:log(string.format("施法位置: %s", tostring(finalCastPosition)))
        
            castPosition = finalCastPosition
            skillCasted = true
        end

    elseif abilityInfo.abilityName == "batrider_flamebreak" then
        if targetInfo.distance <= aoeRadius then
            castPosition = entityPos
            self:log("目标距离小于作用范围，在自身位置施放火焰切割")
        else
            if self:containsStrategy(self.hero_strategy, "弹开") then
                castPosition = targetPos - targetDirection * aoeRadius
                self:log("使用弹开策略，向后施放火焰切割")
            else
                castPosition = targetPos + targetDirection * 200
                self:log("使用普通策略，向前施放火焰切割")
            end
        end
    
        self:log(string.format("在施法距离+作用范围内，1准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", 
            abilityInfo.abilityName, targetInfo.distance, castRange, aoeRadius))
        self:log(string.format("施法位置: %s", tostring(castPosition)))
        skillCasted = true
        
    elseif abilityInfo.abilityName == "shadow_demon_shadow_poison" then
        castPosition = entityPos + targetDirection * 300
        skillCasted = true

    elseif abilityInfo.abilityName == "dark_willow_bramble_maze" then
        if targetInfo.distance < 250 then
            castPosition = targetPos + targetDirection * 250
        else
            castPosition = targetPos - targetDirection * 200
        end
        skillCasted = true

    elseif abilityInfo.abilityName == "skywrath_mage_mystic_flare" and entity:HasScepter() then
        self:log("天怒双大")
        castPosition = targetPos - targetDirection * 170
        skillCasted = true

    elseif abilityInfo.abilityName == "zuus_cloud" and self:containsStrategy(self.global_strategy, "防守策略") then
        castPosition = targetPos - targetDirection * aoeRadius
        skillCasted = true

    elseif abilityInfo.abilityName == "zuus_cloud" and self:containsStrategy(self.hero_strategy, "对自己放雷云") then
        castPosition = entityPos
        skillCasted = true

    elseif abilityInfo.abilityName == "void_spirit_aether_remnant" then
        local startPoint
        if targetInfo.distance > aoeRadius then
            startPoint = targetPos - targetDirection * aoeRadius
        else
            startPoint = entityPos + targetDirection * 10
        end
    
        self:log("开始点: " .. tostring(startPoint))
        self:log("结束点: " .. tostring(targetPos))
    
        vectorStartPoint = startPoint
        vectorEndPoint = targetPos
        isVectorSkill = true
        skillCasted = true

    elseif abilityInfo.abilityName == "luna_eclipse" then
        if self:containsStrategy(self.hero_strategy, "大招封走位") then
            castPosition = targetPos - targetDirection * aoeRadius
        else
            castPosition = targetPos
            self:log(string.format("找到目标 %s 准备施放技能 %s", targetName, abilityInfo.abilityName))
            self:log(string.format("目标地点是 %s ", targetPos))
        end
        skillCasted = true

    elseif abilityInfo.abilityName == "sniper_shrapnel" then
        if self:containsStrategy(self.global_strategy, "技能封走位") then
            castPosition = targetPos - targetDirection * aoeRadius
        else
            castPosition = targetPos
            self:log(string.format("目标是 %s ", target:GetUnitName()))
            self:log(string.format("目标地点是 %s ", targetPos))
        end
        skillCasted = true

    elseif abilityInfo.abilityName == "snapfire_mortimer_kisses" then
        castPosition = targetPos - targetDirection * aoeRadius
        skillCasted = true

    elseif abilityInfo.abilityName == "queenofpain_blink" then
        castPosition = targetPos - (targetDirection * 200)
        skillCasted = true

    elseif abilityInfo.abilityName == "bloodseeker_blood_bath" then
        if self:containsStrategy(self.hero_strategy, "血祭封走位") then
            castPosition = targetPos - targetDirection * aoeRadius
        else
            castPosition = targetPos
            self:log(string.format("目标是 %s ", target:GetUnitName()))
            self:log(string.format("目标地点是 %s ", targetPos))
        end
        skillCasted = true

    elseif abilityInfo.abilityName == "earth_spirit_stone_caller" then
        if self.earthSpiritStonePosition == "脚底下" then
            castPosition = entityAbsPos + targetDirection * 50
        elseif self.earthSpiritStonePosition == "敌人身后" then
            castPosition = targetPos
        end
    
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("石头放置位置是 %s ", castPosition))
        skillCasted = true

    elseif abilityInfo.abilityName == "puck_waning_rift" and self:containsStrategy(self.hero_strategy, "飞身后") then
        local direction = (targetPos - entityAbsPos):Normalized()
        local distanceToTarget = (targetPos - entityAbsPos):Length2D()
        
        if distanceToTarget <= 300 then
            castPosition = entityAbsPos + direction * castRange
        else
            castPosition = entityAbsPos
        end
    
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("施法位置是 %s ", castPosition))
        self:log(string.format("与目标距离 %s ", distanceToTarget))
        skillCasted = true


    elseif abilityInfo.abilityName == "arc_warden_tempest_double" and self:containsStrategy(self.hero_strategy, "最大距离分身") then
        local direction = (targetPos - entityAbsPos):Normalized()
        local distanceToTarget = (targetPos - entityAbsPos):Length2D()
        

        castPosition = entityAbsPos + direction * castRange

    
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("施法位置是 %s ", castPosition))
        self:log(string.format("与目标距离 %s ", distanceToTarget))
        skillCasted = true



    elseif abilityInfo.abilityName == "earthshaker_fissure" and self:containsStrategy(self.hero_strategy, "朝面前沟壑") then
        local forward = entity:GetForwardVector()
        castPosition = entityPos + forward * 100
        skillCasted = true

        

    elseif abilityInfo.abilityName == "faceless_void_time_walk" then
        local directionToEnemy = (targetPos - entityPos):Normalized()
        local behindEnemyPos = targetPos + directionToEnemy * aoeRadius
        local distanceToBehindPos = (behindEnemyPos - entityPos):Length2D()
        
        if distanceToBehindPos <= castRange then
            castPosition = behindEnemyPos
        else
            castPosition = targetPos
        end
        skillCasted = true

    elseif abilityInfo.abilityName == "storm_spirit_ball_lightning" then
        local distanceToTarget = (targetPos - entityAbsPos):Length2D()
        local vortexAbility = entity:FindAbilityByName("storm_spirit_electric_vortex")
        local vortexIsReady = vortexAbility and (vortexAbility:IsFullyCastable() or not self:NeedsModifierRefresh(target, {"modifier_storm_spirit_electric_vortex_pull"}, 1))

        if self:containsStrategy(self.hero_strategy, "仅电子涡流就绪时出击") and vortexIsReady then
            castPosition = targetPos + targetDirection * 300

        elseif self:containsStrategy(self.hero_strategy, "折叠飞") then
            local heroPosition = entityPos
            local targetPosition = target:GetOrigin()
            local distanceToTarget = (targetPosition - heroPosition):Length2D()

            -- 从全局记录表中获取上次施法位置
            local lastCastPos = self:GetLastCastPositionFromGlobal(entity, "storm_spirit_ball_lightning")
            if lastCastPos then
                local direction = (targetPosition - lastCastPos):Normalized()
                -- 如果当前和敌人的距离超过800，只乘以300
                if distanceToTarget > 500 then
                    castPosition = targetPosition + direction * 300
                    self:log(string.format("[FOLDING_FLY] 距离超过800(%.2f)，使用300倍数: (%.2f, %.2f, %.2f)", distanceToTarget, lastCastPos.x, lastCastPos.y, lastCastPos.z))
                else
                    castPosition = targetPosition + direction * 1500
                    self:log(string.format("[FOLDING_FLY] 距离在800内(%.2f)，使用1500倍数: (%.2f, %.2f, %.2f)", distanceToTarget, lastCastPos.x, lastCastPos.y, lastCastPos.z))
                end
            else
                local direction = (targetPosition - heroPosition):Normalized()
                castPosition = targetPosition + direction * 300
                self:log("[FOLDING_FLY] 未找到全局记录的施法位置，使用英雄当前位置")
            end
            self:log("[FOLDING_FLY] 原始目标位置:", targetPosition)
            self:log("[FOLDING_FLY] 最终施法位置:", castPosition)
        
        elseif self:containsStrategy(self.hero_strategy, "飞脸前") and distanceToTarget >= 300 then
            castPosition = targetPos - targetDirection * 300
            self:log(string.format("找到目标 %s 准备施放技能 %s", targetName, abilityInfo.abilityName))
            self:log(string.format("目标地点是 %s ", targetPos))

        else
            local distance
            if self:containsStrategy(self.hero_strategy, "球状闪电保持距离") then
                distance = entity:Script_GetAttackRange() + 1000
                self:log(string.format("球状闪电保持距离策略，距离: %s",distance))
            else
                distance = entity:Script_GetAttackRange() 
                self:log(string.format("默认策略，距离: %s",distance))
            end

            self:log(string.format("风暴之灵的攻击距离: %s", distance))
            
            local vortexAbility = entity:FindAbilityByName("storm_spirit_electric_vortex")
            if vortexAbility and vortexAbility:IsFullyCastable() then
                distance = 200
                self:log("涡流技能CD准备就绪，设置distance为50")
            end

            castPosition = targetPos + targetDirection * distance
            self:log(string.format("在施法距离+作用范围内，2准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, castRange, aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))
        end
        skillCasted = true
        
    elseif abilityInfo.abilityName == "ember_spirit_fire_remnant" then
        local safePoints = {
            Vector(-1046.34, -2568.91, 128.00),
            Vector(-1052.44, -3368.61, 128.00),
            Vector(1289.64, -3362.54, 128.00),
            Vector(1299.61, -2518.67, 128.00)
        }
    
        if self:containsStrategy(self.hero_strategy, "躲避模式") or self:containsStrategy(self.hero_strategy, "躲避模式1000码") then
            local myPos = entityAbsPos
            
            local farthestPoint = safePoints[1]
            local maxDistance = (farthestPoint - myPos):Length2D()
    
            for i = 2, #safePoints do
                local distance = (safePoints[i] - myPos):Length2D()
                if distance > maxDistance then
                    maxDistance = distance
                    farthestPoint = safePoints[i]
                end
            end
    
            castPosition = farthestPoint
            self:log("躲避模式：释放技能到离自己最远安全点")
        else
            if entity:HasModifier("modifier_ember_spirit_fire_remnant") then
                local remnants = FindUnitsInRadius(
                    entity:GetTeamNumber(),
                    entityAbsPos,
                    nil,
                    3000,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL, 
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_FARTHEST,
                    false
                )

                local hasRemnant = false
                for _, remnant in pairs(remnants) do
                    if remnant:GetUnitName() == "npc_dota_ember_spirit_remnant" then
                        hasRemnant = true
                        break
                    end
                end
                if hasRemnant then
                    print("搜到残焰了")
                    print("asdqwe搜到残焰了")
                end
                -- 从全局记录表中获取上次施法位置
                local lastCastPos = self:GetLastCastPositionFromGlobal(entity, "ember_spirit_fire_remnant")
                if hasRemnant and lastCastPos then
                    local targetX = targetPos.x
                    local targetY = targetPos.y
                    local targetZ = targetPos.z
                    
                    local lastX = lastCastPos.x
                    local lastY = lastCastPos.y
                    local lastZ = lastCastPos.z
                    
                    print("asdqwe目标坐标", targetX, targetY, targetZ)
                    print("asdqwe上次施法坐标（从全局记录获取）", lastX, lastY, lastZ)
                    
                    local dx = targetX - lastX
                    local dy = targetY - lastY
                    local dz = targetZ - lastZ
                    
                    local length = math.sqrt(dx*dx + dy*dy + dz*dz)
                    local dirX = dx / length
                    local dirY = dy / length
                    local dirZ = dz / length
                    
                    print("asdqwe方向分量", dirX, dirY, dirZ)
                    
                    local newX = targetX + (dirX * 500)
                    local newY = targetY + (dirY * 500)
                    local newZ = targetZ + (dirZ * 500)
                    
                    print("asdqwe新计算坐标", newX, newY, newZ)
                    
                    castPosition = Vector(newX, newY, newZ)
                else
                    castPosition = targetPos + targetDirection * 500
                    self:log("残焰状态但使用默认位置：释放技能到敌人背后500码")
                    print("asdqwe没有残焰或者位置的施法")
                end
            else
                castPosition = targetPos + targetDirection * 500
                self:log("普通模式：释放技能到敌人背后500码")
                print("asdqwe不在飞魂状态的施法")
            end

            -- 不再需要手动设置 lastTryCastPosition，全局监听器会自动记录
            print("asdqwe尝试施法的位置", castPosition)
        end
    
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("目标地点是 %s ", castPosition))
        skillCasted = true

    elseif abilityInfo.abilityName == "invoker_tornado" then
        if self:containsStrategy(self.hero_strategy, "帕金森") then
            if self.target:HasModifier("modifier_invoker_tornado") and self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 1) then
                castPosition = targetPos
                skillCasted = true
            else
                local basePosition = entityPos + targetDirection * 500
                
                if not self.lastOffsetX then self.lastOffsetX = 0 end
                if not self.lastOffsetY then self.lastOffsetY = 0 end
                
                local randomOffsetX, randomOffsetY
                
                if self.lastOffsetX <= 0 then
                    randomOffsetX = RandomFloat(0, 200)
                else
                    randomOffsetX = RandomFloat(-200, 0)
                end
                
                if self.lastOffsetY <= 0 then
                    randomOffsetY = RandomFloat(0, 200)
                else
                    randomOffsetY = RandomFloat(-200, 0)
                end
                
                castPosition = Vector(
                    basePosition.x + randomOffsetX,
                    basePosition.y + randomOffsetY,
                    basePosition.z
                )
            
                self.lastOffsetX = randomOffsetX
                self.lastOffsetY = randomOffsetY
                skillCasted = true
            end
        else
            local enemies = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entityPos,
                nil,
                castRange,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_CLOSEST,
                false
            )
        
            for _, enemy in pairs(enemies) do
                if self:NeedsModifierRefresh(enemy, {"modifier_invoker_tornado"}, 1) then
                    castPosition = enemy:GetAbsOrigin()
                    skillCasted = true
                    break
                end
            end
        
            if not skillCasted then
                castPosition = self.target:GetAbsOrigin()
                skillCasted = true
            end
        end
    
    else
        -- 定义需要对着目标释放的技能表（即使在AOE范围内也不对脚下释放）
        local targetCastAbilities = {
            ["drow_ranger_multishot"] = true,
            ["warlock_rain_of_chaos"] = true,
            ["warlock_upheaval"] = true,
            ["lich_ice_spire"] = true,
            ["monkey_king_wukongs_command"] = true,
            ["phoenix_sun_ray"] = true,
            ["storm_spirit_ball_lightning"] = true,
            ["dawnbreaker_celestial_hammers"] = true,
        }
    
        -- 定义始终在脚下释放的技能表
        local selfCastAbilities = {
            ["dragon_knight_breathe_fire"] = true
        }
    
        -- 定义需要预判的技能表
        local predictCastAbilities = {
            ["invoker_sun_strike"] = true
        }
    
        local distance = (targetPos - entityAbsPos):Length2D()
        
        -- 处理始终在脚下释放的技能
        if selfCastAbilities[abilityInfo.abilityName] then
            local direction = (targetPos - entityAbsPos):Normalized()
            castPosition = entityAbsPos + direction * 100
            self:log(string.format("技能 %s 在脚下1码处释放", abilityInfo.abilityName))
            skillCasted = true
        
        -- 处理AOE范围内且处于防守策略的情况
        elseif distance <= aoeRadius and 
               self:containsStrategy(self.global_strategy, "防守策略") and
               not targetCastAbilities[abilityInfo.abilityName] then
            local direction = (targetPos - entityAbsPos):Normalized()
            castPosition = entityAbsPos + direction * 100
            self:log(string.format("目标 %s 在AoE范围内(%d)，在前方1码处释放技能 %s", 
                targetName, aoeRadius, abilityInfo.abilityName))
            skillCasted = true
        
        -- 处理需要预判的技能
        elseif predictCastAbilities[abilityInfo.abilityName] then
            local targetForward = target:GetForwardVector()
            local predictedPos = targetPos + targetForward * aoeRadius
            local distanceToPredict = (predictedPos - entityAbsPos):Length2D()
            local directionToPredict = (predictedPos - entityAbsPos):Normalized()
            
            if distanceToPredict <= castRange and 
               entity:GetForwardVector():Dot(directionToPredict) > 0 then
                castPosition = predictedPos
                self:log(string.format("对目标 %s 预判施放技能 %s，位置 %s", 
                    targetName, abilityInfo.abilityName, tostring(predictedPos)))
            else
                castPosition = targetPos
                self:log(string.format("预判位置不合适，对目标 %s 直接施放技能 %s", 
                    targetName, abilityInfo.abilityName))
            end
            skillCasted = true

        elseif bit.band(abilityInfo.abilityBehavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
            local maxCastDistance = castRange + aoeRadius
            local targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
            targetFlags = bit.bor(targetFlags, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS)
        
            local enemies = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entityAbsPos,
                nil,
                maxCastDistance,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                targetFlags,
                FIND_ANY_ORDER,
                false
            )
        
            local farthestDist = 0
            local farthestEnemy = nil
            for _, enemy in ipairs(enemies) do
                local dist = (enemy:GetOrigin() - entityAbsPos):Length2D()
                if dist > farthestDist then
                    farthestDist = dist
                    farthestEnemy = enemy
                end
            end
        
            vectorStartPoint = targetPos
            vectorEndPoint = vectorStartPoint
            if farthestEnemy then
                local direction = (farthestEnemy:GetOrigin() - entityAbsPos):Normalized()
                vectorEndPoint = entityAbsPos + direction * math.min(farthestDist, maxCastDistance)
            end
        
            self:log(string.format("矢量施法：从 %s 到 %s (最大距离%d)", 
                tostring(vectorStartPoint), 
                tostring(vectorEndPoint),
                maxCastDistance))
                
            isVectorSkill = true
            skillCasted = true

        -- 其他情况直接对目标位置释放
        else
            castPosition = targetPos
            self:log(string.format("对目标 %s 施放技能 %s，位置 %s", 
                targetName, abilityInfo.abilityName, tostring(targetPos)))
            skillCasted = true
        end
    end

    -- 统一处理技能施放
    if skillCasted then
        if isVectorSkill and vectorStartPoint and vectorEndPoint then
            self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, vectorStartPoint, vectorEndPoint)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, vectorStartPoint, abilityInfo.castPoint)
        elseif castPosition then
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        end
        
        -- 统一记录施法信息
        self:log(string.format("技能 %s 已施放，目标: %s", abilityInfo.abilityName, targetName))
        if castPosition then
            self:log(string.format("施法位置: %s", tostring(castPosition)))
        end
        if isVectorSkill then
            self:log(string.format("矢量技能 - 起点: %s, 终点: %s", tostring(vectorStartPoint), tostring(vectorEndPoint)))
        end
        
        return true
    end

    return false
end




function CommonAI:calculateNextBallLightningCastTime(entity, target, ballLightningSkill, currentPosition, expectedFlightTime,castPosition)
    local nextTargetPosition = target:GetOrigin()
    local nextTargetDirection = (nextTargetPosition - currentPosition):Normalized()
    local nextCastPosition = nextTargetPosition
    
    local expectedTurnTime = self:calculateTurnTime(entity, nextCastPosition,castPosition)
    local expectedCastPoint = ballLightningSkill:GetCastPoint()
    
    -- 总准备时间应该是转身时间加上施法前摇时间
    local totalPreparationTime = expectedTurnTime + expectedCastPoint
    
    self:log(string.format("[FOLDING_FLY] 下一次球状闪电施法总准备时间: %.3f 秒 (转身: %.3f 秒, 施法前摇: %.3f 秒)", 
                           totalPreparationTime, expectedTurnTime, expectedCastPoint))
    
    -- 返回总准备时间
    return totalPreparationTime + 0.05
end

function CommonAI:getBallLightningSpeed(ability)
    local kv = ability:GetAbilityKeyValues()
    local speed = 0
    local currentLevel = ability:GetLevel()

    self:log("[FOLDING_FLY] 进入 getBallLightningSpeed 函数")
    self:log(string.format("[FOLDING_FLY] 当前技能等级: %d", currentLevel))

    if kv.AbilityValues then
        self:log("[FOLDING_FLY] 在 KV 中找到 AbilityValues")
        if kv.AbilityValues.ball_lightning_move_speed then
            local speedValue = kv.AbilityValues.ball_lightning_move_speed
            self:log(string.format("[FOLDING_FLY] 找到 ball_lightning_move_speed，类型: %s", type(speedValue)))
            if type(speedValue) == "string" then
                self:log(string.format("[FOLDING_FLY] ball_lightning_move_speed 是字符串: %s", speedValue))
                -- 分割字符串为数字数组
                local speeds = {}
                for s in speedValue:gmatch("%S+") do
                    table.insert(speeds, tonumber(s))
                end
                self:log(string.format("[FOLDING_FLY] 分割后的速度数组: %s", table.concat(speeds, ", ")))
                speed = speeds[currentLevel] or speeds[#speeds]
            elseif type(speedValue) == "table" then
                self:log("[FOLDING_FLY] ball_lightning_move_speed 是一个表")
                for k, v in pairs(speedValue) do
                    self:log(string.format("[FOLDING_FLY] 等级 %s, 速度 %s", tostring(k), tostring(v)))
                end
                speed = tonumber(speedValue[currentLevel] or speedValue[#speedValue])
            else
                speed = tonumber(speedValue)
            end
            self:log(string.format("[FOLDING_FLY] 选择的速度: %s", tostring(speed)))
        else
            self:log("[FOLDING_FLY] 未找到 ball_lightning_move_speed，检查特殊值键")
        end
    else
        self:log("[FOLDING_FLY] 在 KV 中未找到 AbilityValues")
    end

    if not speed or speed == 0 then
        self:log("[FOLDING_FLY] 警告: ball_lightning_move_speed 值无效，使用默认值")
        speed = 1400  -- 使用一个默认值，这里使用最低等级的速度
    end

    self:log(string.format("[FOLDING_FLY] 最终返回的速度值: %s", tostring(speed)))
    return speed
end