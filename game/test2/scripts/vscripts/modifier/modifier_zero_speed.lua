modifier_zero_speed = class({})

function modifier_zero_speed:IsHidden()
    return false
end

function modifier_zero_speed:IsDebuff()
    return true
end

function modifier_zero_speed:IsPurgable()
    return false
end

function modifier_zero_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_REDUCTION_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
    }
    return funcs
end

function modifier_zero_speed:GetModifierMoveSpeedReductionPercentage()
    return 100 -- 减少100%移速
end

function modifier_zero_speed:GetModifierMoveSpeed_Limit()
    return 0
end

function modifier_zero_speed:GetModifierMoveSpeed_AbsoluteMin()
    return 0
end

function modifier_zero_speed:GetModifierIgnoreMovespeedLimit()
    return 1
end