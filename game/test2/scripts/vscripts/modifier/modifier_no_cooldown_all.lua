if modifier_no_cooldown_all == nil then
    modifier_no_cooldown_all = class({})
end

function modifier_no_cooldown_all:IsHidden()
    return true
end

function modifier_no_cooldown_all:IsPurgable()
    return false
end

function modifier_no_cooldown_all:RemoveOnDeath()
    return false
end

function modifier_no_cooldown_all:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ABILITY_START,
    }
    return funcs
end

function modifier_no_cooldown_all:OnAbilityFullyCast(keys)
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
            "invoker_tornado",
            "invoker_alacrity",
            "invoker_forge_spirit"
        }

        -- 只有在施法者是拥有这个 modifier 的英雄时才继续执行
        if hero == caster then
            -- 检查是否是一技能，或者表中的技能
            if ability:GetAbilityIndex() or table.contains(skillTable, ability:GetAbilityName()) then
                -- 将技能的冷却时间设为0
                ability:EndCooldown()

                -- 将技能的魔法消耗设为0，并返还相应的魔法值
                local originalManaCost = ability:GetManaCost(ability:GetLevel() - 1)
                hero:GiveMana(originalManaCost)

                -- 获取当前等级的最大充能层数并设置
                local level = ability:GetLevel()
                local maxCharges = ability:GetMaxAbilityCharges(level)
                ability:SetCurrentAbilityCharges(maxCharges)

                print("已经重置冷却和设置最大充能层数", ability:GetAbilityName())
            end
        end
    end
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
