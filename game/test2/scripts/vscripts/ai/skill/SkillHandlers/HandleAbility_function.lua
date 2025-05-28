function CommonAI:HandleUnitTargetAbility(entity, abilityInfo, target, targetInfo)

    if self:isSelfCastAbility(abilityInfo.abilityName) then --只对自己释放的技能
        if self:isSelfCastAbilityWithRange(abilityInfo.abilityName) then
            -- 对自己释放但需要考虑范围的技能
            if abilityInfo.aoeRadius > 0 then
                local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.aoeRadius)


                if self:IsInRange(target, totalRange) then
                    entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                else
                    -- 敌人不在施法范围内
                    if self.currentState ~= AIStates.Channeling then
                        -- 移动到施法距离内
                        self:MoveToRange(targetInfo.targetPos, totalRange)
                        self:SetState(AIStates.Seek)
                        self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
                    end
                end
            end
        else
            self:log("对自己施放的技能，无需考虑范围")
            if abilityInfo.abilityName == "lich_frost_shield" then
                local targetToCast = FindSuitableTarget(entity, abilityInfo, "modifier_lich_frost_shield", true, "friendly")
                if targetToCast then
                    if log then
                        log(string.format("巫妖技能检查: 选择目标 %s", targetToCast:GetUnitName()))
                    end
                    entity:CastAbilityOnTarget(targetToCast, abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                else
                    if log then
                        log("巫妖技能检查: 未找到合适的目标")
                    end
                end
            else
                local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, 0)
                if totalRange == 0 then
                    entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                else
                    if self:IsInRange(self.target, totalRange) then
                        entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
                        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                    else
                        self:MoveToRange(targetInfo.targetPos, totalRange)
                        self:SetState(AIStates.Seek)
                        self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
                    end
                end
            end
        end

    elseif abilityInfo.targetTeam ~= DOTA_UNIT_TARGET_TEAM_FRIENDLY then
        if abilityInfo.castRange > 0 then
            local currentTarget = self.treetarget or target
            local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange)

            if self:IsInRange(currentTarget, totalRange) then
                -- 敌人在施法范围内
                self:HandleEnemyTargetAction(entity, currentTarget, abilityInfo, targetInfo)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, currentTarget)
            else
                -- 敌人不在施法范围内
                if self:HandleEnemyTargetOutofRangeAction(entity, currentTarget, abilityInfo, targetInfo) then
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, currentTarget)
                elseif self.currentState ~= AIStates.Channeling then
                    -- 移动到施法距离内
                    local targetPosition = self.treetarget and self.treetarget:GetAbsOrigin() or targetInfo.targetPos
                    self:MoveToRange(targetPosition, totalRange)
                    self:SetState(AIStates.Seek)
                    self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
                end
            end
        end
    else
        self:log("对队友释放的技能")
        if abilityInfo.abilityName == "clinkz_death_pact" then
            -- 使用FindNearestNoSelfAllyLastResort搜索ally
            local lastResortAlly = self:FindNearestNoSelfAllyLastResort(entity)
            if lastResortAlly then
                self:log("找到目标了")
                entity:CastAbilityOnTarget(lastResortAlly, abilityInfo.skill, 0)
            else
                -- 如果没有找到ally，可以在这里添加日志或其他处理
                self:log("没有找到可用的目标来使用死亡契约")
            end
        end
        self:HandleAllyTargetAbility(entity, abilityInfo,targetInfo)
    end
end

function CommonAI:HandlePointTargetAbility(entity, abilityInfo, target, targetInfo)
    if abilityInfo.targetTeam ~= DOTA_UNIT_TARGET_TEAM_FRIENDLY then
        local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange)
        if self:IsInRange(target, totalRange) then
            -- 敌人在施法范围内
            self:HandleEnemyPoint_InCastRange(entity, target, abilityInfo, targetInfo)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
        elseif self:IsInRange(target, self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange + abilityInfo.aoeRadius)) then
            -- 敌人在作用范围内
            self:HandleEnemyPoint_InAoeRange(entity, target, abilityInfo, targetInfo)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
        else
            -- 敌人不在范围内
            if self:HandleEnemyPoint_OutofRangeAction(entity, target, abilityInfo, targetInfo) then
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
            else
                -- 移动到施法距离内
                local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange + abilityInfo.aoeRadius)
                self:MoveToRange(targetInfo.targetPos, totalRange)
                self:SetState(AIStates.Seek)
                self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离+作用范围: %.2f", targetInfo.distance, totalRange))
            end
        end
    elseif self:isSelfCastAbility(abilityInfo.abilityName) then
        -- 对自己释放技能

        self:log("对自己施放技能")
        entity:CastAbilityOnPosition(entity:GetAbsOrigin(), abilityInfo.skill, 0)

        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
    else
        self:HandleAllyPointAbility(entity, abilityInfo, targetInfo)
    end
end

