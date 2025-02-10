modifier_health_regen_7 = class({})

function modifier_health_regen_7:IsHidden()
    return false
end

function modifier_health_regen_7:IsDebuff()
    return false
end

function modifier_health_regen_7:IsPurgable()
    return false
end

function modifier_health_regen_7:GetTexture()
    return "item_tango"
end

function modifier_health_regen_7:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_health_regen_7:GetModifierConstantHealthRegen()
    return 7
end

function modifier_health_regen_7:AllowIllusionDuplicate()
    return false
end