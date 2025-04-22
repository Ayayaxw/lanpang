modifier_percent_armor_buff = class({})

function modifier_percent_armor_buff:IsHidden() return false end
function modifier_percent_armor_buff:IsDebuff() return false end
function modifier_percent_armor_buff:IsPurgable() return true end

function modifier_percent_armor_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BASE_PERCENTAGE
    }
end

function modifier_percent_armor_buff:GetModifierPhysicalArmorBase_Percentage()
    return -100  -- 返回100表示增加100%基础护甲
end