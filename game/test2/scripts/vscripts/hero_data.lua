-- hero_data.lua
heroes_precache = {
    {particleName = "alchemist", soundName = "alchemist", name = "npc_dota_hero_alchemist", chinese = "炼金术士", id = 73, model = "alchemist"},
    {particleName = "axe", soundName = "axe", name = "npc_dota_hero_axe", chinese = "斧王", id = 2, model = "axe"},
    {particleName = "bristleback", soundName = "bristleback", name = "npc_dota_hero_bristleback", chinese = "钢背兽", id = 99, model = "bristleback"},
    {particleName = "centaur", soundName = "centaur", name = "npc_dota_hero_centaur", chinese = "半人马战行者", id = 96, model = "centaur"},
    {particleName = "chaos_knight", soundName = "chaos_knight", name = "npc_dota_hero_chaos_knight", chinese = "混沌骑士", id = 81, model = "chaos_knight"},
    {particleName = "dawnbreaker", soundName = "dawnbreaker", name = "npc_dota_hero_dawnbreaker", chinese = "破晓辰星", id = 135, model = "dawnbreaker"},
    {particleName = "doom_bringer", soundName = "doombringer", name = "npc_dota_hero_doom_bringer", chinese = "末日使者", id = 69, model = "doom"},
    {particleName = "dragon_knight", soundName = "dragon_knight", name = "npc_dota_hero_dragon_knight", chinese = "龙骑士", id = 49, model = "dragon_knight"},
    {particleName = "earthshaker", soundName = "earthshaker", name = "npc_dota_hero_earthshaker", chinese = "撼地者", id = 7, model = "earthshaker"},
    {particleName = "elder_titan", soundName = "elder_titan", name = "npc_dota_hero_elder_titan", chinese = "上古巨神", id = 103, model = "elder_titan"},
    {particleName = "earth_spirit", soundName = "earth_spirit", name = "npc_dota_hero_earth_spirit", chinese = "大地之灵", id = 107, model = "earth_spirit"},
    {particleName = "huskar", soundName = "huskar", name = "npc_dota_hero_huskar", chinese = "哈斯卡", id = 59, model = "huskar"},
    {particleName = "kunkka", soundName = "kunkka", name = "npc_dota_hero_kunkka", chinese = "昆卡", id = 23, model = "kunkka"},
    {particleName = "legion_commander", soundName = "legion_commander", name = "npc_dota_hero_legion_commander", chinese = "军团指挥官", id = 104, model = "legion_commander"},
    {particleName = "life_stealer", soundName = "life_stealer", name = "npc_dota_hero_life_stealer", chinese = "噬魂鬼", id = 54, model = "life_stealer"},
    {particleName = "mars", soundName = "mars", name = "npc_dota_hero_mars", chinese = "玛尔斯", id = 129, model = "mars"},
    {particleName = "night_stalker", soundName = "nightstalker", name = "npc_dota_hero_night_stalker", chinese = "暗夜魔王", id = 60, model = "nightstalker"},
    {particleName = "ogre_magi", soundName = "ogre_magi", name = "npc_dota_hero_ogre_magi", chinese = "食人魔魔法师", id = 84, model = "ogre_magi"},
    {particleName = "omniknight", soundName = "omniknight", name = "npc_dota_hero_omniknight", chinese = "全能骑士", id = 57, model = "omniknight"},
    {particleName = "primal_beast", soundName = "primal_beast", name = "npc_dota_hero_primal_beast", chinese = "兽", id = 137, model = "primal_beast"},
    {particleName = "pudge", soundName = "pudge", name = "npc_dota_hero_pudge", chinese = "帕吉", id = 14, model = "pudge"},
    {particleName = "slardar", soundName = "slardar", name = "npc_dota_hero_slardar", chinese = "斯拉达", id = 28, model = "slardar"},
    {particleName = "shredder", soundName = "shredder", name = "npc_dota_hero_shredder", chinese = "伐木机", id = 98, model = "shredder"},
    {particleName = "spirit_breaker", soundName = "spirit_breaker", name = "npc_dota_hero_spirit_breaker", chinese = "裂魂人", id = 71, model = "spirit_breaker"},
    {particleName = "sven", soundName = "sven", name = "npc_dota_hero_sven", chinese = "斯温", id = 18, model = "sven"},
    {particleName = "tidehunter", soundName = "tidehunter", name = "npc_dota_hero_tidehunter", chinese = "潮汐猎人", id = 29, model = "tidehunter"},
    {particleName = "tiny", soundName = "tiny", name = "npc_dota_hero_tiny", chinese = "小小", id = 19, model = "tiny"},
    {particleName = "treant", soundName = "treant", name = "npc_dota_hero_treant", chinese = "树精卫士", id = 83, model = "treant_protector"},
    {particleName = "tusk", soundName = "tusk", name = "npc_dota_hero_tusk", chinese = "巨牙海民", id = 100, model = "tuskarr"},
    {particleName = "abyssal_underlord", soundName = "abyssal_underlord", name = "npc_dota_hero_abyssal_underlord", chinese = "孽主", id = 108, model = "abyssal_underlord"},
    {particleName = "undying", soundName = "undying", name = "npc_dota_hero_undying", chinese = "不朽尸王", id = 85, model = "undying"},
    {particleName = "skeleton_king", soundName = "skeletonking", name = "npc_dota_hero_skeleton_king", chinese = "冥魂大帝", id = 42, model = "wraith_king"},
    
    {particleName = "antimage", soundName = "antimage", name = "npc_dota_hero_antimage", chinese = "敌法师", id = 1, model = "antimage"},
    {particleName = "arc_warden", soundName = "arc_warden", name = "npc_dota_hero_arc_warden", chinese = "天穹守望者", id = 113, model = "arc_warden"},
    {particleName = "bloodseeker", soundName = "bloodseeker", name = "npc_dota_hero_bloodseeker", chinese = "血魔", id = 4, model = "blood_seeker"},
    {particleName = "bounty_hunter", soundName = "bounty_hunter", name = "npc_dota_hero_bounty_hunter", chinese = "赏金猎人", id = 62, model = "bounty_hunter"},
    {particleName = "clinkz", soundName = "clinkz", name = "npc_dota_hero_clinkz", chinese = "克林克兹", id = 56, model = "clinkz"},
    {particleName = "drow_ranger", soundName = "drowranger", name = "npc_dota_hero_drow_ranger", chinese = "卓尔游侠", id = 6, model = "drow"},
    {particleName = "ember_spirit", soundName = "ember_spirit", name = "npc_dota_hero_ember_spirit", chinese = "灰烬之灵", id = 106, model = "ember_spirit"},
    {particleName = "faceless_void", soundName = "faceless_void", name = "npc_dota_hero_faceless_void", chinese = "虚空假面", id = 41, model = "faceless_void"},
    {particleName = "gyrocopter", soundName = "gyrocopter", name = "npc_dota_hero_gyrocopter", chinese = "矮人直升机", id = 72, model = "gyro"},
    {particleName = "hoodwink", soundName = "hoodwink", name = "npc_dota_hero_hoodwink", chinese = "森海飞霞", id = 123, model = "hoodwink"},
    {particleName = "juggernaut", soundName = "juggernaut", name = "npc_dota_hero_juggernaut", chinese = "主宰", id = 8, model = "juggernaut"},
    {particleName = "luna", soundName = "luna", name = "npc_dota_hero_luna", chinese = "露娜", id = 48, model = "luna"},
    {particleName = "medusa", soundName = "medusa", name = "npc_dota_hero_medusa", chinese = "美杜莎", id = 94, model = "medusa"},
    {particleName = "meepo", soundName = "meepo", name = "npc_dota_hero_meepo", chinese = "米波", id = 82, model = "meepo"},
    {particleName = "monkey_king", soundName = "monkey_king", name = "npc_dota_hero_monkey_king", chinese = "齐天大圣", id = 114, model = "monkey_king"},
    {particleName = "morphling", soundName = "morphling", name = "npc_dota_hero_morphling", chinese = "变体精灵", id = 10, model = "morphling"},
    {particleName = "naga_siren", soundName = "naga_siren", name = "npc_dota_hero_naga_siren", chinese = "娜迦海妖", id = 89, model = "siren"},
    {particleName = "phantom_assassin", soundName = "phantom_assassin", name = "npc_dota_hero_phantom_assassin", chinese = "幻影刺客", id = 44, model = "phantom_assassin"},
    {particleName = "phantom_lancer", soundName = "phantom_lancer", name = "npc_dota_hero_phantom_lancer", chinese = "幻影长矛手", id = 12, model = "phantom_lancer"},
    {particleName = "razor", soundName = "razor", name = "npc_dota_hero_razor", chinese = "雷泽", id = 15, model = "razor"},
    {particleName = "riki", soundName = "riki", name = "npc_dota_hero_riki", chinese = "力丸", id = 32, model = "rikimaru"},
    {particleName = "nevermore", soundName = "nevermore", name = "npc_dota_hero_nevermore", chinese = "影魔", id = 11, model = "shadow_fiend"},
    {particleName = "slark", soundName = "slark", name = "npc_dota_hero_slark", chinese = "斯拉克", id = 93, model = "slark"},
    {particleName = "sniper", soundName = "sniper", name = "npc_dota_hero_sniper", chinese = "狙击手", id = 35, model = "sniper"},
    {particleName = "spectre", soundName = "spectre", name = "npc_dota_hero_spectre", chinese = "幽鬼", id = 67, model = "spectre"},
    {particleName = "templar_assassin", soundName = "templar_assassin", name = "npc_dota_hero_templar_assassin", chinese = "圣堂刺客", id = 46, model = "lanaya"},
    {particleName = "terrorblade", soundName = "terrorblade", name = "npc_dota_hero_terrorblade", chinese = "恐怖利刃", id = 109, model = "terrorblade"},
    {particleName = "troll_warlord", soundName = "troll_warlord", name = "npc_dota_hero_troll_warlord", chinese = "巨魔战将", id = 95, model = "troll_warlord"},
    {particleName = "ursa", soundName = "ursa", name = "npc_dota_hero_ursa", chinese = "熊战士", id = 70, model = "ursa"},
    {particleName = "viper", soundName = "viper", name = "npc_dota_hero_viper", chinese = "冥界亚龙", id = 47, model = "viper"},
    {particleName = "weaver", soundName = "weaver", name = "npc_dota_hero_weaver", chinese = "编织者", id = 63, model = "weaver"},
    {particleName = "kez", soundName = "kez", name = "npc_dota_hero_kez", chinese = "凯", id = 145, model = "kez"},
    
    {particleName = "ancient_apparition", soundName = "ancient_apparition", name = "npc_dota_hero_ancient_apparition", chinese = "远古冰魄", id = 68, model = "ancient_apparition"},
    {particleName = "crystal_maiden", soundName = "crystalmaiden", name = "npc_dota_hero_crystal_maiden", chinese = "水晶室女", id = 5, model = "crystal_maiden"},
    {particleName = "death_prophet", soundName = "death_prophet", name = "npc_dota_hero_death_prophet", chinese = "死亡先知", id = 43, model = "death_prophet"},
    {particleName = "disruptor", soundName = "disruptor", name = "npc_dota_hero_disruptor", chinese = "干扰者", id = 87, model = "disruptor"},
    {particleName = "enchantress", soundName = "enchantress", name = "npc_dota_hero_enchantress", chinese = "魅惑魔女", id = 58, model = "enchantress"},
    {particleName = "grimstroke", soundName = "grimstroke", name = "npc_dota_hero_grimstroke", chinese = "天涯墨客", id = 121, model = "grimstroke"},
    {particleName = "jakiro", soundName = "jakiro", name = "npc_dota_hero_jakiro", chinese = "杰奇洛", id = 64, model = "jakiro"},
    {particleName = "keeper_of_the_light", soundName = "keeper_of_the_light", name = "npc_dota_hero_keeper_of_the_light", chinese = "光之守卫", id = 90, model = "keeper_of_the_light"},
    {particleName = "leshrac", soundName = "leshrac", name = "npc_dota_hero_leshrac", chinese = "拉席克", id = 52, model = "leshrac"},
    {particleName = "lich", soundName = "lich", name = "npc_dota_hero_lich", chinese = "巫妖", id = 31, model = "lich"},
    {particleName = "lina", soundName = "lina", name = "npc_dota_hero_lina", chinese = "莉娜", id = 25, model = "lina"},
    {particleName = "lion", soundName = "lion", name = "npc_dota_hero_lion", chinese = "莱恩", id = 26, model = "lion"},
    {particleName = "muerta", soundName = "muerta", name = "npc_dota_hero_muerta", chinese = "琼英碧灵", id = 138, model = "muerta"},
    {particleName = "furion", soundName = "furion", name = "npc_dota_hero_furion", chinese = "先知", id = 53, model = "furion"},
    {particleName = "necrolyte", soundName = "necrolyte", name = "npc_dota_hero_necrolyte", chinese = "瘟疫法师", id = 36, model = "necrolyte"},
    {particleName = "oracle", soundName = "oracle", name = "npc_dota_hero_oracle", chinese = "神谕者", id = 111, model = "oracle"},
    {particleName = "obsidian_destroyer", soundName = "obsidian_destroyer", name = "npc_dota_hero_obsidian_destroyer", chinese = "殁境神蚀者", id = 76, model = "obsidian_destroyer"},
    {particleName = "puck", soundName = "puck", name = "npc_dota_hero_puck", chinese = "帕克", id = 13, model = "puck"},
    {particleName = "pugna", soundName = "pugna", name = "npc_dota_hero_pugna", chinese = "帕格纳", id = 45, model = "pugna"},
    {particleName = "queenofpain", soundName = "queenofpain", name = "npc_dota_hero_queenofpain", chinese = "痛苦女王", id = 39, model = "queenofpain"},
    {particleName = "rubick", soundName = "rubick", name = "npc_dota_hero_rubick", chinese = "拉比克", id = 86, model = "rubick"},
    {particleName = "shadow_demon", soundName = "shadow_demon", name = "npc_dota_hero_shadow_demon", chinese = "暗影恶魔", id = 79, model = "shadow_demon"},
    {particleName = "shadow_shaman", soundName = "shadowshaman", name = "npc_dota_hero_shadow_shaman", chinese = "暗影萨满", id = 27, model = "shadowshaman"},
    {particleName = "silencer", soundName = "silencer", name = "npc_dota_hero_silencer", chinese = "沉默术士", id = 75, model = "silencer"},
    {particleName = "skywrath_mage", soundName = "skywrath_mage", name = "npc_dota_hero_skywrath_mage", chinese = "天怒法师", id = 101, model = "skywrath_mage"},
    {particleName = "storm_spirit", soundName = "stormspirit", name = "npc_dota_hero_storm_spirit", chinese = "风暴之灵", id = 17, model = "storm_spirit"},
    {particleName = "tinker", soundName = "tinker", name = "npc_dota_hero_tinker", chinese = "修补匠", id = 34, model = "tinker"},
    {particleName = "warlock", soundName = "warlock", name = "npc_dota_hero_warlock", chinese = "术士", id = 37, model = "warlock"},
    {particleName = "witch_doctor", soundName = "witchdoctor", name = "npc_dota_hero_witch_doctor", chinese = "巫医", id = 30, model = "witchdoctor"},
    {particleName = "zuus", soundName = "zuus", name = "npc_dota_hero_zuus", chinese = "宙斯", id = 22, model = "zeus"},
    {particleName = "ringmaster", soundName = "ringmaster", name = "npc_dota_hero_ringmaster", chinese = "驯兽师", id = 131, model = "ringmaster"},
    
    {particleName = "abaddon", soundName = "abaddon", name = "npc_dota_hero_abaddon", chinese = "亚巴顿", id = 102, model = "abaddon"},
    {particleName = "bane", soundName = "bane", name = "npc_dota_hero_bane", chinese = "祸乱之源", id = 3, model = "bane"},
    {particleName = "batrider", soundName = "batrider", name = "npc_dota_hero_batrider", chinese = "蝙蝠骑士", id = 65, model = "batrider"},
    {particleName = "beastmaster", soundName = "beastmaster", name = "npc_dota_hero_beastmaster", chinese = "兽王", id = 38, model = "beastmaster"},
    {particleName = "brewmaster", soundName = "brewmaster", name = "npc_dota_hero_brewmaster", chinese = "酒仙", id = 78, model = "brewmaster"},
    {particleName = "broodmother", soundName = "broodmother", name = "npc_dota_hero_broodmother", chinese = "育母蜘蛛", id = 61, model = "broodmother"},
    {particleName = "chen", soundName = "chen", name = "npc_dota_hero_chen", chinese = "陈", id = 66, model = "chen"},
    {particleName = "rattletrap", soundName = "rattletrap", name = "npc_dota_hero_rattletrap", chinese = "发条技师", id = 51, model = "rattletrap"},
    {particleName = "dark_seer", soundName = "dark_seer", name = "npc_dota_hero_dark_seer", chinese = "黑暗贤者", id = 55, model = "dark_seer"},
    {particleName = "dark_willow", soundName = "dark_willow", name = "npc_dota_hero_dark_willow", chinese = "邪影芳灵", id = 119, model = "dark_willow"},
    {particleName = "dazzle", soundName = "dazzle", name = "npc_dota_hero_dazzle", chinese = "戴泽", id = 50, model = "dazzle"},
    {particleName = "enigma", soundName = "enigma", name = "npc_dota_hero_enigma", chinese = "谜团", id = 33, model = "enigma"},
    {particleName = "wisp", soundName = "wisp", name = "npc_dota_hero_wisp", chinese = "艾欧", id = 91, model = "wisp"},
    {particleName = "invoker", soundName = "invoker", name = "npc_dota_hero_invoker", chinese = "祈求者", id = 74, model = "invoker"},
    {particleName = "lone_druid", soundName = "lone_druid", name = "npc_dota_hero_lone_druid", chinese = "德鲁伊", id = 80, model = "lone_druid"},
    {particleName = "lycan", soundName = "lycan", name = "npc_dota_hero_lycan", chinese = "狼人", id = 77, model = "lycan"},
    {particleName = "magnataur", soundName = "magnataur", name = "npc_dota_hero_magnataur", chinese = "马格纳斯", id = 97, model = "magnataur"},
    {particleName = "marci", soundName = "marci", name = "npc_dota_hero_marci", chinese = "玛西", id = 136, model = "marci"},
    {particleName = "mirana", soundName = "mirana", name = "npc_dota_hero_mirana", chinese = "米拉娜", id = 9, model = "mirana"},
    {particleName = "nyx_assassin", soundName = "nyx_assassin", name = "npc_dota_hero_nyx_assassin", chinese = "司夜刺客", id = 88, model = "nerubian_assassin"},
    {particleName = "pangolier", soundName = "pangolier", name = "npc_dota_hero_pangolier", chinese = "石鳞剑士", id = 120, model = "pangolier"},
    {particleName = "phoenix", soundName = "phoenix", name = "npc_dota_hero_phoenix", chinese = "凤凰", id = 110, model = "phoenix"},
    {particleName = "sand_king", soundName = "sandking", name = "npc_dota_hero_sand_king", chinese = "沙王", id = 16, model = "sand_king"},
    {particleName = "snapfire", soundName = "snapfire", name = "npc_dota_hero_snapfire", chinese = "电炎绝手", id = 128, model = "snapfire"},
    {particleName = "techies", soundName = "techies", name = "npc_dota_hero_techies", chinese = "工程师", id = 105, model = "techies"},
    {particleName = "vengefulspirit", soundName = "vengefulspirit", name = "npc_dota_hero_vengefulspirit", chinese = "复仇之魂", id = 20, model = "vengeful"},
    {particleName = "venomancer", soundName = "venomancer", name = "npc_dota_hero_venomancer", chinese = "剧毒术士", id = 40, model = "venomancer"},
    {particleName = "visage", soundName = "visage", name = "npc_dota_hero_visage", chinese = "维萨吉", id = 92, model = "visage"},
    {particleName = "void_spirit", soundName = "void_spirit", name = "npc_dota_hero_void_spirit", chinese = "虚无之灵", id = 126, model = "void_spirit"},
    {particleName = "windrunner", soundName = "windrunner", name = "npc_dota_hero_windrunner", chinese = "风行者", id = 21, model = "windrunner"},
    {particleName = "winter_wyvern", soundName = "winter_wyvern", name = "npc_dota_hero_winter_wyvern", chinese = "寒冬飞龙", id = 112, model = "winterwyvern"},
    -- {particleName = "target_dummy", soundName = "target_dummy", name = "npc_dota_hero_target_dummy", chinese = "傀儡目标", id = 999, model = "target_dummy"},
}

