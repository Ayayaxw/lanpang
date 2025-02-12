-- disabled_skills.lua

-- 被禁用的技能列表
function CommonAI:Ini_DisabledSkills()
    self.disabledSkills = {
        npc_dota_hero_treant = {"treant_eyes_in_the_forest"},
        npc_dota_hero_monkey_king = {"monkey_king_primal_spring", "monkey_king_tree_dance", "monkey_king_primal_spring_early", "monkey_king_untransform", "monkey_king_mischiefs","monkey_king_jingu_mastery"},
        npc_dota_hero_hoodwink = {""},
        npc_dota_hero_faceless_void = {"faceless_void_time_walk_reverse"},
        npc_dota_hero_skeleton_king = {"skeleton_king_reincarnation"},
        npc_dota_hero_elder_titan = {""},
        npc_dota_hero_tusk = {""},
        npc_dota_hero_pudge = {"pudge_eject"},
        npc_dota_hero_bristleback = {"bristleback_viscous_nasal_goo"},
        npc_dota_hero_doom_bringer = {"doom_bringer_devour"},
        npc_dota_hero_shredder = {},
        npc_dota_hero_kunkka = {"kunkka_return"},
        npc_dota_hero_spectre = {"spectre_reality","spectre_dispersion"},
        npc_dota_hero_viper = {""},
        npc_dota_hero_juggernaut ={"juggernaut_omni_slash","juggernaut_blade_fury","juggernaut_healing_ward"},
        npc_dota_hero_terrorblade = {"terrorblade_sunder"},
        npc_dota_hero_naga_siren = {"naga_siren_reel_in","naga_siren_song_of_the_siren_cancel","naga_siren_song_of_the_siren"},
        npc_dota_hero_phantom_lancer = {"phantom_lancer_doppelwalk"},
        npc_dota_hero_troll_warlord = {"troll_warlord_battle_trance"},
        --npc_dota_hero_riki={"riki_smoke_screen","riki_tricks_of_the_trade"},
        npc_dota_hero_meepo = {"meepo_megameepo","meepo_petrify","meepo_megameepo_fling"},
        npc_dota_hero_clinkz = {"clinkz_death_pact","clinkz_tar_bomb"},
        npc_dota_hero_morphling = {"morphling_morph_agi","morphling_morph_str","morphling_morph_replicate","morphling_morph","morphling_accumulation"},
        npc_dota_hero_ursa = {""},
        npc_dota_hero_tinker = {"tinker_keen_teleport","tinker_eureka"},
        npc_dota_hero_pangolier = {"pangolier_gyroshell_stop","pangolier_swashbuckle"},
        npc_dota_hero_puck = {"puck_ethereal_jaunt","puck_phase_shift"},
        npc_dota_hero_storm_spirit = {"storm_spirit_ball_lightning"},
        npc_dota_hero_keeper_of_the_light = {"keeper_of_the_light_chakra_magic","keeper_of_the_light_recall","keeper_of_the_light_illuminate_end"},
        npc_dota_hero_rubick = {"rubick_telekinesis_land","rubick_spell_steal"},
        npc_dota_hero_leshrac = {"leshrac_greater_lightning_storm","leshrac_diabolic_edict"},
        npc_dota_hero_death_prophet= {"death_prophet_spirit_siphon"},
        npc_dota_hero_shadow_demon = {"shadow_demon_shadow_poison_release"},
        npc_dota_hero_lich = {"lich_ice_spire"},
        npc_dota_hero_lina = {"lina_laguna_blade"},
        npc_dota_hero_oracle = {"oracle_false_promise"},
        npc_dota_hero_windrunner = {"windrunner_focusfire_cancel"},
        npc_dota_hero_mirana = {"mirana_leap"},
        npc_dota_hero_techies = {"techies_reactive_tazer_stop"},
        npc_dota_hero_rattletrap = {"rattletrap_battery_assault"},
        npc_dota_hero_nyx_assassin = {"nyx_assassin_unburrow",},
        npc_dota_hero_snapfire = {"snapfire_spit_creep","snapfire_gobble_up"},
        npc_dota_hero_ember_spirit = {"ember_spirit_searing_chains","ember_spirit_activate_fire_remnant","ember_spirit_fire_remnant","ember_spirit_sleight_of_fist"},
        npc_dota_hero_earth_spirit = {"earth_spirit_stone_caller"},
        npc_dota_hero_void_spirit = {"void_spirit_resonant_pulse"},
        npc_dota_hero_bristleback = {"bristleback_warpath"},
        npc_dota_hero_night_stalker = {"night_stalker_hunter_in_the_night"},
        npc_dota_hero_necrolyte = {"necrolyte_ghost_shroud","necrolyte_reapers_scythe"},
        npc_dota_hero_lion = {"lion_voodoo","lion_mana_drain"},
        npc_dota_hero_grimstroke = {"grimstroke_return"},
        npc_dota_hero_lich = {"lich_frost_shield"},
        npc_dota_hero_templar_assassin = {"templar_assassin_trap"},
        npc_dota_hero_phoenix= {"phoenix_sun_ray_toggle_move","phoenix_sun_ray_stop","phoenix_icarus_dive_stop"},
        npc_dota_hero_abaddon = {"abaddon_borrowed_time"},
        npc_dota_hero_shadow_shaman = {"shadow_shaman_voodoo"},
        npc_dota_hero_lone_druid = {"lone_druid_spirit_link"},
        npc_dota_hero_death_prophet = {"death_prophet_silence",},
        npc_dota_brewmaster_storm_1 = {"brewmaster_primal_split_cancel","brewmaster_storm_cyclone"},
        npc_dota_brewmaster_storm_2 = {"brewmaster_primal_split_cancel","brewmaster_storm_cyclone"},
        npc_dota_brewmaster_storm_3 = {"brewmaster_primal_split_cancel","brewmaster_storm_cyclone"},
        npc_dota_brewmaster_fire_1 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_fire_2 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_fire_3 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_earth_1 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_earth_2 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_earth_3 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_void_1 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_void_2 = {"brewmaster_primal_split_cancel"},
        npc_dota_brewmaster_void_3 = {"brewmaster_primal_split_cancel"},
        npc_dota_hero_brewmaster = {"brewmaster_drunken_brawler"},
        npc_dota_lone_druid_bear1 = {"lone_druid_spirit_bear_return"},
        npc_dota_lone_druid_bear2 = {"lone_druid_spirit_bear_return"},
        npc_dota_lone_druid_bear3 = {"lone_druid_spirit_bear_return"},
        npc_dota_lone_druid_bear4 = {"lone_druid_spirit_bear_return"},
        npc_dota_hero_chen = {"chen_holy_persuasion"},
        npc_dota_hero_rattletrap = {"rattletrap_jetpack"},
        npc_dota_hero_crystal_maiden = {"crystal_maiden_freezing_field_stop"},
        npc_dota_roshan = {"seasonal_party_hat"},
        npc_dota_hero_invoker = {"invoker_ghost_walk","invoker_invoke","invoker_quas","invoker_wex","invoker_exort"},
        npc_dota_hero_bane = {"bane_nightmare_end"},
        npc_dota_hero_wisp = {"wisp_tether_break"},

    }
    if Main.currentChallenge == Main.Challenges.CD0_1skill then
        self.disabledSkills.npc_dota_hero_magnataur = {"magnataur_empower"}
        self.disabledSkills.npc_dota_hero_rattletrap = {"rattletrap_jetpack","rattletrap_battery_assault"}
        self.disabledSkills.npc_dota_hero_oracle = {"oracle_rain_of_destiny"}

    elseif Main.currentChallenge == Main.Challenges.Fall_Flat then
        self.disabledSkills.npc_dota_hero_bristleback = {"bristleback_bristleback"}
    end

end


function CommonAI:IsDisabledSkill(abilityName, heroName)
    -- 如果是拉比克或水人，直接检查所有英雄的禁用技能列表
    if heroName == "npc_dota_hero_rubick" or heroName == "npc_dota_hero_morphling" then
        -- 遍历所有英雄的禁用技能
        for _, disabledList in pairs(self.disabledSkills) do
            for _, disabledSkill in ipairs(disabledList) do
                if abilityName == disabledSkill then
                    return true
                end
            end
        end
    else
        -- 其他英雄按原来的方式检查
        for _, disabledSkill in ipairs(self.disabledSkills[heroName]) do
            if abilityName == disabledSkill then
                return true
            end
        end
    end
    return false
end