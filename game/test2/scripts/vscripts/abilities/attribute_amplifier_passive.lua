LinkLuaModifier("modifier_attribute_amplifier_hidden", "abilities/attribute_amplifier_passive", LUA_MODIFIER_MOTION_NONE)

attribute_amplifier_passive = class({})

function attribute_amplifier_passive:GetIntrinsicModifierName()
    return "modifier_attribute_amplifier_hidden"
end

function attribute_amplifier_passive:IsHidden()
    return true
end

modifier_attribute_amplifier_hidden = class({})

function modifier_attribute_amplifier_hidden:IsHidden() return true end
function modifier_attribute_amplifier_hidden:IsDebuff() return false end
function modifier_attribute_amplifier_hidden:IsPurgable() return false end
function modifier_attribute_amplifier_hidden:RemoveOnDeath() return false end
function modifier_attribute_amplifier_hidden:IsPermanent() return true end
function modifier_attribute_amplifier_hidden:AllowIllusionDuplicate() return true end

function modifier_attribute_amplifier_hidden:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_attribute_amplifier_hidden:OnCreated()
    if not IsServer() then return end
    local hero = self:GetParent()
    
    if hero:IsIllusion() then
        local original_hero = hero:GetReplicatingOtherHero()
        if original_hero then
            self.bonus_str = original_hero:GetBaseStrength() * 2
            self.bonus_agi = original_hero:GetBaseAgility() * 2
            self.bonus_int = original_hero:GetBaseIntellect() * 2
        end
    else
        self.bonus_str = hero:GetBaseStrength() * 2
        self.bonus_agi = hero:GetBaseAgility() * 2
        self.bonus_int = hero:GetBaseIntellect() * 2
    end
end

function modifier_attribute_amplifier_hidden:GetModifierBonusStats_Strength()
    return self.bonus_str or 0
end

function modifier_attribute_amplifier_hidden:GetModifierBonusStats_Agility()
    return self.bonus_agi or 0
end

function modifier_attribute_amplifier_hidden:GetModifierBonusStats_Intellect()
    return self.bonus_int or 0
end