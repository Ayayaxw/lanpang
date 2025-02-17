function CommonAI:HandleEnemyPoint_InAoeRange(entity,target,abilityInfo,targetInfo)

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

    elseif abilityInfo.abilityName == "muerta_the_calling" then
        local targetDirection = (targetInfo.targetPos - entity:GetOrigin()):Normalized()
        local castRange = abilityInfo.castRange
        local aoeRadius = abilityInfo.aoeRadius
        local effectiveRadius = aoeRadius - 50 -- 有效半径（边缘内缩50码）
    
        -- 将目标方向调整为最接近的有效方向
        local validAngles = {0, 60, 120, 180, 240, 300} -- 12、2、4、6、8、10点钟方向的角度
        local targetAngle = math.deg(math.atan2(targetDirection.y, targetDirection.x))
        if targetAngle < 0 then targetAngle = targetAngle + 360 end
        
        local closestAngle = validAngles[1]
        local minDiff = 360
        for _, angle in ipairs(validAngles) do
            local diff = math.abs(targetAngle - angle)
            if diff < minDiff then
                minDiff = diff
                closestAngle = angle
            end
        end
    
        -- 计算调整后的方向
        local adjustedDirection = Vector(math.cos(math.rad(closestAngle)), math.sin(math.rad(closestAngle)), 0):Normalized()
    
        -- 计算新的施法位置
        local distanceToTarget = (targetInfo.targetPos - entity:GetOrigin()):Length2D()
        local castDistance = math.min(castRange, distanceToTarget - effectiveRadius)
        local castPosition = entity:GetOrigin() + adjustedDirection * castDistance
    
        -- 打印施法信息
        self:log(string.format("准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, distanceToTarget, castDistance, aoeRadius))
        self:log(string.format("原始目标方向角度: %.2f，调整后角度: %.2f", targetAngle, closestAngle))
        self:log(string.format("施法位置: %s", tostring(castPosition)))
    
        -- 计算当前单位与施法位置的距离
        local distanceToCastPosition = (castPosition - entity:GetOrigin()):Length2D()
        self:log(string.format("当前单位与施法位置的距离: %.2f", distanceToCastPosition))
    
        -- 施放技能
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)

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
        else
            local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
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
        castPosition = targetInfo.targetPos + targetInfo.targetDirection * 50
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)


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