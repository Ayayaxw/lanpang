modifier_attribute_reversal = class({})

function modifier_attribute_reversal:OnCreated()
    if not IsServer() then return end
    self:CalculateAttributeChanges()
end

function modifier_attribute_reversal:CalculateAttributeChanges()
    local hero = self:GetParent()
    local finalLevel = 30  -- 假设最终等级是30
    
    -- 获取基础属性和属性成长
    local base_str = hero:GetBaseStrength()
    local base_agi = hero:GetBaseAgility()
    local base_int = hero:GetBaseIntellect()
    
    local gain_str = hero:GetStrengthGain()
    local gain_agi = hero:GetAgilityGain()
    local gain_int = hero:GetIntellectGain()
    
    -- 反转基础属性和属性成长
    local reversed_base_str = self:ReverseNumber(math.floor(base_str))
    local reversed_base_agi = self:ReverseNumber(math.floor(base_agi))
    local reversed_base_int = self:ReverseNumber(math.floor(base_int))
    
    local reversed_gain_str = self:ReverseGain(gain_str)
    local reversed_gain_agi = self:ReverseGain(gain_agi)
    local reversed_gain_int = self:ReverseGain(gain_int)
    
    -- 计算正常情况下30级的属性值
    local normal_str = base_str + gain_str * (finalLevel - 1)
    local normal_agi = base_agi + gain_agi * (finalLevel - 1)
    local normal_int = base_int + gain_int * (finalLevel - 1)
    
    -- 计算反转后30级的属性值
    local reversed_str = reversed_base_str + reversed_gain_str * (finalLevel - 1)
    local reversed_agi = reversed_base_agi + reversed_gain_agi * (finalLevel - 1)
    local reversed_int = reversed_base_int + reversed_gain_int * (finalLevel - 1)
    
    -- 计算需要调整的值
    self.strength_adjustment = math.floor(reversed_str - normal_str)
    self.agility_adjustment = math.floor(reversed_agi - normal_agi)
    self.intellect_adjustment = math.floor(reversed_int - normal_int)
    
    self:PrintAttributeChanges(base_str, base_agi, base_int, gain_str, gain_agi, gain_int,
                               reversed_base_str, reversed_base_agi, reversed_base_int,
                               reversed_gain_str, reversed_gain_agi, reversed_gain_int)
end

function modifier_attribute_reversal:ReverseNumber(num)
    -- 如果是整数，直接反转
    if math.floor(num) == num then
        local reversed = 0
        while num > 0 do
            reversed = reversed * 10 + num % 10
            num = math.floor(num / 10)
        end
        return reversed
    else
        -- 如果是小数，调用 ReverseGain 函数
        return self:ReverseGain(num)
    end
end

function modifier_attribute_reversal:ReverseGain(num)
    -- 将数字精确到一位小数
    local rounded = math.floor(num * 10 + 0.5) / 10
    -- 将数字转换为字符串
    local str = string.format("%.1f", rounded)
    
    -- 如果小数点后是0，当作整数处理
    if str:sub(-1) == "0" then
        str = str:sub(1, -3)  -- 去掉 ".0"
        local reversed = string.reverse(str)
        return tonumber(reversed)
    else
        -- 否则，反转整个字符串（包括小数点）
        local reversed = string.reverse(str)
        return tonumber(reversed)
    end
end

function modifier_attribute_reversal:PrintAttributeChanges(base_str, base_agi, base_int, 
                                                           gain_str, gain_agi, gain_int,
                                                           rev_base_str, rev_base_agi, rev_base_int,
                                                           rev_gain_str, rev_gain_agi, rev_gain_int)
    print("Attribute Reversal for " .. self:GetParent():GetName())
    print(string.format("Strength: Base %.0f->%d, Gain %.1f->%.1f, Final Adjustment: %d",
          base_str, rev_base_str, gain_str, rev_gain_str, self.strength_adjustment))
    print(string.format("Agility: Base %.0f->%d, Gain %.1f->%.1f, Final Adjustment: %d",
          base_agi, rev_base_agi, gain_agi, rev_gain_agi, self.agility_adjustment))
    print(string.format("Intellect: Base %.0f->%d, Gain %.1f->%.1f, Final Adjustment: %d",
          base_int, rev_base_int, gain_int, rev_gain_int, self.intellect_adjustment))
end

function modifier_attribute_reversal:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function modifier_attribute_reversal:GetModifierBonusStats_Strength()
    return self.strength_adjustment
end

function modifier_attribute_reversal:GetModifierBonusStats_Agility()
    return self.agility_adjustment
end

function modifier_attribute_reversal:GetModifierBonusStats_Intellect()
    return self.intellect_adjustment
end

function modifier_attribute_reversal:IsHidden()
    return true
end

function modifier_attribute_reversal:IsDebuff()
    return false
end

function modifier_attribute_reversal:IsPurgable()
    return false
end



function modifier_attribute_reversal:RemoveOnDeath()
    return false
end
