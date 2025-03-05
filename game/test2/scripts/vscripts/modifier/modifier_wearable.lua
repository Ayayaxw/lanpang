modifier_wearable = class({})

function modifier_wearable:CheckState()
    local state = { 
        --[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_DISARMED] = true,
        -- 添加无视地形移动相关的状态
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_BASE_BLOCKER] = true,
    }
    return state
end

function modifier_wearable:IsPurgable()
    return false
end

function modifier_wearable:IsStunDebuff()
    return false
end

function modifier_wearable:IsPurgeException()
    return false
end

function modifier_wearable:IsHidden()
    return true
end