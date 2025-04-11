modifier_attribute_boost = class({})

function modifier_attribute_boost:IsHidden() return true end
function modifier_attribute_boost:IsPurgable() return false end
function modifier_attribute_boost:IsDebuff() return false end
function modifier_attribute_boost:RemoveOnDeath() return false end
function modifier_attribute_boost:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end -- 允许多个独立实例
--允许幻象继承
function modifier_attribute_boost:AllowIllusionDuplicate() return true end
function modifier_attribute_boost:OnCreated(kv)
    if not IsServer() then return end

    -- 读取参数，无默认值（确保外部传入正确参数）
    self.attribute_value = kv.value
    self.attribute_type = kv.attribute_type
    
    -- 设置堆叠显示为当前增益数值
    self:SetStackCount(self.attribute_value)
    
    -- 更新英雄属性
    self:GetParent():CalculateStatBonus(true)
end

function modifier_attribute_boost:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

-- 根据类型返回对应属性增益
function modifier_attribute_boost:GetModifierBonusStats_Strength()
    local bonus = (self.attribute_type == "strength" or self.attribute_type == "all") and self.attribute_value or 0
    return bonus
end

function modifier_attribute_boost:GetModifierBonusStats_Agility()
    local bonus = (self.attribute_type == "agility" or self.attribute_type == "all") and self.attribute_value or 0
    return bonus
end

function modifier_attribute_boost:GetModifierBonusStats_Intellect()
    local bonus = (self.attribute_type == "intelligence" or self.attribute_type == "all") and self.attribute_value or 0
    return bonus
end

