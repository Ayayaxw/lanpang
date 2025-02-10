modifier_naibangren = class({})

function modifier_naibangren:IsHidden()
    return true
end

function modifier_naibangren:IsDebuff()
    return false
end

function modifier_naibangren:IsPurgable()
    return false
end

function modifier_naibangren:OnCreated(kv)
    if not IsServer() then return end

    -- 获取当前生命值和最大生命值
    local parent = self:GetParent()
    local currentHealth = parent:GetHealth()
    local maxHealth = parent:GetMaxHealth()

    -- 记录原始最大生命值
    self.originalMaxHealth = maxHealth

    -- 设置新的最大生命值为原来的三倍
    parent:SetBaseMaxHealth(maxHealth * 3)
    parent:SetHealth(currentHealth * 3)

    -- 每秒回复百分比生命值
    self:StartIntervalThink(0.01)
end

function modifier_naibangren:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()
    local healAmount = parent:GetMaxHealth() * 0.0005

    -- 回复5%最大生命值
    parent:Heal(healAmount, self:GetAbility())
end

function modifier_naibangren:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
    return funcs
end

function modifier_naibangren:GetModifierHealthBonus()
    -- 增加最大生命值
    return self.originalMaxHealth * 2
end

function modifier_naibangren:OnDestroy()
    if not IsServer() then return end

    -- 恢复最大生命值为原来的数值
    local parent = self:GetParent()
    parent:SetBaseMaxHealth(self.originalMaxHealth)
    parent:SetHealth(math.min(parent:GetHealth(), self.originalMaxHealth))
end
