modifier_increase_attribute = class({})

function modifier_increase_attribute:IsHidden() return false end


function modifier_increase_attribute:IsPurgable() return false end
function modifier_increase_attribute:IsDebuff() return false end
function modifier_increase_attribute:RemoveOnDeath() return false end

function modifier_increase_attribute:GetTexture()
    return "slark_essence_shift"
end

function modifier_increase_attribute:OnCreated(kv)
    self.attribute_bonus = 1
    if IsServer() then
        self:SetStackCount(1)
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_increase_attribute:OnRefresh(kv)
    if IsServer() then
        self:IncrementStackCount()
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_increase_attribute:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
    return funcs
end

function modifier_increase_attribute:GetModifierBonusStats_Strength()
    return self:GetStackCount() * self.attribute_bonus
end

function modifier_increase_attribute:GetModifierBonusStats_Agility()
    return self:GetStackCount() * self.attribute_bonus
end

function modifier_increase_attribute:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * self.attribute_bonus
end
