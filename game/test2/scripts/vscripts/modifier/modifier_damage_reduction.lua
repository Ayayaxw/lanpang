modifier_damage_reduction = class({})

function modifier_damage_reduction:IsHidden()
    return false
end

function modifier_damage_reduction:IsDebuff()
    return false
end

function modifier_damage_reduction:IsPurgable()
    return false
end

function modifier_damage_reduction:OnCreated(kv)
    if IsServer() then
        self.damage_reduction = kv.damage_reduction or 100
    end
end

function modifier_damage_reduction:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_damage_reduction:GetModifierIncomingDamage_Percentage()
    return -self.damage_reduction
end 