function CommonAI:HandleNoTargetAbility(entity, abilityInfo, target, targetInfo)
    self:log("无目标技能")
    -- 修改：如果radius不等于零，并且小于150，就令它等于150
    if abilityInfo.aoeRadius ~= 0 and abilityInfo.aoeRadius < 150 then
        abilityInfo.aoeRadius = 150
    end
    local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange + abilityInfo.aoeRadius)
    if  totalRange == 0 then
        self:log(string.format("技能: %s 没有作用范围，直接释放", abilityInfo.abilityName))
        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
    else

        if self:IsInRange(target, totalRange) then

            if abilityInfo.abilityName == "zuus_heavenly_jump" and self.needToDodge == true then
                local heroPosition = self.entity:GetAbsOrigin()
                local dirToEnemy = (target:GetAbsOrigin() - heroPosition):Normalized()
                local heroForward = self.entity:GetForwardVector()
                local angle = math.deg(math.acos(heroForward:Dot(dirToEnemy)))
            
                if angle < 30 then
                    -- 如果角度小于30度，从英雄和敌人的连线往北偏转30度移动200码
                    local radians = math.rad(30)
                    local cos = math.cos(radians)
                    local sin = math.sin(radians)
                    
                    -- 计算旋转后的向量（逆时针旋转，所以用负的sin）
                    local rotatedX = dirToEnemy.x * cos + dirToEnemy.y * sin
                    local rotatedY = -dirToEnemy.x * sin + dirToEnemy.y * cos
                    local moveDirection = Vector(rotatedX, rotatedY, dirToEnemy.z):Normalized()
                    
                    local movePosition = heroPosition + moveDirection * 200
                    self.entity:MoveToPosition(movePosition)
                    self:log("Zeus正在从敌人方向往北偏转30°移动200码")
                else
                    -- 如果角度大于等于30度，直接释放技能
                    self:log("Zeus直接释放Heavenly Jump")
                    entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                end
            elseif abilityInfo.abilityName == "invoker_ice_wall" and not self:containsStrategy(self.hero_strategy, "正面冰墙") then
                local heroPosition = self.entity:GetAbsOrigin()
                local targetPosition = target:GetAbsOrigin()
                local distanceToTarget = (targetPosition - heroPosition):Length2D()
                local heroForward = self.entity:GetForwardVector()
                
                -- 圆的半径
                local circleRadius = 300
                
                -- 计算切点
                -- cos(theta) = r/d，其中theta是圆心角的一半
                local cosTheta = circleRadius / distanceToTarget
                local theta = math.acos(cosTheta)
                
                -- 计算从圆心到敌人的基准角度
                local baseAngle = math.atan2(targetPosition.y - heroPosition.y, targetPosition.x - heroPosition.x)
                
                -- 计算右侧切点的角度（基准角度减去theta）
                local tangentAngle = baseAngle - theta
                
                -- 计算切点位置
                local tangentPoint = Vector(
                    heroPosition.x + circleRadius * math.cos(tangentAngle),
                    heroPosition.y + circleRadius * math.sin(tangentAngle),
                    heroPosition.z
                )
                
                -- 计算应该面向的方向（从英雄到切点的方向）
                local dirToTangent = (tangentPoint - heroPosition):Normalized()
                local currentAngle = math.deg(math.acos(heroForward:Dot(dirToTangent)))
                
                if currentAngle > 5 then
                    -- 需要调整方向，向切点方向移动
                    local movePosition = heroPosition + dirToTangent * 50
                    self:log("Invoker正在调整到切点方向")
                    self.entity:MoveToPosition(movePosition)
                    return
                end
                
                -- 角度合适，直接释放技能
                self:log("Invoker释放Ice Wall")
                entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)

            elseif abilityInfo.abilityName == "rattletrap_power_cogs" then
                local heroPosition = self.entity:GetAbsOrigin()
                local dirToEnemy = (target:GetAbsOrigin() - heroPosition):Normalized()
                local heroForward = self.entity:GetForwardVector()
                local angle = math.deg(math.acos(heroForward:Dot(dirToEnemy)))
                local distanceToEnemy = (target:GetAbsOrigin() - heroPosition):Length2D()
                local hasCogImmune = self.entity:HasModifier("modifier_rattletrap_cog_immune")
                
                if angle < 45 then
                    -- 如果角度小于45度，说明基本面对着敌人，直接放技能
                    self:log("发条面对敌人，直接释放齿轮")
                    entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                else
                    -- 如果没有齿轮免疫，直接放技能
                    if not hasCogImmune then
                        self:log("发条没有齿轮免疫，直接释放齿轮")
                        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                    -- 如果有齿轮免疫且距离大于400，需要转身面对敌人
                    elseif distanceToEnemy > 500 then
                        self:log("发条需要转身面对敌人")
                        local movePosition = target:GetAbsOrigin()
                        local order = {
                            UnitIndex = self.entity:entindex(),
                            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                            TargetIndex = self.target and self.target:entindex(),
                            Position = movePosition
                        }
                        ExecuteOrderFromTable(order)
                    else
                        -- 距离小于400且有齿轮免疫，直接放技能
                        self:log("发条直接释放齿轮")
                        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                    end
                end
            elseif abilityInfo.abilityName == "slark_pounce" then
                local heroPosition = self.entity:GetAbsOrigin()
                local dirToEnemy = (target:GetAbsOrigin() - heroPosition):Normalized()
                local heroForward = self.entity:GetForwardVector()
                local angle = math.deg(math.acos(heroForward:Dot(dirToEnemy)))
                local distanceToEnemy = (target:GetAbsOrigin() - heroPosition):Length2D()
                
                if angle < 20 or distanceToEnemy < 100 then
                    -- 如果角度小于45度或距离小于100，直接释放技能
                    self:log("小鱼人面对敌人或距离足够近，直接跳跃")
                    entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                else
                    -- 需要转身面对敌人
                    self:log("小鱼人需要转身面对敌人")
                    local movePosition = target:GetAbsOrigin()
                    local order = {
                        UnitIndex = self.entity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                        TargetIndex = self.target and self.target:entindex(),
                        Position = movePosition
                    }
                    ExecuteOrderFromTable(order)
                end
            else
                self:log(string.format("技能: %s 敌人在作用范围内，直接释放", abilityInfo.abilityName))
                entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
            end
        else
            self:MoveToRange(targetInfo.targetPos, totalRange)
            self:SetState(AIStates.Seek)

        end
    end
