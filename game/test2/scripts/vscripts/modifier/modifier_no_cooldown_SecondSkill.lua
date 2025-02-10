if modifier_no_cooldown_SecondSkill == nil then
    modifier_no_cooldown_SecondSkill = class({})
end

function modifier_no_cooldown_SecondSkill:IsHidden()
    return true
end

function modifier_no_cooldown_SecondSkill:IsPurgable()
    return false
end

function modifier_no_cooldown_SecondSkill:RemoveOnDeath()
    return false
end

function modifier_no_cooldown_SecondSkill:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
    return funcs
end

function modifier_no_cooldown_SecondSkill:OnAbilityFullyCast(keys)
    if IsServer() then
        local hero = self:GetParent()
        local ability = keys.ability
        local caster = keys.unit

        -- 维护一个特定技能的表
        local skillTable = {
            "invoker_alacrity",
            "invoker_emp", 
            "invoker_tornado", 
            "beastmaster_call_of_the_wild_hawk",
            "alchemist_unstable_concoction",
            "elder_titan_ancestral_spirit",
            "pangolier_shield_crash",
            "dawnbreaker_celestial_hammer",
            "tusk_launch_snowball",
            "tusk_snowball",
            "phoenix_fire_spirits",
            "pangolier_shield_crash",
            "morphling_adaptive_strike_agi",
            "morphling_adaptive_strike_str"
        }

        -- 关联技能表
        local linkedSkills = {
            ["kez_talon_toss"] = "kez_grappling_claw",
            ["kez_grappling_claw"] = "kez_talon_toss"
        }

        -- 只有在施法者是拥有这个 modifier 的英雄时才继续执行
        if hero == caster then
            local noCooldownAbilityIndices = {1} -- 默认只有1技能无CD

            -- 如果是影魔，则改为3技能
            if hero:GetUnitName() == "npc_dota_hero_nevermore" then
                noCooldownAbilityIndices = {3}
            -- 如果是巨魔战将，则1技能和2技能都无CD
            elseif hero:GetUnitName() == "npc_dota_hero_troll_warlord" then
                noCooldownAbilityIndices = {1, 2}
            end

            -- 检查是否是指定技能，或者表中的技能
            if table.contains(noCooldownAbilityIndices, ability:GetAbilityIndex()) or table.contains(skillTable, ability:GetAbilityName()) then
                -- 先返还魔法值（只对主技能返还）
                local originalManaCost = ability:GetManaCost(ability:GetLevel())
                hero:GiveMana(originalManaCost)

                -- 重置主技能的冷却和充能
                self:ResetCooldownAndCharges(hero, ability)

                -- 检查并重置关联技能（只重置冷却，不返还魔法值）
                local linkedSkillName = linkedSkills[ability:GetAbilityName()]
                if linkedSkillName then
                    local linkedAbility = hero:FindAbilityByName(linkedSkillName)
                    if linkedAbility then
                        self:ResetCooldownAndCharges(hero, linkedAbility)
                        print("已经重置关联技能", linkedSkillName)
                    end
                end
            end
        end
    end
end

function modifier_no_cooldown_SecondSkill:ResetCooldownAndCharges(hero, ability)
    -- 只重置冷却和充能次数，不返还魔法值
    ability:EndCooldown()

    -- 获取当前等级的最大充能层数并设置
    local level = ability:GetLevel()
    local maxCharges = ability:GetMaxAbilityCharges(level)
    ability:SetCurrentAbilityCharges(maxCharges)

    print("已经重置冷却和设置最大充能层数", ability:GetAbilityName())
end

function modifier_no_cooldown_SecondSkill:ResetManaOnly(hero, ability)
    -- 只返还魔法值
    local originalManaCost = ability:GetManaCost(ability:GetLevel() - 1)
    hero:GiveMana(originalManaCost)
    
    print("已经返还魔法值", ability:GetAbilityName())
end


-- 辅助函数：检查技能是否在表中
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
