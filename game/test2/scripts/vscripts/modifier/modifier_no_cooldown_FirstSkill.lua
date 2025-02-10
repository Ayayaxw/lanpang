if modifier_no_cooldown_FirstSkill == nil then
    modifier_no_cooldown_FirstSkill = class({})
end

function modifier_no_cooldown_FirstSkill:IsHidden()
    return true
end

function modifier_no_cooldown_FirstSkill:IsPurgable()
    return false
end

function modifier_no_cooldown_FirstSkill:RemoveOnDeath()
    return false
end

function modifier_no_cooldown_FirstSkill:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ABILITY_START,
    }
    return funcs
end

function modifier_no_cooldown_FirstSkill:OnAbilityFullyCast(keys)
    if IsServer() then
        local hero = self:GetParent()
        local ability = keys.ability
        local caster = keys.unit

        -- 维护一个特定技能的表
        local skillTable = {
            "primal_beast_onslaught",
            "primal_beast_onslaught_release",
            "hoodwink_acorn_shot",
            "nevermore_shadowraze3",
            "nevermore_shadowraze1",
            "nevermore_shadowraze2",
            "invoker_cold_snap",
            "invoker_ghost_walk",
            "invoker_ice_wall",
            "invoker_tornado",

            "invoker_forge_spirit",
            "rubick_telekinesis_land",
            "invoker_deafening_blast",
        }

        -- 关联技能表
        local linkedSkills = {
            ["rubick_telekinesis_land"] = "rubick_telekinesis",
            -- 可以在这里添加更多的关联技能
        }

        -- 只有在施法者是拥有这个 modifier 的英雄时才继续执行
        if hero == caster then
            -- 检查是否是一技能，或者表中的技能
            if ability:GetAbilityIndex() == 0 or table.contains(skillTable, ability:GetAbilityName()) then
                -- 重置当前技能
                self:ResetAbility(hero, ability)

                -- 检查并重置关联技能
                local linkedSkillName = linkedSkills[ability:GetAbilityName()]
                if linkedSkillName then
                    local linkedAbility = hero:FindAbilityByName(linkedSkillName)
                    if linkedAbility then
                        self:ResetAbility(hero, linkedAbility)
                        print("已经重置关联技能", linkedSkillName)
                    end
                end
            end
        end
    end
end


function modifier_no_cooldown_FirstSkill:ResetAbility(hero, ability)
    local abilityName = ability:GetAbilityName()

    -- 如果是地震猛击，只返还魔法值
    if abilityName == "ursa_earthshock" then
        -- 返还魔法值
        local originalManaCost = ability:GetManaCost(ability:GetLevel() - 1)
        hero:GiveMana(originalManaCost)
        print("地震猛击 - 仅返还魔法值")
        return
    end

    -- 其他技能正常处理
    -- 重置冷却时间
    ability:EndCooldown()

    -- 返还魔法值
    local originalManaCost = ability:GetManaCost(ability:GetLevel() - 1)
    hero:GiveMana(originalManaCost)

    -- 设置最大充能层数
    local level = ability:GetLevel()
    local maxCharges = ability:GetMaxAbilityCharges(level)
    ability:SetCurrentAbilityCharges(maxCharges)

    print("已经重置冷却和设置最大充能层数", abilityName)
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
