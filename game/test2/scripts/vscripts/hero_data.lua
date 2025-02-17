-- hero_data.lua
heroes_precache = {
    {type = 1, particleName = "alchemist", soundName = "alchemist", name = "npc_dota_hero_alchemist", chinese = "炼金术士", id = 73, model = "alchemist"},
    {type = 1, particleName = "axe", soundName = "axe", name = "npc_dota_hero_axe", chinese = "斧王", id = 2, model = "axe"},
    {type = 1, particleName = "bristleback", soundName = "bristleback", name = "npc_dota_hero_bristleback", chinese = "钢背兽", id = 99, model = "bristleback"},
    {type = 1, particleName = "centaur", soundName = "centaur", name = "npc_dota_hero_centaur", chinese = "半人马战行者", id = 96, model = "centaur"},
    {type = 1, particleName = "chaos_knight", soundName = "chaos_knight", name = "npc_dota_hero_chaos_knight", chinese = "混沌骑士", id = 81, model = "chaos_knight"},
    {type = 1, particleName = "dawnbreaker", soundName = "dawnbreaker", name = "npc_dota_hero_dawnbreaker", chinese = "破晓辰星", id = 135, model = "dawnbreaker"},
    {type = 1, particleName = "doom_bringer", soundName = "doombringer", name = "npc_dota_hero_doom_bringer", chinese = "末日使者", id = 69, model = "doom"},
    {type = 1, particleName = "dragon_knight", soundName = "dragon_knight", name = "npc_dota_hero_dragon_knight", chinese = "龙骑士", id = 49, model = "dragon_knight"},
    {type = 1, particleName = "earthshaker", soundName = "earthshaker", name = "npc_dota_hero_earthshaker", chinese = "撼地者", id = 7, model = "earthshaker"},
    {type = 1, particleName = "elder_titan", soundName = "elder_titan", name = "npc_dota_hero_elder_titan", chinese = "上古巨神", id = 103, model = "elder_titan"},
    {type = 1, particleName = "earth_spirit", soundName = "earth_spirit", name = "npc_dota_hero_earth_spirit", chinese = "大地之灵", id = 107, model = "earth_spirit"},
    {type = 1, particleName = "huskar", soundName = "huskar", name = "npc_dota_hero_huskar", chinese = "哈斯卡", id = 59, model = "huskar"},
    {type = 1, particleName = "kunkka", soundName = "kunkka", name = "npc_dota_hero_kunkka", chinese = "昆卡", id = 23, model = "kunkka"},
    {type = 1, particleName = "legion_commander", soundName = "legion_commander", name = "npc_dota_hero_legion_commander", chinese = "军团指挥官", id = 104, model = "legion_commander"},
    {type = 1, particleName = "life_stealer", soundName = "life_stealer", name = "npc_dota_hero_life_stealer", chinese = "噬魂鬼", id = 54, model = "life_stealer"},
    {type = 1, particleName = "mars", soundName = "mars", name = "npc_dota_hero_mars", chinese = "玛尔斯", id = 129, model = "mars"},
    {type = 1, particleName = "night_stalker", soundName = "nightstalker", name = "npc_dota_hero_night_stalker", chinese = "暗夜魔王", id = 60, model = "nightstalker"},
    {type = 1, particleName = "ogre_magi", soundName = "ogre_magi", name = "npc_dota_hero_ogre_magi", chinese = "食人魔魔法师", id = 84, model = "ogre_magi"},
    {type = 1, particleName = "omniknight", soundName = "omniknight", name = "npc_dota_hero_omniknight", chinese = "全能骑士", id = 57, model = "omniknight"},
    {type = 1, particleName = "primal_beast", soundName = "primal_beast", name = "npc_dota_hero_primal_beast", chinese = "兽", id = 137, model = "primal_beast"},
    {type = 1, particleName = "pudge", soundName = "pudge", name = "npc_dota_hero_pudge", chinese = "帕吉", id = 14, model = "pudge"},
    {type = 1, particleName = "slardar", soundName = "slardar", name = "npc_dota_hero_slardar", chinese = "斯拉达", id = 28, model = "slardar"},
    {type = 1, particleName = "shredder", soundName = "shredder", name = "npc_dota_hero_shredder", chinese = "伐木机", id = 98, model = "shredder"},
    {type = 1, particleName = "spirit_breaker", soundName = "spirit_breaker", name = "npc_dota_hero_spirit_breaker", chinese = "裂魂人", id = 71, model = "spirit_breaker"},
    {type = 1, particleName = "sven", soundName = "sven", name = "npc_dota_hero_sven", chinese = "斯温", id = 18, model = "sven"},
    {type = 1, particleName = "tidehunter", soundName = "tidehunter", name = "npc_dota_hero_tidehunter", chinese = "潮汐猎人", id = 29, model = "tidehunter"},
    {type = 1, particleName = "tiny", soundName = "tiny", name = "npc_dota_hero_tiny", chinese = "小小", id = 19, model = "tiny"},
    {type = 1, particleName = "treant", soundName = "treant", name = "npc_dota_hero_treant", chinese = "树精卫士", id = 83, model = "treant_protector"},
    {type = 1, particleName = "tusk", soundName = "tusk", name = "npc_dota_hero_tusk", chinese = "巨牙海民", id = 100, model = "tuskarr"},
    {type = 1, particleName = "abyssal_underlord", soundName = "abyssal_underlord", name = "npc_dota_hero_abyssal_underlord", chinese = "孽主", id = 108, model = "abyssal_underlord"},
    {type = 1, particleName = "undying", soundName = "undying", name = "npc_dota_hero_undying", chinese = "不朽尸王", id = 85, model = "undying"},
    {type = 1, particleName = "skeleton_king", soundName = "skeletonking", name = "npc_dota_hero_skeleton_king", chinese = "冥魂大帝", id = 42, model = "wraith_king"},
    
    {type = 2, particleName = "antimage", soundName = "antimage", name = "npc_dota_hero_antimage", chinese = "敌法师", id = 1, model = "antimage"},
    {type = 2, particleName = "arc_warden", soundName = "arc_warden", name = "npc_dota_hero_arc_warden", chinese = "天穹守望者", id = 113, model = "arc_warden"},
    {type = 2, particleName = "bloodseeker", soundName = "bloodseeker", name = "npc_dota_hero_bloodseeker", chinese = "血魔", id = 4, model = "blood_seeker"},
    {type = 2, particleName = "bounty_hunter", soundName = "bounty_hunter", name = "npc_dota_hero_bounty_hunter", chinese = "赏金猎人", id = 62, model = "bounty_hunter"},
    {type = 2, particleName = "clinkz", soundName = "clinkz", name = "npc_dota_hero_clinkz", chinese = "克林克兹", id = 56, model = "clinkz"},
    {type = 2, particleName = "drow_ranger", soundName = "drowranger", name = "npc_dota_hero_drow_ranger", chinese = "卓尔游侠", id = 6, model = "drow"},
    {type = 2, particleName = "ember_spirit", soundName = "ember_spirit", name = "npc_dota_hero_ember_spirit", chinese = "灰烬之灵", id = 106, model = "ember_spirit"},
    {type = 2, particleName = "faceless_void", soundName = "faceless_void", name = "npc_dota_hero_faceless_void", chinese = "虚空假面", id = 41, model = "faceless_void"},
    {type = 2, particleName = "gyrocopter", soundName = "gyrocopter", name = "npc_dota_hero_gyrocopter", chinese = "矮人直升机", id = 72, model = "gyro"},
    {type = 2, particleName = "hoodwink", soundName = "hoodwink", name = "npc_dota_hero_hoodwink", chinese = "森海飞霞", id = 123, model = "hoodwink"},
    {type = 2, particleName = "juggernaut", soundName = "juggernaut", name = "npc_dota_hero_juggernaut", chinese = "主宰", id = 8, model = "juggernaut"},
    {type = 2, particleName = "luna", soundName = "luna", name = "npc_dota_hero_luna", chinese = "露娜", id = 48, model = "luna"},
    {type = 2, particleName = "medusa", soundName = "medusa", name = "npc_dota_hero_medusa", chinese = "美杜莎", id = 94, model = "medusa"},
    {type = 2, particleName = "meepo", soundName = "meepo", name = "npc_dota_hero_meepo", chinese = "米波", id = 82, model = "meepo"},
    {type = 2, particleName = "monkey_king", soundName = "monkey_king", name = "npc_dota_hero_monkey_king", chinese = "齐天大圣", id = 114, model = "monkey_king"},
    {type = 2, particleName = "morphling", soundName = "morphling", name = "npc_dota_hero_morphling", chinese = "变体精灵", id = 10, model = "morphling"},
    {type = 2, particleName = "naga_siren", soundName = "naga_siren", name = "npc_dota_hero_naga_siren", chinese = "娜迦海妖", id = 89, model = "siren"},
    {type = 2, particleName = "phantom_assassin", soundName = "phantom_assassin", name = "npc_dota_hero_phantom_assassin", chinese = "幻影刺客", id = 44, model = "phantom_assassin"},
    {type = 2, particleName = "phantom_lancer", soundName = "phantom_lancer", name = "npc_dota_hero_phantom_lancer", chinese = "幻影长矛手", id = 12, model = "phantom_lancer"},
    {type = 2, particleName = "razor", soundName = "razor", name = "npc_dota_hero_razor", chinese = "雷泽", id = 15, model = "razor"},
    {type = 2, particleName = "riki", soundName = "riki", name = "npc_dota_hero_riki", chinese = "力丸", id = 32, model = "rikimaru"},
    {type = 2, particleName = "nevermore", soundName = "nevermore", name = "npc_dota_hero_nevermore", chinese = "影魔", id = 11, model = "shadow_fiend"},
    {type = 2, particleName = "slark", soundName = "slark", name = "npc_dota_hero_slark", chinese = "斯拉克", id = 93, model = "slark"},
    {type = 2, particleName = "sniper", soundName = "sniper", name = "npc_dota_hero_sniper", chinese = "狙击手", id = 35, model = "sniper"},
    {type = 2, particleName = "spectre", soundName = "spectre", name = "npc_dota_hero_spectre", chinese = "幽鬼", id = 67, model = "spectre"},
    {type = 2, particleName = "templar_assassin", soundName = "templar_assassin", name = "npc_dota_hero_templar_assassin", chinese = "圣堂刺客", id = 46, model = "lanaya"},
    {type = 2, particleName = "terrorblade", soundName = "terrorblade", name = "npc_dota_hero_terrorblade", chinese = "恐怖利刃", id = 109, model = "terrorblade"},
    {type = 2, particleName = "troll_warlord", soundName = "troll_warlord", name = "npc_dota_hero_troll_warlord", chinese = "巨魔战将", id = 95, model = "troll_warlord"},
    {type = 2, particleName = "ursa", soundName = "ursa", name = "npc_dota_hero_ursa", chinese = "熊战士", id = 70, model = "ursa"},
    {type = 2, particleName = "viper", soundName = "viper", name = "npc_dota_hero_viper", chinese = "冥界亚龙", id = 47, model = "viper"},
    {type = 2, particleName = "weaver", soundName = "weaver", name = "npc_dota_hero_weaver", chinese = "编织者", id = 63, model = "weaver"},
    {type = 2, particleName = "kez", soundName = "kez", name = "npc_dota_hero_kez", chinese = "凯", id = 145, model = "kez"},
    
    {type = 4, particleName = "ancient_apparition", soundName = "ancient_apparition", name = "npc_dota_hero_ancient_apparition", chinese = "远古冰魄", id = 68, model = "ancient_apparition"},
    {type = 4, particleName = "crystal_maiden", soundName = "crystalmaiden", name = "npc_dota_hero_crystal_maiden", chinese = "水晶室女", id = 5, model = "crystal_maiden"},
    {type = 4, particleName = "death_prophet", soundName = "death_prophet", name = "npc_dota_hero_death_prophet", chinese = "死亡先知", id = 43, model = "death_prophet"},
    {type = 4, particleName = "disruptor", soundName = "disruptor", name = "npc_dota_hero_disruptor", chinese = "干扰者", id = 87, model = "disruptor"},
    {type = 4, particleName = "enchantress", soundName = "enchantress", name = "npc_dota_hero_enchantress", chinese = "魅惑魔女", id = 58, model = "enchantress"},
    {type = 4, particleName = "grimstroke", soundName = "grimstroke", name = "npc_dota_hero_grimstroke", chinese = "天涯墨客", id = 121, model = "grimstroke"},
    {type = 4, particleName = "jakiro", soundName = "jakiro", name = "npc_dota_hero_jakiro", chinese = "杰奇洛", id = 64, model = "jakiro"},
    {type = 4, particleName = "keeper_of_the_light", soundName = "keeper_of_the_light", name = "npc_dota_hero_keeper_of_the_light", chinese = "光之守卫", id = 90, model = "keeper_of_the_light"},
    {type = 4, particleName = "leshrac", soundName = "leshrac", name = "npc_dota_hero_leshrac", chinese = "拉席克", id = 52, model = "leshrac"},
    {type = 4, particleName = "lich", soundName = "lich", name = "npc_dota_hero_lich", chinese = "巫妖", id = 31, model = "lich"},
    {type = 4, particleName = "lina", soundName = "lina", name = "npc_dota_hero_lina", chinese = "莉娜", id = 25, model = "lina"},
    {type = 4, particleName = "lion", soundName = "lion", name = "npc_dota_hero_lion", chinese = "莱恩", id = 26, model = "lion"},
    {type = 4, particleName = "muerta", soundName = "muerta", name = "npc_dota_hero_muerta", chinese = "琼英碧灵", id = 138, model = "muerta"},
    {type = 4, particleName = "furion", soundName = "furion", name = "npc_dota_hero_furion", chinese = "先知", id = 53, model = "furion"},
    {type = 4, particleName = "necrolyte", soundName = "necrolyte", name = "npc_dota_hero_necrolyte", chinese = "瘟疫法师", id = 36, model = "necrolyte"},
    {type = 4, particleName = "oracle", soundName = "oracle", name = "npc_dota_hero_oracle", chinese = "神谕者", id = 111, model = "oracle"},
    {type = 4, particleName = "obsidian_destroyer", soundName = "obsidian_destroyer", name = "npc_dota_hero_obsidian_destroyer", chinese = "殁境神蚀者", id = 76, model = "obsidian_destroyer"},
    {type = 4, particleName = "puck", soundName = "puck", name = "npc_dota_hero_puck", chinese = "帕克", id = 13, model = "puck"},
    {type = 4, particleName = "pugna", soundName = "pugna", name = "npc_dota_hero_pugna", chinese = "帕格纳", id = 45, model = "pugna"},
    {type = 4, particleName = "queenofpain", soundName = "queenofpain", name = "npc_dota_hero_queenofpain", chinese = "痛苦女王", id = 39, model = "queenofpain"},
    {type = 4, particleName = "rubick", soundName = "rubick", name = "npc_dota_hero_rubick", chinese = "拉比克", id = 86, model = "rubick"},
    {type = 4, particleName = "shadow_demon", soundName = "shadow_demon", name = "npc_dota_hero_shadow_demon", chinese = "暗影恶魔", id = 79, model = "shadow_demon"},
    {type = 4, particleName = "shadow_shaman", soundName = "shadowshaman", name = "npc_dota_hero_shadow_shaman", chinese = "暗影萨满", id = 27, model = "shadowshaman"},
    {type = 4, particleName = "silencer", soundName = "silencer", name = "npc_dota_hero_silencer", chinese = "沉默术士", id = 75, model = "silencer"},
    {type = 4, particleName = "skywrath_mage", soundName = "skywrath_mage", name = "npc_dota_hero_skywrath_mage", chinese = "天怒法师", id = 101, model = "skywrath_mage"},
    {type = 4, particleName = "storm_spirit", soundName = "stormspirit", name = "npc_dota_hero_storm_spirit", chinese = "风暴之灵", id = 17, model = "storm_spirit"},
    {type = 4, particleName = "tinker", soundName = "tinker", name = "npc_dota_hero_tinker", chinese = "修补匠", id = 34, model = "tinker"},
    {type = 4, particleName = "warlock", soundName = "warlock", name = "npc_dota_hero_warlock", chinese = "术士", id = 37, model = "warlock"},
    {type = 4, particleName = "witch_doctor", soundName = "witchdoctor", name = "npc_dota_hero_witch_doctor", chinese = "巫医", id = 30, model = "witchdoctor"},
    {type = 4, particleName = "zuus", soundName = "zuus", name = "npc_dota_hero_zuus", chinese = "宙斯", id = 22, model = "zeus"},
    {type = 4, particleName = "ringmaster", soundName = "ringmaster", name = "npc_dota_hero_ringmaster", chinese = "驯兽师", id = 131, model = "ringmaster"},
    
    {type = 8, particleName = "abaddon", soundName = "abaddon", name = "npc_dota_hero_abaddon", chinese = "亚巴顿", id = 102, model = "abaddon"},
    {type = 8, particleName = "bane", soundName = "bane", name = "npc_dota_hero_bane", chinese = "祸乱之源", id = 3, model = "bane"},
    {type = 8, particleName = "batrider", soundName = "batrider", name = "npc_dota_hero_batrider", chinese = "蝙蝠骑士", id = 65, model = "batrider"},
    {type = 8, particleName = "beastmaster", soundName = "beastmaster", name = "npc_dota_hero_beastmaster", chinese = "兽王", id = 38, model = "beastmaster"},
    {type = 8, particleName = "brewmaster", soundName = "brewmaster", name = "npc_dota_hero_brewmaster", chinese = "酒仙", id = 78, model = "brewmaster"},
    {type = 8, particleName = "broodmother", soundName = "broodmother", name = "npc_dota_hero_broodmother", chinese = "育母蜘蛛", id = 61, model = "broodmother"},
    {type = 8, particleName = "chen", soundName = "chen", name = "npc_dota_hero_chen", chinese = "陈", id = 66, model = "chen"},
    {type = 8, particleName = "rattletrap", soundName = "rattletrap", name = "npc_dota_hero_rattletrap", chinese = "发条技师", id = 51, model = "rattletrap"},
    {type = 8, particleName = "dark_seer", soundName = "dark_seer", name = "npc_dota_hero_dark_seer", chinese = "黑暗贤者", id = 55, model = "dark_seer"},
    {type = 8, particleName = "dark_willow", soundName = "dark_willow", name = "npc_dota_hero_dark_willow", chinese = "邪影芳灵", id = 119, model = "dark_willow"},
    {type = 8, particleName = "dazzle", soundName = "dazzle", name = "npc_dota_hero_dazzle", chinese = "戴泽", id = 50, model = "dazzle"},
    {type = 8, particleName = "enigma", soundName = "enigma", name = "npc_dota_hero_enigma", chinese = "谜团", id = 33, model = "enigma"},
    {type = 8, particleName = "wisp", soundName = "wisp", name = "npc_dota_hero_wisp", chinese = "艾欧", id = 91, model = "wisp"},
    {type = 8, particleName = "invoker", soundName = "invoker", name = "npc_dota_hero_invoker", chinese = "祈求者", id = 74, model = "invoker"},
    {type = 8, particleName = "lone_druid", soundName = "lone_druid", name = "npc_dota_hero_lone_druid", chinese = "德鲁伊", id = 80, model = "lone_druid"},
    {type = 8, particleName = "lycan", soundName = "lycan", name = "npc_dota_hero_lycan", chinese = "狼人", id = 77, model = "lycan"},
    {type = 8, particleName = "magnataur", soundName = "magnataur", name = "npc_dota_hero_magnataur", chinese = "马格纳斯", id = 97, model = "magnataur"},
    {type = 8, particleName = "marci", soundName = "marci", name = "npc_dota_hero_marci", chinese = "玛西", id = 136, model = "marci"},
    {type = 8, particleName = "mirana", soundName = "mirana", name = "npc_dota_hero_mirana", chinese = "米拉娜", id = 9, model = "mirana"},
    {type = 8, particleName = "nyx_assassin", soundName = "nyx_assassin", name = "npc_dota_hero_nyx_assassin", chinese = "司夜刺客", id = 88, model = "nerubian_assassin"},
    {type = 8, particleName = "pangolier", soundName = "pangolier", name = "npc_dota_hero_pangolier", chinese = "石鳞剑士", id = 120, model = "pangolier"},
    {type = 8, particleName = "phoenix", soundName = "phoenix", name = "npc_dota_hero_phoenix", chinese = "凤凰", id = 110, model = "phoenix"},
    {type = 8, particleName = "sand_king", soundName = "sandking", name = "npc_dota_hero_sand_king", chinese = "沙王", id = 16, model = "sand_king"},
    {type = 8, particleName = "snapfire", soundName = "snapfire", name = "npc_dota_hero_snapfire", chinese = "电炎绝手", id = 128, model = "snapfire"},
    {type = 8, particleName = "techies", soundName = "techies", name = "npc_dota_hero_techies", chinese = "工程师", id = 105, model = "techies"},
    {type = 8, particleName = "vengefulspirit", soundName = "vengefulspirit", name = "npc_dota_hero_vengefulspirit", chinese = "复仇之魂", id = 20, model = "vengeful"},
    {type = 8, particleName = "venomancer", soundName = "venomancer", name = "npc_dota_hero_venomancer", chinese = "剧毒术士", id = 40, model = "venomancer"},
    {type = 8, particleName = "visage", soundName = "visage", name = "npc_dota_hero_visage", chinese = "维萨吉", id = 92, model = "visage"},
    {type = 8, particleName = "void_spirit", soundName = "void_spirit", name = "npc_dota_hero_void_spirit", chinese = "虚无之灵", id = 126, model = "void_spirit"},
    {type = 8, particleName = "windrunner", soundName = "windrunner", name = "npc_dota_hero_windrunner", chinese = "风行者", id = 21, model = "windrunner"},
    {type = 8, particleName = "winter_wyvern", soundName = "winter_wyvern", name = "npc_dota_hero_winter_wyvern", chinese = "寒冬飞龙", id = 112, model = "winterwyvern"},
}

