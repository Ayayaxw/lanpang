modifier_extra_health_bonus = class({})

function modifier_extra_health_bonus:IsHidden()
    return true
end

function modifier_extra_health_bonus:IsPurgable()
    return false
end

function modifier_extra_health_bonus:IsDebuff()
    return false
end

function modifier_extra_health_bonus:RemoveOnDeath()
    return false
end

function modifier_extra_health_bonus:AllowIllusionDuplicate()
    return true
end

function modifier_extra_health_bonus:GetTexture()
    return "item_heart"
end

function modifier_extra_health_bonus:OnCreated(kv)
    if IsServer() then
        -- 从参数中获取额外生命值，如果没有提供则默认为100
        self.extra_health = kv.bonus_health or 100
        
        -- 确保数值为非负
        if self.extra_health < 0 then
            self.extra_health = 0
        end
        
        -- 强制重新计算属性以应用修饰符的加成
        local parent = self:GetParent()
        if parent:IsHero() then
            -- 英雄单位使用CalculateStatBonus
            parent:CalculateStatBonus(true)
        else
            -- 非英雄单位不需要调用CalculateStatBonus
            -- 可以使用其他方法刷新状态
            parent:SetMaxHealth(parent:GetMaxHealth() + self.extra_health)
            parent:SetHealth(parent:GetHealth() + self.extra_health)
        end
    end
end

function modifier_extra_health_bonus:OnRefresh(kv)
    if IsServer() then
        -- 记录旧的生命值加成，用于计算生命值差值
        local old_extra_health = self.extra_health or 0
        
        -- 更新额外生命值
        if kv and kv.bonus_health then
            self.extra_health = kv.bonus_health
            
            -- 确保数值为非负
            if self.extra_health < 0 then
                self.extra_health = 0
            end
            
            -- 强制重新计算属性以应用修饰符的加成
            local parent = self:GetParent()
            if parent:IsHero() then
                -- 英雄单位使用CalculateStatBonus
                parent:CalculateStatBonus(true)
            else
                -- 非英雄单位处理生命值差值
                local health_diff = self.extra_health - old_extra_health
                if health_diff ~= 0 then
                    parent:SetMaxHealth(parent:GetMaxHealth() + health_diff)
                    
                    -- 如果是增加生命值，同时增加当前生命值
                    if health_diff > 0 then
                        parent:SetHealth(parent:GetHealth() + health_diff)
                    end
                end
            end
        end
    end
end

function modifier_extra_health_bonus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }
    return funcs
end

function modifier_extra_health_bonus:GetModifierExtraHealthBonus()
    -- 对英雄单位返回额外生命值，对非英雄单位返回0（因为已经在OnCreated/OnRefresh直接修改）
    if self:GetParent():IsHero() then
        return self.extra_health or 0
    else
        return 0
    end
end

-- 设置额外生命值的方法（可供外部调用）
function modifier_extra_health_bonus:SetExtraHealth(value)
    if IsServer() then
        -- 记录旧的生命值加成，用于计算生命值差值
        local old_extra_health = self.extra_health or 0
        
        -- 确保数值为非负
        if value < 0 then
            self.extra_health = 0
        else
            self.extra_health = value
        end
        
        -- 强制重新计算属性以应用修饰符的加成
        local parent = self:GetParent()
        if parent:IsHero() then
            -- 英雄单位使用CalculateStatBonus
            parent:CalculateStatBonus(true)
        else
            -- 非英雄单位处理生命值差值
            local health_diff = self.extra_health - old_extra_health
            if health_diff ~= 0 then
                parent:SetMaxHealth(parent:GetMaxHealth() + health_diff)
                
                -- 如果是增加生命值，同时增加当前生命值
                if health_diff > 0 then
                    parent:SetHealth(parent:GetHealth() + health_diff)
                end
            end
        end
    end
end

function modifier_extra_health_bonus:GetCustomDescription()
    return string.format("额外生命值: +%d", self.extra_health or 0)
end 