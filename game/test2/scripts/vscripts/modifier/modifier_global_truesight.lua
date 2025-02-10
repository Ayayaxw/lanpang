modifier_global_truesight = class({})

function modifier_global_truesight:IsHidden()
    return false
end

function modifier_global_truesight:IsDebuff()
    return false
end

function modifier_global_truesight:IsPurgable()
    return false
end

function modifier_global_truesight:GetTexture()
    return "item_gem" 
end

function modifier_global_truesight:CheckState()
    return {
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true
    }
end

function modifier_global_truesight:IsAura()
    return true
end

function modifier_global_truesight:GetAuraRadius()
    return FIND_UNITS_EVERYWHERE -- 全地图范围
end

function modifier_global_truesight:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_global_truesight:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_global_truesight:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_global_truesight:GetModifierAura()
    return "modifier_truesight"
end