function CommonAI:Ini_HighPrioritySkills()
    self.highPrioritySkills = {

        npc_dota_hero_terrorblade = {"terrorblade_sunder"},
        npc_dota_hero_tiny = {"tiny_avalanche"},
        npc_dota_hero_dawnbreaker = {""},
        npc_dota_hero_chaos_knight = {"chaos_knight_phantasm"},
        npc_dota_hero_hoodwink = {"modifier_hoodwink_scurry_active","hoodwink_acorn_shot"},
        npc_dota_hero_spirit_breaker = {"spirit_breaker_bulldoze","spirit_breaker_charge_of_darkness"},
        npc_dota_hero_legion_commander = {"legion_commander_press_the_attack","legion_commander_duel"},
        npc_dota_hero_shredder = {"shredder_reactive_armor"},
        npc_dota_hero_omniknight = {"omniknight_martyr"},
        npc_dota_hero_juggernaut = {},
        npc_dota_hero_monkey_king = {"monkey_king_tree_dance","monkey_king_primal_spring"},
        npc_dota_hero_ancient_apparition = {"ancient_apparition_ice_blast_release"},
        npc_dota_hero_tinker = {"tinker_defense_matrix"},
        npc_dota_hero_techies = {"techies_reactive_tazer","techies_suicide"},

        npc_dota_hero_morphling = {"morphling_waveform"},
        npc_dota_hero_oracle = {"oracle_false_promise"},
        npc_dota_hero_huskar = {"huskar_life_break"},
        npc_dota_hero_clinkz = {"clinkz_death_pact"},
        npc_dota_hero_troll_warlord = {"troll_warlord_battle_trance"},
        npc_dota_hero_earth_spirit = {"earth_spirit_stone_caller"},
        npc_dota_hero_kez = {"kez_shodo_sai_parry_cancel"},

    }

    if self:containsStrategy(self.hero_strategy, "神罗天征") then
        self.highPrioritySkills.npc_dota_hero_invoker = {"invoker_deafening_blast"}
    end
    if self:containsStrategy(self.hero_strategy, "优先变羊") then
        self.highPrioritySkills.npc_dota_hero_shadow_shaman = {"shadow_shaman_voodoo"}
    end
    if self:containsStrategy(self.hero_strategy, "优先沉默") then
        self.highPrioritySkills.npc_dota_hero_arc_warden = {"arc_warden_tempest_double","arc_warden_flux"}
    end
    if self:containsStrategy(self.hero_strategy, "先手晕") then
        self.highPrioritySkills.npc_dota_hero_chaos_knight = {"chaos_knight_phantasm","chaos_knight_chaos_bolt"}
    end
    if self:containsStrategy(self.hero_strategy, "先大后矛") then
        self.highPrioritySkills.npc_dota_hero_mars = {"mars_arena_of_blood"}
    end



    -- self:log("运行了初始化Ini_HighPrioritySkills")
    -- for hero, skills in pairs(self.highPrioritySkills) do
    --     self:log(hero .. ":")
    --     for _, skill in ipairs(skills) do
    --         self:log("  - " .. skill)
    --     end
    -- end
end