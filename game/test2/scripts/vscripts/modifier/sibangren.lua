modifier_sibangren = class({})

function modifier_sibangren:IsHidden()
    return true
end

function modifier_sibangren:IsDebuff()
    return false
end

function modifier_sibangren:IsPurgable()
    return false
end

function modifier_sibangren:OnCreated(kv)
    if not IsServer() then return end

    local parent = self:GetParent()

    -- 增加的固定攻击力
    self.additionalDamage = 100   

    -- 记录原始攻击力
    self.originalBaseDamageMin = parent:GetBaseDamageMin()
    self.originalBaseDamageMax = parent:GetBaseDamageMax()
    print("self.originalBaseDamageMin",self.originalBaseDamageMin)
    print("self.additionalDamage",self.additionalDamage)
    a=self.originalBaseDamageMin + self.additionalDamage
    b=self.originalBaseDamageMax+self.additionalDamage
    print("self.SetBaseDamageMin",a)
    print("self.SetBaseDamageMin",b)
    -- 设置新的攻击力
    parent:SetBaseDamageMin(100)
    parent:SetBaseDamageMax(100)

end

function modifier_sibangren:OnDestroy()
    if not IsServer() then return end

end
