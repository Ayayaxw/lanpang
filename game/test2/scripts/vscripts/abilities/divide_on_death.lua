-- 技能定义
divide_on_death = class({})

function divide_on_death:GetIntrinsicModifierName()
    return "modifier_divide_on_death"
end

function divide_on_death:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function divide_on_death:GetMaxLevel()
    return 1
end

-- modifier定义
LinkLuaModifier("modifier_divide_on_death", "abilities/divide_on_death.lua", LUA_MODIFIER_MOTION_NONE)

modifier_divide_on_death = class({})

function modifier_divide_on_death:IsHidden()
    return true
end

function modifier_divide_on_death:IsDebuff()
    return false
end

function modifier_divide_on_death:IsPurgable()
    return false
end

function modifier_divide_on_death:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_divide_on_death:OnDeath(event)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    
    -- 确保是技能拥有者死亡时触发
    if event.unit ~= parent then return end
    
    -- 记录死亡位置
    local death_position = parent:GetAbsOrigin()
    
    -- 获取或初始化死亡计数
    if not parent.death_count then
        parent.death_count = 0
    end
    parent.death_count = parent.death_count + 1
    
    -- 计算要生成的单位数量：2^n - 1
    local clone_count = math.pow(2, parent.death_count) - 1
    
    -- 销毁所有现存的克隆体
    local clones = parent.clones or {}
    for _, clone in pairs(clones) do
        if IsValidEntity(clone) then
            clone:ForceKill(false)
            UTIL_Remove(clone)
        end
    end
    parent.clones = {}
    
    -- 1秒后复活并生成克隆体
    Timers:CreateTimer(1.0, function()
        -- 复活本体并传送回死亡位置
        parent:RespawnHero(false, false)
        -- 移除泉水无敌
        parent:RemoveModifierByName("modifier_fountain_invulnerability")
        FindClearSpaceForUnit(parent, death_position, true)
        
        -- 获取本体属性
        local parent_hp = parent:GetMaxHealth()
        local parent_str = parent:GetBaseStrength()
        local parent_agi = parent:GetBaseAgility()
        local parent_int = parent:GetBaseIntellect()
        
        -- 生成克隆体
        for i = 1, clone_count do
            local clone = CreateUnitByName(
                parent:GetUnitName(),
                death_position + RandomVector(100),
                true,
                parent,
                parent:GetOwner(),
                parent:GetTeamNumber()
            )
            
            -- -- 设置克隆体属性
            -- clone:SetBaseMaxHealth(parent_hp)
            -- clone:SetHealth(parent_hp)
            -- clone:SetBaseMoveSpeed(parent:GetBaseMoveSpeed())
            -- clone:SetBaseAttackTime(parent:GetBaseAttackTime())
            
            -- -- 设置三维属性
            -- clone:SetBaseStrength(parent_str)
            -- clone:SetBaseAgility(parent_agi)
            -- clone:SetBaseIntellect(parent_int)
            
            -- 记录克隆体
            table.insert(parent.clones, clone)
        end
    end)
end