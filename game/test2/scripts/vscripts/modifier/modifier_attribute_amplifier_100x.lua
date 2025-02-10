modifier_attribute_amplifier_100x = class({})

function modifier_attribute_amplifier_100x:OnCreated()
    self:CalculateAttributeChanges()
end



function modifier_attribute_amplifier_100x:AllowIllusionDuplicate()
    return true
end

function modifier_attribute_amplifier_100x:CalculateAttributeChanges()
    local hero = self:GetParent()
    
    -- 获取当前三维属性
    local current_str = hero:GetStrength()
    local current_agi = hero:GetAgility()
    local current_int = hero:GetIntellect(false)
    
    -- 计算需要增加的属性值（每个属性都翻100倍）
    self.strength_adjustment = current_str * 99  -- 增加99倍，加上原有的就是100倍
    self.agility_adjustment = current_agi * 99
    self.intellect_adjustment = current_int * 99
    
    self:PrintAttributeChanges(current_str, current_agi, current_int)
end

function modifier_attribute_amplifier_100x:PrintAttributeChanges(current_str, current_agi, current_int)
    print("Attribute Amplifier (100x) for " .. self:GetParent():GetName())
    print(string.format("Current Attributes: Str %d, Agi %d, Int %d", current_str, current_agi, current_int))
    print(string.format("New Attributes: Str %d, Agi %d, Int %d", 
        current_str + self.strength_adjustment, 
        current_agi + self.agility_adjustment, 
        current_int + self.intellect_adjustment))
    print(string.format("Adjustments: Str +%d, Agi +%d, Int +%d", 
        self.strength_adjustment, self.agility_adjustment, self.intellect_adjustment))
end

function modifier_attribute_amplifier_100x:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function modifier_attribute_amplifier_100x:GetModifierBonusStats_Strength()
    return self.strength_adjustment
end

function modifier_attribute_amplifier_100x:GetModifierBonusStats_Agility()
    return self.agility_adjustment
end

function modifier_attribute_amplifier_100x:GetModifierBonusStats_Intellect()
    return self.intellect_adjustment
end

function modifier_attribute_amplifier_100x:IsHidden()
    return false
end

function modifier_attribute_amplifier_100x:IsDebuff()
    return false
end

function modifier_attribute_amplifier_100x:IsPurgable()
    return false
end

function modifier_attribute_amplifier_100x:RemoveOnDeath()
    return false
end