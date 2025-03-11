modifier_health_bonus_percentage = class({})

function modifier_health_bonus_percentage:IsHidden()
    return false
end

function modifier_health_bonus_percentage:IsDebuff()
    return false
end

function modifier_health_bonus_percentage:IsPurgable()
    return false
end

function modifier_health_bonus_percentage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS
    }
    return funcs
end

-- 初始化修饰器时设置生命值提升百分比
function modifier_health_bonus_percentage:OnCreated(kv)
    if IsServer() then
        -- 从参数中获取生命值提升百分比，如果没有提供则默认为30%
        self.health_bonus_pct = kv.health_bonus_pct or 30
        
        -- 确保数值为非负
        if self.health_bonus_pct < 0 then
            self.health_bonus_pct = 0
        end
        
        -- 计算初始加成值
        self:UpdateBonusHealth()
        
        -- 设置定时器定期更新生命值加成（因为基础生命值可能会变化）
        self:StartIntervalThink(1.0)
    end
end

function modifier_health_bonus_percentage:OnIntervalThink()
    if IsServer() then
        self:UpdateBonusHealth()
    end
end

-- 更新生命值加成
function modifier_health_bonus_percentage:UpdateBonusHealth()
    if IsServer() then
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            -- 使用更兼容的方式获取基础生命值
            local base_health = parent:GetBaseMaxHealth()
            
            -- 计算百分比加成（四舍五入）
            self.bonus_health = math.floor(base_health * self.health_bonus_pct / 100 + 0.5)
            
            -- 通用属性刷新方法
            if parent.CalculateStatBonus then
                parent:CalculateStatBonus(true)  -- 仅对英雄生效
            else
                -- 对非英雄单位使用替代方案
                local current_max_health = parent:GetMaxHealth()
                parent:SetBaseMaxHealth(base_health)  -- 临时设置基础值
                parent:SetBaseMaxHealth(base_health)  -- 二次设置强制刷新
                parent:SetHealth(math.min(parent:GetHealth(), current_max_health))
            end
            
            -- 确保强制刷新修饰器
            self:ForceRefresh()
        end
    end
end

-- 设置生命值提升百分比的方法
function modifier_health_bonus_percentage:SetHealthBonusPct(value)
    if IsServer() then
        -- 确保数值为非负
        if value < 0 then
            self.health_bonus_pct = 0
        else
            self.health_bonus_pct = value
        end
        
        -- 更新加成值
        self:UpdateBonusHealth()
    end
end

-- 获取当前生命值提升百分比
function modifier_health_bonus_percentage:GetHealthBonusPct()
    return self.health_bonus_pct
end

function modifier_health_bonus_percentage:GetModifierHealthBonus()
    return self.bonus_health or 0
end

-- 可选：在移除修饰器时处理生命值变化
function modifier_health_bonus_percentage:OnRemoved()
    -- 不需要特殊处理，游戏会自动重新计算单位属性
end 