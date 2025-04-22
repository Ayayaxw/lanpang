function CommonAI:Ini_SkillTargetType()

    self.skillTargetType = {
        morphling_replicate = DOTA_UNIT_TARGET_TYPE.HERO,
        terrorblade_sunder = DOTA_UNIT_TARGET_TYPE.HERO,
        vengefulspirit_nether_swap = DOTA_UNIT_TARGET_TYPE.HERO,
        kunkka_x_marks_the_spot = DOTA_UNIT_TARGET_TYPE.HERO,
        spectre_haunt_single = DOTA_UNIT_TARGET_TYPE.HERO,
    }
end

function CommonAI:GetSkillTargetType(skill)
    local abilityName = skill:GetAbilityName()

    return self.skillTargetType[abilityName] or skill:GetAbilityTargetType()
end