heroesFacets = {
    ["npc_dota_hero_antimage"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "antimage_magebanes_mirror",
            },
            [2] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "antimage_mana_thirst",
            },
        },
    },
    ["npc_dota_hero_axe"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "strength",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "axe_one_man_army",
                ["AbilityName"] = "axe_one_man_army",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "axe_call_out",
            },
        },
    },
    ["npc_dota_hero_bane"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "bane_dream_stalker",
            },
            [2] = {
                ["Icon"] = "movement",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "bane_sleepwalk",
            },
        },
    },
    ["npc_dota_hero_bloodseeker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "movement",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "bloodseeker_arterial_spray",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Gray",
                ["GradientID"] = "1",
                ["name"] = "bloodseeker_bloodrush",
            },
        },
    },
    ["npc_dota_hero_crystal_maiden"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Gray",
                ["GradientID"] = "1",
                ["name"] = "crystal_maiden_frozen_expanse",
            },
            [2] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "crystal_maiden_cold_comfort",
            },
        },
    },
    ["npc_dota_hero_drow_ranger"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "1",
                ["name"] = "drow_ranger_high_ground",
                ["AbilityName"] = "drow_ranger_vantage_point",
            },
            [2] = {
                ["Icon"] = "multi_arrow",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "drow_ranger_sidestep",
            },
        },
    },
    ["npc_dota_hero_earthshaker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "earthshaker_tectonic_buildup",
            },
            [2] = {
                ["Icon"] = "movement",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "earthshaker_slugger",
                ["AbilityName"] = "earthshaker_slugger",
            },
        },
    },
    ["npc_dota_hero_juggernaut"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "spinning",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "juggernaut_bladestorm",
            },
            [2] = {
                ["Icon"] = "agility",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "juggernaut_agigain",
                ["AbilityName"] = "juggernaut_bladeform",
            },
        },
    },
    ["npc_dota_hero_mirana"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "moon",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "mirana_moonlight",
                ["AbilityName"] = "mirana_invis",
            },
            [2] = {
                ["Icon"] = "sun",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "mirana_sunlight",
                ["AbilityName"] = "mirana_solar_flare",
            },
        },
    },
    ["npc_dota_hero_nevermore"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor_broken",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "nevermore_lasting_presence",
            },
            [2] = {
                ["Icon"] = "slow",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "nevermore_shadowmire",
            },
        },
    },
    ["npc_dota_hero_morphling"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "agility",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "morphling_agi",
                ["AbilityName"] = "morphling_ebb",
            },
            [2] = {
                ["Icon"] = "strength",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "morphling_str",
                ["AbilityName"] = "morphling_flow",
            },
        },
    },
    ["npc_dota_hero_phantom_lancer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "illusion",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "phantom_lancer_convergence",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "phantom_lancer_divergence",
            },
        },
    },
    ["npc_dota_hero_puck"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "movement",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "puck_jostling_rift",
            },
            [2] = {
                ["Icon"] = "curve_ball",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "puck_curveball",
            },
        },
    },
    ["npc_dota_hero_pudge"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "meat",
                ["Color"] = "Green",
                ["GradientID"] = "3",
                ["name"] = "pudge_fresh_meat",
            },
            [2] = {
                ["Icon"] = "pudge_hook",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "pudge_flayers_hook",
            },
        },
    },
    ["npc_dota_hero_razor"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "barrier",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "razor_thunderhead",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "razor_spellamp",
                ["AbilityName"] = "razor_dynamo",
            },
        },
    },
    ["npc_dota_hero_sand_king"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "vision",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "sand_king_sandshroud",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "sand_king_dust_devil",
            },
        },
    },
    ["npc_dota_hero_storm_spirit"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "storm_spirit_shock_collar",
            },
            [2] = {
                ["Icon"] = "movement",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "storm_spirit_static_slide",
            },
        },
    },
    ["npc_dota_hero_sven"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "sven_heavy_plate",
            },
            [2] = {
                ["Icon"] = "strength",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "sven_strscaling",
                ["AbilityName"] = "sven_wrath_of_god",
            },
        },
    },
    ["npc_dota_hero_tiny"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Gray",
                ["GradientID"] = "2",
                ["name"] = "tiny_crash_landing",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Green",
                ["GradientID"] = "4",
                ["name"] = "tiny_insurmountable",
                ["AbilityName"] = "tiny_insurmountable",
            },
        },
    },
    ["npc_dota_hero_vengefulspirit"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "vengefulspirit_avenging_missile",
            },
            [2] = {
                ["Icon"] = "fist",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["KeyValueOverrides"] = {
                    ["AttackRate"] = "1.5",
                },
                ["name"] = "vvengefulspirit_melee",
                ["AbilityName"] = "vengefulspirit_soul_strike",
            },
        },
    },
    ["npc_dota_hero_windrunner"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["Deprecated"] = "true",
                ["name"] = "windrunner_tailwind",
            },
            [2] = {
                ["Icon"] = "focus_fire",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "windrunner_focusfire",
            },
            [3] = {
                ["Icon"] = "multi_arrow",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["AbilityIconReplacements"] = {
                    ["windrunner_focusfire"] = "windrunner_whirlwind",
                    ["windrunner_focusfire_cancel"] = "windrunner_whirlwind_stop",
                },
                ["name"] = "windrunner_whirlwind",
            },
        },
    },
    ["npc_dota_hero_zuus"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "range",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "zuus_livewire",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "zuus_divine_rampage",
            },
        },
    },
    ["npc_dota_hero_kunkka"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "kunkka_high_tide",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "kunkka_grog",
            },
        },
    },
    ["npc_dota_hero_lina"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "lina_supercharge",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "lina_dot",
                ["AbilityName"] = "lina_slow_burn",
            },
        },
    },
    ["npc_dota_hero_lich"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "snowflake",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "lich_frostbound",
            },
            [2] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "lich_growing_cold",
            },
        },
    },
    ["npc_dota_hero_lion"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "lion_essence_eater",
            },
            [2] = {
                ["Icon"] = "fist",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "lion_fist_of_death",
            },
        },
    },
    ["npc_dota_hero_shadow_shaman"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "chicken",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "shadow_shaman_cluster_cluck",
            },
            [2] = {
                ["Icon"] = "snake",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "shadow_shaman_massive_serpent_ward",
            },
        },
    },
    ["npc_dota_hero_slardar"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "slardar_leg_day",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "slardar_brineguard",
            },
        },
    },
    ["npc_dota_hero_tidehunter"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Green",
                ["GradientID"] = "2",
                ["name"] = "tidehunter_kraken_swell",
            },
            [2] = {
                ["Icon"] = "overshadow",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["KeyValueOverrides"] = {
                    ["AttributeBaseStrength"] = "24",
                    ["AttributeStrengthGain"] = "4.1",
                },
                ["name"] = "tidehunter_sizescale",
                ["AbilityName"] = "tidehunter_krill_eater",
            },
        },
    },
    ["npc_dota_hero_witch_doctor"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "witch_doctor_headhunter",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "witch_doctor_voodoo_festeration",
            },
            [3] = {
                ["Icon"] = "death_ward",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "witch_doctor_cleft_death",
            },
        },
    },
    ["npc_dota_hero_riki"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "xp",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "riki_contract_killer",
            },
            [2] = {
                ["Icon"] = "agility",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "riki_exterminator",
            },
        },
    },
    ["npc_dota_hero_enigma"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "slow",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "enigma_gravity",
                ["AbilityName"] = "enigma_event_horizon",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "enigma_fragment",
                ["AbilityName"] = "enigma_splitting_image",
            },
        },
    },
    ["npc_dota_hero_tinker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "tinker_repair_bots",
            },
            [2] = {
                ["Icon"] = "movement",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "tinker_translocator",
            },
        },
    },
    ["npc_dota_hero_sniper"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "vision",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "sniper_ghillie_suit",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "sniper_scattershot",
            },
        },
    },
    ["npc_dota_hero_necrolyte"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "necrolyte_profane_potency",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Green",
                ["GradientID"] = "3",
                ["name"] = "necrolyte_rapid_decay",
            },
        },
    },
    ["npc_dota_hero_warlock"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "warlock_golem",
            },
            [2] = {
                ["Icon"] = "xp",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "warlock_grimoire",
                ["AbilityName"] = "warlock_black_grimoire",
            },
        },
    },
    ["npc_dota_hero_beastmaster"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "beastmaster_wild_hunt",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "beastmaster_beast_mode",
            },
        },
    },
    ["npc_dota_hero_queenofpain"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "queenofpain_lifesteal",
                ["AbilityName"] = "queenofpain_succubus",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "queenofpain_selfdmg",
                ["AbilityName"] = "queenofpain_masochist",
            },
        },
    },
    ["npc_dota_hero_venomancer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "snot",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "venomancer_patient_zero",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "venomancer_plague_carrier",
            },
        },
    },
    ["npc_dota_hero_faceless_void"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "faceless_void_temporal_impunity",
            },
            [2] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "faceless_void_chronosphere",
                ["AbilityName"] = "faceless_void_chronosphere",
            },
            [3] = {
                ["Icon"] = "chrono_cube",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "faceless_void_time_zone",
                ["AbilityName"] = "faceless_void_time_zone",
            },
        },
    },
    ["npc_dota_hero_skeleton_king"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "skeleton_king_facet_bone_guard",
                ["AbilityName"] = "skeleton_king_bone_guard",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "skeleton_king_facet_cursed_blade",
                ["AbilityName"] = "skeleton_king_spectral_blade",
            },
        },
    },
    ["npc_dota_hero_death_prophet"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "slow",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "death_prophet_suppress",
            },
            [2] = {
                ["Icon"] = "spirit",
                ["Color"] = "Green",
                ["GradientID"] = "1",
                ["name"] = "death_prophet_ghosts",
                ["AbilityName"] = "death_prophet_spirit_collector",
            },
            [3] = {
                ["Icon"] = "healing",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "death_prophet_delayed_damage",
                ["AbilityName"] = "death_prophet_mourning_ritual",
            },
        },
    },
    ["npc_dota_hero_phantom_assassin"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "phantom_assassin_veiled_one",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "phantom_assassin_methodical",
            },
        },
    },
    ["npc_dota_hero_pugna"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "pugna_siphoning_ward",
            },
            [2] = {
                ["Icon"] = "siege",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "pugna_rewards_of_ruin",
            },
        },
    },
    ["npc_dota_hero_templar_assassin"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "templar_assassin_voidblades",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "templar_assassin_refractor",
            },
        },
    },
    ["npc_dota_hero_viper"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "viper_poison_burst",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "viper_caustic_bath",
            },
        },
    },
    ["npc_dota_hero_luna"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "luna_lunar_orbit",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "luna_moonshield",
            },
            [3] = {
                ["Icon"] = "damage",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "luna_moonstorm",
            },
        },
    },
    ["npc_dota_hero_dragon_knight"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "dragon_fire",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "dragon_knight_fire_dragon",
            },
            [2] = {
                ["Icon"] = "dragon_poison",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "dragon_knight_corrosive_dragon",
            },
            [3] = {
                ["Icon"] = "dragon_frost",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "dragon_knight_frost_dragon",
            },
        },
    },
    ["npc_dota_hero_dazzle"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "dazzle_facet_nothl_boon",
                ["AbilityName"] = "dazzle_nothl_boon",
            },
            [2] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "dazzle_poison_bloom",
            },
        },
    },
    ["npc_dota_hero_rattletrap"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Gray",
                ["GradientID"] = "2",
                ["name"] = "rattletrap_hookup",
            },
            [2] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "rattletrap_expanded_armature",
            },
        },
    },
    ["npc_dota_hero_leshrac"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "leshrac_attacks_mana",
                ["AbilityName"] = "leshrac_chronoptic_nourishment",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "leshrac_misanthropy",
            },
        },
    },
    ["npc_dota_hero_furion"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "furion_soothing_saplings",
            },
            [2] = {
                ["Icon"] = "siege",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "furion_ironwood_treant",
            },
        },
    },
    ["npc_dota_hero_life_stealer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Yellow",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "life_stealer_maxhp_gain",
                ["AbilityName"] = "life_stealer_corpse_eater",
            },
            [2] = {
                ["Icon"] = "lifestealer_rage",
                ["Color"] = "Yellow",
                ["GradientID"] = "3",
                ["name"] = "life_stealer_rage",
                ["AbilityName"] = "life_stealer_rage",
            },
            [3] = {
                ["Icon"] = "broken_chain",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "life_stealer_rage_dispell",
                ["AbilityName"] = "life_stealer_unfettered",
            },
        },
    },
    ["npc_dota_hero_dark_seer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "dark_seer_atkspd",
                ["AbilityName"] = "dark_seer_quick_wit",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["KeyValueOverrides"] = {
                    ["MovementSpeed"] = "275",
                },
                ["name"] = "dark_seer_movespd",
                ["AbilityName"] = "dark_seer_heart_of_battle",
            },
        },
    },
    ["npc_dota_hero_clinkz"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "no_vision",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "clinkz_suppressive_fire",
            },
            [2] = {
                ["Icon"] = "teleport",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "clinkz_engulfing_step",
            },
        },
    },
    ["npc_dota_hero_omniknight"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "omniknight_omnipresent",
            },
            [2] = {
                ["Icon"] = "healing",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "omniknight_dmgheals",
                ["AbilityName"] = "omniknight_healing_hammer",
            },
        },
    },
    ["npc_dota_hero_enchantress"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "enchantress_overprotective_wisps",
            },
            [2] = {
                ["Icon"] = "range",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "enchantress_spellbound",
            },
        },
    },
    ["npc_dota_hero_huskar"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "huskar_bloodbath",
            },
            [2] = {
                ["Icon"] = "healing",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "huskar_nothl_transfusion",
            },
            [3] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "huskar_nothl_conflagration",
            },
        },
    },
    ["npc_dota_hero_night_stalker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "no_vision",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "night_stalker_blinding_void",
            },
            [2] = {
                ["Icon"] = "moon",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "night_stalker_dayswap",
                ["AbilityName"] = "night_stalker_night_reign",
            },
        },
    },
    ["npc_dota_hero_broodmother"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "debuff",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "broodmother_necrotic_webs",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "broodmother_feeding_frenzy",
            },
        },
    },
    ["npc_dota_hero_bounty_hunter"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "bounty_hunter_shuriken",
            },
            [2] = {
                ["Icon"] = "gold",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "bounty_hunter_mugging",
                ["AbilityName"] = "bounty_hunter_cutpurse",
            },
        },
    },
    ["npc_dota_hero_weaver"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "weaver_skitterstep",
            },
            [2] = {
                ["Icon"] = "xp",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "weaver_hivemind",
            },
        },
    },
    ["npc_dota_hero_jakiro"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "jakiro_fire",
                ["AbilityName"] = "jakiro_liquid_fire",
            },
            [2] = {
                ["Icon"] = "snowflake",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "jakiro_ice",
                ["AbilityName"] = "jakiro_liquid_ice",
            },
        },
    },
    ["npc_dota_hero_batrider"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "batrider_buff_on_displacement",
                ["AbilityName"] = "batrider_stoked",
            },
            [2] = {
                ["Icon"] = "siege",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "batrider_arsonist",
            },
        },
    },
    ["npc_dota_hero_chen"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["AbilityIconReplacements"] = {
                    ["chen_summon_convert"] = "chen_summon_convert_centaur",
                },
                ["name"] = "chen_centaur_convert",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["AbilityIconReplacements"] = {
                    ["chen_summon_convert"] = "chen_summon_convert_wolf",
                },
                ["name"] = "chen_wolf_convert",
            },
            [3] = {
                ["Icon"] = "slow",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["AbilityIconReplacements"] = {
                    ["chen_summon_convert"] = "chen_summon_convert_hellbear",
                },
                ["name"] = "chen_hellbear_convert",
            },
            [4] = {
                ["Icon"] = "summons",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["AbilityIconReplacements"] = {
                    ["chen_summon_convert"] = "chen_summon_convert_troll",
                },
                ["name"] = "chen_troll_convert",
            },
            [5] = {
                ["Icon"] = "mana",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["AbilityIconReplacements"] = {
                    ["chen_summon_convert"] = "chen_summon_convert_satyr",
                },
                ["name"] = "chen_satyr_convert",
            },
        },
    },
    ["npc_dota_hero_spectre"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "spectre",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "spectre_forsaken",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "spectre_twist_the_knife",
            },
        },
    },
    ["npc_dota_hero_doom_bringer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "meat",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "doom_bringer_gluttony",
            },
            [2] = {
                ["Icon"] = "gold",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "doom_bringer_boost_selling",
                ["AbilityName"] = "doom_bringer_devils_bargain",
            },
            [3] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "doom_bringer_impending_doom",
            },
        },
    },
    ["npc_dota_hero_ancient_apparition"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "debuff",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "ancient_apparition_bone_chill",
            },
            [2] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "ancient_apparition_exposure",
            },
        },
    },
    ["npc_dota_hero_ursa"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "ursa_grudge_bearer",
            },
            [2] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "ursa_debuff_reduce",
                ["AbilityName"] = "ursa_bear_down",
            },
        },
    },
    ["npc_dota_hero_spirit_breaker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "spirit_breaker_bull_rush",
            },
            [2] = {
                ["Icon"] = "movement",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "spirit_breaker_imbalanced",
            },
        },
    },
    ["npc_dota_hero_gyrocopter"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "gyrocopter_secondary_strikes",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "gyrocopter_afterburner",
            },
        },
    },
    ["npc_dota_hero_alchemist"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "gold",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "alchemist_seed_money",
            },
            [2] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "alchemist_mixologist",
            },
        },
    },
    ["npc_dota_hero_invoker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "invoker_passive",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "invoker_agnostic",
            },
            [2] = {
                ["Icon"] = "invoker_active",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "invoker_elitist",
            },
        },
    },
    ["npc_dota_hero_silencer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "silencer",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "silencer_irrepressible",
                ["AbilityName"] = "silencer_irrepressible",
            },
            [2] = {
                ["Icon"] = "debuff",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "silencer_reverberating_silence",
            },
        },
    },
    ["npc_dota_hero_obsidian_destroyer"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "obsidian_destroyer_obsidian_decimator",
            },
            [2] = {
                ["Icon"] = "healing",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "obsidian_destroyer_overwhelming_devourer",
            },
        },
    },
    ["npc_dota_hero_lycan"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Gray",
                ["GradientID"] = "1",
                ["name"] = "lycan_pack_leader",
            },
            [2] = {
                ["Icon"] = "spirit",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["AbilityIconReplacements"] = {
                    ["lycan_summon_wolves"] = "lycan_summon_spirit_wolves",
                },
                ["name"] = "lycan_spirit_wolves",
            },
            [3] = {
                ["Icon"] = "wolf",
                ["Color"] = "Green",
                ["GradientID"] = "2",
                ["name"] = "lycan_alpha_wolves",
            },
        },
    },
    ["npc_dota_hero_brewmaster"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "brewmaster_roll_out_the_barrel",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "brewmaster_drunken_master",
            },
        },
    },
    ["npc_dota_hero_shadow_demon"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "shadow_demon_promulgate",
            },
            [2] = {
                ["Icon"] = "illusion",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "shadow_demon_facet_soul_mastery",
                ["AbilityName"] = "shadow_demon_shadow_servant",
            },
        },
    },
    ["npc_dota_hero_lone_druid"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Green",
                ["GradientID"] = "1",
                ["name"] = "lone_druid_bear_with_me",
            },
            [2] = {
                ["Icon"] = "overshadow",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "lone_druid_unbearable",
            },
            [3] = {
                ["Icon"] = "item",
                ["Color"] = "Gray",
                ["GradientID"] = "1",
                ["name"] = "lone_druid_bear_necessities",
                ["AbilityName"] = "lone_druid_bear_necessities",
            },
        },
    },
    ["npc_dota_hero_chaos_knight"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "illusion",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "chaos_knight_strong_illusions",
                ["AbilityName"] = "chaos_knight_phantasmagoria",
            },
            [2] = {
                ["Icon"] = "rng",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "chaos_knight_irrationality",
            },
        },
    },
    ["npc_dota_hero_meepo"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "meepo_more_meepo",
            },
            [2] = {
                ["Icon"] = "item",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "meepo_pack_rat",
                ["AbilityName"] = "meepo_pack_rat",
            },
        },
    },
    ["npc_dota_hero_treant"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "treant_primeval_power",
            },
            [2] = {
                ["Icon"] = "tree",
                ["Color"] = "Green",
                ["GradientID"] = "2",
                ["name"] = "treant_sapling",
            },
        },
    },
    ["npc_dota_hero_ogre_magi"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "rng",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "ogre_magi_fat_chance",
            },
            [2] = {
                ["Icon"] = "ogre",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "ogre_magi_learning_curve",
            },
        },
    },
    ["npc_dota_hero_undying"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Green",
                ["GradientID"] = "4",
                ["name"] = "undying_rotting_mitts",
            },
            [2] = {
                ["Icon"] = "strength",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "undying_ripped",
            },
        },
    },
    ["npc_dota_hero_rubick"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "mana",
                ["Color"] = "Purple",
                ["GradientID"] = "2",
                ["name"] = "rubick_frugal_filch",
            },
            [2] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "rubick_arcane_accumulation",
            },
        },
    },
    ["npc_dota_hero_disruptor"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "disruptor_thunderstorm",
            },
            [2] = {
                ["Icon"] = "fence",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "disruptor_line_walls",
                ["AbilityName"] = "disruptor_kinetic_fence",
            },
        },
    },
    ["npc_dota_hero_nyx_assassin"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "nyx_assassin_burn_mana",
                ["AbilityName"] = "nyx_assassin_innate_mana_burn",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "nyx_assassin_scuttle",
            },
        },
    },
    ["npc_dota_hero_naga_siren"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor_broken",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "naga_siren_passive_riptide",
                ["AbilityName"] = "naga_siren_rip_tide",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Green",
                ["GradientID"] = "2",
                ["name"] = "naga_siren_active_riptide",
                ["AbilityName"] = "naga_siren_deluge",
            },
        },
    },
    ["npc_dota_hero_keeper_of_the_light"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "slow",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "keeper_of_the_light_facet_solar_bind",
                ["AbilityName"] = "keeper_of_the_light_radiant_bind",
            },
            [2] = {
                ["Icon"] = "teleport",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "keeper_of_the_light_facet_recall",
                ["AbilityName"] = "keeper_of_the_light_recall",
            },
        },
    },
    ["npc_dota_hero_wisp"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "wisp_kritzkrieg",
            },
            [2] = {
                ["Icon"] = "armor",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "wisp_medigun",
            },
        },
    },
    ["npc_dota_hero_visage"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "visage_sepulchre",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "visage_faithful_followers",
            },
            [3] = {
                ["Icon"] = "gold",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "visage_gold_assumption",
            },
        },
    },
    ["npc_dota_hero_slark"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "agility",
                ["Color"] = "Green",
                ["GradientID"] = "2",
                ["name"] = "slark_leeching_leash",
            },
            [2] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "slark_dark_reef_renegade",
            },
        },
    },
    ["npc_dota_hero_medusa"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "snake",
                ["Color"] = "Green",
                ["GradientID"] = "1",
                ["name"] = "medusa_engorged",
            },
            [2] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["Deprecated"] = "true",
                ["name"] = "medusa_mana_pact",
            },
            [3] = {
                ["Icon"] = "slow",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "medusa_slow_attacks",
                ["AbilityName"] = "medusa_venomed_volley",
            },
        },
    },
    ["npc_dota_hero_troll_warlord"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "troll_warlord_insensitive",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "troll_warlord_bad_influence",
            },
        },
    },
    ["npc_dota_hero_centaur"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "centaur_counter_strike",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "centaur_horsepower",
                ["AbilityName"] = "centaur_horsepower",
            },
        },
    },
    ["npc_dota_hero_magnataur"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "movement",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "magnataur_run_through",
            },
            [2] = {
                ["Icon"] = "vortex_in",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "magnataur_reverse_polarity",
            },
            [3] = {
                ["Icon"] = "vortex_out",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["AbilityIconReplacements"] = {
                    ["magnataur_reverse_polarity"] = "magnataur_reversed_reverse_polarity",
                },
                ["name"] = "magnataur_reverse_reverse_polarity",
            },
        },
    },
    ["npc_dota_hero_shredder"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "tree",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "shredder_shredder",
            },
            [2] = {
                ["Icon"] = "spinning",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "shredder_second_chakram",
                ["AbilityName"] = "shredder_twisted_chakram",
            },
        },
    },
    ["npc_dota_hero_bristleback"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "bristleback_berserk",
            },
            [2] = {
                ["Icon"] = "snot",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "bristleback_snot_rocket",
            },
            [3] = {
                ["Icon"] = "no_vision",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "bristleback_seeing_red",
            },
        },
    },
    ["npc_dota_hero_tusk"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "tusk_facet_tag_team",
                ["AbilityName"] = "tusk_tag_team",
            },
            [2] = {
                ["Icon"] = "movement",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "tusk_facet_fist_bump",
                ["AbilityName"] = "tusk_drinking_buddies",
            },
        },
    },
    ["npc_dota_hero_skywrath_mage"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "skywrath_mage_shield",
                ["AbilityName"] = "skywrath_mage_shield_of_the_scion",
            },
            [2] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "skywrath_mage_staff",
                ["AbilityName"] = "skywrath_mage_staff_of_the_scion",
            },
        },
    },
    ["npc_dota_hero_abaddon"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "abaddon_death_dude",
                ["AbilityName"] = "abaddon_the_quickening",
            },
            [2] = {
                ["Icon"] = "barrier",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "abaddon_mephitic_shroud",
            },
        },
    },
    ["npc_dota_hero_elder_titan"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor_broken",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "elder_titan_deconstruction",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "elder_titan_boost_atkspd",
                ["AbilityName"] = "elder_titan_momentum",
            },
        },
    },
    ["npc_dota_hero_legion_commander"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "legion_commander_stonehall_plate",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "legion_commander_spoils_of_war",
            },
        },
    },
    ["npc_dota_hero_ember_spirit"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "fist",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "ember_spirit_double_impact",
            },
            [2] = {
                ["Icon"] = "debuff",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "ember_spirit_chain_gang",
            },
        },
    },
    ["npc_dota_hero_earth_spirit"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "earth_spirit_resonance",
            },
            [2] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Gray",
                ["GradientID"] = "2",
                ["name"] = "earth_spirit_stepping_stone",
            },
            [3] = {
                ["Icon"] = "spinning",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "earth_spirit_ready_to_roll",
            },
        },
    },
    ["npc_dota_hero_terrorblade"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "twin_hearts",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "terrorblade_condemned",
            },
            [2] = {
                ["Icon"] = "illusion",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "terrorblade_soul_fragment",
            },
        },
    },
    ["npc_dota_hero_phoenix"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "barrier",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "phoenix_facet_immolate",
                ["AbilityName"] = "phoenix_dying_light",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "phoenix_hotspot",
            },
        },
    },
    ["npc_dota_hero_oracle"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "oracle_facet_dmg",
                ["AbilityName"] = "oracle_clairvoyant_curse",
            },
            [2] = {
                ["Icon"] = "healing",
                ["Color"] = "Green",
                ["GradientID"] = "1",
                ["name"] = "oracle_facet_heal",
                ["AbilityName"] = "oracle_clairvoyant_cure",
            },
        },
    },
    ["npc_dota_hero_techies"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "range",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "techies_atk_range",
                ["AbilityName"] = "techies_squees_scope",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "techies_spleens_secret_sauce",
            },
            [3] = {
                ["Icon"] = "item",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "techies_backpack",
                ["AbilityName"] = "techies_spoons_stash",
            },
        },
    },
    ["npc_dota_hero_winter_wyvern"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "winter_wyvern_heal_mana",
                ["AbilityName"] = "winter_wyvern_essence_of_the_blueheart",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "winter_wyvern_atk_range",
                ["AbilityName"] = "winter_wyvern_dragon_sight",
            },
        },
    },
    ["npc_dota_hero_arc_warden"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "arc_warden",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "arc_warden_order",
            },
            [2] = {
                ["Icon"] = "arc_warden_alt",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "arc_warden_disorder",
            },
        },
    },
    ["npc_dota_hero_abyssal_underlord"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "abyssal_underlord_demons_reach",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Yellow",
                ["GradientID"] = "3",
                ["name"] = "abyssal_underlord_summons",
                ["AbilityName"] = "abyssal_underlord_abyssal_horde",
            },
        },
    },
    ["npc_dota_hero_monkey_king"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "monkey_king_wukongs_faithful",
            },
            [2] = {
                ["Icon"] = "tree",
                ["Color"] = "Green",
                ["GradientID"] = "4",
                ["name"] = "monkey_king_simian_stride",
            },
        },
    },
    ["npc_dota_hero_pangolier"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "double_bounce",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "pangolier_double_jump",
            },
            [2] = {
                ["Icon"] = "speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "pangolier_thunderbolt",
            },
        },
    },
    ["npc_dota_hero_dark_willow"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "damage",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "dark_willow_throwing_shade",
            },
            [2] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Green",
                ["GradientID"] = "4",
                ["name"] = "dark_willow_thorny_thicket",
            },
        },
    },
    ["npc_dota_hero_grimstroke"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "grimstroke_inkstigate",
            },
            [2] = {
                ["Icon"] = "brush",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "grimstroke_fine_art",
            },
        },
    },
    ["npc_dota_hero_mars"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Red",
                ["GradientID"] = "2",
                ["name"] = "mars_victory_feast",
            },
            [2] = {
                ["Icon"] = "no_vision",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "mars_arena",
            },
        },
    },
    ["npc_dota_hero_void_spirit"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "armor",
                ["Color"] = "Purple",
                ["GradientID"] = "1",
                ["name"] = "void_spirit_sanctuary",
            },
            [2] = {
                ["Icon"] = "nuke",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "void_spirit_phys_barrier",
                ["AbilityName"] = "void_spirit_symmetry",
            },
            [3] = {
                ["Icon"] = "illusion",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "void_spirit_aether_artifice",
            },
        },
    },
    ["npc_dota_hero_snapfire"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "snapfire_ricochet_ii",
            },
            [2] = {
                ["Icon"] = "range",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "snapfire_full_bore",
            },
        },
    },
    ["npc_dota_hero_hoodwink"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "range",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "hoodwink_hunter",
            },
            [2] = {
                ["Icon"] = "tree",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "hoodwink_treebounce_trickshot",
            },
        },
    },
    ["npc_dota_hero_dawnbreaker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "dawnbreaker_solar_charged",
            },
            [2] = {
                ["Icon"] = "dawnbreaker_hammer",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "dawnbreaker_gleaming_hammer",
            },
        },
    },
    ["npc_dota_hero_marci"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "marci_sidekick",
                ["AbilityName"] = "marci_guardian",
            },
            [2] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "marci_bodyguard",
                ["AbilityName"] = "marci_bodyguard",
            },
        },
    },
    ["npc_dota_hero_primal_beast"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "primal_beast_romp_n_stomp",
            },
            [2] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Yellow",
                ["GradientID"] = "3",
                ["name"] = "primal_beast_ferocity",
            },
        },
    },
    ["npc_dota_hero_muerta"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "spirit",
                ["Color"] = "Green",
                ["GradientID"] = "1",
                ["name"] = "muerta_dance_of_the_dead",
            },
            [2] = {
                ["Icon"] = "teleport",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "muerta_ofrenda",
                ["AbilityName"] = "muerta_ofrenda",
            },
        },
    },
    ["npc_dota_hero_ringmaster"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "item",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "ringmaster_default",
            },
        },
    },
    ["npc_dota_hero_kez"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "kez",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "kez_default",
            },
        },
    },
}
