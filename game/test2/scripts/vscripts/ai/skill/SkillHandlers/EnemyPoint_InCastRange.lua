function CommonAI:HandleEnemyPoint_InCastRange(entity,target,abilityInfo,targetInfo)
    self:log(string.format("在castrange施法范围内，准备对敌人脚底下施放技能"))

    if  Main.currentChallenge == Main.Challenges.CD0_1skill then
    -- 检查技能名称
        if abilityInfo.abilityName == "tusk_ice_shards" then
            -- 计算新的目标位置，沿方向向量移动200码
            local newTargetPos = targetInfo.targetPos - targetInfo.targetDirection * 200

            -- 施放技能到新的目标位置
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)
            return true
        elseif abilityInfo.abilityName == "monkey_king_primal_spring" then
            -- 固定目标位置为 Vector(100, -3000, 0)
            local newTargetPos = Vector(100, -3000, 0)
            abilityInfo.channelTime = 0.01
            -- 施放技能到新的目标位置
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)
            return true
        elseif abilityInfo.abilityName == "riki_smoke_screen" and target:GetUnitName() == "npc_dota_hero_faceless_void" then
            -- 获取角色面向的前方向量并归一化
            local directionToTarget = (targetInfo.targetPos - entity:GetOrigin()):Normalized()
            
            -- 计算新的目标位置，沿前方向量移动100码
            local newTargetPos = entity:GetOrigin()
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTargetPos, abilityInfo.castPoint)
        
            -- 施放技能到新的目标位置
            
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            return true
        elseif abilityInfo.abilityName == "morphling_waveform" then
            if not self.lastCastOrigin then
                self.lastCastOrigin = entity:GetOrigin()
                self.isLastCastSpecial = false
            end
        
            local castPosition
        
            if targetInfo.distance < 500 and not self.isLastCastSpecial then
                local currentPosition = entity:GetOrigin()
                local distanceToLastCast = (currentPosition - self.lastCastOrigin):Length()
                
                if distanceToLastCast < 500 then
                    -- Calculate the direction vector from current position to last cast position
                    local direction = (self.lastCastOrigin - currentPosition):Normalized()
                    
                    -- Calculate new cast position
                    local newCastDistance = 500
                    castPosition = currentPosition + direction * newCastDistance
                else
                    castPosition = self.lastCastOrigin
                end
                
                self.isLastCastSpecial = true
            else
                -- 普通施法：朝目标方向施法
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
                self.isLastCastSpecial = false
            end
        
            -- 更新上一次施法位置
            self.lastCastOrigin = entity:GetOrigin()
        
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        elseif abilityInfo.abilityName == "riki_tricks_of_the_trade" then
            local castPosition
            
            if targetInfo.distance > 700 then
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * 700
                abilityInfo.channelTime = 0.01
            else
                castPosition = targetInfo.targetPos
            end
            
            self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
            self:log(string.format("施法位置: %s", tostring(castPosition)))
            
            -- 施放技能
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  castPosition, abilityInfo.castPoint)
            return true
        elseif abilityInfo.abilityName == "storm_spirit_ball_lightning" then
            if self:containsStrategy(self.hero_strategy, "折叠飞") then
                if not self.hasCastBackwardBallLightning then
                    local heroPosition = entity:GetOrigin()
                    local heroForward = entity:GetForwardVector()
                    -- 计算英雄身后的位置
                    local castPosition = Vector(
                        heroPosition.x - heroForward.x * 300,
                        heroPosition.y - heroForward.y * 300,
                        heroPosition.z
                    )
            
                    -- 记录开始时间
                    self.ballLightningCastStartTime = GameRules:GetGameTime()
            
                    -- 计算预期的转身和施法时间
                    local expectedCastPoint, expectedTurnTime = self:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                    
                    self:log("开始测试风暴之灵向后施法")
                    self:log(string.format("英雄位置: (%.2f, %.2f, %.2f)", heroPosition.x, heroPosition.y, heroPosition.z))
                    self:log(string.format("施法位置: (%.2f, %.2f, %.2f)", castPosition.x, castPosition.y, castPosition.z))
                    self:log(string.format("预期转身时间: %.3f 秒", expectedTurnTime))
                    self:log(string.format("预期总施法前摇时间: %.3f 秒", expectedCastPoint))
            
                    -- 执行向后施法
                    entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            
                    -- 标记已经执行过这个测试
                    self.hasCastBackwardBallLightning = true
            
                    -- 设置一个定时器来检查实际的施法时间
                    Timers:CreateTimer(0.01, function()
                        if abilityInfo.skill:IsInAbilityPhase() or entity:IsChanneling() then
                            local actualCastTime = GameRules:GetGameTime() - self.ballLightningCastStartTime
                            self:log(string.format("实际施法前摇时间: %.3f 秒", actualCastTime))
                            self:log(string.format("时间差异: %.3f 秒", actualCastTime - expectedCastPoint))
                            return nil  -- 停止定时器
                        end
                        return 0.01  -- 继续检查
                    end)
            
                    return true
                end
            else
                local distance = 300
                if self.target and self.target:IsRangedAttacker() then
                    distance = 50
                end
                
                local castPosition = targetInfo.targetPos + targetInfo.targetDirection * distance
                        
                self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
                self:log(string.format("施法位置: %s", tostring(castPosition)))
                            
                -- 施放技能
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                return true
            end
        elseif abilityInfo.abilityName == "sandking_burrowstrike" then
            -- 沙王
            if targetInfo.distance < 50 then
                local castPosition = entity:GetOrigin()
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            elseif targetInfo.distance < 300 then
                local castPosition = entity:GetOrigin() + targetInfo.targetDirection * 200
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            else
                entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            end
            
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true

        elseif abilityInfo.abilityName == "ember_spirit_fire_remnant" then
            if not self.emberSpiritCastCount then
                self.emberSpiritCastCount = 0
            end
            self.emberSpiritCastCount = self.emberSpiritCastCount + 1
            self:log("Ember Spirit Fire Remnant: Cast number " .. self.emberSpiritCastCount)
        
            local castPosition
        
            -- Define rectangle corners
            local corners = {
                Vector(-1075, -2603, 256), -- Top-left
                Vector(1302, -2603, 256),  -- Top-right
                Vector(-1075, -3257, 256), -- Bottom-left
                Vector(1302, -3257, 256)   -- Bottom-right
            }
            if abilityInfo.skill:GetCurrentAbilityCharges() == 1 and target:GetUnitName() ~= "npc_dota_hero_faceless_void" or self.cancastfire_remnant then

                castPosition = targetInfo.targetPos + targetInfo.targetDirection * 100

            else
                if self.emberSpiritCastCount == 1 then
                    -- 第一次施法
                    local rectLeft, rectRight = -1075, 1302
                    local rectTop, rectBottom = -2503, -3357
            
                    local heroPos = entity:GetOrigin()
                    local targetDir = targetInfo.targetDirection
                    local targetPos = targetInfo.targetPos
            
                    -- 初始化 intersections 表
                    local intersections = {}
                    
                    -- 计算交点
                    -- 检查与左边界的交点
                    local tLeft = (rectLeft - targetPos.x) / targetDir.x
                    if tLeft > 0 then
                        local y = targetPos.y + tLeft * targetDir.y
                        if y >= rectBottom and y <= rectTop then
                            table.insert(intersections, Vector(rectLeft, y, 256))
                        end
                    end
                    
                    -- 检查与右边界的交点
                    local tRight = (rectRight - targetPos.x) / targetDir.x
                    if tRight > 0 then
                        local y = targetPos.y + tRight * targetDir.y
                        if y >= rectBottom and y <= rectTop then
                            table.insert(intersections, Vector(rectRight, y, 256))
                        end
                    end
                    
                    -- 检查与上边界的交点
                    local tTop = (rectTop - targetPos.y) / targetDir.y
                    if tTop > 0 then
                        local x = targetPos.x + tTop * targetDir.x
                        if x >= rectLeft and x <= rectRight then
                            table.insert(intersections, Vector(x, rectTop, 256))
                        end
                    end
                    
                    -- 检查与下边界的交点
                    local tBottom = (rectBottom - targetPos.y) / targetDir.y
                    if tBottom > 0 then
                        local x = targetPos.x + tBottom * targetDir.x
                        if x >= rectLeft and x <= rectRight then
                            table.insert(intersections, Vector(x, rectBottom, 256))
                        end
                    end
            
                    -- 打印调试信息
                    self:log("Debug: targetPos = " .. tostring(targetPos))
                    self:log("Debug: targetDir = " .. tostring(targetDir))
                    self:log("Debug: 计算的交点数量: " .. #intersections)
            
                    -- 选择最远的交点
                    local maxDist = 0
                    local farthestIntersection
                    for _, intersection in ipairs(intersections) do
                        local dist = (intersection - targetPos):Length2D()
                        if dist > maxDist then
                            maxDist = dist
                            farthestIntersection = intersection
                        end
                    end
                
                    -- 如果没有找到交点，使用目标位置
                    if not farthestIntersection then
                        self:log("警告: 没有找到交点")
                        farthestIntersection = targetPos
                    end
                
                    -- 找到离最远交点最近的角落
                    local minDist = math.huge
                    for _, corner in ipairs(corners) do
                        local dist = (corner - farthestIntersection):Length2D()
                        if dist < minDist then
                            minDist = dist
                            castPosition = corner
                        end
                    end
                
                    -- 记录这次施法的位置
                    self.lastCastPosition = castPosition
                    
                    self:log("第一次施法: 在位置 (" .. castPosition.x .. ", " .. castPosition.y .. ", " .. castPosition.z .. ") 施法")
                else
                    -- 第二次及以后的施法
                    -- 选择与上次施法对角的位置
                    if self.lastCastPosition.x < 0 then
                        -- 上次在左边，这次选右边
                        if self.lastCastPosition.y > -2930 then
                            -- 上次在左上，这次选右下
                            castPosition = corners[4]
                        else
                            -- 上次在左下，这次选右上
                            castPosition = corners[2]
                        end
                    else
                        -- 上次在右边，这次选左边
                        if self.lastCastPosition.y > -2930 then
                            -- 上次在右上，这次选左下
                            castPosition = corners[3]
                        else
                            -- 上次在右下，这次选左上
                            castPosition = corners[1]
                        end
                    end
                    
                    -- 更新 lastCastPosition 为这次施法的位置
                    self.lastCastPosition = castPosition
                    
                    if self.emberSpiritCastCount % 2 == 1 then
                        self:log("奇数次施法: 在位置 (" .. castPosition.x .. ", " .. castPosition.y .. ", " .. castPosition.z .. ") 施法")
                    else
                        self:log("偶数次施法: 在位置 (" .. castPosition.x .. ", " .. castPosition.y .. ", " .. castPosition.z .. ") 施法")
                    end
                end
            end
        
            -- Call the casting function
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, entity:GetOrigin(), abilityInfo.castPoint)
            return true
        end
    end

    if abilityInfo.abilityName == "ancient_apparition_cold_feet" then
        -- 计算方向向量并归一化
        if not target:HasModifier("modifier_cold_feet") then
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)

        else
            -- 搜索施法距离范围内其他没有modifier_cold_feet的英雄单位
            local newTarget = nil
            local closestDistance = abilityInfo.castRange
    
            local heroes = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                abilityInfo.castRange,
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
                entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTarget:GetOrigin(), abilityInfo.castPoint)
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
        return true
    
    elseif abilityInfo.abilityName == "death_prophet_silence" then
        -- 计算方向向量并归一化
        if self:NeedsModifierRefresh(target,{"modifier_death_prophet_silence"}, 0.5) then
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
    
        else
            -- 搜索施法距离范围内其他没有modifier_death_prophet_silence的英雄单位
            local newTarget = self:FindUntargetedUnitInRange(entity, abilityInfo, {"modifier_death_prophet_silence"}, 0.5)
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTarget:GetOrigin(), abilityInfo.castPoint)
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
        return true

    elseif abilityInfo.abilityName == "pangolier_swashbuckle" then
        local entityPos = entity:GetOrigin()
        local targetPos = self.target:GetOrigin()
        local directionToTarget = (targetPos - entityPos):Normalized()
        local distanceToTarget = (targetPos - entityPos):Length2D()
        
        local startPoint
        if distanceToTarget > 200 then
            -- 如果距离大于200，选择距离目标200码的位置
            startPoint = targetPos - directionToTarget * 200
        else
            -- 如果距离小于200，选择目标身后200码的位置
            startPoint = targetPos + directionToTarget * 200
        end
        
        endPoint = targetInfo.targetPos
        self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, endPoint)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
        return true


    elseif abilityInfo.abilityName == "viper_nethertoxin" then
        -- 计算方向向量并归一化
        if self:NeedsModifierRefresh(target,{"modifier_viper_nethertoxin"}, 0) then
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
    
        else
            -- 搜索施法距离范围内其他没有modifier_death_prophet_silence的英雄单位
            local newTarget = self:FindUntargetedUnitInRange(entity, abilityInfo, {"modifier_viper_nethertoxin"}, 0)
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTarget:GetOrigin(), abilityInfo.castPoint)
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
        return true

    
    
    -- elseif abilityInfo.abilityName == "pudge_meat_hook" then
    --     -- 获取角色面向的前方向量并归一化

    --     local newTargetPos = entity:GetOrigin() + targetInfo.targetDirection * 100
    
    --     -- 施放技能到新的目标位置
    --     entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
    --     return true
    elseif abilityInfo.abilityName == "lion_impale" then
        -- 获取角色面向的前方向量并归一化

        local newTargetPos = entity:GetOrigin() + targetInfo.targetDirection * 100
    
        -- 施放技能到新的目标位置
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        
        return true
    elseif abilityInfo.abilityName == "tidehunter_gush" then
        -- 获取角色面向的前方向量并归一化

        local newTargetPos = entity:GetOrigin() + targetInfo.targetDirection * 100
    
        -- 施放技能到新的目标位置
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)
        return 
        
    elseif abilityInfo.abilityName == "mirana_leap" and self:containsStrategy(self.hero_strategy, "有人贴脸就跳") then
        -- 初始化或增加计数器
        self.voidSpiritCastCount = (self.voidSpiritCastCount or 0) + 1
        local casterPos = entity:GetAbsOrigin()
        local castRange = abilityInfo.castRange
        
        -- 计算从自己到敌人的方向向量
        local directionToTarget = (targetInfo.targetPos - casterPos):Normalized()
        
        -- 计算施法点（在这个方向上的最远距离）
        local startPoint = casterPos + directionToTarget * castRange
        
        self:log("开始点: " .. tostring(startPoint))
        
        -- 调用施法函数
        self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, targetInfo.targetPos)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "magnataur_skewer"then
        local casterPos = entity:GetAbsOrigin()
        local castRange = abilityInfo.castRange
        -- 计算从自己到敌人的方向向量
        local directionToTarget = (targetInfo.targetPos - casterPos):Normalized()

        entity:CastAbilityOnPosition(casterPos + directionToTarget * castRange,abilityInfo.skill,0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
        return true


    elseif abilityInfo.abilityName == "juggernaut_healing_ward" then

        local newTargetPos = entity:GetOrigin() + targetInfo.targetDirection * 350
        
    
        -- 施放技能到新的目标位置
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)

        return true


    elseif abilityInfo.abilityName == "morphling_waveform" then
        -- 计算目标方向
        if self:containsStrategy(self.hero_strategy, "无缝波") then
            if not self.lastCastOrigin then
                self.lastCastOrigin = entity:GetOrigin()
                self.isLastCastSpecial = false
            end

            local castPosition

            if targetInfo.distance < 500 and not self.isLastCastSpecial then
                local currentPosition = entity:GetOrigin()
                local distanceToLastCast = (currentPosition - self.lastCastOrigin):Length()
                
                if distanceToLastCast < 500 then
                    -- Calculate the direction vector from current position to last cast position
                    local direction = (self.lastCastOrigin - currentPosition):Normalized()
                    
                    -- Calculate new cast position
                    local newCastDistance = 500
                    castPosition = currentPosition + direction * newCastDistance
                else
                    castPosition = self.lastCastOrigin
                end
                
                self.isLastCastSpecial = true
            else
                -- 普通施法：朝目标方向施法
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
                self.isLastCastSpecial = false
            end

                -- 更新上一次施法位置
                self.lastCastOrigin = entity:GetOrigin()

                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                return true
            
        elseif self:containsStrategy(self.hero_strategy, "波最远") then
            local direction = (targetInfo.target:GetOrigin() - entity:GetOrigin()):Normalized()
            
            -- 直接朝目标方向施放最大距离
            local newTargetPos = entity:GetOrigin() + direction * abilityInfo.castRange
                        
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTargetPos, abilityInfo.castPoint)
            return true
        elseif self:containsStrategy(self.hero_strategy, "圆形波") then
            -- 初始化圆形施法的参考点和角度
            if not self.circleCenter then
                -- 第一次施法：设置圆心为当前位置，初始角度为0
                self.circleCenter = entity:GetOrigin()
                self.currentAngle = 0
                self.circleRadius = 500
            end

            -- 计算下一个施法位置
            -- 首先找到英雄在圆上的切点
            local heroPos = entity:GetOrigin()
            local toCenter = self.circleCenter - heroPos
            local distanceToCenter = toCenter:Length2D()

            -- 计算切线角度
            local tangentAngle
            if distanceToCenter <= self.circleRadius then
                -- 如果英雄在圆内或圆上，选择当前角度继续施法
                tangentAngle = self.currentAngle
            else
                -- 如果英雄在圆外，计算切线角度
                local angleToCenter = math.atan2(toCenter.y, toCenter.x)
                local tangentOffset = math.asin(self.circleRadius / distanceToCenter)
                -- 选择其中一个切点（这里选择逆时针方向的切点）
                tangentAngle = angleToCenter + tangentOffset
            end

            -- 在切线方向上施法到最远距离
            local castDirection = Vector(math.cos(tangentAngle), math.sin(tangentAngle), 0)
            local castPosition = entity:GetOrigin() + castDirection * abilityInfo.castRange

            -- 更新下一次施法的角度（逆时针旋转）
            self.currentAngle = tangentAngle + math.pi / 6  -- 每次旋转30度

            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true

        elseif self:containsStrategy(self.hero_strategy, "反复横跳波") then
            -- 使用固定的中心点
            local centerPoint = Vector(150, 150, 128)
            local heroPos = entity:GetOrigin()
            local radius = abilityInfo.castRange * 0.5  -- 使用施法距离的一半作为基础距离
            
            -- 计算英雄当前相对于中心点的角度
            local currentAngle = math.atan2(heroPos.y - centerPoint.y, heroPos.x - centerPoint.x)
            
            -- 计算英雄到中心点的距离
            local distToCenter = math.sqrt(
                (heroPos.x - centerPoint.x) * (heroPos.x - centerPoint.x) + 
                (heroPos.y - centerPoint.y) * (heroPos.y - centerPoint.y)
            )
            
            -- 计算目标位置
            local targetAngle = currentAngle + math.rad(5)  -- 在当前角度基础上增加5度
            local castPosition
            
            -- 根据当前位置判断下一个位置
            if distToCenter < radius * 0.1 then
                -- 如果在中心点附近，选择右侧位置
                castPosition = Vector(
                    centerPoint.x + radius * math.cos(targetAngle),
                    centerPoint.y + radius * math.sin(targetAngle),
                    heroPos.z
                )
            else
                -- 根据当前位置判断下一个位置应该在哪边
                -- 计算当前位置在中心点的哪一侧
                local currentSide = (heroPos.x - centerPoint.x) * math.cos(targetAngle) + 
                                  (heroPos.y - centerPoint.y) * math.sin(targetAngle)
                
                -- 选择对面的位置
                local sideMultiplier = currentSide > 0 and -radius or radius
                castPosition = Vector(
                    centerPoint.x + sideMultiplier * math.cos(targetAngle),
                    centerPoint.y + sideMultiplier * math.sin(targetAngle),
                    heroPos.z
                )
            end
        
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true

        else

            local direction = (targetInfo.target:GetOrigin() - entity:GetOrigin()):Normalized()
            local distance = (targetInfo.target:GetOrigin() - entity:GetOrigin()):Length2D()
            
            -- 获取英雄当前攻击距离
            local attackRange = entity:Script_GetAttackRange()
            
            -- 计算目标身后的位置(目标位置 + 攻击距离)
            local behindTargetPos = targetInfo.target:GetOrigin() + direction * attackRange
            
            -- 计算从自身到目标身后位置的距离
            local distanceToBehindPos = (behindTargetPos - entity:GetOrigin()):Length2D()
            
            -- 根据施法距离决定释放位置
            local newTargetPos
            if distanceToBehindPos <= abilityInfo.castRange then
                -- 如果可以到达目标身后的位置
                newTargetPos = behindTargetPos
            else
                -- 如果施法距离不够,就朝目标方向施放最大距离
                newTargetPos = entity:GetOrigin() + direction * abilityInfo.castRange
            end
            
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTargetPos, abilityInfo.castPoint)
            return true
        end

    elseif abilityInfo.abilityName == "monkey_king_boundless_strike" then
        -- 获取角色面向的前方向量并归一化
        local directionToTarget = (targetInfo.targetPos - entity:GetOrigin()):Normalized()
        
        -- 计算新的目标位置，沿前方向量移动100码
        local newTargetPos = entity:GetOrigin() + directionToTarget * 350
        
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)

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
        return true

    elseif abilityInfo.abilityName == "batrider_flamebreak" then
        local castPosition
        if targetInfo.distance <= abilityInfo.aoeRadius then
            castPosition = entity:GetOrigin()
            self:log("目标距离小于作用范围，在自身位置施放火焰切割")
        else
            if self:containsStrategy(self.hero_strategy, "弹开") then
                castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
                self:log("使用弹开策略，向后施放火焰切割")
            else
                castPosition = targetInfo.targetPos + targetInfo.targetDirection * 200
                self:log("使用普通策略，向前施放火焰切割")
            end
        end
    
        self:log(string.format("在施法距离+作用范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f，作用范围: %.2f", 
            abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange, abilityInfo.aoeRadius))
        self:log(string.format("施法位置: %s", tostring(castPosition)))
    
        -- 施放技能
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
    
        return true
        
    elseif abilityInfo.abilityName == "shadow_demon_shadow_poison" then
        -- 毒狗放毒
        local castPosition = entity:GetOrigin() + targetInfo.targetDirection * 300
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "dark_willow_bramble_maze" then
        -- 小仙女
        if targetInfo.distance < 250 then
            local castPosition = targetInfo.targetPos + targetInfo.targetDirection * 250
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        else
            local castPosition = targetInfo.targetPos - targetInfo.targetDirection * 200
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
        end
        
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "skywrath_mage_mystic_flare" and entity:HasScepter() then
        self:log("天怒双大")
        -- 计算施法位置
        local castPosition = targetInfo.targetPos - targetInfo.targetDirection * 170
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "zuus_cloud" and self:containsStrategy(self.global_strategy, "防守策略") then

        local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "zuus_cloud" and self:containsStrategy(self.hero_strategy, "对自己放雷云") then

        local castPosition = entity:GetOrigin()
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "void_spirit_aether_remnant" then

        local startPoint
        -- 根据距离判断第一个施法点的位置
        if targetInfo.distance > abilityInfo.aoeRadius then
            startPoint = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
        else
            startPoint = entity:GetOrigin() + targetInfo.targetDirection * 10
        end
    
        self:log("开始点: " .. tostring(startPoint))
        self:log("结束点: " .. tostring(targetInfo.targetPos))
    
        -- 调用施法函数
        self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, targetInfo.targetPos)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
        
        return true

    elseif abilityInfo.abilityName == "luna_eclipse" then
        -- 计算方向向量并归一化
        if self:containsStrategy(self.hero_strategy, "大招封走位") then
            local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        else
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
                        local targetName
            if target.GetUnitName then
                targetName = target:GetUnitName()
            else
                targetName = "未知单位"
            end
            self:log(string.format("找到目标 %s 准备施放技能 %s", targetName, abilityInfo.abilityName))
            self:log(string.format("目标地点是 %s ", targetInfo.targetPos ))
        
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  targetInfo.targetPos, abilityInfo.castPoint)
            return true
        end
    elseif abilityInfo.abilityName == "snapfire_mortimer_kisses" then
        local castPosition = targetInfo.targetPos - targetInfo.targetDirection * abilityInfo.aoeRadius
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "queenofpain_blink" then
  
        local castPosition = targetInfo.targetPos - (targetInfo.targetDirection * 200)
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "bloodseeker_blood_bath" then
        -- 计算方向向量并归一化
        if self:containsStrategy(self.hero_strategy, "血祭封走位") then
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

    elseif abilityInfo.abilityName == "earth_spirit_stone_caller" then
        local entityPos = entity:GetAbsOrigin()
        local castPosition
    
        if self.earthSpiritStonePosition == "脚底下" then
            local distanceToTarget = (targetInfo.targetPos - entityPos):Length2D()
            castPosition = entityPos + targetInfo.targetDirection * 50

        elseif self.earthSpiritStonePosition == "敌人身后" then
            castPosition = targetInfo.targetPos
        end
    
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("石头放置位置是 %s ", castPosition))
    
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true
    elseif abilityInfo.abilityName == "puck_waning_rift" and self:containsStrategy(self.hero_strategy, "飞身后") then
        local entityPos = entity:GetAbsOrigin()
        local targetPos = targetInfo.targetPos
        local direction = (targetPos - entityPos):Normalized()
        local distanceToTarget = (targetPos - entityPos):Length2D()
        local castPosition
        
        -- 获取技能施法距离
        local castRange = abilityInfo.castRange
        
        if distanceToTarget <= 300 then
            -- 在300范围内，朝着敌人方向施法到最远距离
            castPosition = entityPos + direction * castRange
        else
            -- 在300范围外，原地施法
            castPosition = entityPos
        end
    
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("施法位置是 %s ", castPosition))
        self:log(string.format("与目标距离 %s ", distanceToTarget))
    
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "earthshaker_fissure" and self:containsStrategy(self.hero_strategy, "朝面前沟壑") then
        -- 获取英雄当前的朝向
        local forward = entity:GetForwardVector()
        -- 计算身前100码的位置
        local castPosition = entity:GetOrigin() + forward * 100
        
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "storm_spirit_ball_lightning" then
        if self:containsStrategy(self.hero_strategy, "折叠飞") then
            if not self.foldingFlyCount then
                self.foldingFlyCount = 0
            end
            -- 初始化折叠飞记录
            if not self.foldingFlyRecords then
                self.foldingFlyRecords = {}
            end
            
            local currentFoldingFlyCount = self.foldingFlyCount
            
            -- 检查是否允许新的折叠飞进入
            if self.isFoldingFlying then
                self:log(string.format("[STORM_TEST] 检测到已有折叠飞正在进行 (当前折叠飞次数: %d)", currentFoldingFlyCount))
                
                -- 打印之前的折叠飞记录
                self:log("[STORM_TEST] 之前的折叠飞记录:")
                for i, record in ipairs(self.foldingFlyRecords) do
                    self:log(string.format("[STORM_TEST]   - ID: %d, 次数: %d, 预期飞行时间: %.3f", record.id, record.count, record.expectedFlightTime))
                end
                
                -- 检查当前次数是否已有记录
                local currentCountRecorded = false
                for _, record in ipairs(self.foldingFlyRecords) do
                    if record.count == currentFoldingFlyCount and not record.completed then
                        currentCountRecorded = true
                        break
                    end
                end
                
                if currentCountRecorded then
                    self:log(string.format("[STORM_TEST] 当前折叠飞次数 %d 已有未完成记录，不允许新的进入", currentFoldingFlyCount))
                    return false
                else
                    self:log(string.format("[STORM_TEST] 当前折叠飞次数 %d 尚无未完成记录，允许进入", currentFoldingFlyCount))
                end
            end
        
            self.isFoldingFlying = true
        
            self.currentBallLightningID = math.random(1, 1000000)
            local currentID = self.currentBallLightningID
        
            local heroPosition = entity:GetOrigin()
            local targetPosition = target:GetOrigin()
            local targetDirection = (targetPosition - heroPosition):Normalized()
            local castPosition

            if self.lastCastPosition then
                -- 计算从上一个施法点到目标位置的方向向量
                local direction = (targetPosition - self.lastCastPosition):Normalized()
                
                -- 计算新的施法位置，从目标位置再往前延伸300单位
                castPosition = targetPosition + direction * 300
            else
                -- 如果 self.lastCastPosition 不存在，计算从英雄到目标的方向
                local direction = (targetPosition - heroPosition):Normalized()
                
                -- 计算新的施法位置，目标位置后方300单位
                castPosition = targetPosition + direction * 300
            end
            
            -- 输出日志，方便调试
            self:log("原始目标位置:", targetPosition)
            self:log("最终施法位置:", castPosition)
        
            -- 获取球状闪电的飞行速度
            local ballLightningSpeed = self:getBallLightningSpeed(abilityInfo.skill)
        
            -- 确保 ballLightningSpeed 不为 nil
            if not ballLightningSpeed then
                self:log("[STORM_TEST] 警告: 无法获取球状闪电速度，使用默认值 1400")
                ballLightningSpeed = 1400
            end
        
            -- 记录开始时间
            self.ballLightningCastStartTime = GameRules:GetGameTime()
        
            -- 计算预期的转身时间
            local expectedTurnTime = self:calculateTurnTime(entity, targetPosition, castPosition)
            
            -- 获取施法前摇时间
            local expectedCastPoint = abilityInfo.castPoint or 0.3
            if not expectedCastPoint then
                self:log("[STORM_TEST] 警告: expectedCastPoint 为 nil，使用默认值 0.3")
                expectedCastPoint = 0.3
            end
            
            -- 计算到目标的距离
            local distance = (castPosition - heroPosition):Length2D()
            
            -- 计算预计飞行时间
            local expectedFlightTime = distance / ballLightningSpeed
        
            -- 创建新的折叠飞记录
            local newRecord = {
                id = currentID,
                count = currentFoldingFlyCount,
                expectedFlightTime = expectedFlightTime,
                completed = false
            }
            table.insert(self.foldingFlyRecords, newRecord)
        
            -- 如果记录超过10条，删除最旧的已完成记录
            while #self.foldingFlyRecords > 10 do
                local oldestCompletedIndex = nil
                for i, record in ipairs(self.foldingFlyRecords) do
                    if record.completed then
                        oldestCompletedIndex = i
                        break
                    end
                end
                if oldestCompletedIndex then
                    table.remove(self.foldingFlyRecords, oldestCompletedIndex)
                else
                    break  -- 如果没有已完成的记录，就停止删除
                end
            end
        
            self:log(string.format("[STORM_TEST] 准备施放下一个球状闪电 (ID: %d, 折叠飞次数: %d)", currentID, currentFoldingFlyCount))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 英雄位置: (%.2f, %.2f, %.2f)", currentID, currentFoldingFlyCount, heroPosition.x, heroPosition.y, heroPosition.z))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 施法位置: (%.2f, %.2f, %.2f)", currentID, currentFoldingFlyCount, castPosition.x, castPosition.y, castPosition.z))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 距离: %.2f", currentID, currentFoldingFlyCount, distance))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 球状闪电飞行速度: %.2f", currentID, currentFoldingFlyCount, ballLightningSpeed))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 预期转身时间: %.3f 秒", currentID, currentFoldingFlyCount, expectedTurnTime))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 预期施法前摇时间: %.3f 秒", currentID, currentFoldingFlyCount, expectedCastPoint))
            self:log(string.format("[STORM_TEST] [ID: %d, 折叠飞次数: %d] 预期飞行时间: %.3f 秒", currentID, currentFoldingFlyCount, expectedFlightTime))
        
            -- 执行向目标施法
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            self:log(string.format("[STORM_TEST] 已经发出了球状闪电指令 (ID: %d, 折叠飞次数: %d)", currentID, currentFoldingFlyCount))

            -- 检查当前 castPosition 与上一次的距离

            



            local baseTime = GameRules:GetGameTime()

            local castStartTime = baseTime
            local flightStartTime
            local hasEndedFlight = false
            local hadModifier = false
            
            -- 在定时器之前，保存 self 到局部变量 this
            local this = self
        
            if this.foldingFlyTimer then
                Timers:RemoveTimer(this.foldingFlyTimer)
            end
        
            this.foldingFlyTimer = Timers:CreateTimer(0, function()
                if not this.isFoldingFlying then
                    return nil
                end
                if this.foldingFlyCount == 0 then
                    this.foldingFlyCount = 1 
                    this:log(string.format("[STORM_TEST] 折叠飞次数增加（首次） (ID: %d, 新的折叠飞次数: %d)", currentID, this.foldingFlyCount))
                end
                local currentRelativeTime = GameRules:GetGameTime() - baseTime
                
                if not flightStartTime then
                    if entity:FindModifierByName("modifier_storm_spirit_ball_lightning") then
                        

                        self.lastCastPosition = castPosition

                        flightStartTime = currentRelativeTime
                        local actualCastTime = flightStartTime
                        this:log(string.format("[STORM_TEST] 实际施法前摇时间: %.3f 秒 (ID: %d, 折叠飞次数: %d)", actualCastTime, currentID, currentFoldingFlyCount))
                        this:log(string.format("[STORM_TEST] 预计前摇时间: %.3f 秒 (ID: %d, 折叠飞次数: %d)", (expectedTurnTime + expectedCastPoint), currentID, currentFoldingFlyCount))
                        this:log(string.format("[STORM_TEST] 施法前摇时间差异: %.3f 秒 (ID: %d, 折叠飞次数: %d)", actualCastTime - (expectedTurnTime + expectedCastPoint), currentID, currentFoldingFlyCount))
                        this:log(string.format("[STORM_TEST] 球状闪电飞行开始 (ID: %d, 折叠飞次数: %d)", currentID, currentFoldingFlyCount))
                        hadModifier = true
                    end
                else
                    if entity:FindModifierByName("modifier_storm_spirit_ball_lightning") then




                        hadModifier = true
                        local elapsedFlightTime = currentRelativeTime - flightStartTime
                        local remainingTime = expectedFlightTime - elapsedFlightTime
                        
                        -- 实时计算下一次施法时间
                        local timeToNextCast = this:calculateNextBallLightningCastTime(entity, target, abilityInfo.skill, entity:GetOrigin(), remainingTime, castPosition)
                        
                        if remainingTime > 0 and not this.parameterChangeExecuted then
                            this:log(string.format("[STORM_TEST] 预计还需 %.3f 秒到达目标地点 (ID: %d, 折叠飞次数: %d)", remainingTime, currentID, currentFoldingFlyCount))
                            this:log(string.format("[STORM_TEST] 下一次施法准备时间: %.3f 秒 (ID: %d, 折叠飞次数: %d)", timeToNextCast, currentID, currentFoldingFlyCount))
                            -- 检查是否可以准备下一次施法
                            if timeToNextCast >= remainingTime then
                                this.nextBallLightningCastReady = true
                                this.shouldStop = true
                                this.parameterChangeExecuted = true
                                this:log(string.format("[STORM_TEST] 下一次球状闪电施法已准备就绪 (ID: %d, 折叠飞次数: %d)", currentID, currentFoldingFlyCount))
                            end
                        end
                    elseif hadModifier then


                        if self.lastCastPosition and currentFoldingFlyCount >= 1 then
                            local distanceBetweenCasts = (castPosition - self.lastCastPosition):Length2D()
                            self:log(string.format("[STORM_TEST] 当前 castPosition 与上一次的距离: %.2f", distanceBetweenCasts))
            
                            if distanceBetweenCasts <= 1800 then
                                if self.hero_strategy and type(self.hero_strategy) == "table" then
                                    for i, strategy in ipairs(self.hero_strategy) do
                                        if strategy == "折叠飞" then
                                            table.remove(self.hero_strategy, i)
                                            break
                                        end
                                    end
                                end
                                self:SetState(AIStates.Idle)
                                self:log(string.format("停止折叠飞"))
                                return nil
                            end
                            
                        end
                        hadModifier = false
                        -- 增加折叠飞次数
                        this.foldingFlyCount = this.foldingFlyCount + 1
                        this:log(string.format("[STORM_TEST] 折叠飞次数增加 (ID: %d, 新的折叠飞次数: %d)", currentID, this.foldingFlyCount))
                        local flightEndTime = currentRelativeTime
                        local actualFlightTime = flightEndTime - flightStartTime
                        
                        this:log(string.format("[STORM_TEST] 球状闪电飞行结束 (ID: %d, 折叠飞次数: %d)", currentID, currentFoldingFlyCount))
                        this:log(string.format("[STORM_TEST] 实际飞行时间: %.3f 秒 (ID: %d, 折叠飞次数: %d)", actualFlightTime, currentID, currentFoldingFlyCount))
                        this:log(string.format("[STORM_TEST] 预计飞行时间: %.3f 秒 (ID: %d, 折叠飞次数: %d)", expectedFlightTime, currentID, currentFoldingFlyCount))
                        this:log(string.format("[STORM_TEST] 飞行时间差异: %.3f 秒 (ID: %d, 折叠飞次数: %d)", actualFlightTime - expectedFlightTime, currentID, currentFoldingFlyCount))
                        
                        -- 更新记录状态
                        for _, record in ipairs(this.foldingFlyRecords) do
                            if record.id == currentID then
                                record.completed = true
                                break
                            end
                        end
                        
                        hasEndedFlight = true
                        this.isFoldingFlying = false
                        return nil  -- 停止计时器
                    end
                end
                -- 在每次循环中更新日志中的折叠飞次数
                this:log(string.format("[STORM_TEST] 当前折叠飞次数: %d (ID: %d)", this.foldingFlyCount, currentID))
                if self:containsStrategy(self.hero_strategy, "默认策略") then
                    return false
                end
                return 0.03  -- 继续检查
            end)
            
            return true
        
        elseif self:containsStrategy(self.hero_strategy, "飞脸前") then

            entity:CastAbilityOnPosition(targetInfo.targetPos - targetInfo.targetDirection * 300 , abilityInfo.skill, 0)
                        local targetName
            if target.GetUnitName then
                targetName = target:GetUnitName()
            else
                targetName = "未知单位"
            end
            self:log(string.format("找到目标 %s 准备施放技能 %s", targetName, abilityInfo.abilityName))
            self:log(string.format("目标地点是 %s ", targetInfo.targetPos ))
        
            abilityInfo.castPoint = self:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            return true
        else
            local entityPos = entity:GetAbsOrigin()
            local targetPos = targetInfo.targetPos
            local direction = (targetPos - entityPos):Normalized()
            local distanceToTarget = (targetPos - entityPos):Length2D()
            local castPosition = targetPos
            
            
                -- 如果距离小于200，计算目标背后200码的位置
            castPosition = targetPos + direction * 350
            
        
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            
            local targetName
            if target.GetUnitName then
                targetName = target:GetUnitName()
            else
                targetName = "未知单位"
            end
            
            self:log(string.format("找到目标 %s 准备施放技能 %s", targetName, abilityInfo.abilityName))
            self:log(string.format("施法位置是 %s", castPosition))
            self:log(string.format("与目标距离 %s", distanceToTarget))
        
            abilityInfo.castPoint = self:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        end
        
    elseif abilityInfo.abilityName == "ember_spirit_fire_remnant" then
        local safePoints = {
            Vector(-1046.34, -2568.91, 128.00),
            Vector(-1052.44, -3368.61, 128.00),
            Vector(1289.64, -3362.54, 128.00),
            Vector(1299.61, -2518.67, 128.00)
        }
    
        local castPosition
    
        if self:containsStrategy(self.hero_strategy, "躲避模式") or self:containsStrategy(self.hero_strategy, "躲避模式1000码") then
            local myPos = entity:GetAbsOrigin()
            
            -- 找到离自己最远的安全点
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
            -- 先定义要记录的位置
            local positionToRecord = nil

            if entity:HasModifier("modifier_ember_spirit_fire_remnant") then
                -- 搜索2000码内的所有残焰
                local remnants = FindUnitsInRadius(
                    entity:GetTeamNumber(),
                    entity:GetAbsOrigin(),
                    nil,
                    3000,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL, 
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_FARTHEST,
                    false
                )

                local hasRemnant = false
                -- 检查是否有残焰
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
                if hasRemnant and self.lastCastPosition then
                    -- 分别获取各个坐标
                    local targetX = targetInfo.targetPos.x
                    local targetY = targetInfo.targetPos.y
                    local targetZ = targetInfo.targetPos.z
                    
                    local lastX = self.lastCastPosition.x
                    local lastY = self.lastCastPosition.y
                    local lastZ = self.lastCastPosition.z
                    
                    print("asdqwe目标坐标", targetX, targetY, targetZ)
                    print("asdqwe上次施法坐标", lastX, lastY, lastZ)
                    
                    -- 计算方向向量
                    local dx = targetX - lastX
                    local dy = targetY - lastY
                    local dz = targetZ - lastZ
                    
                    -- 归一化
                    local length = math.sqrt(dx*dx + dy*dy + dz*dz)
                    local dirX = dx / length
                    local dirY = dy / length
                    local dirZ = dz / length
                    
                    print("asdqwe方向分量", dirX, dirY, dirZ)
                    
                    -- 计算新位置
                    local newX = targetX + (dirX * 500)
                    local newY = targetY + (dirY * 500)
                    local newZ = targetZ + (dirZ * 500)
                    
                    print("asdqwe新计算坐标", newX, newY, newZ)
                    
                    -- 创建新的Vector
                    castPosition = Vector(newX, newY, newZ)
                    positionToRecord = castPosition
                
                
                else
                    -- 没有残焰或没有上次施法位置，使用原来的逻辑
                    castPosition = targetInfo.targetPos + targetInfo.targetDirection * 500
                    -- 记录这次的施法位置

                    self:log("残焰状态但使用默认位置：释放技能到敌人背后500码")
                    print("asdqwe没有残焰或者位置的施法")
                end
            else
                -- 原来的逻辑
                castPosition = targetInfo.targetPos + targetInfo.targetDirection * 500
                -- 记录这次的施法位置
                self:log("普通模式：释放技能到敌人背后500码")
                print("asdqwe不在飞魂状态的施法")
            end

            -- 保存这次要施法的位置，供OnSpellCast使用
            self.lastTryCastPosition = castPosition
            print("asdqwe尝试施法的位置",self.lastTryCastPosition)
        end
    
        entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        self:log(string.format("目标是 %s ", target:GetUnitName()))
        self:log(string.format("目标地点是 %s ", castPosition))
    
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        return true

    elseif abilityInfo.abilityName == "invoker_tornado" then
        if self:containsStrategy(self.hero_strategy, "帕金森") then
            -- 先检查敌人是否正在被吹起
            if self.target:HasModifier("modifier_invoker_tornado") and self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 1) then

                entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
                return true

            else
                -- 没有吹风状态时使用帕金森施法
                local basePosition = entity:GetOrigin() + targetInfo.targetDirection * 500
                
                -- 初始化 lastOffsetX 和 lastOffsetY，如果它们还不存在
                if not self.lastOffsetX then self.lastOffsetX = 0 end
                if not self.lastOffsetY then self.lastOffsetY = 0 end
                
                -- 根据上次的偏移决定这次的偏移方向
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
                
                local castPosition = Vector(
                    basePosition.x + randomOffsetX,
                    basePosition.y + randomOffsetY,
                    basePosition.z
                )
            
                -- 更新上次的偏移值
                self.lastOffsetX = randomOffsetX
                self.lastOffsetY = randomOffsetY
            
                -- 调用施法函数
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, startPoint, abilityInfo.castPoint)
                return true
            end
        else
            local enemies = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                abilityInfo.castRange,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_CLOSEST,
                false
            )
        
            for _, enemy in pairs(enemies) do
                if self:NeedsModifierRefresh(enemy, {"modifier_invoker_tornado"}, 1) then
                    local targetPosition = enemy:GetAbsOrigin()
                    entity:CastAbilityOnPosition(targetPosition, abilityInfo.skill, 0)
                    abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetPosition, abilityInfo.castPoint)
                    return true
                end
            end
        
            -- 如果没找到需要刷新龙卷风的目标，就对self.target释放
            local targetPosition = self.target:GetAbsOrigin()
            entity:CastAbilityOnPosition(targetPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetPosition, abilityInfo.castPoint)
            return true
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
    
        local distance = (targetInfo.targetPos - entity:GetAbsOrigin()):Length2D()
        local targetName = target.GetUnitName and target:GetUnitName() or "未知单位"
        
        -- 处理始终在脚下释放的技能
        if selfCastAbilities[abilityInfo.abilityName] then
            local direction = (targetInfo.targetPos - entity:GetAbsOrigin()):Normalized()
            local castPosition = entity:GetAbsOrigin() + direction * 100
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            self:log(string.format("技能 %s 在脚下1码处释放", abilityInfo.abilityName))
        
        -- 处理AOE范围内且处于防守策略的情况
        elseif distance <= abilityInfo.aoeRadius and 
               self:containsStrategy(self.global_strategy, "防守策略") and
               not targetCastAbilities[abilityInfo.abilityName] then
            local direction = (targetInfo.targetPos - entity:GetAbsOrigin()):Normalized()
            local castPosition = entity:GetAbsOrigin() + direction * 100
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            self:log(string.format("目标 %s 在AoE范围内(%d)，在前方1码处释放技能 %s", 
                targetName, abilityInfo.aoeRadius, abilityInfo.abilityName))
        
        -- 处理需要预判的技能
        elseif predictCastAbilities[abilityInfo.abilityName] then
            local targetForward = target:GetForwardVector()
            local predictedPos = targetInfo.targetPos + targetForward * abilityInfo.aoeRadius
            local distanceToPredict = (predictedPos - entity:GetAbsOrigin()):Length2D()
            local directionToPredict = (predictedPos - entity:GetAbsOrigin()):Normalized()
            
            if distanceToPredict <= abilityInfo.castRange and 
               entity:GetForwardVector():Dot(directionToPredict) > 0 then
                entity:CastAbilityOnPosition(predictedPos, abilityInfo.skill, 0)
                self:log(string.format("对目标 %s 预判施放技能 %s，位置 %s", 
                    targetName, abilityInfo.abilityName, tostring(predictedPos)))
            else
                entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
                self:log(string.format("预判位置不合适，对目标 %s 直接施放技能 %s", 
                    targetName, abilityInfo.abilityName))
            end
        elseif bit.band(abilityInfo.abilityBehavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then

            local maxCastDistance = abilityInfo.castRange + abilityInfo.aoeRadius
            
            -- 动态设置目标flags
            local targetFlags = DOTA_UNIT_TARGET_FLAG_NONE

            targetFlags = bit.bor(targetFlags, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS)

        
            -- 直接内联搜索逻辑
            local enemies = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                maxCastDistance,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                targetFlags,
                FIND_ANY_ORDER,
                false
            )
        
            -- 寻找最远单位
            local farthestDist = 0
            local farthestEnemy = nil
            for _, enemy in ipairs(enemies) do
                local dist = (enemy:GetOrigin() - entity:GetOrigin()):Length2D()
                if dist > farthestDist then
                    farthestDist = dist
                    farthestEnemy = enemy
                end
            end
        
            -- 计算施法点
            local vectorStart = targetInfo.targetPos
            local vectorEnd = vectorStart
            if farthestEnemy then
                local direction = (farthestEnemy:GetOrigin() - entity:GetOrigin()):Normalized()
                vectorEnd = entity:GetOrigin() + direction * math.min(farthestDist, maxCastDistance)
            end
        
            -- 执行施法
            self:log(string.format("矢量施法：从 %s 到 %s (最大距离%d)", 
                tostring(vectorStart), 
                tostring(vectorEnd),
                maxCastDistance))
                
            self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, vectorStart, vectorEnd)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, vectorStart, abilityInfo.castPoint)
            
            return true

        -- 其他情况直接对目标位置释放
        else
            entity:CastAbilityOnPosition(targetInfo.targetPos, abilityInfo.skill, 0)
            self:log(string.format("对目标 %s 施放技能 %s，位置 %s", 
                targetName, abilityInfo.abilityName, tostring(targetInfo.targetPos)))
        end
        
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        return true
    end
