modifier_sniper_kill_bonus = class({})

function modifier_sniper_kill_bonus:IsHidden()
    return false
end

function modifier_sniper_kill_bonus:IsPurgable()
    return false
end

function modifier_sniper_kill_bonus:GetTexture()
    return "sniper_assassinate"
end

function modifier_sniper_kill_bonus:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_HERO_KILLED
    }
    return funcs
end

function modifier_sniper_kill_bonus:OnHeroKilled(event)
    if not IsServer() then return end
    
    local parent = self:GetParent()
    local attacker = event.attacker
    local target = event.target
    
    -- 检查被击杀的是否是敌方英雄
    if target:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then return end
    
    -- 检查击杀者是否是拥有该buff的英雄或其召唤物/幻象
    local isValidKiller = false
    if attacker == parent then
        isValidKiller = true
    else
        -- 检查是否是召唤物
        if attacker:IsSummoned() then
            local owner = attacker:GetOwner()
            if owner == parent then
                isValidKiller = true
            end
        end
        
        -- 检查是否是幻象
        if attacker:IsIllusion() then
            local owner = attacker:GetOwner()
            if owner == parent then
                isValidKiller = true
            end
        end
    end
    
    if not isValidKiller then return end
    
    -- 恢复生命值和魔法值
    local maxHealth = parent:GetMaxHealth()
    local maxMana = parent:GetMaxMana()
    local healAmount = maxHealth * 0.02
    local manaAmount = maxMana * 0.02
    
    parent:Heal(healAmount, nil)
    parent:GiveMana(manaAmount)

    -- 添加恢复特效
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_break_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    -- 检查并降低技能冷却
    for i = 0, parent:GetAbilityCount() - 1 do
        local ability = parent:GetAbilityByIndex(i)
        if ability and ability:GetCooldownTimeRemaining() > 0 then
            local currentCooldown = ability:GetCooldownTimeRemaining()
            local cooldownReduction = 1 
            local newCooldown = math.max(0, currentCooldown - cooldownReduction)
            ability:EndCooldown()
            if newCooldown > 0 then
                ability:StartCooldown(newCooldown)
            end
        end
    end
end