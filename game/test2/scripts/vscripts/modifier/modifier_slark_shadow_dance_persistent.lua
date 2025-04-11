modifier_slark_shadow_dance_persistent = class({})

function modifier_slark_shadow_dance_persistent:IsHidden()
    return false
end

function modifier_slark_shadow_dance_persistent:IsDebuff()
    return false
end

function modifier_slark_shadow_dance_persistent:IsPurgable()
    return false
end

function modifier_slark_shadow_dance_persistent:RemoveOnDeath()
    return false
end

function modifier_slark_shadow_dance_persistent:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_slark_shadow_dance_persistent:AllowIllusionDuplicate()
    return true
end

function modifier_slark_shadow_dance_persistent:GetTexture()
    return "slark_shadow_dance"
end

function modifier_slark_shadow_dance_persistent:OnCreated(kv)
    if not IsServer() then return end
    
    -- Initial state is invisible
    self.is_visible = false
    self.reveal_end_time = 0
    
    -- 获取渐隐时间参数，如果没有提供则使用默认值0.6
    self.fade_time = kv and kv.fade_time or 0.6
    
    -- Apply initial invisibility
    self:UpdateInvisibility()
    
    -- Start checking state
    self:StartIntervalThink(0.1)
end

function modifier_slark_shadow_dance_persistent:OnIntervalThink()
    if not IsServer() then return end
    
    local current_time = GameRules:GetGameTime()
    local parent = self:GetParent()
    
    -- 检查控制状态
    local is_controlled = false
    
    -- 检查眩晕
    if parent:IsStunned() then
        is_controlled = true
    end
    
    -- 检查妖术
    if parent:IsHexed() then
        is_controlled = true
    end

    if parent:IsRooted() then
        is_controlled = true
    end


    if parent:IsLeashed() then
        is_controlled = true
    end
    
    -- 检查嘲讽
    if parent:IsTaunted() then
        is_controlled = true
    end
    
    -- 检查恐惧
    if parent:IsFeared() then
        is_controlled = true
    end
    
    -- 如果处于控制状态，则显形
    if is_controlled then
        self:Reveal()
    -- 如果不在控制状态，且显形时间已过，则重新隐身
    elseif self.is_visible and current_time >= self.reveal_end_time then
        self.is_visible = false
        self:UpdateInvisibility()
    end
end

function modifier_slark_shadow_dance_persistent:UpdateInvisibility()
    local parent = self:GetParent()
    
    -- 无论当前状态如何，都先移除现有的渐隐修饰器
    parent:RemoveModifierByName("modifier_slark_fade_transition")
    
    if self.is_visible then
        -- 可见状态，不添加任何修饰器
    else
        -- 隐身状态，添加新的渐隐修饰器
        parent:AddNewModifier(parent, nil, "modifier_slark_fade_transition", {})
    end
end

function modifier_slark_shadow_dance_persistent:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_slark_shadow_dance_persistent:Reveal()
    if not IsServer() then return end
    
    -- If already revealed, just extend the duration
    if self.is_visible then
        self.reveal_end_time = GameRules:GetGameTime() + self.fade_time
        return
    end
    
    -- Set to revealed state
    self.is_visible = true
    self.reveal_end_time = GameRules:GetGameTime() + self.fade_time
    
    -- Update invisibility status
    self:UpdateInvisibility()
end

function modifier_slark_shadow_dance_persistent:OnAttack(keys)
    if not IsServer() then return end
    if keys.attacker ~= self:GetParent() then return end
    
    self:Reveal()
end

function modifier_slark_shadow_dance_persistent:OnAbilityExecuted(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetParent() then return end
    
    self:Reveal()
end

function modifier_slark_shadow_dance_persistent:OnTakeDamage(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetParent() then return end
    
    -- Optional: Uncomment if you want taking damage to reveal
    -- self:Reveal()
end

LinkLuaModifier("modifier_slark_fade_transition", "modifier/modifier_slark_shadow_dance_persistent.lua", LUA_MODIFIER_MOTION_NONE)

modifier_slark_fade_transition = class({})

function modifier_slark_fade_transition:IsHidden() return false end
function modifier_slark_fade_transition:IsDebuff() return false end
function modifier_slark_fade_transition:IsPurgable() return false end

function modifier_slark_fade_transition:OnCreated()
    -- 初始化基础变量
    self.invisible_fade_time = 0.1
    

end

function modifier_slark_fade_transition:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
end

function modifier_slark_fade_transition:GetModifierInvisibilityLevel()

    return self:GetElapsedTime() / 100
end

-- 根据时间判断是否应该进入隐身状态
function modifier_slark_fade_transition:CheckState()
    if self:GetElapsedTime() >= self.invisible_fade_time then
        return {
            [MODIFIER_STATE_INVISIBLE] = true,
        }
    else
        return {}
    end
end

function modifier_slark_fade_transition:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end