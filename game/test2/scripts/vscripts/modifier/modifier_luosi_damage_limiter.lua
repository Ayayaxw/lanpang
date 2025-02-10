-- 定义 modifier
modifier_luosi_damage_limiter = class({})

function modifier_luosi_damage_limiter:IsHidden()
    return false -- 在状态栏显示，这样玩家可以知道单位有特殊效果
end

function modifier_luosi_damage_limiter:IsPurgable()
    return false -- 不可被净化
end

function modifier_luosi_damage_limiter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_luosi_damage_limiter:GetModifierIncomingDamage_Percentage(params)
    return -100 -- 减少100%的伤害，相当于免疫伤害
end

function modifier_luosi_damage_limiter:OnTakeDamage(params)
    if params.unit == self:GetParent() then
        local unit = self:GetParent()
        local attacker = params.attacker

        -- 检查攻击者是否是神堂刺客或者伤害大于0
        if attacker:GetUnitName() == "npc_dota_hero_templar_assassin" or params.original_damage > 0 then
            -- 如果单位当前生命值大于1，则减少1点生命值

            unit:SetHealth(unit:GetHealth() - 1)

        end
    end
end