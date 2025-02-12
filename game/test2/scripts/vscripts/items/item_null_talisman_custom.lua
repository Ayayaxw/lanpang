LinkLuaModifier("modifier_item_null_talisman_stats", "items/item_null_talisman_custom.lua", LUA_MODIFIER_MOTION_NONE)

item_null_talisman_custom = class({})

function item_null_talisman_custom:GetIntrinsicModifierName()
    return "modifier_item_null_talisman_stats"
end

modifier_item_null_talisman_stats = class({})

function modifier_item_null_talisman_stats:IsHidden() return true end
function modifier_item_null_talisman_stats:IsDebuff() return false end
function modifier_item_null_talisman_stats:IsPurgable() return false end
function modifier_item_null_talisman_stats:RemoveOnDeath() return false end

function modifier_item_null_talisman_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
end

local function GetItemCount(unit)
    local count = 0
    for i = 0, 8 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetName() == "item_null_talisman_custom" then
            count = count + 1
        end
    end
    return count
end

function modifier_item_null_talisman_stats:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect") * GetItemCount(self:GetParent())
end

function modifier_item_null_talisman_stats:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength") * GetItemCount(self:GetParent())
end

function modifier_item_null_talisman_stats:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility") * GetItemCount(self:GetParent())
end

function modifier_item_null_talisman_stats:GetModifierManaBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_max_mana_percentage") * GetItemCount(self:GetParent())
end

function modifier_item_null_talisman_stats:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") * GetItemCount(self:GetParent())
end