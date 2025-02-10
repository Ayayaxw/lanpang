modifier_decrease_attribute = class({})

function modifier_decrease_attribute:IsHidden() return false end
function modifier_decrease_attribute:IsPurgable() return false end
function modifier_decrease_attribute:IsDebuff() return true end
function modifier_decrease_attribute:RemoveOnDeath() return false end

function modifier_decrease_attribute:GetTexture()
    return "slark_essence_shift"
end

function modifier_decrease_attribute:OnCreated(kv)
    self.attribute_reduction = 1
    if IsServer() then
        self:SetStackCount(1)
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_decrease_attribute:OnRefresh(kv)
    if IsServer() then
        self:IncrementStackCount()
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_decrease_attribute:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_decrease_attribute:GetModifierBonusStats_Strength()
    return self:GetStackCount() * -self.attribute_reduction
end

function modifier_decrease_attribute:GetModifierBonusStats_Agility()
    return self:GetStackCount() * -self.attribute_reduction
end

function modifier_decrease_attribute:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * -self.attribute_reduction
end

function modifier_decrease_attribute:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end