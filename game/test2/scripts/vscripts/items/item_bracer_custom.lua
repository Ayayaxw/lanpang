-- 护腕的代码
LinkLuaModifier("modifier_item_bracer_custom", "items/item_bracer_custom.lua", LUA_MODIFIER_MOTION_NONE)

item_bracer_custom = class({})

function item_bracer_custom:GetIntrinsicModifierName()
    return "modifier_item_bracer_custom"
end

modifier_item_bracer_custom = class({})

function modifier_item_bracer_custom:IsHidden() return true end
function modifier_item_bracer_custom:IsDebuff() return false end
function modifier_item_bracer_custom:IsPurgable() return false end

function modifier_item_bracer_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
end

function modifier_item_bracer_custom:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_bracer_custom:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_bracer_custom:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_bracer_custom:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_bracer_custom:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_bracer_custom:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end