function CommonAI:HandleEnemyTargetOutofRangeAction(entity,target,abilityInfo,targetInfo)
    if abilityInfo.abilityName == "furion_sprout" then
        -- 计算新的目标位置
        local newTargetPosition = entity:GetOrigin() + targetInfo.targetDirection * abilityInfo.castRange
        self:log("Casting Sprout at position: " .. tostring(newTargetPosition))
        entity:CastAbilityOnPosition(newTargetPosition, abilityInfo.skill, 0)
        abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity,  newTargetPosition, abilityInfo.castPoint)
        return true
    -- elseif abilityInfo.abilityName == "oracle_fortunes_end"  then

    
    --     -- 检查是否有 modifier_oracle_fortunes_end_purge 并且剩余时间大于 0.1 秒
    --     local modifier = entity:FindModifierByName("modifier_oracle_fortunes_end_purge_repeatedly")
    --     if modifier and modifier:GetRemainingTime() > 0.1 then
    --         self:log("Found modifier_oracle_fortunes_end_purge with remaining time: " .. modifier:GetRemainingTime())
    --         return false
    --     end
        
    --     -- 如果没有符合条件的 modifier，则执行原来的逻辑
    --     self:log("Casting oracle_fortunes_end on self")
    --     entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
    --     return true
    end
    return false
end