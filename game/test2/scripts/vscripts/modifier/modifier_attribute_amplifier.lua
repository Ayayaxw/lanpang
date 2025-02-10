modifier_attribute_amplifier = class({})

function modifier_attribute_amplifier:OnCreated()
    if not IsServer() then return end
    self:CalculateAttributeChanges()
end

function modifier_attribute_amplifier:CalculateAttributeChanges()
    local hero = self:GetParent()
    
    -- 获取当前三维属性
    local current_str = hero:GetStrength()
    local current_agi = hero:GetAgility()
    local current_int = hero:GetIntellect(false)
    
    -- 计算需要增加的属性值（每个属性都翻10倍）
    self.strength_adjustment = current_str * 2  -- 增加9倍，加上原有的就是10倍
    self.agility_adjustment = current_agi * 2
    self.intellect_adjustment = current_int * 2
    
    self:PrintAttributeChanges(current_str, current_agi, current_int)
end

function modifier_attribute_amplifier:PrintAttributeChanges(current_str, current_agi, current_int)
    print("Attribute Amplifier for " .. self:GetParent():GetName())
    print(string.format("Current Attributes: Str %d, Agi %d, Int %d", current_str, current_agi, current_int))
    print(string.format("New Attributes: Str %d, Agi %d, Int %d", 
        current_str + self.strength_adjustment, 
        current_agi + self.agility_adjustment, 
        current_int + self.intellect_adjustment))
    print(string.format("Adjustments: Str +%d, Agi +%d, Int +%d", 
        self.strength_adjustment, self.agility_adjustment, self.intellect_adjustment))
end

function modifier_attribute_amplifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function modifier_attribute_amplifier:GetModifierBonusStats_Strength()
    return self.strength_adjustment
end

function modifier_attribute_amplifier:GetModifierBonusStats_Agility()
    return self.agility_adjustment
end

function modifier_attribute_amplifier:GetModifierBonusStats_Intellect()
    return self.intellect_adjustment
end

function modifier_attribute_amplifier:IsHidden()
    return false
end

function modifier_attribute_amplifier:IsDebuff()
    return false
end

function modifier_attribute_amplifier:IsPurgable()
    return false
end

function modifier_attribute_amplifier:RemoveOnDeath()
    return false
end