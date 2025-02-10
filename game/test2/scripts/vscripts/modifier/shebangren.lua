modifier_shebangren = class({})
require('libraries/projectiles')

function modifier_shebangren:IsDebuff()
    return false
end

function modifier_shebangren:IsPurgable()
    return false
end

function modifier_shebangren:IgnoreSpellImmunity()
    return true
end

function modifier_shebangren:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end


function PrintTable(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end


function modifier_shebangren:OnCreated(kv)
    if not IsServer() then return end

    local parent = self:GetParent()

    -- 记录原始最大生命值和当前生命值
    self.originalMaxHealth = parent:GetMaxHealth()
    self.originalHealth = parent:GetHealth()

    -- 获取英雄的智力值
    local intelligence = parent:GetIntellect(false)
    print("Intelligence: ", intelligence)

    -- 计算基础攻击力，使得最终攻击力为1200
    local baseDamage = 1200 - intelligence + 1
    self.baseDamage = baseDamage
    print("Base Damage: ", baseDamage)

    -- 确保baseDamage正确赋值
    if not baseDamage then
        print("Error: baseDamage is nil")
        return
    end

    -- 设置新的攻击力
    parent:SetBaseDamageMin(baseDamage)
    parent:SetBaseDamageMax(baseDamage)
    parent:SetBaseHealthRegen(-14.5)

    -- 刷新属性
    parent:CalculateStatBonus(true)

    -- -- 调试信息
    -- print("modifier_shebangren created")
    -- print("Original Max Health: ", self.originalMaxHealth)
    -- print("Original Health: ", self.originalHealth)
    -- print("Intelligence: ", intelligence)
    -- print("Base Damage: ", baseDamage)
end


function modifier_shebangren:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_EVENT_ON_PROJECTILE_HIT,
        --MODIFIER_PROPERTY_HEALTH_BONUS -- 新增属性函数
    }
    return funcs
end

function modifier_shebangren:GetModifierHealthBonus(params)
    local parent = self:GetParent()
    local targetHealth = 45
    local currentMaxHealth = parent:GetMaxHealth()
    return targetHealth - currentMaxHealth
end



-- function modifier_shebangren:OnAttackStart(keys)
--     if not IsServer() then return end
--     local attacker = keys.attacker

--     if attacker == self:GetParent() then
--         print("Attack Started by: ", attacker:GetUnitName())
--         local target = keys.target
--         local damage = attacker:GetAttackDamage()
--         print("Current Attack Damage: ", damage)

--         -- 寻找目标周围的敌人
--         local enemies = FindUnitsInRadius(
--             attacker:GetTeamNumber(),
--             target:GetAbsOrigin(),
--             nil,
--             300, -- 搜索范围为300
--             DOTA_UNIT_TARGET_TEAM_ENEMY,
--             DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
--             DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
--             FIND_ANY_ORDER,
--             false
--         )

--         local new_target = nil
--         for _, enemy in pairs(enemies) do
--             if enemy ~= target then
--                 new_target = enemy
--                 break
--             end
--         end

--         if new_target then
--             -- 创建一个新的投射物
--             local projectile = {
--                 EffectName = "particles/units/heroes/hero_drow/drow_base_attack.vpcf",
--                 vSpawnOrigin = attacker:GetAbsOrigin(),
--                 Source = attacker,
--                 Target = new_target,
--                 vVelocity = (new_target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized() * 900,
--                 UnitBehavior = PROJECTILES_DESTROY,
--                 bMultipleHits = false,
--                 bIsAttack = true,  -- 确保这是一个攻击投射物
--                 bIgnoreSource = true,
--                 TreeBehavior = PROJECTILES_NOTHING,
--                 bDodgeable = true,
--                 bTreeFullCollision = false,
--                 WallBehavior = PROJECTILES_NOTHING,
--                 GroundBehavior = PROJECTILES_NOTHING,
--                 fGroundOffset = 80,
--                 bRecreateOnChange = true,
--                 bZCheck = false,
--                 bGroundLock = true,
--                 bProvidesVision = true,
--                 iVisionRadius = 350,
--                 iVisionTeamNumber = attacker:GetTeam(),
--                 bFlyingVision = false,
--                 fVisionTickTime = .1,
--                 fVisionLingerDuration = 1,
--                 draw = true,
--                 UnitTest = function(self, unit)
--                     return unit:GetTeamNumber() ~= attacker:GetTeamNumber()
--                 end,
--                 OnUnitHit = function(self, unit)
--                     print("HIT UNIT: " .. unit:GetUnitName())
--                     -- 造成与英雄当前攻击力相同的伤害
--                     ApplyDamage({
--                         victim = unit,
--                         attacker = self.Source,
--                         damage = damage,
--                         damage_type = DAMAGE_TYPE_PHYSICAL,
--                         ability = self.Ability,
--                     })
--                     print("Damage applied to: ", unit:GetUnitName(), "Damage: ", damage)
--                 end,
--             }
--             print("Creating split attack projectile with the following parameters:")
--             PrintTable(projectile)
--             -- 使用 Projectiles 库创建投射物
--             Projectiles:CreateProjectile(projectile)
--             print("Tracking projectile created successfully")
--         end
--     end
-- end




function modifier_shebangren:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()

    -- 恢复最大生命值为原来的数值
    parent:SetMaxHealth(self.originalMaxHealth)
    parent:SetHealth(math.min(parent:GetHealth(), self.originalMaxHealth))

    -- 恢复原始攻击力
    local baseDamage = self.baseDamage or 0
    parent:SetBaseDamageMin(parent:GetBaseDamageMin() - baseDamage)
    parent:SetBaseDamageMax(parent:GetBaseDamageMax() - baseDamage)
end
