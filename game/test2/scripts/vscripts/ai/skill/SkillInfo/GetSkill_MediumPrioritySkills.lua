function CommonAI:Ini_MediumPrioritySkills()
        self.mediumPrioritySkills = {
            npc_dota_hero_life_stealer = {"life_stealer_infest","life_stealer_open_wounds"},
            npc_dota_hero_earthshaker = {"earthshaker_echo_slam"},
            npc_dota_hero_tusk = {"tusk_snowball","tusk_ice_shards"},
            npc_dota_hero_kunkka = {"kunkka_ghostship","kunkka_tidal_wave","kunkka_torrent_storm"},
            npc_dota_hero_omniknight = {"omniknight_purification"},
            npc_dota_hero_tidehunter = {"tidehunter_ravage"},
            npc_dota_hero_spectre = {"spectre_dispersion"},
            npc_dota_hero_juggernaut = {"juggernaut_swift_slash","juggernaut_omni_slash","juggernaut_healing_ward"},

            --npc_dota_hero_riki = {"riki_smoke_screen","riki_tricks_of_the_trade"},
            npc_dota_hero_razor = {"razor_eye_of_the_storm","razor_static_link","razor_plasma_field"},
            npc_dota_hero_faceless_void = {"faceless_void_chronosphere","faceless_void_time_dilation"},
            npc_dota_hero_rubick = {"rubick_spell_steal"},
            npc_dota_hero_ursa = {"ursa_enrage","ursa_earthshock"},
            npc_dota_hero_monkey_king = {"monkey_king_wukongs_command","monkey_king_boundless_strike"},
            npc_dota_hero_pugna = {"pugna_life_drain"},
            npc_dota_hero_phoenix = {"phoenix_supernova"},
            npc_dota_hero_chaos_knight = {"chaos_knight_chaos_bolt"},
            npc_dota_hero_warlock = {"warlock_rain_of_chaos","warlock_fatal_bonds","warlock_shadow_word"},
            npc_dota_hero_keeper_of_the_light= {"keeper_of_the_light_spirit_form"},
            npc_dota_hero_lion = {"lion_voodoo","lion_impale"},
            npc_dota_hero_storm_spirit = {"storm_spirit_electric_vortex","storm_spirit_ball_lightning"},
            npc_dota_hero_lina = {"lina_light_strike_array"},
            npc_dota_hero_skywrath_mage = {"skywrath_mage_ancient_seal"},
            npc_dota_hero_muerta = {"muerta_the_calling","muerta_dead_shot"},
            npc_dota_hero_phantom_assassin = {"phantom_assassin_fan_of_knives"},
            npc_dota_hero_witch_doctor = {"witch_doctor_voodoo_switcheroo"},
            npc_dota_hero_jakiro = {"jakiro_ice_path","jakiro_macropyre"},
            npc_dota_hero_death_prophet = {"death_prophet_silence"},
            npc_dota_hero_leshrac = {"leshrac_pulse_nova","leshrac_defilement","leshrac_split_earth","leshrac_greater_lightning_storm"},
            npc_dota_hero_tinker = {"tinker_laser","tinker_march_of_the_machines","tinker_warp_grenade","tinker_rearm"},
            npc_dota_hero_necrolyte = {},
            npc_dota_hero_queenofpain = {"queenofpain_scream_of_pain","queenofpain_sonic_wave"},
            npc_dota_hero_silencer = {"silencer_global_silence"},
            npc_dota_hero_void_spirit= {"void_spirit_resonant_pulse","void_spirit_aether_remnant","void_spirit_astral_step","void_spirit_dissimilate"},
            npc_dota_hero_luna = {"luna_eclipse"},
            npc_dota_hero_huskar = {""},
            npc_dota_hero_magnataur = {"magnataur_reverse_polarity","magnataur_horn_toss","magnataur_reversed_reverse_polarity"},
            npc_dota_hero_disruptor = {"disruptor_static_storm","disruptor_kinetic_field"},
            npc_dota_hero_zuus = {"zuus_heavenly_jump","zuus_cloud"},
            npc_dota_hero_sniper = {"sniper_shrapnel"},
            npc_dota_hero_brewmaster = {"brewmaster_primal_split"},
            npc_dota_hero_mirana = {"mirana_starfall"},
            npc_dota_hero_dark_seer = {"dark_seer_wall_of_replica","dark_seer_surge","dark_seer_vacuum",},
            npc_dota_hero_shadow_demon = {"shadow_demon_disruption"},
            npc_dota_hero_spirit_breaker = {"spirit_breaker_planar_pocket"},
            
            npc_dota_hero_dazzle = {"dazzle_nothl_projection","dazzle_shallow_grave","dazzle_shadow_wave"},
            npc_dota_hero_batrider = {"batrider_firefly","batrider_flaming_lasso"},
            npc_dota_hero_venomancer = {"venomancer_noxious_plague","venomancer_plague_ward"},
            npc_dota_hero_rattletrap = {"rattletrap_battery_assault","rattletrap_jetpack","rattletrap_power_cogs"},
            npc_dota_hero_dark_willow = {"dark_willow_shadow_realm","dark_willow_terrorize","dark_willow_pixie_dust"},
            npc_dota_hero_invoker = {"invoker_tornado","invoker_emp","invoker_ice_wall","invoker_chaos_meteor","invoker_deafening_blast","invoker_sun_strike","invoker_forge_spirit","invoker_cold_snap","invoker_alacrity"},
            npc_dota_hero_techies = {"techies_land_mines"},
            npc_dota_hero_troll_warlord = {"troll_warlord_whirling_axes_melee"},
            npc_dota_hero_nevermore = {"nevermore_frenzy"},
            npc_dota_hero_terrorblade = {"terrorblade_terror_wave","terrorblade_metamorphosis"},
            npc_dota_hero_ember_spirit = {"ember_spirit_sleight_of_fist","ember_spirit_activate_fire_remnant"},
            npc_dota_hero_bristleback = {"bristleback_bristleback"},
            npc_dota_hero_centaur = {"centaur_stampede","centaur_hoof_stomp"},
            npc_dota_hero_axe = {"axe_culling_blade","axe_berserkers_call"},
            npc_dota_hero_earth_spirit = {"earth_spirit_geomagnetic_grip","earth_spirit_rolling_boulder","earth_spirit_magnetize"},
            npc_dota_hero_undying = {"undying_flesh_golem","undying_tombstone","undying_decay"},
            npc_dota_hero_dragon_knight = {"dragon_knight_dragon_tail"},
            npc_dota_hero_tiny = {"tiny_toss"},
            npc_dota_hero_treant = {"treant_overgrowth","treant_natures_grasp","treant_leech_seed"},
            npc_dota_hero_vengefulspirit = {"vengefulspirit_magic_missile","vengefulspirit_nether_swap"},
            npc_dota_hero_bane = {"bane_fiends_grip","bane_nightmare"},
            npc_dota_hero_windrunner = {"windrunner_windrun","windrunner_shackleshot","windrunner_focusfire","windrunner_gale_force"},
            npc_dota_hero_nyx_assassin = {"nyx_assassin_spiked_carapace","nyx_assassin_impale","nyx_assassin_burrow","nyx_assassin_vendetta"},
            npc_dota_hero_enigma = {"enigma_midnight_pulse","enigma_black_hole"},
            npc_dota_hero_visage = {"visage_gravekeepers_cloak"},
            npc_dota_hero_kez = {"kez_switch_weapons"},
            npc_dota_hero_drow_ranger = {"drow_ranger_glacier","drow_ranger_wave_of_silence"},
            npc_dota_hero_pangolier = {"pangolier_rollup"},
            npc_dota_hero_shadow_shaman = {"shadow_shaman_voodoo"},
            npc_dota_hero_weaver = {"weaver_time_lapse"},
            npc_dota_hero_brewmaster = {"brewmaster_storm_cyclone"},

            


            -- 添加其他英雄的技能优先级表
        }
