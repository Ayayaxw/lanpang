modifier_attack_damage_percentage = class({})

function modifier_attack_damage_percentage:IsHidden()
    return false
end

function modifier_attack_damage_percentage:IsDebuff()
    return false
end

function modifier_attack_damage_percentage:IsPurgable()
    return false
end

function modifier_attack_damage_percentage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

-- 初始化修饰器时设置攻击力提升百分比
function modifier_attack_damage_percentage:OnCreated(kv)
    if IsServer() then
        -- 从参数中获取攻击力提升百分比，如果没有提供则默认为25%
        self.damage_bonus_pct = kv.damage_bonus_pct or 25
        
        -- 确保数值合法
        if self.damage_bonus_pct < 0 then
            self.damage_bonus_pct = 0
        end
    end
end

-- 设置攻击力提升百分比的方法
function modifier_attack_damage_percentage:SetAttackDamagePct(value)
    if IsServer() then
        -- 确保数值合法
        if value < 0 then
            self.damage_bonus_pct = 0
        else
            self.damage_bonus_pct = value
        end
        
        -- 不使用CalculateStatBonus方法，直接通知游戏重新计算属性
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            -- 使用ForceRefresh让游戏引擎自动更新单位状态
            self:ForceRefresh()
        end
    end
end

-- 获取当前攻击力提升百分比
function modifier_attack_damage_percentage:GetAttackDamagePct()
    return self.damage_bonus_pct
end

function modifier_attack_damage_percentage:GetModifierBaseDamageOutgoing_Percentage()
    return self.damage_bonus_pct
end

-- 可选：在移除修饰器时处理属性变化
function modifier_attack_damage_percentage:OnRemoved()
    -- 不需要特殊处理，游戏会自动重新计算单位属性
end 