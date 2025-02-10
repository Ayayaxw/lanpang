modifier_double_on_death = class({})

function modifier_double_on_death:IsHidden()
    return false
end

function modifier_double_on_death:IsPurgable() 
    return false
end

function modifier_double_on_death:GetTexture()
    return "item_aegis"
end

function modifier_double_on_death:OnCreated(kv)
    if IsServer() then
        local unit = self:GetParent()
        if not unit.death_count then
            unit.death_count = 0
            unit.initial_health = unit:GetBaseMaxHealth()
            unit.initial_attack = unit:GetBaseDamageMin()
        end
        unit:AddNewModifier(unit, nil, "modifier_phased", {})
    end
end

function modifier_double_on_death:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }
    return funcs
end

function modifier_double_on_death:GetModifierExtraHealthBonus()
    local unit = self:GetParent()
    if unit.death_count and unit.initial_health then
        local multiplier = math.pow(1.1, unit.death_count)
        -- 四舍五入到2位小数
        multiplier = math.floor(multiplier * 100 + 0.5) / 100
        return unit.initial_health * multiplier - 10
    end
    return 0
end

function modifier_double_on_death:OnDeath(keys)
    if IsServer() then
        local unit = keys.unit
        if unit == self:GetParent() then
            Timers:CreateTimer(0.1, function()
                unit.death_count = unit.death_count + 1
                
                -- 计算新的基础攻击力 (1.1倍)
                local multiplier = math.pow(1.1, unit.death_count)
                -- 四舍五入到2位小数
                multiplier = math.floor(multiplier * 100 + 0.5) / 100
                local new_base_damage = unit.initial_attack * multiplier
                
                unit:RespawnUnit()
                
                -- 直接设置基础攻击力
                unit:SetBaseDamageMin(new_base_damage)
                unit:SetBaseDamageMax(new_base_damage)
                
                -- 重新添加modifier来刷新状态
                unit:RemoveModifierByName("modifier_double_on_death")
                unit:AddNewModifier(unit, nil, "modifier_double_on_death", {})
                
                unit:SetHealth(unit:GetMaxHealth())
                
                local particle = ParticleManager:CreateParticle(
                    "particles/units/heroes/hero_undying/undying_zombie_death_dirt01.vpcf",
                    PATTACH_ABSORIGIN_FOLLOW,
                    unit
                )
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 播放僵尸复活音效
                EmitSoundOn("Undying_Zombie.Spawn", unit)
            end)
        end
    end
end

function modifier_double_on_death:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_double_on_death:GetCustomDescription()
    local unit = self:GetParent()
    if unit.death_count then
        local multiplier = math.pow(1.1, unit.death_count)
        -- 四舍五入到2位小数
        multiplier = math.floor(multiplier * 100 + 0.5) / 100
        return string.format("每次死亡后立即复活，属性提升1.1倍\n当前倍率：x%.2f", multiplier)
    end
    return "每次死亡后立即复活，属性提升1.1倍"
end