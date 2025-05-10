modifier_attack_rate_custom = class({})

function modifier_attack_rate_custom:IsHidden() return true end
function modifier_attack_rate_custom:IsDebuff() return false end
function modifier_attack_rate_custom:IsPurgable() return false end

function modifier_attack_rate_custom:OnCreated(kv)
    -- 通过传入参数控制攻击速率
    self.fixed_attack_rate = kv.fixed_attack_rate or 1.0
end

function modifier_attack_rate_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
    }
end

function modifier_attack_rate_custom:GetModifierFixedAttackRate()
    return self.fixed_attack_rate
end 