end




function CommonAI:calculateNextBallLightningCastTime(entity, target, ballLightningSkill, currentPosition, expectedFlightTime,castPosition)
    local nextTargetPosition = target:GetOrigin()
    local nextTargetDirection = (nextTargetPosition - currentPosition):Normalized()
    local nextCastPosition = nextTargetPosition
    
    local expectedTurnTime = self:calculateTurnTime(entity, nextCastPosition,castPosition)
    local expectedCastPoint = ballLightningSkill:GetCastPoint()
    
    -- 总准备时间应该是转身时间加上施法前摇时间
    local totalPreparationTime = expectedTurnTime + expectedCastPoint
    
    self:log(string.format("[STORM_TEST] 下一次球状闪电施法总准备时间: %.3f 秒 (转身: %.3f 秒, 施法前摇: %.3f 秒)", 
                           totalPreparationTime, expectedTurnTime, expectedCastPoint))
    
    -- 返回总准备时间
    return totalPreparationTime + 0.05
end

function CommonAI:getBallLightningSpeed(ability)
    local kv = ability:GetAbilityKeyValues()
    local speed = 0
    local currentLevel = ability:GetLevel()

    self:log("STORM_TEST: 进入 getBallLightningSpeed 函数")
    self:log(string.format("STORM_TEST: 当前技能等级: %d", currentLevel))

    if kv.AbilityValues then
        self:log("STORM_TEST: 在 KV 中找到 AbilityValues")
        if kv.AbilityValues.ball_lightning_move_speed then
            local speedValue = kv.AbilityValues.ball_lightning_move_speed
            self:log(string.format("STORM_TEST: 找到 ball_lightning_move_speed，类型: %s", type(speedValue)))
            if type(speedValue) == "string" then
                self:log(string.format("STORM_TEST: ball_lightning_move_speed 是字符串: %s", speedValue))
                -- 分割字符串为数字数组
                local speeds = {}
                for s in speedValue:gmatch("%S+") do
                    table.insert(speeds, tonumber(s))
                end
                self:log(string.format("STORM_TEST: 分割后的速度数组: %s", table.concat(speeds, ", ")))
                speed = speeds[currentLevel] or speeds[#speeds]
            elseif type(speedValue) == "table" then
                self:log("STORM_TEST: ball_lightning_move_speed 是一个表")
                for k, v in pairs(speedValue) do
                    self:log(string.format("STORM_TEST: 等级 %s, 速度 %s", tostring(k), tostring(v)))
                end
                speed = tonumber(speedValue[currentLevel] or speedValue[#speedValue])
            else
                speed = tonumber(speedValue)
            end
            self:log(string.format("STORM_TEST: 选择的速度: %s", tostring(speed)))
        else
            self:log("STORM_TEST: 未找到 ball_lightning_move_speed，检查特殊值键")
        end
    else
        self:log("STORM_TEST: 在 KV 中未找到 AbilityValues")
    end

    if not speed or speed == 0 then
        self:log("STORM_TEST: 警告: ball_lightning_move_speed 值无效，使用默认值")
        speed = 1400  -- 使用一个默认值，这里使用最低等级的速度
    end

    self:log(string.format("STORM_TEST: 最终返回的速度值: %s", tostring(speed)))
    return speed
end