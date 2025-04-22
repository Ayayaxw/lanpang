modifier_attack_damage_percentage = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_attack_damage_percentage:IsHidden()
    return true
end

function modifier_attack_damage_percentage:IsDebuff()
    return self.damage_bonus_pct and self.damage_bonus_pct < 0
end

function modifier_attack_damage_percentage:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_attack_damage_percentage:OnCreated(kv)
    self.damage_bonus_pct = kv.damage_bonus_pct or 0
end

function modifier_attack_damage_percentage:OnRefresh(kv)
    self.damage_bonus_pct = kv.damage_bonus_pct or 0
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_attack_damage_percentage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

function modifier_attack_damage_percentage:GetModifierBaseDamageOutgoing_Percentage()
    return self.damage_bonus_pct
end

--------------------------------------------------------------------------------
