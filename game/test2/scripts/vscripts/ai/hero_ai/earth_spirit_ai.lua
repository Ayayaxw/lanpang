EarthSpiritAI = {}
setmetatable(EarthSpiritAI, {__index = CommonAI})

function EarthSpiritAI.new(entity)
    local instance = CommonAI.new(entity)
    setmetatable(instance, {__index = EarthSpiritAI})
    instance:constructor(entity)  -- 调用 EarthSpiritAI 的构造函数
    return instance
end

function EarthSpiritAI:constructor(entity)
    CommonAI.constructor(self, entity)  -- 调用父类的构造函数
    -- EarthSpiritAI 特有的初始化代码
end

AIStates = {
    Idle = 0,
    Seek = 1,
    Attack = 2,
    CastSpell = 4,
    Channeling = 8,
    UseItem = 16,
    PostCast = 32,
    PreparingCast = 64,
}

function EarthSpiritAI:Think(entity)

    if not self.boulder_smashcount then
        self.boulder_smashcount = 0 
    end

    if not self.petrifyBoulderSmashCount then
        self.petrifyBoulderSmashCount = 0
    end

    self.entity = entity  -- 设置当前实体
    if hero_duel.EndDuel then
        return 1
    end
    if not entity:IsAlive() then
        local respawnTime = entity:GetRespawnTime()
        self:log(string.format("英雄死亡，等待复活... 复活剩余时间: %.2f 秒", respawnTime))
        return respawnTime + 1.0  -- 等待复活时间再多加 1 秒后再次检查
    end
    if self.currentState == AIStates.CastSpell or self.currentState == AIStates.Channeling then
        self:log("正在施法中，跳过本次 AI 思考过程")
        return self.nextThinkTime
    end

    self:log("开始寻找目标...")
    local target, enemyHeroCount = self:FindHeroTarget(entity)
    self.enemyHeroCount = enemyHeroCount
    if target then
        self:log("找到英雄目标了，敌人数量：" .. self.enemyHeroCount)
        local targetPos = target:GetOrigin()
    else
        self:log("没有找到英雄目标")
    end

    -- 如果没有找到英雄单位，再寻找普通单位

    local ally = self:FindNearestNoSelfAlly(entity)

    --获取土猫可用技能
    local earthSpiritAbilities = GetEarthSpiritAbilities(entity)


    if earthSpiritAbilities["earth_spirit_geomagnetic_grip"] then
        geomagnetic_grip_castRange = CommonAI:GetSkillCastRange(entity, earthSpiritAbilities["earth_spirit_geomagnetic_grip"])
    end
    if earthSpiritAbilities["earth_spirit_stone_caller"] then
        stone_caller_castRange = CommonAI:GetSkillCastRange(entity, earthSpiritAbilities["earth_spirit_stone_caller"])
    end
    if earthSpiritAbilities["earth_spirit_boulder_smash"] then
        boulder_smash_castRange = CommonAI:GetSkillCastRange(entity, earthSpiritAbilities["earth_spirit_boulder_smash"])
    end
    if earthSpiritAbilities["earth_spirit_rolling_boulder"] then
        rolling_boulder_castRange = CommonAI:GetSkillCastRange(entity, earthSpiritAbilities["earth_spirit_rolling_boulder"])
    end
    if earthSpiritAbilities["earth_spirit_petrify"] then
        spirit_petrify_castRange = CommonAI:GetSkillCastRange(entity, earthSpiritAbilities["earth_spirit_petrify"])
    end

    if not target then
        target = self:FindTarget(entity)
        if target then
            self:log("找到普通目标了")
            local targetPos = target:GetOrigin()
        else
            local target = self:FindNearestEnemyLastResort(entity)
            self:log("没有单位，挂机")
            local distanceToTarget = (target:GetAbsOrigin() - entity:GetAbsOrigin()):Length2D()
            local targetDirection = (target:GetOrigin() - entity:GetOrigin()):Normalized()
            if earthSpiritAbilities["earth_spirit_rolling_boulder"] then
                local maxDistance = target:GetUnitName() == "npc_dota_hero_faceless_void" and 1450 or 2180
                if distanceToTarget <= maxDistance then
                    local entityPos = entity:GetAbsOrigin()
                    local targetPos = target:GetAbsOrigin()
                    local direction = (targetPos - entityPos):Normalized()
                    local endPoint = entityPos + direction * 950
                    local width = 180
                
                    -- 查找直线上是否存在符合条件的单位
                    local unitsInLine = FindUnitsInLine(
                        entity:GetTeamNumber(),
                        entityPos,
                        endPoint,
                        nil,
                        width,
                        DOTA_UNIT_TARGET_TEAM_BOTH,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE
                    )
                
                    local validStoneFound = false
                    for _, unit in pairs(unitsInLine) do
                        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                            validStoneFound = true
                            break
                        end
                    end
                
                    if validStoneFound then
                        -- 如果找到符合条件的单位，对敌人释放 Rolling Boulder
                        self:log("找到有效的石头，对敌人释放 Rolling Boulder")
                        entity:CastAbilityOnPosition(targetPos, earthSpiritAbilities["earth_spirit_rolling_boulder"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_rolling_boulder"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_rolling_boulder"], castPoint, 0, target)
                    else
                        -- 如果没有找到，在自己身前朝向敌人方向 250码的地方释放 Stone Caller
                        self:log("没找到有效的石头，在前方 250 码处释放 Stone Caller")
                        local stonePos = entityPos + direction * 250
                        entity:CastAbilityOnPosition(stonePos, earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                    end
                end
            end

            if earthSpiritAbilities["earth_spirit_petrify"] and not entity:HasModifier("modifier_earth_spirit_rolling_boulder_caster") then
                local targetDirection = (target:GetOrigin() - entity:GetOrigin()):Normalized()
                local entityForwardVector = entity:GetForwardVector()
                local dotProduct = targetDirection:Dot(entityForwardVector)
            

                if dotProduct > 0.8 then
                    entity:CastAbilityOnTarget(entity, earthSpiritAbilities["earth_spirit_petrify"], -1)
                    if earthSpiritAbilities["earth_spirit_petrify"] then
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_petrify"])
                        self:log("自己化身残岩：", castPoint)
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_petrify"], castPoint, 0, target)
                    else
                        self:log("earth_spirit_petrify 技能不可用")
                        -- 处理技能不可用的情况
                    end

                else
                end
            end

            if earthSpiritAbilities["earth_spirit_boulder_smash"] and distanceToTarget <= 2180 then

                self.boulder_smashcount = self.boulder_smashcount + 1

                -- 查找自己身边200范围内的符合条件的无敌单位
                local units = FindUnitsInRadius(
                    entity:GetTeamNumber(),
                    entity:GetAbsOrigin(),
                    nil,
                    200,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_ANY_ORDER,
                    false
                )
            
                local validStoneFound = false
                for _, unit in pairs(units) do
                    if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                        validStoneFound = true
                        break
                    end
                end
            
                if validStoneFound then
                    -- 如果有符合条件的单位，对着target的位置释放技能
                    self:log("找到有效的石头，对目标位置释放 Boulder Smash")
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_boulder_smash"], -1)
                    local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_boulder_smash"])
                    return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_boulder_smash"], castPoint, 0, target)
                else
                    -- 如果没有，就对着自己脚底下释放 Stone Caller
                    self:log("没找到有效的石头，在自己脚下释放 Stone Caller")
                    entity:CastAbilityOnPosition(entity:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                    local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                    return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                end
            end


            return self.nextThinkTime
        end
    end

    local distanceToTarget = (target:GetAbsOrigin() - entity:GetAbsOrigin()):Length2D()
    local targetDirection = (target:GetOrigin() - entity:GetOrigin()):Normalized()
    --有没有被控
    if not CommonAI:IsUnableToCastAbility(entity) then
        --判断有没有石头
        local stone_charger
        if entity:GetHeroFacetID() ~= 2 then
            stone_charger = earthSpiritAbilities["earth_spirit_stone_caller"]:GetCurrentAbilityCharges()

        else
            if earthSpiritAbilities["earth_spirit_stone_caller"]:IsFullyCastable() then
                stone_charger = 1
            else 
                stone_charger = 0
            end
        end


        --有石头的土猫
        --有石头的土猫

        if entity:HasModifier("modifier_earthspirit_petrify") then
            -- 如果有符合条件的单位，对着target的位置释放技能
            self:log("自己就是石头，冲")
            entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_boulder_smash"], -1)
            local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_boulder_smash"])
            return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_boulder_smash"], castPoint, 0, target)

        else
            if stone_charger > 0 then
                self:log("土猫有石头，石头数量：", stone_charger)

                --续大招磁化
                local magnetizeModifier = target:FindModifierByName("modifier_earth_spirit_magnetize")
                if magnetizeModifier and magnetizeModifier:GetRemainingTime() < 1 then
                    self:log("续大招磁化，剩余时间：", magnetizeModifier:GetRemainingTime())
                    entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                    local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                    self:log("续大招磁化，施法前摇：", castPoint)
                    return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                end



                --对面附近有石头就拉石头
                if earthSpiritAbilities["earth_spirit_geomagnetic_grip"] and distanceToTarget <= geomagnetic_grip_castRange then
                    self:log("检查是否可以拉石头，与目标距离：", distanceToTarget, "技能施法距离：", geomagnetic_grip_castRange)
                    local stonePos = FindGeomagneticGripTarget(entity, geomagnetic_grip_castRange, target)
                    if stonePos then 
                        self:log("找到石头，位置：", stonePos.x, stonePos.y, stonePos.z)
                        entity:CastAbilityOnPosition(stonePos, earthSpiritAbilities["earth_spirit_geomagnetic_grip"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_geomagnetic_grip"])
                        self:log("拉石头，施法前摇：", castPoint)
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_geomagnetic_grip"], castPoint, 0, target)
                    --旁边没有石头，准备自己放
                    elseif distanceToTarget > stone_caller_castRange and distanceToTarget <= stone_caller_castRange + 100 then
                        self:log("目标超出扔石头范围，准备在最大范围处扔石头")
                        local newTargetPos = entity:GetOrigin() + stone_caller_castRange * targetDirection
                        --超过施法范围，对着施法范围最大处扔石头
                        entity:CastAbilityOnPosition(newTargetPos, earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                        self:log("扔石头到最大范围，施法前摇：", castPoint)
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                    elseif distanceToTarget <= stone_caller_castRange then
                        self:log("目标在扔石头范围内，直接对目标扔石头")
                        entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                        self:log("对目标扔石头，施法前摇：", castPoint)
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                    else
                        self:log("距离检查失败，不符合任何条件")
                    end
                end

                --放大招
                if earthSpiritAbilities["earth_spirit_magnetize"] and distanceToTarget <= 300 then
                    self:log("准备放大招，与目标距离：", distanceToTarget)
                    entity:CastAbilityNoTarget(earthSpiritAbilities["earth_spirit_magnetize"], -1)
                    local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_magnetize"])
                    self:log("放大招，施法前摇：", castPoint)
                    return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_magnetize"], castPoint, 0, target)
                end


                --滚
                if earthSpiritAbilities["earth_spirit_rolling_boulder"] then
                    local maxDistance = (target:GetUnitName() == "npc_dota_hero_faceless_void" or (target:GetUnitName() == "npc_dota_hero_storm_spirit" and self.boulder_smashcount < 3)) and 1450 or 2180
                    if distanceToTarget <= maxDistance then
                        local entityPos = entity:GetAbsOrigin()
                        local targetPos = target:GetAbsOrigin()
                        local direction = (targetPos - entityPos):Normalized()
                        local endPoint = entityPos + direction * 950
                        local width = 180
                    
                        -- 查找直线上是否存在符合条件的单位
                        local unitsInLine = FindUnitsInLine(
                            entity:GetTeamNumber(),
                            entityPos,
                            endPoint,
                            nil,
                            width,
                            DOTA_UNIT_TARGET_TEAM_BOTH,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_INVULNERABLE
                        )
                    
                        local validStoneFound = false
                        for _, unit in pairs(unitsInLine) do
                            if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                                validStoneFound = true
                                break
                            end
                        end
                    
                        if validStoneFound then
                            -- 如果找到符合条件的单位，对敌人释放 Rolling Boulder
                            self:log("找到有效的石头，对敌人释放 Rolling Boulder")
                            entity:CastAbilityOnPosition(targetPos, earthSpiritAbilities["earth_spirit_rolling_boulder"], -1)
                            local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_rolling_boulder"])
                            return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_rolling_boulder"], castPoint, 0, target)
                        else
                            -- 如果没有找到，在自己身前朝向敌人方向 250码的地方释放 Stone Caller
                            self:log("没找到有效的石头，在前方 250 码处释放 Stone Caller")
                            local stonePos = entityPos + direction * 250
                            entity:CastAbilityOnPosition(stonePos, earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                            local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                            return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                        end
                    end
                end


                --踢
                if earthSpiritAbilities["earth_spirit_boulder_smash"] and distanceToTarget <= 2180 then

                    self.boulder_smashcount = self.boulder_smashcount + 1

                    -- 查找自己身边200范围内的符合条件的无敌单位
                    local units = FindUnitsInRadius(
                        entity:GetTeamNumber(),
                        entity:GetAbsOrigin(),
                        nil,
                        200,
                        DOTA_UNIT_TARGET_TEAM_BOTH,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                        FIND_ANY_ORDER,
                        false
                    )
                
                    local validStoneFound = false
                    for _, unit in pairs(units) do
                        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                            validStoneFound = true
                            break
                        end
                    end
                
                    if validStoneFound then
                        -- 如果有符合条件的单位，对着target的位置释放技能
                        self:log("找到有效的石头，对目标位置释放 Boulder Smash")
                        entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_boulder_smash"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_boulder_smash"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_boulder_smash"], castPoint, 0, target)
                    else
                        -- 如果没有，就对着自己脚底下释放 Stone Caller
                        self:log("没找到有效的石头，在自己脚下释放 Stone Caller")
                        entity:CastAbilityOnPosition(entity:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_stone_caller"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_stone_caller"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_stone_caller"], castPoint, 0, target)
                    end
                end
                --无路可走了，对着自己放
                if earthSpiritAbilities["earth_spirit_petrify"] then
                    local targetDirection = (target:GetOrigin() - entity:GetOrigin()):Normalized()
                    local entityForwardVector = entity:GetForwardVector()
                    local dotProduct = targetDirection:Dot(entityForwardVector)
                
                    local shouldCast = false
                
                    if self:containsStrategy(self.hero_strategy, "无CD1技能") then
                        shouldCast = dotProduct > 0.8
                    else
                        local healthPercentage = entity:GetHealth() / entity:GetMaxHealth()
                        shouldCast = healthPercentage < 0.3 and dotProduct > 0.8
                    end
                
                    if shouldCast then
                        entity:CastAbilityOnTarget(entity, earthSpiritAbilities["earth_spirit_petrify"], -1)
                        if earthSpiritAbilities["earth_spirit_petrify"] then
                            local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_petrify"])
                            self:log("自己化身残岩：", castPoint)
                            return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_petrify"], castPoint, 0, target)
                        else
                            self:log("earth_spirit_petrify 技能不可用")
                            -- 处理技能不可用的情况
                        end
                    end
                end
                --都不行，揍人去了
                self:CheckItemsAndAttack(target)
                return self.nextThinkTime

            else
                --没有石头的土猫
                self:log("土猫没有石头")
                --有大放大招
                if earthSpiritAbilities["earth_spirit_magnetize"] and distanceToTarget <= 300 then
                    self:log("准备放大招，与目标距离：", distanceToTarget)
                    entity:CastAbilityNoTarget(earthSpiritAbilities["earth_spirit_magnetize"], -1)
                    local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_magnetize"])
                    self:log("放大招，施法前摇：", castPoint)
                    return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_magnetize"], castPoint, 0, target)
                end

                --对面附近有石头就拉石头，没石头就不放了
                if earthSpiritAbilities["earth_spirit_geomagnetic_grip"] and distanceToTarget <= geomagnetic_grip_castRange then
                    self:log("检查是否可以拉石头，与目标距离：", distanceToTarget, "技能施法距离：", geomagnetic_grip_castRange)
                    local stonePos = FindGeomagneticGripTarget(entity, geomagnetic_grip_castRange, target)
                    if stonePos then 
                        self:log("找到石头，位置：", stonePos.x, stonePos.y, stonePos.z)
                        entity:CastAbilityOnPosition(stonePos, earthSpiritAbilities["earth_spirit_geomagnetic_grip"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_geomagnetic_grip"])
                        self:log("拉石头，施法前摇：", castPoint)
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_geomagnetic_grip"], castPoint, 0, target)
                    end
                end


                --踢
                if earthSpiritAbilities["earth_spirit_boulder_smash"] and distanceToTarget <= 2180 then
                    self:log("踢能放")
                    -- 查找自己身边200范围内的符合条件的无敌单位
                    local units = FindUnitsInRadius(
                        entity:GetTeamNumber(),
                        entity:GetAbsOrigin(),
                        nil,
                        200,
                        DOTA_UNIT_TARGET_TEAM_BOTH,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                        FIND_ANY_ORDER,
                        false
                    )
                
                    local validStoneFound = false
                    for _, unit in pairs(units) do
                        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                            validStoneFound = true
                            break
                        end
                    end
                
                    if validStoneFound or entity:HasModifier("modifier_earthspirit_petrify") then
                        -- 如果有符合条件的单位，对着target的位置释放技能
                        self:log("找到有效的石头，对目标位置释放 Boulder Smash")
                        entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_boulder_smash"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_boulder_smash"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_boulder_smash"], castPoint, 0, target)
                    elseif distanceToTarget <= 800 then
                        local entities = FindUnitsInRadius(
                            entity:GetTeam(),
                            entity:GetAbsOrigin(),
                            nil,
                            200,
                            DOTA_UNIT_TARGET_TEAM_BOTH,
                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_ANY_ORDER,
                            false
                        )
                    
                        local foundUnit = nil
                        for _, foundEntity in ipairs(entities) do
                            if foundEntity ~= entity then
                                foundUnit = foundEntity
                                break
                            end
                        end
                    
                        if foundUnit then
                            entity:CastAbilityOnPosition(target:GetAbsOrigin(), earthSpiritAbilities["earth_spirit_boulder_smash"], -1)
                            local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_boulder_smash"])
                            return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_boulder_smash"], castPoint, 0, target)
                        end
                    end
                    
                end

                --滚
                if earthSpiritAbilities["earth_spirit_rolling_boulder"] and distanceToTarget <= 2180 then
                    local entityPos = entity:GetAbsOrigin()
                    local targetPos = target:GetAbsOrigin()
                    local direction = (targetPos - entityPos):Normalized()
                    local endPoint = entityPos + direction * 650
                    local width = 180
                
                    -- 查找直线上是否存在符合条件的单位
                    local unitsInLine = FindUnitsInLine(
                        entity:GetTeamNumber(),
                        entityPos,
                        endPoint,
                        nil,
                        width,
                        DOTA_UNIT_TARGET_TEAM_BOTH,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE
                    )
                
                    local validStoneFound = false
                    for _, unit in pairs(unitsInLine) do
                        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                            validStoneFound = true
                            break
                        end
                    end
                
                    if validStoneFound then
                        -- 如果找到符合条件的单位，对敌人释放 Rolling Boulder
                        self:log("找到有效的石头，对敌人释放 Rolling Boulder")
                        entity:CastAbilityOnPosition(targetPos, earthSpiritAbilities["earth_spirit_rolling_boulder"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_rolling_boulder"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_rolling_boulder"], castPoint, 0, target)
                    elseif distanceToTarget <= 950 then
                        -- 如果没有找到，在自己身前朝向敌人方向 250码的地方释放 Stone Caller
                        self:log("没找到有效的石头，950范围内可以冲")
                        entity:CastAbilityOnPosition(targetPos, earthSpiritAbilities["earth_spirit_rolling_boulder"], -1)
                        local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_rolling_boulder"])
                        return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_rolling_boulder"], castPoint, 0, target)
                    end
                end


                --无路可走了，对着自己放
                if earthSpiritAbilities["earth_spirit_petrify"] then
                    local targetDirection = (target:GetOrigin() - entity:GetOrigin()):Normalized()
                    local entityForwardVector = entity:GetForwardVector()
                    local dotProduct = targetDirection:Dot(entityForwardVector)
                
                    local shouldCast = false
                
                    if self:containsStrategy(self.hero_strategy, "无CD1技能") then
                        shouldCast = dotProduct > 0.8
                    else
                        local healthPercentage = entity:GetHealth() / entity:GetMaxHealth()
                        shouldCast = healthPercentage < 0.3 and dotProduct > 0.8
                    end
                
                    if shouldCast then
                        entity:CastAbilityOnTarget(entity, earthSpiritAbilities["earth_spirit_petrify"], -1)
                        if earthSpiritAbilities["earth_spirit_petrify"] then
                            local castPoint = self:GetRealCastPoint(earthSpiritAbilities["earth_spirit_petrify"])
                            self:log("自己化身残岩：", castPoint)
                            return self:OnSpellCast(entity, earthSpiritAbilities["earth_spirit_petrify"], castPoint, 0, target)
                        else
                            self:log("earth_spirit_petrify 技能不可用")
                            -- 处理技能不可用的情况
                        end
                    end
                end
                --都不行，揍人去了
                self:CheckItemsAndAttack(target)
                return self.nextThinkTime
            end
        end

        return self.nextThinkTime
    else
        self:log("处于无法释放技能的状态")
        if not entity:IsFeared() and not entity:IsTaunted()  then
            self:log(string.format("被控了放不了技能！！普攻去"))
            if self.currentState ~= AIStates.CastSpell and self.currentState ~= AIStates.Channeling then
                self:CheckItemsAndAttack(target)
                return self.nextThinkTime
            end
        
        else
            self:log(string.format("普攻也放不了，啥也不干"))
            return self.nextThinkTime
        end
        
    end


end


function FindGeomagneticGripTarget(caster, gripCastRange, target)
    local searchRadius = 180
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        target:GetAbsOrigin(),
        nil,
        searchRadius,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false
    )

    for _, unit in pairs(units) do
        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
            return unit:GetAbsOrigin()
        end
    end

    
    local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
    local endPoint = target:GetAbsOrigin() + direction * gripCastRange
    local width = 180

    local unitsInLine = FindUnitsInLine(
        caster:GetTeamNumber(),
        target:GetAbsOrigin(),
        endPoint,
        nil,
        width,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    )

    for _, unit in pairs(unitsInLine) do
        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
            return unit:GetAbsOrigin()
        end
    end

    return false
end



function GetEarthSpiritAbilities(entity)
    local abilities = {}
    local abilityNames = {
        "earth_spirit_boulder_smash",
        "earth_spirit_rolling_boulder",
        "earth_spirit_geomagnetic_grip",
        "earth_spirit_stone_caller",
        "earth_spirit_petrify",
        "earth_spirit_magnetize"
    }

    for _, name in ipairs(abilityNames) do
        local ability = entity:FindAbilityByName(name)
        if ability then
            if name == "earth_spirit_stone_caller" then
                abilities[name] = ability
            elseif not ability:IsHidden() and CommonAI:IsSkillReady(ability) then
                abilities[name] = ability
            end
        end
    end

    return abilities
end