function CommonAI:HandleEnemyTargetAction(entity,target,abilityInfo,targetInfo)
    self:log(string.format("在施法范围内，准备施放技能: %s，目标距离: %.2f，施法距离: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.castRange))
    -- 检查技能名称


    if abilityInfo.abilityName == "pugna_life_drain" then
        -- 查找附近是否存在友方单位 npc_dota_pugna_nether_ward
        local allies = FindUnitsInRadius(
            entity:GetTeamNumber(),
            entity:GetOrigin(),
            nil,
            700,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        local netherWard = nil
    
        for _, ally in pairs(allies) do
            if ally:GetUnitName() == "npc_dota_pugna_nether_ward" then
                netherWard = ally
                break
            end
        end
    
        -- 如果找到npc_dota_pugna_nether_ward
        if netherWard then
            -- 查找netherWard周围是否有敌人
            local enemiesAroundNetherWard = FindUnitsInRadius(
                netherWard:GetTeamNumber(),
                netherWard:GetOrigin(),
                nil,
                700,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )
            
            -- 如果netherWard周围有敌人且周围敌人数量超过2，释放技能到netherWard
            if #enemiesAroundNetherWard > 0 and self.enemyHeroCount >= 2 then
                entity:CastAbilityOnTarget(netherWard, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, netherWard:GetOrigin(), abilityInfo.castPoint)
            else
                entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            end
        else
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        end

    elseif abilityInfo.abilityName == "lich_chain_frost" then
        -- 查找附近是否存在友方单位 npc_dota_pugna_nether_ward
        local allies = FindUnitsInRadius(
            entity:GetTeamNumber(),
            entity:GetOrigin(),
            nil,
            abilityInfo.castRange,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        local ice_spire = nil
    
        for _, ally in pairs(allies) do
            if ally:GetUnitName() == "npc_dota_lich_ice_spire" then
                ice_spire = ally
                break
            end
        end
    
        -- 如果找到npc_dota_pugna_nether_ward
        if ice_spire then
            -- 查找netherWard周围是否有敌人
            local enemiesAroundice_spire = FindUnitsInRadius(
                ice_spire:GetTeamNumber(),
                ice_spire:GetOrigin(),
                nil,
                700,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )
            
            if #enemiesAroundice_spire > 0 then
                entity:CastAbilityOnTarget(ice_spire, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, ice_spire:GetOrigin(), abilityInfo.castPoint)
            else
                entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            end
        else
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        end


    elseif abilityInfo.abilityName == "pugna_decrepify" then
        if self.enemyHeroCount >= 2 then
            self:log("目标大于2")
            entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
        else
            self:log("目标小于2")
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        end


    elseif abilityInfo.abilityName == "terrorblade_sunder" then
        local radius = 800
        local highestEnemyHeroHP = 0
        local highestHPUnit = nil
        local highestHPPercentage = 0
        local enemyTarget = nil
    
        -- 寻找周围800码的敌方英雄单位，排除召唤单位和幻象
        local enemyHeroes = FindUnitsInRadius(
            entity:GetTeamNumber(),
            entity:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
            FIND_ANY_ORDER,
            false
        )
    
        for _, hero in pairs(enemyHeroes) do
            if hero:IsRealHero() then
                local hpPercentage = hero:GetHealthPercent()
                if hpPercentage > highestEnemyHeroHP then
                    highestEnemyHeroHP = hpPercentage
                    enemyTarget = hero
                end
            end
        end
    
        -- 寻找周围800码的所有英雄单位，包括幻象和敌我双方
        local allUnits = FindUnitsInRadius(
            entity:GetTeamNumber(),
            entity:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
    
        for _, unit in pairs(allUnits) do
            if unit:IsHero() then
                local hpPercentage = unit:GetHealthPercent()
                if hpPercentage > highestHPPercentage then
                    highestHPPercentage = hpPercentage
                    highestHPUnit = unit
                end
            end
        end
    
        if highestHPPercentage > (highestEnemyHeroHP + 50) then
            self.target = highestHPUnit
        else
            self.target = enemyTarget
        end
    
        if self.target then
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.target:GetAbsOrigin(), abilityInfo.castPoint)
        end
    

    elseif abilityInfo.abilityName == "kez_kazurai_katana" then
        ExecuteOrderFromTable({
            UnitIndex = entity:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
            Position = self.target:GetAbsOrigin(),
            TargetIndex = self.target:entindex(),
            AbilityIndex = abilityInfo.skill:entindex(),
        })
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.target:GetAbsOrigin(), abilityInfo.castPoint)


    elseif abilityInfo.abilityName == "marci_companion_run" then 

        CommonAI:CastVectorSkillToUnitAndPoint(entity, abilityInfo.skill, self.target, targetInfo.targetPos)

        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)

    elseif abilityInfo.abilityName == "muerta_dead_shot" then
        if self.originTargetPosition then
            -- 检查技能是否准备就绪
            if abilityInfo.skill:IsFullyCastable() then
                -- 获取技能索引
                local abilityIndex = abilityInfo.skill:GetEntityIndex()
                self:log("Ability index: " .. abilityIndex)
    
                -- 获取目标位置
                local targetPosition = self.originTargetPosition
                local treeIndex = self.target:entindex()
                local startPosition = entity:GetOrigin()
                
                local order1 = {
                    UnitIndex = entity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION,
                    Position = targetPosition,
                    TargetIndex = GetTreeIdForEntityIndex(treeIndex),
                    AbilityIndex = abilityIndex,
                }

                local order2 = {
                    UnitIndex = entity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET_TREE,
                    TargetIndex = GetTreeIdForEntityIndex(treeIndex),
                    AbilityIndex = abilityIndex,
                    Position = targetPosition,
                }

                ExecuteOrderFromTable(order1)
                ExecuteOrderFromTable(order2)
                print("开枪！")
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.originTargetPosition, abilityInfo.castPoint)
            else
                entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            end
        else
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        end

    elseif abilityInfo.abilityName == "monkey_king_tree_dance" then
        -- 获取角色面向的前方向量并归一化
        local forwardDirection = entity:GetForwardVector():Normalized()
        
        -- 查找最近的树
        local trees = GridNav:GetAllTreesAroundPoint(entity:GetOrigin(), 500, true)
        local closestTree = nil
        local closestDistance = math.huge
    
        for _, tree in pairs(trees) do
            local treePos = tree:GetAbsOrigin()
            local treedistance = (treePos - entity:GetOrigin()):Length2D()
            local directionToTree = (treePos - entity:GetOrigin()):Normalized()
            
            -- 确保树不在角色身后
            if treedistance < closestDistance and directionToTree:Dot(forwardDirection) > 0 then
                closestTree = tree
                closestDistance = treedistance
            end
        end
    
        if closestTree then
            -- 施放技能到最近的树
            entity:CastAbilityOnTarget(closestTree, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, closestTree:GetOrigin(), abilityInfo.castPoint)
        else
            -- 找不到合适的树，输出错误信息或进行其他处理
            self:log("No suitable tree found for Monkey King Tree Dance.")
        end

    elseif abilityInfo.abilityName == "luna_eclipse" then
        -- 计算方向向量并归一化
        local forwardDirection = entity:GetForwardVector():Normalized()

        -- 计算新的目标位置，沿前方向量移动1200码
        local newTargetPos = entity:GetOrigin() + forwardDirection * 675

        -- 施放技能到新的目标位置
        entity:CastAbilityOnPosition(newTargetPos, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, newTargetPos, abilityInfo.castPoint)

    elseif abilityInfo.abilityName == "ancient_apparition_cold_feet" then
        -- 计算方向向量并归一化
        if not self.target:HasModifier("modifier_cold_feet") then
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
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
                entity:CastAbilityOnTarget(newTarget, abilityInfo.skill, 0)
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

    elseif abilityInfo.abilityName == "death_prophet_spirit_siphon" then
        -- 计算方向向量并归一化
        self:log("死亡先知吸血")
        if not self.target:HasModifier("modifier_death_prophet_spirit_siphon_slow") then
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        else
            -- 检查英雄当前生命值是否低于50%
            local isLowHealth = entity:GetHealth() / entity:GetMaxHealth() < 0.5
            local newTarget = nil
            local closestDistance = abilityInfo.castRange
    
            local enemies = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                1200,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                isLowHealth and (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC) or DOTA_UNIT_TARGET_HERO,
                0,
                FIND_CLOSEST,
                false
            )
    
            for _, enemy in pairs(enemies) do
                if not enemy:HasModifier("modifier_death_prophet_spirit_siphon_slow") then
                    if isLowHealth or (enemy:IsHero() and not enemy:IsSummoned()) then
                        local distance = (enemy:GetOrigin() - entity:GetOrigin()):Length2D()
                        if distance < closestDistance then
                            newTarget = enemy
                            closestDistance = distance
                        end
                    end
                end
            end
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnTarget(newTarget, abilityInfo.skill, 0)
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
                table.insert(self.disabledSkills[heroName], "death_prophet_spirit_siphon")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end

    elseif abilityInfo.abilityName == "bloodseeker_rupture" then
        self:log("血魔破裂")
        if not self.target:HasModifier("modifier_bloodseeker_rupture") then
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        else
            local newTarget = nil
            local closestDistance = abilityInfo.castRange
    
            local enemies = FindUnitsInRadius(
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
    
            for _, enemy in pairs(enemies) do
                if not enemy:HasModifier("modifier_bloodseeker_rupture") then
                    if enemy:IsHero() and not enemy:IsSummoned() then
                        local distance = (enemy:GetOrigin() - entity:GetOrigin()):Length2D()
                        if distance < closestDistance then
                            newTarget = enemy
                            closestDistance = distance
                        end
                    end
                end
            end
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnTarget(newTarget, abilityInfo.skill, 0)
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
                table.insert(self.disabledSkills[heroName], "bloodseeker_rupture")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end
    elseif abilityInfo.abilityName == "shadow_demon_demonic_purge" then
        self:log("暗影恶魔净化")
        if not self.target:HasModifier("modifier_shadow_demon_purge_slow") then
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        else
            local newTarget = nil
            local closestDistance = abilityInfo.castRange
    
            local enemies = FindUnitsInRadius(
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
    
            for _, enemy in pairs(enemies) do
                if not enemy:HasModifier("modifier_shadow_demon_purge_slow") then
                    if enemy:IsHero() and not enemy:IsSummoned() then
                        local distance = (enemy:GetOrigin() - entity:GetOrigin()):Length2D()
                        if distance < closestDistance then
                            newTarget = enemy
                            closestDistance = distance
                        end
                    end
                end
            end
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnTarget(newTarget, abilityInfo.skill, 0)
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
                table.insert(self.disabledSkills[heroName], "shadow_demon_demonic_purge")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end
        


    elseif abilityInfo.abilityName == "oracle_fortunes_end" and (entity:IsRooted() or targetInfo.name == "npc_dota_hero_void_spirit" or targetInfo.name == "npc_dota_hero_silencer") then

        -- 检查是否有 modifier_oracle_fortunes_end_purge 并且剩余时间大于 0.1 秒
        local modifier = entity:FindModifierByName("modifier_oracle_fortunes_end_purge_repeatedly")
        if modifier and modifier:GetRemainingTime() > 0.1 then
            self:log("Found modifier_oracle_fortunes_end_purge with remaining time: " .. modifier:GetRemainingTime())
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
        else
            entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
        end
        
       



    elseif abilityInfo.abilityName == "windrunner_shackleshot" then

        local function hasValidShackleModifier(unit)
            local modifier = unit:FindModifierByName("modifier_windrunner_shackle_shot")
            return modifier and modifier:GetRemainingTime() > 0.5
        end
    
        if not hasValidShackleModifier(self.target) then
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
        else
            -- 搜索施法距离范围内其他没有有效modifier_windrunner_shackle_shot的英雄单位
            local newTarget = nil
            local closestDistance = abilityInfo.castRange
    
            local heroes = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                abilityInfo.castRange,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                0,
                FIND_CLOSEST,
                false
            )
    
            for _, hero in pairs(heroes) do
                if hero:IsHero() and not hero:IsSummoned() and not hasValidShackleModifier(hero) then
                    local distance = (hero:GetOrigin() - entity:GetOrigin()):Length2D()
                    if distance < closestDistance then
                        newTarget = hero
                        closestDistance = distance
                    end
                end
            end
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnTarget(newTarget, abilityInfo.skill, 0)
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
                table.insert(self.disabledSkills[heroName], "windrunner_shackleshot")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end

    elseif abilityInfo.abilityName == "lion_voodoo" then
        local targetToCast = FindSuitableTarget(entity, abilityInfo, "modifier_lion_voodoo", false, "enemy")
        
        if targetToCast then
            if log then
                log(string.format("莱恩技能检查: 选择目标 %s", targetToCast:GetUnitName()))
            end
            entity:CastAbilityOnTarget(targetToCast, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetToCast:GetAbsOrigin(), abilityInfo.castPoint)
        else
            if log then
                log("莱恩技能检查: 未找到合适的目标")
            end
        end

    elseif abilityInfo.abilityName == "shadow_shaman_voodoo" then
        local targetToCast = FindSuitableTarget(entity, abilityInfo, "modifier_shadow_shaman_voodoo", false, "enemy")
        
        if targetToCast then
            if log then
                log(string.format("暗影萨满技能检查: 选择目标 %s", targetToCast:GetUnitName()))
            end
            entity:CastAbilityOnTarget(targetToCast, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetToCast:GetAbsOrigin(), abilityInfo.castPoint)
        else
            if log then
                log("暗影萨满技能检查: 未找到合适的目标")
            end
        end







    elseif abilityInfo.abilityName == "lich_chain_frost" then
        if abilityInfo.castRange == 9999 then
            local nearestIceSpire = nil
            local nearestDistance = math.huge
    
            local iceSpires = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                9999, -- 使用最大搜索范围
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                FIND_CLOSEST,
                false
            )
    
            for _, spire in pairs(iceSpires) do
                if spire:GetUnitName() == "npc_dota_lich_ice_spire" and spire:IsMagicImmune() then
                    local distance = (spire:GetOrigin() - entity:GetOrigin()):Length2D()
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestIceSpire = spire
                    end
                end
            end
    
            if nearestIceSpire then
                entity:CastAbilityOnTarget(nearestIceSpire, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, nearestIceSpire:GetAbsOrigin(), abilityInfo.castPoint)
                return -- 技能已释放，直接返回
            end
        else
            -- 如果 castRange 不等于 9999，使用原始目标
            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            return -- 技能已释放，直接返回
        end


    elseif abilityInfo.abilityName == "oracle_fates_edict" then
        local castTarget = FindSuitableTarget(entity, abilityInfo, "modifier_oracle_fates_edict", true, "both")
        
        if castTarget then
            entity:CastAbilityOnTarget(castTarget, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, castTarget:GetAbsOrigin(), abilityInfo.castPoint)
        else
            if log then
                log("先知技能检查: 未找到合适的目标")
            end
        end


    elseif abilityInfo.abilityName == "clinkz_tar_bomb" then
        -- 计算方向向量并归一化
        if self:NeedsModifierRefresh(self.target,{"modifier_clinkz_tar_bomb_slow"}, 0) then

            entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
    
        else
            local newTarget = self:FindUntargetedUnitInRange(entity, abilityInfo, {"modifier_clinkz_tar_bomb_slow"}, 0)
    
            if newTarget then
                -- 找到新目标，对新目标施放技能
                entity:CastAbilityOnTarget(newTarget, abilityInfo.skill, 0)
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
                table.insert(self.disabledSkills[heroName], "clinkz_tar_bomb")
                self:log(string.format("技能 %s 已加入禁用列表", abilityInfo.abilityName))
            end
        end
        return true


    else
        entity:CastAbilityOnTarget(self.target, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
    end
    
end



function FindSuitableTarget(entity, abilityInfo, modifierName, canTargetSelf, targetTeam)
    local radius = abilityInfo.castRange
    local teamFilter = DOTA_UNIT_TARGET_TEAM_BOTH
    if targetTeam == "enemy" then
        teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
    elseif targetTeam == "friendly" then
        teamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end

    local units = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetAbsOrigin(),
        nil,
        radius,
        teamFilter,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

    local function isValidTarget(unit)
        if not canTargetSelf and unit == entity then
            return false
        end
        local modifierInstance = unit:FindModifierByName(modifierName)
        return not modifierInstance or modifierInstance:GetRemainingTime() < 0.5
    end

    local heroTarget = nil
    local creepTarget = nil

    for _, unit in ipairs(units) do
        if isValidTarget(unit) then
            if unit:IsHero() then
                heroTarget = unit
                break  -- 找到符合条件的英雄立即退出循环
            elseif not creepTarget then
                creepTarget = unit  -- 记录第一个找到的符合条件的非英雄单位
            end
        end
    end

    if heroTarget then
        return heroTarget
    elseif creepTarget then
        return creepTarget
    elseif #units > 0 and (canTargetSelf or units[1] ~= entity) then
        return units[1]  -- 如果没有找到符合条件的目标，选择最近的单位
    end

    return nil  -- 如果没有找到任何合适的目标
end