end

function CommonAI:HandleAllyTargetAbility(entity, abilityInfo, targetInfo)
    if not self.Ally then
        return false
    end
    self:log("对队友放的")
    self:log(string.format("找到友军目标 %s 准备施放技能 %s", self.Ally:GetUnitName(), abilityInfo.abilityName))
    if abilityInfo.castRange > 0 then
        if self:IsInRange(self.Ally, abilityInfo.castRange) then
            -- 友军在范围内
            if abilityInfo.abilityName == "brewmaster_void_astral_pull" then
                self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
                CommonAI:CastVectorSkillToUnitAndPoint(entity, abilityInfo.skill, self.Ally, targetInfo.targetPos)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.Ally:GetOrigin(), abilityInfo.castPoint)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)
            elseif abilityInfo.abilityName == "dawnbreaker_solar_guardian" then
                print("")
                local order = {
                    UnitIndex = entity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    Position = self.Ally:GetOrigin(),
                    AbilityIndex = abilityInfo.skill:entindex(),
                    Queue = false
                }
                ExecuteOrderFromTable(order)
                self:log("使用 ExecuteOrderFromTable 释放破晓辰星终极技能")
            elseif abilityInfo.abilityName == "marci_companion_run" then 

                CommonAI:CastVectorSkillToUnitAndPoint(entity, abilityInfo.skill, self.Ally, targetInfo.targetPos)
        
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            else
                self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
                entity:CastAbilityOnTarget(self.Ally, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.Ally:GetOrigin(), abilityInfo.castPoint)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)
            end
        else
            -- 友军不在范围内
            self:MoveToRange(self.Ally:GetOrigin(), abilityInfo.castRange)
            self:SetState(AIStates.Seek)
            self:log(string.format("友军不在施法范围内，移动到施法范围，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
        end
    end
end

function CommonAI:HandleAllyPointAbility(entity, abilityInfo, targetInfo)
    if not self.Ally then
        return false
    end
    
    self:log("对队友放的")
    self:log(string.format("找到友军目标 %s 准备施放技能 %s", self.Ally:GetUnitName(), abilityInfo.abilityName))
    if abilityInfo.castRange > 0 then
        if self:IsInRange(self.Ally, abilityInfo.castRange) then
            -- 友军在范围内

            if abilityInfo.abilityName == "arc_warden_magnetic_field" then
                self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
                
                local castPosition = self.Ally:GetOrigin()
                
                -- 检查是否存在目标敌人且符合"后置领域"策略
                if self.target and self:containsStrategy(self.hero_strategy, "后置领域") then
                    -- 计算方向向量：从敌人指向盟友
                    local direction = (self.Ally:GetOrigin() - self.target:GetOrigin()):Normalized()
                    -- 从盟友位置沿方向延伸300码
                    castPosition = self.Ally:GetOrigin() + direction * 300
                    self:log("使用后置领域策略，施放位置已调整")
                end
                
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)

            else
                self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
                entity:CastAbilityOnPosition(self.Ally:GetOrigin(), abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.Ally:GetOrigin(), abilityInfo.castPoint)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)
            end
        else
            -- 友军不在范围内
            self:MoveToRange(self.Ally:GetOrigin(), abilityInfo.castRange)
            self:SetState(AIStates.Seek)
            self:log(string.format("友军不在施法范围内，移动到施法范围，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
        end
    end
end
