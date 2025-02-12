LinkLuaModifier("modifier_item_wraith_band_stats", "items/item_wraith_band_custom.lua", LUA_MODIFIER_MOTION_NONE)

item_wraith_band_custom = class({})

function item_wraith_band_custom:GetIntrinsicModifierName()
    return "modifier_item_wraith_band_stats"
end

modifier_item_wraith_band_stats = class({})

function modifier_item_wraith_band_stats:IsHidden() return true end
function modifier_item_wraith_band_stats:IsDebuff() return false end
function modifier_item_wraith_band_stats:IsPurgable() return false end
function modifier_item_wraith_band_stats:RemoveOnDeath() return false end

function modifier_item_wraith_band_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_item_wraith_band_stats:GetModifierBonusStats_Agility()
    local stack_count = 0
    local parent = self:GetParent()
    
    -- 统计背包中该物品的数量
    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_wraith_band_custom" then
            stack_count = stack_count + 1
        end
    end
    
    return self:GetAbility():GetSpecialValueFor("bonus_agility") * stack_count
end

function modifier_item_wraith_band_stats:GetModifierBonusStats_Strength()
    local stack_count = 0
    local parent = self:GetParent()
    
    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_wraith_band_custom" then
            stack_count = stack_count + 1
        end
    end
    
    return self:GetAbility():GetSpecialValueFor("bonus_strength") * stack_count
end

function modifier_item_wraith_band_stats:GetModifierBonusStats_Intellect()
    local stack_count = 0
    local parent = self:GetParent()
    
    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_wraith_band_custom" then
            stack_count = stack_count + 1
        end
    end
    
    return self:GetAbility():GetSpecialValueFor("bonus_intellect") * stack_count
end

function modifier_item_wraith_band_stats:GetModifierAttackSpeedBonus_Constant()
    local stack_count = 0
    local parent = self:GetParent()
    
    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_wraith_band_custom" then
            stack_count = stack_count + 1
        end
    end
    
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") * stack_count
end

function modifier_item_wraith_band_stats:GetModifierPhysicalArmorBonus()
    local stack_count = 0
    local parent = self:GetParent()
    
    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_wraith_band_custom" then
            stack_count = stack_count + 1
        end
    end
    
    return self:GetAbility():GetSpecialValueFor("bonus_armor") * stack_count
end