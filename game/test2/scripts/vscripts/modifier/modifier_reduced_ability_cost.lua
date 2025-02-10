modifier_reduced_ability_cost = class({})

function modifier_reduced_ability_cost:IsHidden()
    return true
end

function modifier_reduced_ability_cost:IsDebuff()
    return false
end

function modifier_reduced_ability_cost:IsPurgable()
    return false  -- 改为 false 使其不可被驱散
end

function modifier_reduced_ability_cost:RemoveOnDeath()
    return false  -- 添加此函数并返回 false 使其死亡不移除
end

function modifier_reduced_ability_cost:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING
    }
    return funcs
end

function modifier_reduced_ability_cost:GetModifierPercentageCooldown()
    return 90
end

function modifier_reduced_ability_cost:GetModifierPercentageManacostStacking()
    return 90
end

function modifier_reduced_ability_cost:GetTexture()
    return "modifiers/rune_arcane"
end

function modifier_reduced_ability_cost:GetEffectName()
    return "particles/generic_gameplay/rune_arcane.vpcf"
end