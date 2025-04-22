function CommonAI:Ini_SkillTargetTeam()

    self.skillTargetTeam = {
        shadow_demon_disruption = DOTA_UNIT_TARGET_TEAM.ENEMY,
        riki_tricks_of_the_trade = DOTA_UNIT_TARGET_TEAM.BOTH,
        oracle_rain_of_destiny = DOTA_UNIT_TARGET_TEAM.BOTH,
        oracle_fates_edict = DOTA_UNIT_TARGET_TEAM.BOTH,
        dark_seer_surge = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        venomancer_plague_ward = DOTA_UNIT_TARGET_TEAM.ENEMY,
        undying_tombstone = DOTA_UNIT_TARGET_TEAM.ENEMY,
        luna_eclipse = DOTA_UNIT_TARGET_TEAM.ENEMY,
        centaur_double_edge = DOTA_UNIT_TARGET_TEAM.ENEMY,
        earth_spirit_geomagnetic_grip = DOTA_UNIT_TARGET_TEAM.ENEMY,
        earthshaker_enchant_totem = DOTA_UNIT_TARGET_TEAM.ENEMY,
        clinkz_death_pact = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        phoenix_supernova = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        brewmaster_void_astral_pull = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        invoker_alacrity = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        slark_depth_shroud = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        earth_spirit_petrify = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        dark_seer_ion_shell = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        weaver_time_lapse = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        item_disperser = DOTA_UNIT_TARGET_TEAM.FRIENDLY,
        
    }
end

function CommonAI:GetSkillTargetTeam(skill)
    local abilityName = skill:GetAbilityName()

    return self.skillTargetTeam[abilityName] or skill:GetAbilityTargetTeam()
end


