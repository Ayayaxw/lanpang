modifier_damage_reduction_dynamic = class({})

function modifier_damage_reduction_dynamic:IsHidden()
    return false
end

function modifier_damage_reduction_dynamic:IsDebuff()
    return false
end

function modifier_damage_reduction_dynamic:IsPurgable()
    return false
end

function modifier_damage_reduction_dynamic:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

-- 初始化修饰器时设置伤害减免百分比
function modifier_damage_reduction_dynamic:OnCreated(kv)
    if IsServer() then
        -- 从参数中获取伤害减免百分比，如果没有提供则默认为50%
        self.damage_reduction_pct = kv.damage_reduction_pct or 50
        -- 确保数值合法
        if self.damage_reduction_pct > 100 then
            self.damage_reduction_pct = 100
        elseif self.damage_reduction_pct < 0 then
            self.damage_reduction_pct = 0
        end
    end
end

-- 设置伤害减免百分比的方法
function modifier_damage_reduction_dynamic:SetDamageReductionPct(value)
    if IsServer() then
        -- 确保数值合法
        if value > 100 then
            self.damage_reduction_pct = 100
        elseif value < 0 then
            self.damage_reduction_pct = 0
        else
            self.damage_reduction_pct = value
        end
    end
end

-- 获取当前伤害减免百分比
function modifier_damage_reduction_dynamic:GetDamageReductionPct()
    return self.damage_reduction_pct
end

function modifier_damage_reduction_dynamic:GetModifierIncomingDamage_Percentage()
    -- 返回负值以减少伤害
    return -self.damage_reduction_pct
end 