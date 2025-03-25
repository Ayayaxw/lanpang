modifier_custom_neutral_upgrade = class({})

function modifier_custom_neutral_upgrade:IsHidden()
    return false
end

function modifier_custom_neutral_upgrade:IsPurgable()
    return false
end

function modifier_custom_neutral_upgrade:IsDebuff()
    return false
end

function modifier_custom_neutral_upgrade:RemoveOnDeath()
    return false
end

function modifier_custom_neutral_upgrade:GetTexture()
    return "item_assault"
end

-- 调整为每层正确的加成数值
function modifier_custom_neutral_upgrade:GetBonusesPerStack()
    return {
        health = 30,       -- 每层生命值加成
        armor = 0.5,        -- 每层护甲值加成
        damage = 3,         -- 每层基础攻击力加成
        attack_speed = 5    -- 每层攻击速度加成
    }
end

function modifier_custom_neutral_upgrade:OnCreated(kv)
    -- 移除IsServer()检查，让属性在客户端和服务端都能正确应用
    self.stack_count = kv.stack_count or 1
    self:SetStackCount(self.stack_count)
    
    local bonuses = self:GetBonusesPerStack()
    local stacks = self:GetStackCount()
    
    self.health_bonus = bonuses.health * stacks
    self.armor_bonus = bonuses.armor * stacks
    self.damage_bonus = bonuses.damage * stacks
    self.attack_speed_bonus = bonuses.attack_speed * stacks
    
    if IsServer() then
        local parent = self:GetParent()
        parent:SetBaseDamageMin(parent:GetBaseDamageMin() + self.damage_bonus)
        parent:SetBaseDamageMax(parent:GetBaseDamageMax() + self.damage_bonus)
        -- 打印攻击速度值，便于调试
        print(self:GetParent():GetName() .. " 攻击速度加成值: " .. self.attack_speed_bonus)
        -- 如果有设置基础攻击速度的API，可以类似这样使用
        -- parent:SetBaseAttackTime(parent:GetBaseAttackTime() - (self.attack_speed_bonus / 100))
    end
end

function modifier_custom_neutral_upgrade:OnRefresh(kv)
    if IsServer() then
        local old_damage_bonus = self.damage_bonus or 0
        self.stack_count = kv.stack_count or (self.stack_count + 1)
        self:SetStackCount(self.stack_count)
        
        local bonuses = self:GetBonusesPerStack()
        local stacks = self:GetStackCount()
        
        self.health_bonus = bonuses.health * stacks
        self.armor_bonus = bonuses.armor * stacks -- 变量名修正
        self.damage_bonus = bonuses.damage * stacks
        self.attack_speed_bonus = bonuses.attack_speed * stacks
        
        local parent = self:GetParent()
        parent:SetBaseDamageMin(parent:GetBaseDamageMin() + (self.damage_bonus - old_damage_bonus))
        parent:SetBaseDamageMax(parent:GetBaseDamageMax() + (self.damage_bonus - old_damage_bonus))
    end
end

function modifier_custom_neutral_upgrade:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        parent:SetBaseDamageMin(parent:GetBaseDamageMin() - self.damage_bonus)
        parent:SetBaseDamageMax(parent:GetBaseDamageMax() - self.damage_bonus)
    end
end

-- 修正生命值加成属性为EXTRA_HEALTH_BONUS
function modifier_custom_neutral_upgrade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,    -- 生命值基础加成
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,  -- 护甲加成
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT -- 攻击速度
    }
end

-- 对应修正后的生命值加成函数
function modifier_custom_neutral_upgrade:GetModifierExtraHealthBonus()
    return self.health_bonus or 0
end

function modifier_custom_neutral_upgrade:GetModifierPhysicalArmorBonus()
    return self.armor_bonus or 0 -- 变量名修正
end

function modifier_custom_neutral_upgrade:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_bonus or 0
end

-- 修正描述中的数值显示
function modifier_custom_neutral_upgrade:GetCustomDescription()
    local bonuses = self:GetBonusesPerStack()
    local stacks = self:GetStackCount()
    return string.format(
        "Neutral Upgrade Stacks: %d\nHealth: +%d\nArmor: +%.1f\nDamage: +%d\nAttack Speed: +%d",
        stacks,
        bonuses.health * stacks,
        bonuses.armor * stacks,
        bonuses.damage * stacks,
        bonuses.attack_speed * stacks
    )
end