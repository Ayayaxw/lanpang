modifier_allow_all_pathing = class({})

function modifier_allow_all_pathing:CheckState()
    local state = { 

        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_BASE_BLOCKER] = true,
    }
    return state
end

function modifier_allow_all_pathing:IsPurgable()
    return false
end

function modifier_allow_all_pathing:IsStunDebuff()
    return false
end

function modifier_allow_all_pathing:IsPurgeException()
    return false
end

function modifier_allow_all_pathing:IsHidden()
    return true
end