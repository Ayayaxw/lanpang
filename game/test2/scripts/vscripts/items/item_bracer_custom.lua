LinkLuaModifier("modifier_item_bracer_stats", "items/item_bracer_custom.lua", LUA_MODIFIER_MOTION_NONE)

item_bracer_custom = class({})

function item_bracer_custom:GetIntrinsicModifierName()
    return "modifier_item_bracer_stats"
end

modifier_item_bracer_stats = class({})

function modifier_item_bracer_stats:IsHidden() return true end
function modifier_item_bracer_stats:IsDebuff() return false end
function modifier_item_bracer_stats:IsPurgable() return false end
function modifier_item_bracer_stats:RemoveOnDeath() return false end

function modifier_item_bracer_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
end

local function GetItemCount(unit)
    local count = 0
    for i = 0, 8 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetName() == "item_bracer_custom" then
            count = count + 1
        end
    end
    return count
end

function modifier_item_bracer_stats:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength") * GetItemCount(self:GetParent())
end

function modifier_item_bracer_stats:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility") * GetItemCount(self:GetParent())
end

function modifier_item_bracer_stats:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect") * GetItemCount(self:GetParent())
end

function modifier_item_bracer_stats:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage") * GetItemCount(self:GetParent())
end

function modifier_item_bracer_stats:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen") * GetItemCount(self:GetParent())
end

function modifier_item_bracer_stats:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health") * GetItemCount(self:GetParent())
end