end
    

function CommonAI:UpdateSkillPriorityBasedOnStrategy()
    -- 创建一个策略映射表
    local strategyAdjustments = {
        ["不要优先放魔晶"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_pangolier = {""}
        end,
        
        ["优先开大"] = function(self)
            self.highPrioritySkills.npc_dota_hero_kez = {"kez_raptor_dance"}
            self.highPrioritySkills.npc_dota_hero_viper = {"viper_viper_strike"}
            self.highPrioritySkills.npc_dota_hero_skywrath_mage = {"skywrath_mage_mystic_flare"}
        end,
        
        ["优先沉默"] = function(self)
            self.highPrioritySkills.npc_dota_hero_skywrath_mage = {"skywrath_mage_ancient_seal"}
        end,
        
        ["防帕克"] = function(self)
            self.highPrioritySkills.npc_dota_hero_muerta = {"muerta_the_calling"}
        end,
        
        ["主动进攻"] = function(self)
            self.highPrioritySkills.npc_dota_hero_zuus = {"zuus_heavenly_jump"}
        end,
        
        ["优先拔树"] = function(self)
            self.highPrioritySkills.npc_dota_hero_tiny = {"tiny_tree_grab"}
        end,
        
        ["优先丢矛"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_phantom_lancer = {"phantom_lancer_spirit_lance"}
        end,
        
        ["优先虚弱"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_bane = {"bane_enfeeble", "bane_fiends_grip"}
        end,
        ["先招小树人"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_furion = {"furion_sprout", "furion_force_of_nature"}
        end,
        
        ["优先力量打击"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_morphling = {"morphling_waveform", "morphling_morph_str"}
        end,
        
        ["优先神灭斩"] = function(self)
            table.insert(self.mediumPrioritySkills.npc_dota_hero_lina, 1, "lina_laguna_blade")
        end,
        
        ["优先吹风"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_invoker = {
                "invoker_tornado", "invoker_emp", "invoker_cold_snap", 
                "invoker_deafening_blast", "invoker_chaos_meteor", 
                "invoker_alacrity", "invoker_forge_spirit", 
                "invoker_ice_wall", "invoker_sun_strike"
            }
        end,
        
        ["火人-灵动迅捷-吹风-磁暴-天火"] = function(self)
            self.mediumPrioritySkills.npc_dota_hero_invoker = {
                "invoker_forge_spirit", "invoker_alacrity", "invoker_tornado",
                "invoker_emp", "invoker_sun_strike", "invoker_cold_snap",
                "invoker_chaos_meteor", "invoker_deafening_blast", "invoker_ice_wall"
            }
        end,
        
        ["天隼冲击优先"] = function(self)
            table.insert(self.mediumPrioritySkills.npc_dota_hero_kez, 1, "kez_falcon_rush")
        end
    }

   -- 特殊条件处理函数
   local function handleSpecialConditions(self)
    -- 处理需要躲避的情况
    if self.needToDodge == true then
        self.highPrioritySkills.npc_dota_hero_zuus = {"zuus_heavenly_jump"}
    end

    -- 处理特殊挑战模式
    if Main.currentChallenge == Main.Challenges.CD0_1skill then
        if self.entity then
            local astralStepAbility = self.entity:FindAbilityByName("void_spirit_astral_step")
            
            if astralStepAbility then
                local chargeCount = astralStepAbility:GetCurrentAbilityCharges()
                
                if chargeCount < 2 then
                    self.highPrioritySkills.npc_dota_hero_void_spirit = nil
                else
                    self:log("已经设定为最高优先级")
                    self.highPrioritySkills.npc_dota_hero_void_spirit = {"void_spirit_astral_step"}
                end
            end
        end
    end
end

    -- 特殊策略处理函数
    local function handleSpecialStrategies(self)
        if self:containsStrategy(self.hero_strategy, "吹起来招小火人-二技能无CD专用") then
            if not self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 1) then
                self.mediumPrioritySkills.npc_dota_hero_invoker = {
                    "invoker_forge_spirit", "invoker_alacrity", "invoker_tornado",
                    "invoker_sun_strike", "invoker_cold_snap", "invoker_emp",
                    "invoker_deafening_blast", "invoker_chaos_meteor", "invoker_ice_wall"
                }
            end
        end
        
        if self:containsStrategy(self.hero_strategy, "吹起来放磁暴") then
            if (not self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 1) 
                or self.target:IsInvulnerable()) and self.target:GetMana() > 100 then
                self.mediumPrioritySkills.npc_dota_hero_invoker = {
                    "invoker_emp", "invoker_forge_spirit", "invoker_alacrity",
                    "invoker_tornado", "invoker_sun_strike", "invoker_emp",
                    "invoker_deafening_blast", "invoker_chaos_meteor", "invoker_ice_wall"
                }
            end
        end
    end

    -- 检查并应用每个策略
    for strategy, adjustment in pairs(strategyAdjustments) do
        if self:containsStrategy(self.hero_strategy, strategy) then
            adjustment(self)
        end
    end

    -- 处理特殊策略
    handleSpecialStrategies(self)

    -- 处理特殊条件
    handleSpecialConditions(self)

    -- 处理变体特殊情况
    if self.entity and self.entity:GetUnitName() == "npc_dota_hero_morphling" then
        local primaryAttr = self.entity:GetPrimaryAttribute()
        if primaryAttr == DOTA_ATTRIBUTE_AGILITY then
            self.highPrioritySkills.npc_dota_hero_morphling = {
                "morphling_morph_str",
                "morphling_morph_agi",
                "morphling_waveform",
                "morphling_adaptive_strike_agi",
                "morphling_adaptive_strike_str"
            }
        else
            self.highPrioritySkills.npc_dota_hero_morphling = {
                "morphling_morph_str",
                "morphling_morph_agi",
                "morphling_waveform",
                "morphling_adaptive_strike_str",
                "morphling_adaptive_strike_agi"
            }
        end
    end
end