function CommonAI:HandleEnemyPoint_InAoeRange(entity,target,abilityInfo,targetInfo)

    -- 添加新函数：检查目标是否有可驱散的增益BUFF
    function CommonAI:HasDispellableBuff(target)
        local hasPurgableBuff = false
        -- 获取目标身上的所有modifier
        local modifiers = target:GetModifiers()
        
        if modifiers then
            for _, modifier in pairs(modifiers) do
                if modifier and not modifier:IsNull() then
                    -- 如果是增益效果(非减益)且可被驱散
                    if not modifier:IsDebuff() and modifier:IsPurgable() then
                        self:log(string.format("目标拥有可驱散增益: %s", modifier:GetName()))
                        hasPurgableBuff = true
                        break
                    end
                end
            end
        end
        
        return hasPurgableBuff
    end

    if abilityInfo.abilityName == "XX" then

        local newTargetPos = entity:GetOrigin() - targetInfo.targetDirection * 350
    
        -- 施放技能到新的目标位置
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)

    elseif abilityInfo.abilityName == "ancient_apparition_cold_feet" then
        -- 计算方向向量并归一化
        if not target:HasModifier("modifier_cold_feet") then
            local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange

            -- 打印施法信息
            self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))
    
            -- 计算当前单位与施法位置的距离
            local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
            self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
    
            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)

        else
            -- 搜索施法距离范围内其他没有modifier_cold_feet的英雄单位
            local newTarget = nil
            local closestDistance = abilityInfo.castRange + abilityInfo.AoeRange
    
            local heroes = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                closestDistance,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                0,
                FIND_CLOSEST,
                false
            )
    
            for _, hero in pairs(heroes) do
                if hero:IsHero() and not hero:IsSummoned() and not hero:HasModifier("modifier_cold_feet") then
                    local distance = (hero:GetOrigin() - entity:GetOrigin()):Length2D()
                    if distance < closestDistance then
                        newTarget = hero
                        closestDistance = distance
                    end
                end
            end
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange

                -- 打印施法信息
                self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
                self:log(string.format("施法位置: %s", tostring(castPosition)))
        
                -- 计算当前单位与施法位置的距离
                local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
                self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
        
                -- 施放技能
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                
            else
                -- 没有找到合适的目标，禁用技能
                local heroName = entity:GetUnitName()
                
                -- 检查 self.disabledSkills 是否存在且为表格
                if type(self.disabledSkills) ~= "table" then
                    self:log("警告: self.disabledSkills 不是表格")
                    self.disabledSkills = {}
                end
                -- 将技能添加到禁用列表
                if not self.disabledSkills[heroName] then
                    self.disabledSkills[heroName] = {}
                end
                table.insert(self.disabledSkills[heroName], "ancient_apparition_cold_feet")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end



    elseif abilityInfo.abilityName == "puck_waning_rift" and self:containsStrategy(self.hero_strategy, "飞身后") then
        local entityPos = entity:GetAbsOrigin()
        local targetPos = targetInfo.targetPos
        local direction = (targetPos - entityPos):Normalized()
        local distanceToTarget = (targetPos - entityPos):Length2D()
        local castPosition
        
        -- 获取技能数据
        local castRange = abilityInfo.castRange
        local aoeRadius = abilityInfo.aoeRadius
        
        -- 计算需要位移的距离：目标距离减去想要保持的距离(aoeRadius)
        local moveDistance = distanceToTarget - aoeRadius
        
        -- 确保位移距离不超过施法距离
        moveDistance = math.min(moveDistance, castRange-10)
        
        -- 朝着敌人方向位移，保持aoeRadius的距离
        castPosition = entityPos + direction * moveDistance
    
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("施法位置是 %s ", castPosition))
        self:log(string.format("与目标距离 %s ", distanceToTarget))
        self:log(string.format("位移距离 %s ", moveDistance))
    
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true
    elseif abilityInfo.abilityName == "tusk_ice_shards" then
        -- 计算新的目标位置，沿方向向量移动200码
        print("敌人的位置" .. tostring(targetInfo.targetPos))
        local newTargetPos = targetInfo.targetPos + targetInfo.targetDirection * 80
        print("新的目标位置" .. tostring(newTargetPos))
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "jakiro_macropyre" then
        -- 计算新的目标位置，沿方向向量移动200码
        if self:containsStrategy(self.hero_strategy, "斜放大招") then
            local entityPos = entity:GetAbsOrigin()
            local targetPos = targetInfo.targetPos
            local direction = (targetPos - entityPos):Normalized()
            local distance = (targetPos - entityPos):Length2D()
            
            -- 圆的参数：以敌人为圆心，半径为250
            local circleCenter = targetPos
            local circleRadius = 220
            
            -- 计算切线
            local castPosition
            
            -- 如果施法者在圆内，无法形成切线，直接朝目标方向施法
            if distance <= circleRadius then
                castPosition = entityPos + direction * abilityInfo.castRange
                self:log("施法者在圆内，直接朝目标方向施法")
            else
                -- 计算从施法者到圆心的单位向量
                local toCircleCenter = (circleCenter - entityPos):Normalized()
                
                -- 计算切线角度（勾股定理）
                local sinTheta = circleRadius / distance
                local cosTheta = math.sqrt(1 + sinTheta * sinTheta)
                
                -- 计算切线方向（顺时针旋转）
                local tangentDirection = Vector(
                    toCircleCenter.x * cosTheta - toCircleCenter.y * sinTheta,
                    toCircleCenter.x * sinTheta + toCircleCenter.y * cosTheta,
                    0
                ):Normalized()
                
                -- 沿切线方向在最大施法距离处施法
                castPosition = entityPos + tangentDirection * abilityInfo.castRange
                
                self:log(string.format("圆半径: %.2f, 到敌人距离: %.2f", circleRadius, distance))
                self:log(string.format("切线角度: sinθ=%.2f, cosθ=%.2f", sinTheta, cosTheta))
                self:log(string.format("切线方向: %s", tostring(tangentDirection)))
            end
            
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            self:log(string.format("斜放大招施法位置: %s", tostring(castPosition)))
            return true
        else
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  targetInfo.targetPos, abilityInfo.castPoint)
            return true
        end

    elseif abilityInfo.abilityName == "sniper_shrapnel" then
        -- 计算方向向量并归一化
        if self:containsStrategy(self.global_strategy, "技能封走位") then
            local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        else
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            self:log(string.format("目标是 %s ", target:GetUnitName()))
            self:log(string.format("目标地点是 %s ", targetInfo.targetPos))
    
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            return true     
        end
    elseif abilityInfo.abilityName == "muerta_the_calling" then
        if self:containsStrategy(self.hero_strategy, "直线封锁") then
            local targetOrigin = targetInfo.targetPos
            local casterOrigin = entity:GetOrigin()
            self:log("AOE范围内直线封锁模式")
            
            -- 从敌人到自己的方向向量（归一化）
            local enemyToCasterDirection = (casterOrigin - targetOrigin):Normalized()
            
            -- 找到距离敌人300码的点
            local pointOnLine = targetOrigin + enemyToCasterDirection * 470
            
            -- 计算垂直于当前直线的方向向量
            -- 垂直向量可以通过交换x和y坐标并取反其中一个来获得
            local perpendicular1 = Vector(-enemyToCasterDirection.y, enemyToCasterDirection.x, 0):Normalized()
            local perpendicular2 = Vector(enemyToCasterDirection.y, -enemyToCasterDirection.x, 0):Normalized()
            
            -- 在垂线上找到距离点240码的两个可能位置
            local possiblePosition1 = pointOnLine + perpendicular1 * 235
            local possiblePosition2 = pointOnLine + perpendicular2 * 235
            
            -- 获取英雄当前朝向
            local heroForward = entity:GetForwardVector()
            
            -- 计算英雄朝向与两个可能位置方向的点积（判断转身幅度）
            local direction1 = (possiblePosition1 - casterOrigin):Normalized()
            local direction2 = (possiblePosition2 - casterOrigin):Normalized()
            
            local dot1 = heroForward:Dot(direction1)
            local dot2 = heroForward:Dot(direction2)
            
            -- 选择转身幅度较小的点（点积越大，夹角越小）
            local finalCastPosition
            if dot1 > dot2 then
                finalCastPosition = possiblePosition1
                self:log("选择垂线1上的施法点")
            else
                finalCastPosition = possiblePosition2
                self:log("选择垂线2上的施法点")
            end
            
            -- 确保施法距离不超过最大施法距离
            local distanceToCast = (finalCastPosition - casterOrigin):Length2D()
            if distanceToCast > abilityInfo.castRange then
                finalCastPosition = casterOrigin + (finalCastPosition - casterOrigin):Normalized() * abilityInfo.castRange
                self:log("施法位置超出范围，使用最大施法距离")
            end
            
            -- 打印施法信息
            self:log(string.format("直线封锁模式: 目标距离: %.2f, 施法距离: %.2f", 
                (targetOrigin - casterOrigin):Length2D(), (finalCastPosition - casterOrigin):Length2D()))
            self:log(string.format("直线上点位置: %s", tostring(pointOnLine)))
            self:log(string.format("最终施法位置: %s", tostring(finalCastPosition)))
            
            -- 施放技能
            entity:CastAbilityOnPosition(finalCastPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, finalCastPosition, abilityInfo.castPoint)
            return true
        else

            local targetOrigin = targetInfo.targetPos
            local casterOrigin = entity:GetOrigin()
            local targetDirection = (targetOrigin - casterOrigin):Normalized()
            local castRange = abilityInfo.castRange
            local aoeRadius = abilityInfo.aoeRadius
        
            -- 将目标方向调整为最接近的有效方向
            local validAngles = {30, 90, 150, 210, 270, 330} -- 12、2、4、6、8、10点钟方向的角度
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
        
            -- 计算调整后的方向
            local adjustedDirection = Vector(math.cos(math.rad(closestAngle)), math.sin(math.rad(closestAngle)), 0):Normalized()
        
            -- 计算从目标反向到六边形角所需的距离
            local distanceToTarget = (targetOrigin - casterOrigin):Length2D()
            
            -- 计算施法位置，使得六边形的角正好位于目标位置
            -- 从目标位置沿着反方向退aoeRadius的距离，就是让六边形角落正好在目标位置的施法点
            local idealCastPosition = targetOrigin - adjustedDirection * aoeRadius
            local idealCastDistance = (idealCastPosition - casterOrigin):Length2D()
            
            -- 确保施法距离不超过最大施法距离
            local finalCastPosition
            if idealCastDistance <= castRange then
                finalCastPosition = idealCastPosition
                self:log("理想施法位置在施法范围内")
            else
                -- 如果超出施法范围，则在最大施法距离处施法
                finalCastPosition = casterOrigin + (idealCastPosition - casterOrigin):Normalized() * castRange
                self:log("理想施法位置超出范围，使用最大施法距离")
            end
        
            -- 打印施法信息
            self:log(string.format("准备施放技能: %s，目标距离: %.2f，理想施法距离: %.2f，最终施法距离: %.2f，作用范围: %.2f", 
                abilityInfo.abilityName, distanceToTarget, idealCastDistance, (finalCastPosition - casterOrigin):Length2D(), aoeRadius))
            self:log(string.format("原始目标方向角度: %.2f，调整后角度: %.2f", targetAngle, closestAngle))
            self:log(string.format("施法位置: %s", tostring(finalCastPosition)))
        
            -- 施放技能
            entity:CastAbilityOnPosition(finalCastPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, finalCastPosition, abilityInfo.castPoint)
        end

    elseif abilityInfo.abilityName == "death_prophet_silence" then
        -- 计算方向向量并归一化
        if self:NeedsModifierRefresh(target,{"modifier_death_prophet_silence"}, 0.5) then
            local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
    
            -- 打印施法信息
            self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))
    
            -- 计算当前单位与施法位置的距离
            local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
            self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
    
            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
    
            
        else
            local newTarget = self:FindUntargetedUnitInRange(entity, abilityInfo, {"modifier_death_prophet_silence"}, 0.5)
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
    
                -- 打印施法信息
                self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
                self:log(string.format("施法位置: %s", tostring(castPosition)))
        
                -- 计算当前单位与施法位置的距离
                local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
                self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
        
                -- 施放技能
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                
            else
                -- 没有找到合适的目标，禁用技能
                local heroName = entity:GetUnitName()
                
                -- 检查 self.disabledSkills 是否存在且为表格
                if type(self.disabledSkills) ~= "table" then
                    self:log("警告: self.disabledSkills 不是表格")
                    self.disabledSkills = {}
                end
                -- 将技能添加到禁用列表
                if not self.disabledSkills[heroName] then
                    self.disabledSkills[heroName] = {}
                end
                table.insert(self.disabledSkills[heroName], "death_prophet_silence")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end
    
    

    elseif abilityInfo.abilityName == "viper_nethertoxin" then
        -- 计算方向向量并归一化
        if self:NeedsModifierRefresh(target,{"modifier_viper_nethertoxin"}, 0) then
            local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
    
            -- 打印施法信息
            self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))
    
            -- 计算当前单位与施法位置的距离
            local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
            self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
    
            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
    
        else
            local newTarget = self:FindUntargetedUnitInRange(entity, abilityInfo, {"modifier_viper_nethertoxin"}, 0)
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
    
                -- 打印施法信息
                self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
                self:log(string.format("施法位置: %s", tostring(castPosition)))
        
                -- 计算当前单位与施法位置的距离
                local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
                self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
        
                -- 施放技能
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                
            else
                -- 没有找到合适的目标，禁用技能
                local heroName = entity:GetUnitName()
                
                -- 检查 self.disabledSkills 是否存在且为表格
                if type(self.disabledSkills) ~= "table" then
                    self:log("警告: self.disabledSkills 不是表格")
                    self.disabledSkills = {}
                end
                -- 将技能添加到禁用列表
                if not self.disabledSkills[heroName] then
                    self.disabledSkills[heroName] = {}
                end
                table.insert(self.disabledSkills[heroName], "viper_nethertoxin")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end

    elseif abilityInfo.abilityName == "skywrath_mage_mystic_flare" and entity:HasScepter() then
        self:log("天怒大自动放歪")
        -- 计算施法位置
        local castPosition
        if target:IsMoving() then 
            castPosition = entity:GetOrigin() + targetInfo.targetDirection * ( abilityInfo.castRange - 140 )
            self:log("目标正在移动")
        else
            castPosition = entity:GetOrigin() + targetInfo.targetDirection * ( abilityInfo.castRange - 70 )
            self:log("目标没在移动")
        end
        
        -- 打印施法信息
        self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
        self:log(string.format("施法位置: %s", tostring(castPosition)))

        -- 计算当前单位与施法位置的距离
        local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
        self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))

        -- 施放技能
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)

    
    elseif abilityInfo.abilityName == "mirana_leap" and self:containsStrategy(self.hero_strategy, "随机跳") then
        -- 初始化或增加计数器
        self.voidSpiritCastCount = (self.voidSpiritCastCount or 0) + 1
        local casterPos = entity:GetAbsOrigin()
        local castRange = abilityInfo.castRange
        
        -- 生成一个-45到45度之间的随机角度
        local randomAngle = math.rad(math.random(-45, 45))
        
        -- 获取前方向量
        local forwardVec = entity:GetForwardVector()
        
        -- 根据随机角度旋转向量
        local rotatedVec = Vector(
            forwardVec.x * math.cos(randomAngle) - forwardVec.y * math.sin(randomAngle),
            forwardVec.x * math.sin(randomAngle) + forwardVec.y * math.cos(randomAngle),
            0
        ):Normalized()
        
        -- 计算施法点（最远距离）
        local startPoint = casterPos + rotatedVec * castRange
        
        self:log("开始点: " .. tostring(startPoint))
        
        -- 调用施法函数
        self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, targetInfo.targetPos)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)

    
    elseif abilityInfo.abilityName == "void_spirit_aether_remnant" then
        -- 初始化或增加计数器
        self.voidSpiritCastCount = (self.voidSpiritCastCount or 0) + 1
        local casterPos = entity:GetAbsOrigin()
        local targetPos = targetInfo.targetPos
        local castRange = abilityInfo.castRange
    
        -- 计算方向向量
        local direction = (targetPos - casterPos):Normalized()
    
        -- 计算第一个施法点
        local startPoint = casterPos + direction * castRange
        local endPoint = targetPos
    
        self:log("开始点: " .. tostring(startPoint))
        self:log("结束点: " .. tostring(endPoint))
    
        -- 调用施法函数
        self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, endPoint)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
        
    elseif abilityInfo.abilityName == "bloodseeker_blood_bath" then
        -- 计算方向向量并归一化
        if self:containsStrategy(self.hero_strategy, "血祭封走位") then
            local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        elseif self:containsStrategy(self.hero_strategy, "血祭脚底下") then
            local castPosition = entity:GetAbsOrigin() + targetInfo.targetDirection * (abilityInfo.aoeRadius- 100 )
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        else
            local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange

            -- 打印施法信息
            -- 计算当前单位与施法位置的距离
            local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        end

    elseif abilityInfo.abilityName == "invoker_emp" then
        if self:containsStrategy(self.hero_strategy, "磁暴炸自己") then
            local castPosition = entity:GetAbsOrigin() + targetInfo.targetDirection * (abilityInfo.aoeRadius- 100 )
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        elseif self:containsStrategy(self.global_strategy, "防守策略") then
            local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true

        else
            local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange

            -- 打印施法信息
            self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))

            -- 计算当前单位与施法位置的距离
            local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
            self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))

            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        end

    elseif abilityInfo.abilityName == "dark_seer_wall_of_replica" or 
    abilityInfo.abilityName == "pangolier_swashbuckle" or 
    abilityInfo.abilityName == "clinkz_burning_army" then
        local startPoint = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
        endPoint = targetInfo.targetPos
        self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, endPoint)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)



    elseif abilityInfo.abilityName == "dark_willow_bramble_maze" then
        local castPosition = entity:GetOrigin() + targetInfo.targetDirection * (abilityInfo.castRange - 100)
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)

    elseif abilityInfo.abilityName == "morphling_waveform" then
        if self:containsStrategy(self.hero_strategy, "波最远") then
            local direction = (targetInfo.target:GetOrigin() - entity:GetOrigin()):Normalized()
            
            -- 直接朝目标方向施放最大距离
            local newTargetPos = entity:GetOrigin() + direction * abilityInfo.castRange
                        
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTargetPos, abilityInfo.castPoint)
            return true
        else
            castPosition = targetInfo.targetPos + targetInfo.targetDirection * 50
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        end

    elseif abilityInfo.abilityName == "earth_spirit_stone_caller" then
        local entityPos = entity:GetAbsOrigin()
        local castPosition
    
        if self.earthSpiritStonePosition == "脚底下" then
            local distanceToTarget = (targetInfo.targetPos - entityPos):Length2D()
            

            castPosition = entityPos + targetInfo.targetDirection * 50

        else
            castPosition = entityPos + targetInfo.targetDirection * abilityInfo.castRange
        end
    
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("石头放置位置是 %s ", castPosition))
    
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "disruptor_kinetic_field" then
        local entityPos = entity:GetAbsOrigin()
        local targetPos = target:GetAbsOrigin()
        local directionToSelf = (entityPos - targetPos):Normalized()
        
        -- 从敌人位置朝向自己方向,距离aoeRadius的位置释放
        local castPosition = targetPos + directionToSelf * abilityInfo.aoeRadius
    
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("动能场放置位置是 %s ", castPosition))
    
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true


    else
        if bit.band(abilityInfo.abilityBehavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then

            -- 计算矢量施法的起点（最大施法距离位置）和终点（敌人当前位置）
            local vectorStart = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
            local vectorEnd = targetInfo.targetPos

            -- 执行施法
            self:log(string.format("矢量施法：从 %s 到 %s (施法距离%.2f)", 
                tostring(vectorStart), 
                tostring(vectorEnd),
                abilityInfo.castRange))
                
            self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, vectorStart, vectorEnd)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, vectorStart, abilityInfo.castPoint)
            
            return true
    -- 计算施法位置
        else
            local castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange

            -- 打印施法信息
            self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))

            -- 计算当前单位与施法位置的距离
            local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
            self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))

            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        end

    end
end