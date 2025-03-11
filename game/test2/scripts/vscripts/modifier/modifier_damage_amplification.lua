modifier_damage_amplification = class({})

function modifier_damage_amplification:IsHidden()
    return false
end

function modifier_damage_amplification:IsDebuff()
    return false
end

function modifier_damage_amplification:IsPurgable()
    return false
end

function modifier_damage_amplification:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

-- 初始化修饰器时设置伤害增强百分比
function modifier_damage_amplification:OnCreated(kv)
    if IsServer() then
        -- 从参数中获取伤害增强百分比，如果没有提供则默认为20%
        self.damage_amp_pct = kv.damage_amp_pct or 20
        -- 只限制最小值为0，不限制最大值，允许超过100%
        if self.damage_amp_pct < 0 then
            self.damage_amp_pct = 0
        end
    end
end

-- 设置伤害增强百分比的方法
function modifier_damage_amplification:SetDamageAmpPct(value)
    if IsServer() then
        -- 只限制最小值为0，不限制最大值
        if value < 0 then
            self.damage_amp_pct = 0
        else
            self.damage_amp_pct = value
        end
    end
end

-- 获取当前伤害增强百分比
function modifier_damage_amplification:GetDamageAmpPct()
    return self.damage_amp_pct
end

function modifier_damage_amplification:GetModifierIncomingDamage_Percentage()
    -- 返回正值以增加伤害
    return self.damage_amp_pct
end 