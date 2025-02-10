function Main:PlayDefeatAnimation(unit)
    -- 创建聚光灯特效
    local particle = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    
    -- 播放失败音效
    EmitSoundOn("PauseMinigame.TI10.Lose", unit)
    self:gradual_slow_down(unit:GetOrigin(), unit:GetOrigin())

    -- 只有单位存活时才给modifier和动作
    if unit:IsAlive() then
        -- 添加状态修饰器:免伤、定身、禁疗
        unit:AddNewModifier(unit, nil, "modifier_damage_reduction_100", { duration = 10 })
        unit:AddNewModifier(unit, nil, "modifier_rooted", { duration = 10 })
        unit:AddNewModifier(unit, nil, "modifier_disable_healing", { duration = 10 })
        -- 播放失败动作
        unit:StartGesture(ACT_DOTA_DEFEAT)
    end
end

function Main:PlayVictoryEffects(unit)
    -- 播放胜利特效
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, unit)
    ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, unit)
    ParticleManager:SetParticleControl(particle1, 0, unit:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle1)

    -- 播放胜利音效
    EmitSoundOn("Hero_LegionCommander.Duel.Victory", unit)
    
    -- 启动渐变减速效果
    self:gradual_slow_down(unit:GetOrigin(), unit:GetOrigin())

    -- 只有单位存活时才给modifier和动作
    if unit:IsAlive() then
        -- 添加状态修饰器
        unit:AddNewModifier(unit, nil, "modifier_damage_reduction_100", { duration = 10 })
        unit:AddNewModifier(unit, nil, "modifier_rooted", { duration = 10 })
        unit:AddNewModifier(unit, nil, "modifier_disable_healing", { duration = 10 })
        -- 播放胜利动作
        unit:StartGesture(ACT_DOTA_VICTORY)
    end
end


function Main:DisableHeroWithModifiers(unit, duration)
    local modifiers = {
        "modifier_disarmed",
        "modifier_silence", 
        "modifier_rooted",
        "modifier_break",
        "modifier_muted"
    }
    
    for _, modifier in ipairs(modifiers) do
        unit:AddNewModifier(unit, nil, modifier, { duration = duration })
    end
end

function Main:ResetUnit(unit)
    -- 恢复生命值和法力值
    unit:SetHealth(unit:GetMaxHealth())
    unit:SetMana(unit:GetMaxMana())
    
    -- 重置所有技能冷却和充能
    for i = 0, unit:GetAbilityCount() - 1 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            ability:EndCooldown()
            -- 恢复充能点数
            local maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel()) 
            if maxCharges > 0 then
                ability:SetCurrentAbilityCharges(maxCharges)
            end
        end
    end
end

function Main:PrepareHeroForDuel(unit, position, duration, forwardDirection)
    -- 禁用单位并添加限制效果
    self:DisableHeroWithModifiers(unit, duration)
    -- 重置单位状态和技能
    self:ResetUnit(unit)
    -- 设置单位朝向
    unit:SetForwardVector(forwardDirection)
    -- 将单位传送到指定位置
    FindClearSpaceForUnit(unit, position, true)
end

-- PrepareHeroForDuel 函数用于准备一个英雄进入决斗状态。该函数会:

-- 参数说明:
-- unit: 需要准备的英雄单位
-- position: 英雄将被传送到的位置(Vector类型)
-- duration: 限制效果的持续时间(数值类型,单位为秒)
-- forwardDirection: 英雄的朝向(Vector类型)
-- 功能说明:
-- 对英雄添加禁用效果(缴械、沉默、定身、破坏),持续时间为传入duration减5秒
-- 将英雄的生命值和法力值恢复满
-- 重置英雄所有技能的冷却时间和充能数量
-- 设置英雄的朝向
-- 将英雄传送到指定位置