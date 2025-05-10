modifier_outgoing_damage_reduction = class({})

function modifier_outgoing_damage_reduction:IsHidden()
    return false
end

function modifier_outgoing_damage_reduction:IsDebuff()
    return false
end

function modifier_outgoing_damage_reduction:IsPurgable()
    return false
end

function modifier_outgoing_damage_reduction:OnCreated(kv)
    self.damage_reduction = kv.damage_reduction or 100
end

function modifier_outgoing_damage_reduction:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

function modifier_outgoing_damage_reduction:GetModifierDamageOutgoing_Percentage()
    return -self.damage_reduction
end 