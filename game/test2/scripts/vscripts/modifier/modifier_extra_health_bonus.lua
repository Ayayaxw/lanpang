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
        local old_health = parent:GetHealth()
        local old_max_health = parent:GetMaxHealth()
        local health_percent = old_health / old_max_health
        
        
        
        
        
        -- 计算应用额外生命值后的理论最大生命值
        local theoretical_max_health = old_max_health + self.extra_health
        
        
        -- 先重新计算属性，让游戏应用修饰符效果
        if parent:IsHero() then
            parent:CalculateStatBonus(true)
        end
        
        -- 获取更新后的最大生命值
        local new_max_health = parent:GetMaxHealth()
        
        
        -- 保持原有的生命值百分比
        local new_health = new_max_health * health_percent
        
        
        parent:SetHealth(new_health)
        
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
            local old_health = parent:GetHealth()
            local old_max_health = parent:GetMaxHealth()
            local health_percent = old_health / old_max_health

            
            
            
            
            -- 计算应用额外生命值后的理论最大生命值
            local theoretical_max_health = old_max_health - old_extra_health + self.extra_health
            

            -- 先重新计算属性，让游戏应用修饰符效果
            if parent:IsHero() then
                parent:CalculateStatBonus(true)
            end
            
            -- 获取更新后的最大生命值
            local new_max_health = parent:GetMaxHealth()
            
            
            -- 保持原有的生命值百分比
            local new_health = new_max_health * health_percent
            
            
            parent:SetHealth(new_health)
            
        end
    end
end

-- function modifier_extra_health_bonus:PlayLevelUpEffect()
--     local parent = self:GetParent()
--     local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_level_up.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
--     ParticleManager:ReleaseParticleIndex(particle)
    
--     -- 可选：播放升级音效
--     EmitSoundOn("General.LevelUp", parent)
-- end

function modifier_extra_health_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }
end

function modifier_extra_health_bonus:GetModifierExtraHealthBonus()
    return self.extra_health or 0
end

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
        local old_health = parent:GetHealth()
        local old_max_health = parent:GetMaxHealth()
        local health_percent = old_health / old_max_health
        
        
        
        
        
        -- 计算应用额外生命值后的理论最大生命值
        local theoretical_max_health = old_max_health - old_extra_health + self.extra_health
        
        
        -- 先重新计算属性，让游戏应用修饰符效果
        if parent:IsHero() then
            parent:CalculateStatBonus(true)
        end
        
        -- 获取更新后的最大生命值
        local new_max_health = parent:GetMaxHealth()
        
        
        -- 保持原有的生命值百分比
        local new_health = new_max_health * health_percent
        
        
        parent:SetHealth(new_health)
        
    end
end

function modifier_extra_health_bonus:GetCustomDescription()
    return string.format("额外生命值: +%d", self.extra_health or 0)
end