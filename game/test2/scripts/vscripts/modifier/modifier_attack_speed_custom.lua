modifier_attack_speed_custom = class({})

function modifier_attack_speed_custom:IsHidden() return true end
function modifier_attack_speed_custom:IsDebuff() return false end
function modifier_attack_speed_custom:IsPurgable() return false end

function modifier_attack_speed_custom:OnCreated(kv)
    -- 通过传入参数控制攻击速度相关设置
    self.base_attack_time = kv.base_attack_time or 0.00000001
    self.ignore_attack_speed_limit = kv.ignore_attack_speed_limit or 1
    -- self.attack_speed_bonus_constant = kv.attack_speed_bonus_constant or 0

    -- local parent = self:GetParent()
    -- parent:SetBaseAttackTime(self.base_attack_time)
end

function modifier_attack_speed_custom:DeclareFunctions()
    return {
        --MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,

    }
end

-- function modifier_attack_speed_custom:GetModifierBaseAttackTimeConstant()
--     return self.base_attack_time
-- end

function modifier_attack_speed_custom:GetModifierIgnoreAttackspeedLimit()
    return self.ignore_attack_speed_limit
end 

