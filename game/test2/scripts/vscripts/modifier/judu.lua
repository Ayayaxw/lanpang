modifier_judu = class({})

function modifier_judu:IsHidden()
    return true
end

function modifier_judu:IsDebuff()
    return false
end

function modifier_judu:IsPurgable()
    return false
end

function modifier_judu:OnCreated(kv)
    if not IsServer() then return end

    -- 获取当前生命值和最大生命值
    local parent = self:GetParent()
    local currentHealth = parent:GetHealth()
    local maxHealth = parent:GetMaxHealth()

    -- 记录原始最大生命值和攻击力
    self.originalMaxHealth = maxHealth
    self.originalBaseDamageMin = parent:GetBaseDamageMin()
    self.originalBaseDamageMax = parent:GetBaseDamageMax()

    -- 设置新的最大生命值为原来的2.5倍
    parent:SetBaseMaxHealth(maxHealth * 2.5)
    parent:SetHealth(currentHealth * 2.5)

    -- 设置新的攻击力为原来的2.5倍
    local newBaseDamageMin = self.originalBaseDamageMin * 2.5
    local newBaseDamageMax = self.originalBaseDamageMax * 2.5

    parent:SetBaseDamageMin(newBaseDamageMin)
    parent:SetBaseDamageMax(newBaseDamageMax)

    -- 调试信息
    print("modifier_judu created")
    print("Original Max Health: ", self.originalMaxHealth)
    print("New Max Health: ", parent:GetMaxHealth())
    print("Original Base Damage Min: ", self.originalBaseDamageMin)
    print("Original Base Damage Max: ", self.originalBaseDamageMax)
    print("New Base Damage Min: ", newBaseDamageMin)
    print("New Base Damage Max: ", newBaseDamageMax)
end

function modifier_judu:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
    }
    return funcs
end

function modifier_judu:GetModifierHealthBonus()
    -- 增加最大生命值
    return self.originalMaxHealth * 1.5
end

function modifier_judu:OnDestroy()
    if not IsServer() then return end

    -- 恢复最大生命值为原来的数值
    local parent = self:GetParent()
    parent:SetBaseMaxHealth(self.originalMaxHealth)
    parent:SetHealth(math.min(parent:GetHealth(), self.originalMaxHealth))

    -- 恢复原始攻击力
    parent:SetBaseDamageMin(self.originalBaseDamageMin)
    parent:SetBaseDamageMax(self.originalBaseDamageMax)
end
