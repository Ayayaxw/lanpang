function CommonAI:HandleEnemyPoint_OutofRangeAction(entity,target,abilityInfo,targetInfo)
    if  Main.currentChallenge == Main.Challenges.CD0_1skill then
        if abilityInfo.abilityName == "leshrac_split_earth" and target:GetUnitName() == "npc_dota_hero_queenofpain" and not self:IsInRange(target, abilityInfo.castRange +  abilityInfo.aoeRadius + 200) then
            -- 计算新的目标位置
            self:log("拉席克对付女王有妙计")
            local newTargetPosition = entity:GetOrigin() + targetInfo.targetDirection * 200
            entity:CastAbilityOnPosition(newTargetPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPosition, abilityInfo.castPoint)
            return true

        elseif abilityInfo.abilityName == "faceless_void_time_walk" then
            self:log("准备释放虚空假面的时间漫步技能")
            self:log("目标距离: " .. tostring(targetInfo.distance))
            self:log("技能施法距离: " .. tostring(abilityInfo.castRange))
            self:log("技能AOE范围: " .. tostring(abilityInfo.aoeRadius))
        
            if targetInfo.distance > abilityInfo.castRange * 2 + abilityInfo.aoeRadius or target:GetUnitName() == "npc_dota_hero_ember_spirit" then
                self:log("目标距离较远，计算最大施法距离的位置")
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
                self:log("计算得到的施法位置: x=" .. tostring(castPosition.x) .. ", y=" .. tostring(castPosition.y) .. ", z=" .. tostring(castPosition.z))
            else
                self:log("目标距离较近，计算最佳施法位置")
                castPosition = targetInfo.targetPos - targetInfo.targetDirection * (abilityInfo.castRange + abilityInfo.aoeRadius -100)
                self:log("计算得到的施法位置: x=" .. tostring(castPosition.x) .. ", y=" .. tostring(castPosition.y) .. ", z=" .. tostring(castPosition.z))
            end
        
            self:log("尝试在计算出的位置释放技能")
            local success = entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            if success then
                self:log("技能释放成功")
            else
                self:log("技能释放失败")
                self:log("当前英雄位置: x=" .. tostring(entity:GetOrigin().x) .. ", y=" .. tostring(entity:GetOrigin().y) .. ", z=" .. tostring(entity:GetOrigin().z))

            end
            
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            self:log("调整后的施法前摇时间: " .. tostring(abilityInfo.castPoint))
            return true

        elseif abilityInfo.abilityName == "sandking_burrowstrike" then

            if targetInfo.distance > abilityInfo.castRange + abilityInfo.aoeRadius + abilityInfo.castRange then
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
            else 
                castPosition = targetInfo.targetPos - targetInfo.targetDirection * (abilityInfo.castRange + abilityInfo.aoeRadius)
            end

            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  castPosition, abilityInfo.castPoint)
            return true

        elseif abilityInfo.abilityName == "void_spirit_aether_remnant" then
            local casterPos = entity:GetOrigin()
            local targetPos = targetInfo.targetPos
            local aoeRadius = abilityInfo.aoeRadius
            local castRange = abilityInfo.castRange
            
            -- 计算方向向量
            local direction = targetInfo.targetDirection
            
            -- 增加施法次数
            self.SkillcastCount = self.SkillcastCount + 1
            
            local startPoint
            local endPoint
            
            -- if self.SkillcastCount == 1 then
            --     startPoint = casterPos + direction * 10
            --     endPoint = casterPos
            -- elseif self.SkillcastCount == 2 then
            --     startPoint = casterPos + direction * 10
            --     endPoint = casterPos - direction * 200 + Vector(0, 200, 256)
            -- elseif self.SkillcastCount == 3 then
            --     startPoint = casterPos + direction * 10
            --     endPoint = casterPos - direction * 200 - Vector(0, 200, 256)
            -- else
                startPoint = entity:GetOrigin()
                local baseDirection = (targetPos - startPoint):Normalized()

                local angle = ((self.SkillcastCount - 4) % 8) * 45
                local radians = math.rad(angle)
                local rotatedDirection = Vector(
                    baseDirection.x * math.cos(radians) - baseDirection.y * math.sin(radians),
                    baseDirection.x * math.sin(radians) + baseDirection.y * math.cos(radians),
                    baseDirection.z
                )
                endPoint = startPoint + rotatedDirection * aoeRadius
            
                -- 添加更多调试输出
                self:log("基础方向: " .. tostring(baseDirection))
                self:log("施法次数: " .. self.SkillcastCount)
                self:log("旋转角度: " .. angle .. "度")
                self:log("旋转方向: " .. tostring(rotatedDirection))
                self:log("开始点: " .. tostring(startPoint))
                self:log("结束点: " .. tostring(endPoint))
            -- end
            
            self:log("开始点: " .. tostring(startPoint))
            self:log("结束点: " .. tostring(endPoint))
            
            -- 调用施法函数
            self:CastVectorSkillToTwoPoints(entity, abilityInfo.skill, startPoint, endPoint)
            return true


        elseif abilityInfo.abilityName == "morphling_waveform" then
            castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true

        elseif abilityInfo.abilityName == "void_spirit_astral_step" and target:GetUnitName()~="npc_dota_hero_life_stealer" then
            castPosition = targetInfo.targetPos - targetInfo.targetDirection * 1000
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        end

    else
        if abilityInfo.abilityName == "puck_waning_rift" and self:containsStrategy(self.hero_strategy, "沉默赶路") then

            if targetInfo.distance > abilityInfo.castRange + abilityInfo.aoeRadius + abilityInfo.castRange then
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
            else 
                castPosition = targetInfo.targetPos - targetInfo.targetDirection * (abilityInfo.castRange + abilityInfo.aoeRadius)
            end

            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  castPosition, abilityInfo.castPoint)
            return true

        elseif abilityInfo.abilityName == "disruptor_static_storm" then
            
            if self:containsStrategy(self.hero_strategy, "防帕克") then
                local entity_position = entity:GetAbsOrigin()
                local forward_vector = entity:GetForwardVector()
                local cast_position = entity_position + forward_vector * 300
                entity:CastAbilityOnPosition(cast_position, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, cast_position, abilityInfo.castPoint)
                return true
            end

        elseif abilityInfo.abilityName == "muerta_the_calling" then
            if self:containsStrategy(self.hero_strategy, "防帕克") then
                local entity_position = entity:GetAbsOrigin()
                local forward_vector = entity:GetForwardVector()
                local cast_position = entity_position + forward_vector * 300
                entity:CastAbilityOnPosition(cast_position, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, cast_position, abilityInfo.castPoint)
                return true
            elseif self:containsStrategy(self.hero_strategy, "铺满") then
                if not self.muerta_cast_count then
                    self.muerta_cast_count = 0
                end
                
                local entity_position = entity:GetAbsOrigin()
                local target_position = self.target:GetAbsOrigin()
                -- 计算朝向敌人的单位向量
                local direction = (target_position - entity_position):Normalized()
                local cast_distance = 0
                
                cast_distance = self.muerta_cast_count * 150  -- 从0开始,每次+150
                
                if cast_distance >= abilityInfo.castRange then
                    -- 如果超过最大施法距离，先用最大距离释放一次
                    cast_distance = abilityInfo.castRange
                    self.muerta_cast_count = 0  -- 重置为0，下次从头开始
                else
                    self.muerta_cast_count = self.muerta_cast_count + 1
                end
                
                local cast_position = entity_position + direction * cast_distance
                entity:CastAbilityOnPosition(cast_position, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, cast_position, abilityInfo.castPoint)
                return true
            end

        elseif abilityInfo.abilityName == "viper_nethertoxin" then
            if self:containsStrategy(self.global_strategy, "防守策略") then
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.aoeRadius - 50
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                return true
            end
        elseif abilityInfo.abilityName == "juggernaut_healing_ward" then
            local newTargetPos = entity:GetOrigin() + targetInfo.targetDirection * 350
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)
            return true
        elseif abilityInfo.abilityName == "elder_titan_ancestral_spirit" then
            local newTargetPos = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
            entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPos, abilityInfo.castPoint)
            return true

        -- elseif abilityInfo.abilityName == "drow_ranger_wave_of_silence" then
        --     if self:containsStrategy(self.global_strategy, "防守策略") then
        --         castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange - 50
        --         entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
        --         abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
        --         return true
        --     end
        elseif abilityInfo.abilityName == "treant_natures_grasp" then
            if self:containsStrategy(self.global_strategy, "防守策略") then
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange - 50
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                return true
            end
        elseif abilityInfo.abilityName == "earthshaker_enchant_totem" then
            if self:containsStrategy(self.hero_strategy, "图腾赶路") then
                castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
                entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
                return true
            end
        elseif abilityInfo.abilityName == "morphling_waveform" and self:containsStrategy(self.hero_strategy, "波赶路")  then
            castPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        elseif abilityInfo.abilityName == "earth_spirit_stone_caller" then
            local entityPos = entity:GetAbsOrigin()
            local castPosition
        
            if self.earthSpiritStonePosition == "脚底下" then
                local distanceToTarget = (targetInfo.targetPos - entityPos):Length2D()
                
                if distanceToTarget > 200 then
                    castPosition = entityPos + targetInfo.targetDirection * 200
                else
                    castPosition = entityPos + targetInfo.targetDirection * 50
                end
            else 
                return false
            end
        
            entity:CastAbilityOnPosition(castPosition, abilityInfo.skill, 0)
            self:log(string.format("目标是 %s ", target:GetUnitName()))
            self:log(string.format("石头放置位置是 %s ", castPosition))
        
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castPosition, abilityInfo.castPoint)
            return true
        end

        return false
    end
end