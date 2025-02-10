modifier_truesight_vision = class({})

function modifier_truesight_vision:IsHidden()
    return false
end

function modifier_truesight_vision:IsDebuff()
    return false
end

function modifier_truesight_vision:IsPurgable()
    return false
end

function modifier_truesight_vision:GetTexture()
    return "item_gem"
end

function modifier_truesight_vision:CheckState()
    return {
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true
    }
end

function modifier_truesight_vision:IsAura()
    return true
end

function modifier_truesight_vision:GetAuraRadius()
    return 2000
end

function modifier_truesight_vision:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC -- 作用于英雄和普通单位
end

function modifier_truesight_vision:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY -- 作用于敌方单位
end

function modifier_truesight_vision:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE -- 无视魔免和无敌
end

function modifier_truesight_vision:GetModifierAura()
    return "modifier_truesight"
end