function GetHeroTypeFromAttribute(attribute)
    local attributeTypes = {
        ["DOTA_ATTRIBUTE_STRENGTH"] = 1,
        ["DOTA_ATTRIBUTE_AGILITY"] = 2,
        ["DOTA_ATTRIBUTE_INTELLECT"] = 4,
        ["DOTA_ATTRIBUTE_ALL"] = 8
    }
    return attributeTypes[attribute] or 8
end

-- 只更新type值
for _, hero in ipairs(heroes_precache) do
    local heroData = Main.heroListKV[hero.name]
    if heroData then
        local attributePrimary = heroData["AttributePrimary"]
        hero.type = GetHeroTypeFromAttribute(attributePrimary)
        
        -- -- 打印更新结果
        -- print(string.format("英雄: %s, 中文名: %s, 主属性: %s, Type值: %d", 
        --     hero.name, 
        --     hero.chinese, 
        --     attributePrimary or "未知", 
        --     hero.type
        -- ))
    end
end

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
                ["Deprecated"] = "true",
                ["name"] = "crystal_maiden_frozen_expanse",
            },
            [2] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["Deprecated"] = "true",
                ["name"] = "crystal_maiden_cold_comfort",
            },
            [3] = {
                ["Icon"] = "armor",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "crystal_maiden_glacial_guard",
            },
            [4] = {
                ["Icon"] = "mana",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "crystal_maiden_arcane_overflow",
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
                ["Deprecated"] = "true",
                ["name"] = "mirana_moonlight",
                ["AbilityName"] = "mirana_invis",
            },
            [2] = {
                ["Icon"] = "sun",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "mirana_sunlight",
                ["AbilityName"] = "mirana_solar_flare",
            },
            [3] = {
                ["Icon"] = "no_vision",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "mirana_starstruck",
            },
            [4] = {
                ["Icon"] = "slow",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["name"] = "mirana_leaps_and_bounds",
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
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "phantom_lancer_convergence",
            },
            [2] = {
                ["Icon"] = "summons",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "phantom_lancer_divergence",
            },
            [3] = {
                ["Icon"] = "phantom_lance",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "phantom_lancer_lancelot",
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
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "pudge_fresh_meat",
            },
            [2] = {
                ["Icon"] = "pudge_hook",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "pudge_flayers_hook",
            },
            [3] = {
                ["Icon"] = "fist",
                ["Color"] = "Green",
                ["GradientID"] = "3",
                ["name"] = "pudge_rotten_core",
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
                ["Deprecated"] = "true",
                ["name"] = "windrunner_focusfire",
            },
            [3] = {
                ["Icon"] = "multi_arrow",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["AbilityIconReplacements"] = {
                    ["windrunner_focusfire"] = "windrunner_whirlwind",
                    ["windrunner_focusfire_cancel"] = "windrunner_whirlwind_stop",
                },
                ["name"] = "windrunner_whirlwind",
            },
            [4] = {
                ["Icon"] = "tree",
                ["Color"] = "Yellow",
                ["GradientID"] = "2",
                ["name"] = "windrunner_tangled",
            },
            [5] = {
                ["Icon"] = "execute",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "windrunner_killshot",
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
                ["Deprecated"] = "true",
                ["name"] = "shadow_shaman_cluster_cluck",
            },
            [2] = {
                ["Icon"] = "chicken",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "shadow_shaman_voodoo_hands",
                ["AbilityName"] = "shadow_shaman_voodoo_hands",
            },
            [3] = {
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
                ["Deprecated"] = "1",
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
                ["Deprecated"] = "true",
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
            [3] = {
                ["Icon"] = "twin_hearts",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "queenofpain_facet_bondage",
                ["AbilityName"] = "queenofpain_bondage",
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
                ["Deprecated"] = "true",
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
                ["Deprecated"] = "1",
                ["name"] = "phantom_assassin_veiled_one",
            },
            [2] = {
                ["Icon"] = "skull",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "phantom_assassin_methodical",
            },
            [3] = {
                ["Icon"] = "phantom_ass_dagger",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "phantom_assassin_sweet_release",
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
            [3] = {
                ["Icon"] = "range",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "templar_assassin_hidden_reach",
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
                ["Deprecated"] = "true",
                ["name"] = "life_stealer_rage",
                ["AbilityName"] = "life_stealer_rage",
            },
            [3] = {
                ["Icon"] = "broken_chain",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "life_stealer_rage_dispell",
                ["AbilityName"] = "life_stealer_unfettered",
            },
            [4] = {
                ["Icon"] = "full_heart",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "life_stealer_fleshfeast",
            },
            [5] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "life_stealer_gorestorm",
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
                ["Deprecated"] = "1",
                ["name"] = "huskar_bloodbath",
            },
            [2] = {
                ["Icon"] = "healing",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["Deprecated"] = "1",
                ["name"] = "huskar_nothl_transfusion",
            },
            [3] = {
                ["Icon"] = "broken_chain",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "huskar_cauterize",
            },
            [4] = {
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
                ["Deprecated"] = "True",
                ["name"] = "night_stalker_blinding_void",
            },
            [2] = {
                ["Icon"] = "moon",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "night_stalker_dayswap",
                ["AbilityName"] = "night_stalker_night_reign",
            },
            [3] = {
                ["Icon"] = "area_of_effect",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["MaxHeroAttributeLevel"] = "6",
                ["name"] = "night_stalker_voidbringer",
            },
        },
    },
    ["npc_dota_hero_broodmother"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "web",
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
                ["Deprecated"] = "true",
                ["name"] = "jakiro_fire",
                ["AbilityName"] = "jakiro_liquid_fire",
            },
            [2] = {
                ["Icon"] = "snowflake",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["Deprecated"] = "true",
                ["name"] = "jakiro_ice",
                ["AbilityName"] = "jakiro_liquid_ice",
            },
            [3] = {
                ["Icon"] = "damage",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "jakiro_twin_terror",
            },
            [4] = {
                ["Icon"] = "snowflake",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "jakiro_ice_breaker",
                ["AbilityName"] = "jakiro_ice_path_detonate",
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
                ["Color"] = "Yellow",
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
                ["Deprecated"] = "true",
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
            [6] = {
                ["Icon"] = "bubbles",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["AbilityIconReplacements"] = {
                    ["chen_summon_convert"] = "chen_summon_convert_frog",
                },
                ["name"] = "chen_frog_convert",
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
                ["Deprecated"] = "true",
                ["name"] = "spirit_breaker_imbalanced",
            },
            [3] = {
                ["Icon"] = "rng",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "spirit_breaker_bulls_hit",
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
            [3] = {
                ["Icon"] = "aghs",
                ["Color"] = "Green",
                ["GradientID"] = "2",
                ["name"] = "alchemist_dividends",
            },
        },
    },
    ["npc_dota_hero_invoker"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "invoker_passive",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "invoker_agnostic",
            },
            [2] = {
                ["Icon"] = "invoker_active",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "invoker_elitist",
            },
            [3] = {
                ["Icon"] = "invoker_quas",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "invoker_quas_focus",
            },
            [4] = {
                ["Icon"] = "invoker_wex",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "invoker_wex_focus",
            },
            [5] = {
                ["Icon"] = "invoker_exort",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "invoker_exort_focus",
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
                ["Deprecated"] = "1",
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
                ["Deprecated"] = "1",
                ["name"] = "chaos_knight_strong_illusions",
                ["AbilityName"] = "chaos_knight_phantasmagoria",
            },
            [2] = {
                ["Icon"] = "rng",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["name"] = "chaos_knight_irrationality",
            },
            [3] = {
                ["Icon"] = "item",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "chaos_knight_facet_fundamental_forging",
                ["AbilityName"] = "chaos_knight_fundamental_forging",
            },
            [4] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "chaos_knight_cloven_chaos",
            },
        },
    },
    ["npc_dota_hero_meepo"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "summons",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["MaxHeroAttributeLevel"] = "6",
                ["name"] = "meepo_more_meepo",
            },
            [2] = {
                ["Icon"] = "illusion",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "meepo_codependent",
            },
            [3] = {
                ["Icon"] = "item",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["Deprecated"] = "1",
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
            [4] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "medusa_undulation",
                ["AbilityName"] = "medusa_undulation",
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
                ["Deprecated"] = "true",
                ["name"] = "magnataur_reverse_polarity",
            },
            [3] = {
                ["Icon"] = "empower",
                ["Color"] = "Gray",
                ["GradientID"] = "1",
                ["name"] = "magnataur_eternal_empowerment",
            },
            [4] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["MaxHeroAttributeLevel"] = "6",
                ["name"] = "magnataur_diminishing_return",
            },
            [5] = {
                ["Icon"] = "vortex_out",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
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
                ["Deprecated"] = "true",
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
                ["Deprecated"] = "True",
                ["name"] = "winter_wyvern_heal_mana",
                ["AbilityName"] = "winter_wyvern_essence_of_the_blueheart",
            },
            [2] = {
                ["Icon"] = "damage",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "True",
                ["name"] = "winter_wyvern_atk_range",
                ["AbilityName"] = "winter_wyvern_dragon_sight",
            },
            [3] = {
                ["Icon"] = "tower",
                ["Color"] = "Blue",
                ["GradientID"] = "2",
                ["name"] = "winter_wyvern_winterproof",
            },
            [4] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Blue",
                ["GradientID"] = "0",
                ["name"] = "winter_wyvern_recursive",
            },
        },
    },
    ["npc_dota_hero_arc_warden"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "arc_warden",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "arc_warden_order",
            },
            [2] = {
                ["Icon"] = "arc_warden_alt",
                ["Color"] = "Gray",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "arc_warden_disorder",
            },
            [3] = {
                ["Icon"] = "arc_warden_alt",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "arc_warden_runed_replica",
            },
            [4] = {
                ["Icon"] = "rune",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "arc_warden_power_capture",
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
                ["MaxHeroAttributeLevel"] = "6",
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
                ["Deprecated"] = "true",
                ["name"] = "dark_willow_thorny_thicket",
            },
            [3] = {
                ["Icon"] = "barrier",
                ["Color"] = "Green",
                ["GradientID"] = "4",
                ["name"] = "dark_willow_shattering_crown",
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
                ["Deprecated"] = "true",
                ["name"] = "hoodwink_treebounce_trickshot",
            },
            [3] = {
                ["Icon"] = "cooldown",
                ["Color"] = "Green",
                ["GradientID"] = "0",
                ["name"] = "hoodwink_hipshot",
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
                ["Deprecated"] = "true",
                ["name"] = "dawnbreaker_gleaming_hammer",
            },
            [3] = {
                ["Icon"] = "fist",
                ["Color"] = "Red",
                ["GradientID"] = "1",
                ["name"] = "dawnbreaker_blaze",
            },
            [4] = {
                ["Icon"] = "Speed",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "dawnbreaker_hearthfire",
            },
        },
    },
    ["npc_dota_hero_marci"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "healing",
                ["Color"] = "Gray",
                ["GradientID"] = "3",
                ["Deprecated"] = "true",
                ["name"] = "marci_sidekick",
                ["AbilityName"] = "marci_guardian",
            },
            [2] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["Deprecated"] = "true",
                ["name"] = "marci_bodyguard",
                ["AbilityName"] = "marci_bodyguard",
            },
            [3] = {
                ["Icon"] = "twin_hearts",
                ["Color"] = "Blue",
                ["GradientID"] = "1",
                ["name"] = "marci_buddy_system",
            },
            [4] = {
                ["Icon"] = "ricochet",
                ["Color"] = "Purple",
                ["GradientID"] = "0",
                ["name"] = "marci_pickmeup",
            },
            [5] = {
                ["Icon"] = "fist",
                ["Color"] = "Yellow",
                ["GradientID"] = "0",
                ["name"] = "marci_fleeting_fury",
            },
        },
    },
    ["npc_dota_hero_primal_beast"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "speed",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["Deprecated"] = "true",
                ["name"] = "primal_beast_romp_n_stomp",
            },
            [2] = {
                ["Icon"] = "broken_chain",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "primal_beast_provoke_the_beast",
            },
            [3] = {
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
                ["Deprecated"] = "true",
                ["name"] = "ringmaster_default",
            },
            [2] = {
                ["Icon"] = "whoopee_cushion",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "ringmaster_carny_classics",
                ["AbilityName"] = "ringmaster_funhouse_mirror",
            },
            [3] = {
                ["Icon"] = "pie",
                ["Color"] = "Red",
                ["GradientID"] = "0",
                ["name"] = "ringmaster_sideshow_secrets",
                ["AbilityName"] = "ringmaster_crystal_ball",
            },
        },
    },
    ["npc_dota_hero_kez"] = {
        ["Facets"] = {
            [1] = {
                ["Icon"] = "kez_flutter",
                ["Color"] = "Yellow",
                ["GradientID"] = "1",
                ["name"] = "kez_flutter",
            },
            [2] = {
                ["Icon"] = "kez_shadowhawk",
                ["Color"] = "Blue",
                ["GradientID"] = "3",
                ["name"] = "kez_shadowhawk_passive",
                ["AbilityName"] = "kez_shadowhawk_passive",
            },
        },
    },
}

