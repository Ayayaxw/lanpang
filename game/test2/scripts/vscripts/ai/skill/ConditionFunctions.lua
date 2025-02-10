function CommonAI:NeedsModifierRefresh(caster, requiredModifiers, minRemainingTime)
    for _, modifier in ipairs(requiredModifiers) do
        local modifiers = caster:FindAllModifiersByName(modifier)
        if #modifiers > 0 then
            local maxRemainingTime = 0
            for _, modifierInstance in ipairs(modifiers) do
                local remainingTime = modifierInstance:GetRemainingTime()
                if remainingTime > maxRemainingTime then
                    maxRemainingTime = remainingTime
                end
            end
            
            if maxRemainingTime > minRemainingTime then
                self:log(string.format("英雄拥有 %s 状态，最长剩余时间 %.2f 秒，超过了要求的 %.2f 秒，不需要刷新", modifier, maxRemainingTime, minRemainingTime))
                return false  -- 不需要刷新
            else
                self:log(string.format("英雄拥有 %s 状态，但最长剩余时间 %.2f 秒，不足要求的 %.2f 秒，需要刷新", modifier, maxRemainingTime, minRemainingTime))
            end
        else
            self:log(string.format("英雄没有 %s 状态，需要施加", modifier))
        end
    end
    return true  -- 需要刷新或施加
end

function CommonAI:IsNotUnderModifiers(caster, forbiddenModifiers, log)
    for _, modifier in ipairs(forbiddenModifiers) do
        if caster:HasModifier(modifier) then
            log(string.format("英雄处于 %s 状态，禁止使用技能", modifier))
            return false
        end
    end
    return true
end

function CommonAI:CountModifiers(unit, modifierName)
    if not unit or not unit.GetModifierCount then
        return 0
    end

    local count = 0
    local modifierCount = unit:GetModifierCount()

    for i = 0, modifierCount - 1 do
        local modifier = unit:GetModifierNameByIndex(i)
        if modifier and modifier == modifierName then
            count = count + 1
        end
    end
    return count
end

function CommonAI:FindUntargetedUnitInRange(entity, abilityInfo, modifiers, refreshTime)
    local untargetedUnit = nil
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
        if hero:IsHero() and not hero:IsSummoned() and self:NeedsModifierRefresh(hero, modifiers, refreshTime) then
            local distance = (hero:GetOrigin() - entity:GetOrigin()):Length2D()
            if distance < closestDistance then
                untargetedUnit = hero
                closestDistance = distance
            end
        end
    end

    return untargetedUnit
end