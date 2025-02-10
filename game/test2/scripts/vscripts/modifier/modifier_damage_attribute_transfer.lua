modifier_damage_attribute_transfer = class({})

function modifier_damage_attribute_transfer:IsHidden() return true end
function modifier_damage_attribute_transfer:IsPurgable() return false end
function modifier_damage_attribute_transfer:IsDebuff() return false end
function modifier_damage_attribute_transfer:RemoveOnDeath() return false end


function modifier_damage_attribute_transfer:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_damage_attribute_transfer:OnTakeDamage(params)
    -- 检查伤害来源是否为 Pugna 的 Life Drain 技能，并且目标是一个真实的英雄而不是幻象
    if params.attacker == self:GetParent() and params.unit:IsAlive() and params.inflictor and params.inflictor:GetName() == "pugna_life_drain" and params.unit:IsRealHero() and not params.unit:IsIllusion() then
    --if params.attacker == self:GetParent() and params.unit:IsAlive() and params.inflictor  and params.unit:IsRealHero() and not params.unit:IsIllusion() then
        if not params.unit:HasModifier("modifier_decrease_attribute") then
            params.unit:AddNewModifier(params.attacker, nil, "modifier_decrease_attribute", {})
        end
        if not params.attacker:HasModifier("modifier_increase_attribute") then
            params.attacker:AddNewModifier(params.attacker, nil, "modifier_increase_attribute", {})
        end
        local mod_decrease = params.unit:FindModifierByName("modifier_decrease_attribute")
        local mod_increase = params.attacker:FindModifierByName("modifier_increase_attribute")

        if mod_decrease then
            mod_decrease:IncrementStackCount()
            params.unit:CalculateStatBonus(true)
        end
        if mod_increase then
            mod_increase:IncrementStackCount()
            params.attacker:CalculateStatBonus(true)
        end
    end
end
