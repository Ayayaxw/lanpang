-- ai/heroes/shadow_shaman.lua

require("ai/core/ai_core")
require("ai/core/common_ai")


ShadowShamanAI = {}

function ShadowShamanAI:IsTargetHexed(target)
    for i = 0, target:GetModifierCount() - 1 do
        local modifierName = target:GetModifierNameByIndex(i)
        if modifierName == "modifier_sheepstick_debuff" or modifierName == "modifier_shadow_shaman_voodoo" then
            return true
        end
    end
    return false
end

function ShadowShamanAI:GetHexRemainingTime(target)
    --Say(entity, "对敌人施放以太冲击。", false)
    --self:log("Function GetHexRemainingTime called")
    --self:log("查看修改器数量", target:GetModifierCount())

    for i = 0, target:GetModifierCount() - 1 do
        local modifierName = target:GetModifierNameByIndex(i)
        --self:log("检查修改器:", i, modifierName)

        if modifierName == "modifier_sheepstick_debuff" or modifierName == "modifier_shadow_shaman_voodoo" then
            -- 获取修饰器实例
            local modifier = target:FindModifierByName(modifierName)
            if modifier then
                -- 获取修饰器的持续时间
                local duration = modifier:GetRemainingTime()
                --self:log("找到Hex，持续时间:", duration)
                return duration
            end
        end
    end
    --self:log("No Hex found, returning 0")
    return 0
end




function ShadowShamanAI:Think(entity)
    if not entity:IsAlive() then
        return nil
    end

    if entity:IsChanneling() then
        return 1
    end

    -- 尝试寻找英雄目标
    local target = CommonAI:FindHeroTarget(entity)
    if not target then
        -- 如果没有英雄，寻找任何其他目标
        target = CommonAI:FindTarget(entity)
    end

    if target then
        local isMagicImmune = target:IsMagicImmune()
        local isDebuffImmune = target:IsDebuffImmune()
        local heroName = entity:GetUnitName()
        local rules = SkillRules[heroName]

        -- 优先对英雄释放妖术和枷锁，如果目标是英雄或没有英雄时对其他单位释放
        if target:IsHero() or not CommonAI:FindHeroTarget(entity) then
            if not isDebuffImmune or not self:IsSkillDisallowedOnDebuffImmune(rules, "shadow_shaman_voodoo") then
                if entity:FindAbilityByName("shadow_shaman_voodoo"):IsFullyCastable() then
                    entity:CastAbilityOnTarget(target, entity:FindAbilityByName("shadow_shaman_voodoo"), entity:GetPlayerOwnerID())
                    return 0.5
                end
            end

            if not isDebuffImmune or not self:IsSkillDisallowedOnDebuffImmune(rules, "shadow_shaman_shackles") then
                if entity:FindAbilityByName("shadow_shaman_shackles"):IsFullyCastable() then
                    hextime = self:GetHexRemainingTime(target)
                    if hextime < 0.4 then
                        entity:CastAbilityOnTarget(target, entity:FindAbilityByName("shadow_shaman_shackles"), entity:GetPlayerOwnerID())
                        return 1
                    else
                        entity:MoveToTargetToAttack(target)
                    end
                end
            end
        end

        -- 对所有目标释放群蛇守卫和以太冲击
        if entity:FindAbilityByName("shadow_shaman_mass_serpent_ward"):IsFullyCastable() then
            entity:CastAbilityOnPosition(target:GetAbsOrigin(), entity:FindAbilityByName("shadow_shaman_mass_serpent_ward"), entity:GetPlayerOwnerID())
            return 0.5
        end

        if not isDebuffImmune or not self:IsSkillDisallowedOnDebuffImmune(rules, "shadow_shaman_ether_shock") then
            if entity:FindAbilityByName("shadow_shaman_ether_shock"):IsFullyCastable() then
                entity:CastAbilityOnTarget(target, entity:FindAbilityByName("shadow_shaman_ether_shock"), entity:GetPlayerOwnerID())
                return 0.5
            end
        end
    end

    -- 如果没有技能可用，则进行普通攻击
    if target then
        entity:MoveToTargetToAttack(target)
    end

    return 0.1
end

function ShadowShamanAI:IsSkillDisallowedOnDebuffImmune(rules, abilityName)
    if not rules or not rules.disallow_on_debuff_immune then
        return false
    end
    return table.contains(rules.disallow_on_debuff_immune, abilityName)
end

-- Helper function to check if a table contains a value
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

BehaviorAttack = {}

function BehaviorAttack:Evaluate()
    return 1
end

function BehaviorAttack:Begin()
    -- 攻击逻辑在HeroAI中实现
end

function BehaviorAttack:Think()
    -- 攻击逻辑在HeroAI中实现
    return "complete"
end