neutral_units = {
    [1] = "npc_dota_neutral_kobold",
    [2] = "npc_dota_neutral_kobold_tunneler", 
    [3] = "npc_dota_neutral_kobold_taskmaster",
    [4] = "npc_dota_neutral_centaur_outrunner",
    [5] = "npc_dota_neutral_centaur_khan",
    [6] = "npc_dota_neutral_fel_beast",
    [7] = "npc_dota_neutral_polar_furbolg_champion",
    [8] = "npc_dota_neutral_polar_furbolg_ursa_warrior",
    [9] = "npc_dota_neutral_warpine_raider",
    [10] = "npc_dota_neutral_mud_golem",
    [11] = "npc_dota_neutral_mud_golem_split",
    [12] = "npc_dota_neutral_ogre_mauler",
    [13] = "npc_dota_neutral_ogre_magi",
    [14] = "npc_dota_neutral_giant_wolf",
    [15] = "npc_dota_neutral_alpha_wolf",
    [16] = "npc_dota_neutral_wildkin",
    [17] = "npc_dota_neutral_enraged_wildkin",
    [18] = "npc_dota_neutral_satyr_soulstealer",
    [19] = "npc_dota_neutral_satyr_hellcaller",
    [20] = "npc_dota_neutral_prowler_acolyte",
    [21] = "npc_dota_neutral_prowler_shaman",
    [22] = "npc_dota_neutral_rock_golem",
    [23] = "npc_dota_neutral_granite_golem",
    [24] = "npc_dota_neutral_ice_shaman",
    [25] = "npc_dota_neutral_frostbitten_golem",
    [26] = "npc_dota_neutral_big_thunder_lizard",
    [27] = "npc_dota_neutral_small_thunder_lizard",
    [28] = "npc_dota_neutral_gnoll_assassin",
    [29] = "npc_dota_neutral_ghost",
    [30] = "npc_dota_neutral_dark_troll",
    [31] = "npc_dota_neutral_dark_troll_warlord",
    [32] = "npc_dota_neutral_satyr_trickster",
    [33] = "npc_dota_neutral_forest_troll_berserker",
    [34] = "npc_dota_neutral_forest_troll_high_priest",
    [35] = "npc_dota_neutral_harpy_scout",
    [36] = "npc_dota_neutral_harpy_storm",
    [37] = "npc_dota_neutral_black_drake",
    [38] = "npc_dota_neutral_black_dragon",
    [39] = "npc_dota_neutral_tadpole",
    [40] = "npc_dota_neutral_froglet",
    [41] = "npc_dota_neutral_grown_frog",
    [42] = "npc_dota_neutral_ancient_frog",
    [43] = "npc_dota_neutral_froglet_mage",
    [44] = "npc_dota_neutral_grown_frog_mage",
    [45] = "npc_dota_neutral_ancient_frog_mage"
}