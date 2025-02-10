modifier_damage_reduction_100 = class({})

function modifier_damage_reduction_100:IsHidden()
    return false
end

function modifier_damage_reduction_100:IsDebuff()
    return false
end

function modifier_damage_reduction_100:IsPurgable()
    return false
end

function modifier_damage_reduction_100:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_damage_reduction_100:GetModifierIncomingDamage_Percentage()
    return -100
end