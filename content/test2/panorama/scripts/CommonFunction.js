function toggleVisibility(panel) {
    if (panel) {
        if (panel.id === "BattleScorePanel1" || panel.id === "BattleScorePanel2") {
            // 处理 BattleScorePanel
            var otherPanelId = panel.id === "BattleScorePanel1" ? "BattleScorePanel2" : "BattleScorePanel1";
            var otherPanel = $("#" + otherPanelId);
            
            // 隐藏另一个面板
            if (otherPanel) {
                otherPanel.style.visibility = "collapse";
                $.Msg(otherPanelId + " collapsed");
            }
            
            // 切换当前面板的可见性
            if (panel.style.visibility === "visible") {
                panel.style.visibility = "collapse";
                $.Msg(panel.id + " collapsed");
            } else {
                panel.style.visibility = "visible";
                $.Msg(panel.id + " visible");
            }
        } else {
            // 处理其他面板
            if (panel.style.visibility === "visible") {
                panel.style.visibility = "collapse";
                $.Msg(panel.id + " collapsed");
            } else {
                panel.style.visibility = "visible";
                $.Msg(panel.id + " visible");
            }
        }
    } else {
        $.Msg("Panel not found for visibility toggle");
    }
}



(function() {
    
    GameEvents.Subscribe("Init_ToolsMode", function(data) {
        var isToolsMode = data.isToolsMode;
        var mainButtonContainer = $("#MainButtonContainer");
        $.Msg("正在设置显示...");
        
        if (isToolsMode) {
            // 如果是工具模式，添加hidden类
            mainButtonContainer.AddClass("hidden");
            $.Msg("工具模式：添加hidden类");
        } else {
            // 如果不是工具模式，不做任何操作
            $.Msg("非工具模式：保持原样");
        }
    });
})();


var heroData = {
    1:   { name: "敌法师",    englishName: "Anti-Mage",           codeName: "antimage",         facingRight: true,  heightAdjust: 5,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    2:   { name: "斧王",      englishName: "Axe",                 codeName: "axe",              facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 20,  avatarFacingRight: true },
    3:   { name: "祸乱之源",  englishName: "Bane",                codeName: "bane",             facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    4:   { name: "血魔",      englishName: "Bloodseeker",        codeName: "bloodseeker",      facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    5:   { name: "水晶室女",  englishName: "Crystal Maiden",     codeName: "crystal_maiden",   facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 50, avatarFacingRight: true },
    6:   { name: "卓尔游侠",  englishName: "Drow Ranger",        codeName: "drow_ranger",      facingRight: true,  heightAdjust: 5,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    7:   { name: "撼地者",    englishName: "Earthshaker",        codeName: "earthshaker",      facingRight: true,  heightAdjust: 0,  heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    8:   { name: "主宰",      englishName: "Juggernaut",         codeName: "juggernaut",       facingRight: true,  heightAdjust: 5,  heroAttribute: 2,  avatarAdjust: 20, avatarFacingRight: false },
    9:   { name: "米拉娜",    englishName: "Mirana",             codeName: "mirana",           facingRight: true,  heightAdjust: 5,  heroAttribute: 8,  avatarAdjust: 40, avatarFacingRight: true },
    10:  { name: "变体精灵",  englishName: "Morphling",          codeName: "morphling",        facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 10, avatarFacingRight: true },
    11:  { name: "影魔",      englishName: "Shadow Fiend",       codeName: "nevermore",        facingRight: true,  heightAdjust: 10, heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    12:  { name: "幻影长矛手",englishName: "Phantom Lancer",     codeName: "phantom_lancer",   facingRight: true,  heightAdjust: 5,  heroAttribute: 2,  avatarAdjust: 25, avatarFacingRight: false },
    13:  { name: "帕克",      englishName: "Puck",               codeName: "puck",             facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    14:  { name: "帕吉",      englishName: "Pudge",              codeName: "pudge",            facingRight: true,  heightAdjust: 0,  heroAttribute: 1,  avatarAdjust: 20,  avatarFacingRight: false },
    15:  { name: "雷泽",      englishName: "Razor",              codeName: "razor",            facingRight: true,  heightAdjust: 10, heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    16:  { name: "沙王",      englishName: "Sand King",          codeName: "sand_king",        facingRight: true,  heightAdjust: -10,heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    17:  { name: "风暴之灵",  englishName: "Storm Spirit",       codeName: "storm_spirit",     facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 10, avatarFacingRight: true },
    18:  { name: "斯温",      englishName: "Sven",               codeName: "sven",             facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 50,  avatarFacingRight: false },
    19:  { name: "小小",      englishName: "Tiny",               codeName: "tiny",             facingRight: true,  heightAdjust: 0,  heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    20:  { name: "复仇之魂",  englishName: "Vengeful Spirit",    codeName: "vengefulspirit",   facingRight: true,  heightAdjust: 10,  heroAttribute: 8,  avatarAdjust: 20,  avatarFacingRight: true },
    21:  { name: "风行者",    englishName: "Windranger",         codeName: "windrunner",       facingRight: true,  heightAdjust: 5,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    22:  { name: "宙斯",      englishName: "Zeus",               codeName: "zuus",             facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    23:  { name: "昆卡",      englishName: "Kunkka",             codeName: "kunkka",           facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 30,  avatarFacingRight: true },
    24:  { name: "unknown",   englishName: "Unknown",            codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0,  avatarAdjust: 0, avatarFacingRight: true },
    25:  { name: "莉娜",      englishName: "Lina",               codeName: "lina",             facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 50, avatarFacingRight: true },
    26:  { name: "莱恩",      englishName: "Lion",               codeName: "lion",             facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    27:  { name: "暗影萨满",  englishName: "Shadow Shaman",      codeName: "shadow_shaman",    facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 20, avatarFacingRight: true },
    28:  { name: "斯拉达",    englishName: "Slardar",            codeName: "slardar",          facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    29:  { name: "潮汐猎人",  englishName: "Tidehunter",         codeName: "tidehunter",       facingRight: true,  heightAdjust: 0,  heroAttribute: 1,  avatarAdjust: 40,  avatarFacingRight: true },
    30:  { name: "巫医",      englishName: "Witch Doctor",       codeName: "witch_doctor",     facingRight: true,  heightAdjust: -10,heroAttribute: 4,  avatarAdjust: 20,  avatarFacingRight: true },
    31:  { name: "巫妖",      englishName: "Lich",               codeName: "lich",             facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 40,  avatarFacingRight: true },
    32:  { name: "力丸",      englishName: "Riki",               codeName: "riki",             facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    33:  { name: "谜团",      englishName: "Enigma",             codeName: "enigma",           facingRight: true,  heightAdjust: 5,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    34:  { name: "修补匠",    englishName: "Tinker",             codeName: "tinker",           facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    35:  { name: "狙击手",    englishName: "Sniper",             codeName: "sniper",           facingRight: true,  heightAdjust: 10, heroAttribute: 2,  avatarAdjust: 30,  avatarFacingRight: true },
    36:  { name: "瘟疫法师",  englishName: "Necrophos",          codeName: "necrolyte",        facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 20,  avatarFacingRight: true },
    37:  { name: "术士",      englishName: "Warlock",            codeName: "warlock",          facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 20, avatarFacingRight: true },
    38:  { name: "兽王",      englishName: "Beastmaster",        codeName: "beastmaster",      facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 20,  avatarFacingRight: true },
    39:  { name: "痛苦女王",  englishName: "Queen of Pain",      codeName: "queenofpain",      facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    40:  { name: "剧毒术士",  englishName: "Venomancer",         codeName: "venomancer",       facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    41:  { name: "虚空假面",  englishName: "Faceless Void",      codeName: "faceless_void",    facingRight: true,  heightAdjust: 5,  heroAttribute: 2,  avatarAdjust: 20, avatarFacingRight: true },
    42:  { name: "冥魂大帝",  englishName: "Wraith King",        codeName: "skeleton_king",    facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    43:  { name: "死亡先知",  englishName: "Death Prophet",      codeName: "death_prophet",    facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 30, avatarFacingRight: true },
    44:  { name: "幻影刺客",  englishName: "Phantom Assassin",   codeName: "phantom_assassin", facingRight: true,  heightAdjust: 5,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    45:  { name: "帕格纳",    englishName: "Pugna",              codeName: "pugna",            facingRight: true,  heightAdjust: 0,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    46:  { name: "圣堂刺客",  englishName: "Templar Assassin",   codeName: "templar_assassin", facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 20, avatarFacingRight: true },
    47:  { name: "冥界亚龙",  englishName: "Viper",              codeName: "viper",            facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: -20,  avatarFacingRight: true },
    48:  { name: "露娜",      englishName: "Luna",               codeName: "luna",             facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    49:  { name: "龙骑士",    englishName: "Dragon Knight",      codeName: "dragon_knight",    facingRight: true,  heightAdjust: 10, heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    50:  { name: "戴泽",      englishName: "Dazzle",             codeName: "dazzle",           facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    51:  { name: "发条技师",  englishName: "Clockwerk",          codeName: "rattletrap",       facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 30,  avatarFacingRight: true },
    52:  { name: "拉席克",    englishName: "Leshrac",            codeName: "leshrac",          facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 20,  avatarFacingRight: true },
    53:  { name: "自然先知",  englishName: "Nature's Prophet",   codeName: "furion",           facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    54:  { name: "噬魂鬼",    englishName: "Lifestealer",        codeName: "life_stealer",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1,  avatarAdjust: 60, avatarFacingRight: true },
    55:  { name: "黑暗贤者",  englishName: "Dark Seer",          codeName: "dark_seer",        facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    56:  { name: "克林克兹",  englishName: "Clinkz",             codeName: "clinkz",           facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    57:  { name: "全能骑士",  englishName: "Omniknight",         codeName: "omniknight",       facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 60,  avatarFacingRight: true },
    58:  { name: "魅惑魔女",  englishName: "Enchantress",        codeName: "enchantress",      facingRight: true,  heightAdjust: 5,  heroAttribute: 4,  avatarAdjust: 0,  avatarFacingRight: true },
    59:  { name: "哈斯卡",    englishName: "Huskar",             codeName: "huskar",           facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    60:  { name: "暗夜魔王",  englishName: "Night Stalker",      codeName: "night_stalker",    facingRight: true,  heightAdjust: 5,  heroAttribute: 1,  avatarAdjust: 0,  avatarFacingRight: true },
    61:  { name: "育母蜘蛛",  englishName: "Broodmother",        codeName: "broodmother",      facingRight: true,  heightAdjust: 0,  heroAttribute: 8,  avatarAdjust: 0,  avatarFacingRight: true },
    62:  { name: "赏金猎人",  englishName: "Bounty Hunter",      codeName: "bounty_hunter",    facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    63:  { name: "编织者",    englishName: "Weaver",             codeName: "weaver",           facingRight: true,  heightAdjust: 0,  heroAttribute: 2,  avatarAdjust: 0,  avatarFacingRight: true },
    64:  { name: "杰奇洛",     englishName: "Jakiro",              codeName: "jakiro",             facingRight: true,  heightAdjust:  0, heroAttribute: 4, avatarAdjust:  0, avatarFacingRight: true },
    65:  { name: "蝙蝠骑士",   englishName: "Batrider",            codeName: "batrider",           facingRight: true,  heightAdjust:  5, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    66:  { name: "陈",         englishName: "Chen",                codeName: "chen",               facingRight: true,  heightAdjust:  5, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    67:  { name: "幽鬼",       englishName: "Spectre",             codeName: "spectre",            facingRight: true,  heightAdjust:  5, heroAttribute: 2, avatarAdjust:  20, avatarFacingRight: true },
    68:  { name: "远古冰魄",   englishName: "Ancient Apparition",  codeName: "ancient_apparition", facingRight: true,  heightAdjust:  5, heroAttribute: 4, avatarAdjust:  30, avatarFacingRight: true },
    69:  { name: "末日使者",   englishName: "Doom",                codeName: "doom_bringer",       facingRight: true,  heightAdjust: 10, heroAttribute: 1, avatarAdjust:  30, avatarFacingRight: true },
    70:  { name: "熊战士",     englishName: "Ursa",                codeName: "ursa",               facingRight: true,  heightAdjust:  5, heroAttribute: 2, avatarAdjust:  0, avatarFacingRight: false },
    71:  { name: "裂魂人",     englishName: "Spirit Breaker",      codeName: "spirit_breaker",     facingRight: true,  heightAdjust: -5, heroAttribute: 1, avatarAdjust:  20, avatarFacingRight: true },
    72:  { name: "矮人直升机", englishName: "Gyrocopter",          codeName: "gyrocopter",         facingRight: true,  heightAdjust:  0, heroAttribute: 2, avatarAdjust:  0, avatarFacingRight: true },
    73:  { name: "炼金术士",   englishName: "Alchemist",           codeName: "alchemist",          facingRight: true,  heightAdjust: 10, heroAttribute: 1, avatarAdjust:  0, avatarFacingRight: true },
    74:  { name: "祈求者",     englishName: "Invoker",             codeName: "invoker",            facingRight: true,  heightAdjust:  5, heroAttribute: 8, avatarAdjust: 40, avatarFacingRight: true },
    75:  { name: "沉默术士",   englishName: "Silencer",            codeName: "silencer",           facingRight: true,  heightAdjust: 10, heroAttribute: 4, avatarAdjust: 10, avatarFacingRight: true },
    76:  { name: "殁境神蚀者", englishName: "Outworld Devourer",   codeName: "obsidian_destroyer", facingRight: true,  heightAdjust:  5, heroAttribute: 4, avatarAdjust: 20, avatarFacingRight: true },
    77:  { name: "狼人",       englishName: "Lycan",               codeName: "lycan",              facingRight: true,  heightAdjust:  0, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    78:  { name: "酒仙",       englishName: "Brewmaster",          codeName: "brewmaster",         facingRight: true,  heightAdjust:  5, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    79:  { name: "暗影恶魔",   englishName: "Shadow Demon",        codeName: "shadow_demon",       facingRight: true,  heightAdjust: 10, heroAttribute: 4, avatarAdjust:  0, avatarFacingRight: true },
    80:  { name: "独行德鲁伊", englishName: "Lone Druid",          codeName: "lone_druid",         facingRight: true,  heightAdjust:  0, heroAttribute: 8, avatarAdjust:  40, avatarFacingRight: true },
    81:  { name: "混沌骑士",   englishName: "Chaos Knight",        codeName: "chaos_knight",       facingRight: true,  heightAdjust:  5, heroAttribute: 1, avatarAdjust: 25, avatarFacingRight: true },
    82:  { name: "米波",       englishName: "Meepo",               codeName: "meepo",              facingRight: true,  heightAdjust: -8, heroAttribute: 2, avatarAdjust:  0, avatarFacingRight: true },
    83:  { name: "树精卫士",   englishName: "Treant Protector",    codeName: "treant",             facingRight: true,  heightAdjust: 10, heroAttribute: 1, avatarAdjust:  40, avatarFacingRight: true },
    84:  { name: "食人魔魔法师", englishName: "Ogre Magi",         codeName: "ogre_magi",          facingRight: true,  heightAdjust:  8, heroAttribute: 1, avatarAdjust: 45, avatarFacingRight: true },
    85:  { name: "不朽尸王",   englishName: "Undying",             codeName: "undying",            facingRight: true,  heightAdjust:  5, heroAttribute: 1, avatarAdjust: 20, avatarFacingRight: true },
    86:  { name: "拉比克",     englishName: "Rubick",              codeName: "rubick",             facingRight: true,  heightAdjust:  5, heroAttribute: 4, avatarAdjust:  20, avatarFacingRight: false },
    87:  { name: "干扰者",     englishName: "Disruptor",           codeName: "disruptor",          facingRight: true,  heightAdjust: 10, heroAttribute: 4, avatarAdjust:  0, avatarFacingRight: true },
    88:  { name: "司夜刺客",   englishName: "Nyx Assassin",        codeName: "nyx_assassin",       facingRight: true,  heightAdjust:  0, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    89:  { name: "娜迦海妖",   englishName: "Naga Siren",          codeName: "naga_siren",         facingRight: true,  heightAdjust:  5, heroAttribute: 2, avatarAdjust:  0, avatarFacingRight: true },
    90:  { name: "光之守卫",   englishName: "Keeper of the Light", codeName: "keeper_of_the_light",facingRight: true,  heightAdjust:  5, heroAttribute: 4, avatarAdjust:  20, avatarFacingRight: true },
    91:  { name: "艾欧",       englishName: "Io",                  codeName: "wisp",               facingRight: true,  heightAdjust:  0, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    92:  { name: "维萨吉",     englishName: "Visage",              codeName: "visage",             facingRight: true,  heightAdjust:  5, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    93:  { name: "斯拉克",     englishName: "Slark",               codeName: "slark",              facingRight: true,  heightAdjust:  0, heroAttribute: 2, avatarAdjust:  0, avatarFacingRight: true },
    94:  { name: "美杜莎",     englishName: "Medusa",              codeName: "medusa",             facingRight: true,  heightAdjust:  5, heroAttribute: 2, avatarAdjust:  0, avatarFacingRight: true },
    95:  { name: "巨魔战将",   englishName: "Troll Warlord",       codeName: "troll_warlord",      facingRight: false, heightAdjust:  5, heroAttribute: 2, avatarAdjust:  -20, avatarFacingRight: true },
    96:  { name: "半人马战行者", englishName: "Centaur Warrunner", codeName: "centaur",            facingRight: true,  heightAdjust:  5, heroAttribute: 1, avatarAdjust:  30, avatarFacingRight: true },
    97:  { name: "马格纳斯",   englishName: "Magnus",              codeName: "magnataur",          facingRight: true,  heightAdjust:  5, heroAttribute: 8, avatarAdjust:  0, avatarFacingRight: true },
    98:  { name: "伐木机",     englishName: "Timbersaw",           codeName: "shredder",           facingRight: true,  heightAdjust:  5, heroAttribute: 1, avatarAdjust:  0, avatarFacingRight: true },
    99:  { name: "钢背兽",     englishName: "Bristleback",         codeName: "bristleback",        facingRight: true,  heightAdjust:  0, heroAttribute: 1, avatarAdjust: 35, avatarFacingRight: true },
    100: { name: "巨牙海民",       englishName: "Tusk",             codeName: "tusk",             facingRight: true,  heightAdjust: 5,  heroAttribute: 1, avatarAdjust: 0,  avatarFacingRight: true  },
    101: { name: "天怒法师",       englishName: "Skywrath Mage",    codeName: "skywrath_mage",    facingRight: true,  heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 0,  avatarFacingRight: true  },
    102: { name: "亚巴顿",         englishName: "Abaddon",          codeName: "abaddon",          facingRight: true,  heightAdjust: 5,  heroAttribute: 8, avatarAdjust: 30,  avatarFacingRight: true  },
    103: { name: "上古巨神",       englishName: "Elder Titan",      codeName: "elder_titan",      facingRight: false, heightAdjust: 5,  heroAttribute: 1, avatarAdjust: 20, avatarFacingRight: true  },
    104: { name: "军团指挥官",     englishName: "Legion Commander", codeName: "legion_commander", facingRight: true,  heightAdjust: 5,  heroAttribute: 1, avatarAdjust: 0,  avatarFacingRight: true  },
    105: { name: "工程师",         englishName: "Techies",          codeName: "techies",          facingRight: true,  heightAdjust: 10, heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: true  },
    106: { name: "灰烬之灵",       englishName: "Ember Spirit",     codeName: "ember_spirit",     facingRight: true,  heightAdjust: 5,  heroAttribute: 2, avatarAdjust: 40, avatarFacingRight: true },
    107: { name: "大地之灵",       englishName: "Earth Spirit",     codeName: "earth_spirit",     facingRight: true,  heightAdjust: 10, heroAttribute: 1, avatarAdjust: 50, avatarFacingRight: true  },
    108: { name: "孽主",           englishName: "Underlord",        codeName: "abyssal_underlord",facingRight: true,  heightAdjust: 10, heroAttribute: 1, avatarAdjust: 0,  avatarFacingRight: true  },
    109: { name: "恐怖利刃",       englishName: "Terrorblade",      codeName: "terrorblade",      facingRight: true,  heightAdjust: 5,  heroAttribute: 2, avatarAdjust: 0,  avatarFacingRight: true  },
    110: { name: "凤凰",           englishName: "Phoenix",          codeName: "phoenix",          facingRight: true,  heightAdjust: 5,  heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: true  },
    111: { name: "神谕者",         englishName: "Oracle",           codeName: "oracle",           facingRight: true,  heightAdjust: 10, heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    112: { name: "寒冬飞龙",       englishName: "Winter Wyvern",    codeName: "winter_wyvern",    facingRight: true,  heightAdjust: 5,  heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: true  },
    113: { name: "天穹守望者",     englishName: "Arc Warden",       codeName: "arc_warden",       facingRight: true,  heightAdjust: 5,  heroAttribute: 2, avatarAdjust: 20,  avatarFacingRight: true  },
    114: { name: "齐天大圣",       englishName: "Monkey King",      codeName: "monkey_king",      facingRight: true,  heightAdjust: 3,  heroAttribute: 2, avatarAdjust: 10, avatarFacingRight: true  },
    115: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    116: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    117: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    118: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    119: { name: "邪影芳灵",       englishName: "Dark Willow",      codeName: "dark_willow",      facingRight: true,  heightAdjust: 5,  heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: true  },
    120: { name: "石鳞剑士",       englishName: "Pangolier",        codeName: "pangolier",        facingRight: false, heightAdjust: 0,  heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: true  },
    121: { name: "天涯墨客",       englishName: "Grimstroke",       codeName: "grimstroke",       facingRight: true,  heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 0,  avatarFacingRight: true  },
    122: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    123: { name: "森海飞霞",       englishName: "Hoodwink",         codeName: "hoodwink",         facingRight: true,  heightAdjust: 0,  heroAttribute: 2, avatarAdjust: 0,  avatarFacingRight: true  },
    124: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    125: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    126: { name: "虚无之灵",       englishName: "Void Spirit",      codeName: "void_spirit",      facingRight: true,  heightAdjust: 10, heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: false },
    127: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    128: { name: "电炎绝手",       englishName: "Snapfire",         codeName: "snapfire",         facingRight: true,  heightAdjust: 10, heroAttribute: 8, avatarAdjust: 20,  avatarFacingRight: true  },
    129: { name: "玛尔斯",         englishName: "Mars",             codeName: "mars",             facingRight: true,  heightAdjust: 5,  heroAttribute: 1, avatarAdjust: 20,  avatarFacingRight: true  },
    130: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    131: { name: "百戏大王",       englishName: "Ringmaster",       codeName: "ringmaster",       facingRight: true,  heightAdjust: 0,  heroAttribute: 4, avatarAdjust: 40, avatarFacingRight: false },
    132: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    133: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    134: { name: "unknown",        englishName: "Unknown",          codeName: "unknown",          facingRight: true,  heightAdjust: 0,  heroAttribute: 0, avatarAdjust: 0,  avatarFacingRight: true  },
    135: { name: "破晓辰星",       englishName: "Dawnbreaker",      codeName: "dawnbreaker",      facingRight: true,  heightAdjust: 10, heroAttribute: 1, avatarAdjust: 0,  avatarFacingRight: true  },
    136: { name: "玛西",           englishName: "Marci",            codeName: "marci",            facingRight: true,  heightAdjust: 10, heroAttribute: 8, avatarAdjust: 0,  avatarFacingRight: true  },
    137: { name: "獸",             englishName: "Primal Beast",     codeName: "primal_beast",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1, avatarAdjust: 50,  avatarFacingRight: true  },
    138: { name: "琼英碧灵",       englishName: "Muerta",           codeName: "muerta",           facingRight: false, heightAdjust: 15,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    139: { name: "unknown",       englishName: "unknown",           codeName: "unknown",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1, avatarAdjust: 50,  avatarFacingRight: true  },
    140: { name: "unknown",       englishName: "unknown",           codeName: "unknown",           facingRight: false, heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    141: { name: "unknown",       englishName: "unknown",           codeName: "unknown",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1, avatarAdjust: 50,  avatarFacingRight: true  },
    142: { name: "unknown",       englishName: "unknown",           codeName: "unknown",           facingRight: false, heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    143: { name: "unknown",       englishName: "unknown",           codeName: "unknown",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1, avatarAdjust: 50,  avatarFacingRight: true  },
    144: { name: "unknown",       englishName: "unknown",           codeName: "unknown",           facingRight: false, heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    145: { name: "凯",            englishName: "Kez",               codeName: "kez",     facingRight: true,  heightAdjust: 10,  heroAttribute: 1, avatarAdjust: 0,  avatarFacingRight: true  },
    146: { name: "unknown",       englishName: "unknown",           codeName: "unknown",           facingRight: false, heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    147: { name: "unknown",       englishName: "unknown",           codeName: "unknown",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1, avatarAdjust: 50,  avatarFacingRight: true  },
    148: { name: "unknown",       englishName: "unknown",           codeName: "unknown",           facingRight: false, heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  },
    149: { name: "unknown",       englishName: "unknown",           codeName: "unknown",     facingRight: true,  heightAdjust: 0,  heroAttribute: 1, avatarAdjust: 50,  avatarFacingRight: true  },
    150: { name: "unknown",       englishName: "unknown",           codeName: "unknown",           facingRight: false, heightAdjust: 5,  heroAttribute: 4, avatarAdjust: 30, avatarFacingRight: true  }
}


var heroesFacets = {
    "npc_dota_hero_antimage": {
        "Facets": {
            "1": {
                "Icon": "ricochet",
                "Color": "Purple",
                "GradientID": "1",
                "name": "antimage_magebanes_mirror"
            },
            "2": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "3",
                "name": "antimage_mana_thirst"
            }
        }
    },
    "npc_dota_hero_axe": {
        "Facets": {
            "1": {
                "Icon": "strength",
                "Color": "Red",
                "GradientID": "0",
                "name": "axe_one_man_army",
                "AbilityName": "axe_one_man_army"
            },
            "2": {
                "Icon": "armor",
                "Color": "Red",
                "GradientID": "2",
                "name": "axe_call_out"
            }
        }
    },
    "npc_dota_hero_bane": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Gray",
                "GradientID": "0",
                "name": "bane_dream_stalker"
            },
            "2": {
                "Icon": "movement",
                "Color": "Purple",
                "GradientID": "1",
                "name": "bane_sleepwalk"
            }
        }
    },
    "npc_dota_hero_bloodseeker": {
        "Facets": {
            "1": {
                "Icon": "movement",
                "Color": "Red",
                "GradientID": "1",
                "name": "bloodseeker_arterial_spray"
            },
            "2": {
                "Icon": "speed",
                "Color": "Gray",
                "GradientID": "1",
                "name": "bloodseeker_bloodrush"
            }
        }
    },
    "npc_dota_hero_crystal_maiden": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Gray",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "crystal_maiden_frozen_expanse"
            },
            "2": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "2",
                "Deprecated": "true",
                "name": "crystal_maiden_cold_comfort"
            },
            "3": {
                "Icon": "armor",
                "Color": "Gray",
                "GradientID": "3",
                "name": "crystal_maiden_glacial_guard"
            },
            "4": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "2",
                "name": "crystal_maiden_arcane_overflow"
            }
        }
    },
    "npc_dota_hero_drow_ranger": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Gray",
                "GradientID": "1",
                "name": "drow_ranger_high_ground",
                "AbilityName": "drow_ranger_vantage_point"
            },
            "2": {
                "Icon": "multi_arrow",
                "Color": "Blue",
                "GradientID": "1",
                "name": "drow_ranger_sidestep"
            }
        }
    },
    "npc_dota_hero_earthshaker": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Red",
                "GradientID": "1",
                "name": "earthshaker_tectonic_buildup"
            },
            "2": {
                "Icon": "movement",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "earthshaker_slugger",
                "AbilityName": "earthshaker_slugger"
            }
        }
    },
    "npc_dota_hero_juggernaut": {
        "Facets": {
            "1": {
                "Icon": "spinning",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "juggernaut_bladestorm"
            },
            "2": {
                "Icon": "agility",
                "Color": "Red",
                "GradientID": "2",
                "name": "juggernaut_agigain",
                "AbilityName": "juggernaut_bladeform"
            }
        }
    },
    "npc_dota_hero_mirana": {
        "Facets": {
            "1": {
                "Icon": "moon",
                "Color": "Blue",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "mirana_moonlight",
                "AbilityName": "mirana_invis"
            },
            "2": {
                "Icon": "sun",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "mirana_sunlight",
                "AbilityName": "mirana_solar_flare"
            },
            "3": {
                "Icon": "no_vision",
                "Color": "Blue",
                "GradientID": "1",
                "name": "mirana_starstruck"
            },
            "4": {
                "Icon": "slow",
                "Color": "Gray",
                "GradientID": "3",
                "name": "mirana_leaps_and_bounds"
            }
        }
    },
    "npc_dota_hero_nevermore": {
        "Facets": {
            "1": {
                "Icon": "armor_broken",
                "Color": "Gray",
                "GradientID": "0",
                "name": "nevermore_lasting_presence"
            },
            "2": {
                "Icon": "slow",
                "Color": "Red",
                "GradientID": "0",
                "name": "nevermore_shadowmire"
            }
        }
    },
    "npc_dota_hero_morphling": {
        "Facets": {
            "1": {
                "Icon": "agility",
                "Color": "Green",
                "GradientID": "0",
                "name": "morphling_agi",
                "AbilityName": "morphling_ebb"
            },
            "2": {
                "Icon": "strength",
                "Color": "Red",
                "GradientID": "0",
                "name": "morphling_str",
                "AbilityName": "morphling_flow"
            }
        }
    },
    "npc_dota_hero_phantom_lancer": {
        "Facets": {
            "1": {
                "Icon": "illusion",
                "Color": "Yellow",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "phantom_lancer_convergence"
            },
            "2": {
                "Icon": "summons",
                "Color": "Blue",
                "GradientID": "2",
                "name": "phantom_lancer_divergence"
            },
            "3": {
                "Icon": "phantom_lance",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "phantom_lancer_lancelot"
            }
        }
    },
    "npc_dota_hero_puck": {
        "Facets": {
            "1": {
                "Icon": "movement",
                "Color": "Purple",
                "GradientID": "0",
                "name": "puck_jostling_rift"
            },
            "2": {
                "Icon": "curve_ball",
                "Color": "Blue",
                "GradientID": "2",
                "name": "puck_curveball"
            }
        }
    },
    "npc_dota_hero_pudge": {
        "Facets": {
            "1": {
                "Icon": "meat",
                "Color": "Red",
                "GradientID": "0",
                "name": "pudge_fresh_meat"
            },
            "2": {
                "Icon": "pudge_hook",
                "Color": "Red",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "pudge_flayers_hook"
            },
            "3": {
                "Icon": "fist",
                "Color": "Green",
                "GradientID": "3",
                "name": "pudge_rotten_core"
            }
        }
    },
    "npc_dota_hero_razor": {
        "Facets": {
            "1": {
                "Icon": "barrier",
                "Color": "Gray",
                "GradientID": "0",
                "name": "razor_thunderhead"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Blue",
                "GradientID": "0",
                "name": "razor_spellamp",
                "AbilityName": "razor_dynamo"
            }
        }
    },
    "npc_dota_hero_sand_king": {
        "Facets": {
            "1": {
                "Icon": "vision",
                "Color": "Gray",
                "GradientID": "3",
                "name": "sand_king_sandshroud"
            },
            "2": {
                "Icon": "speed",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "sand_king_dust_devil"
            }
        }
    },
    "npc_dota_hero_storm_spirit": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Blue",
                "GradientID": "1",
                "name": "storm_spirit_shock_collar"
            },
            "2": {
                "Icon": "movement",
                "Color": "Gray",
                "GradientID": "3",
                "name": "storm_spirit_static_slide"
            }
        }
    },
    "npc_dota_hero_sven": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Blue",
                "GradientID": "0",
                "name": "sven_heavy_plate"
            },
            "2": {
                "Icon": "strength",
                "Color": "Red",
                "GradientID": "0",
                "name": "sven_strscaling",
                "AbilityName": "sven_wrath_of_god"
            }
        }
    },
    "npc_dota_hero_tiny": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Gray",
                "GradientID": "2",
                "name": "tiny_crash_landing"
            },
            "2": {
                "Icon": "armor",
                "Color": "Green",
                "GradientID": "4",
                "name": "tiny_insurmountable",
                "AbilityName": "tiny_insurmountable"
            }
        }
    },
    "npc_dota_hero_vengefulspirit": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Purple",
                "GradientID": "2",
                "name": "vengefulspirit_avenging_missile"
            },
            "2": {
                "Icon": "fist",
                "Color": "Blue",
                "GradientID": "1",
                "KeyValueOverrides": {
                    "AttackRate": "1.5"
                },
                "name": "vvengefulspirit_melee",
                "AbilityName": "vengefulspirit_soul_strike"
            }
        }
    },
    "npc_dota_hero_windrunner": {
        "Facets": {
            "1": {
                "Icon": "speed",
                "Color": "Yellow",
                "GradientID": "2",
                "Deprecated": "true",
                "name": "windrunner_tailwind"
            },
            "2": {
                "Icon": "focus_fire",
                "Color": "Yellow",
                "GradientID": "2",
                "Deprecated": "true",
                "name": "windrunner_focusfire"
            },
            "3": {
                "Icon": "multi_arrow",
                "Color": "Green",
                "GradientID": "0",
                "Deprecated": "true",
                "AbilityIconReplacements": {
                    "windrunner_focusfire": "windrunner_whirlwind",
                    "windrunner_focusfire_cancel": "windrunner_whirlwind_stop"
                },
                "name": "windrunner_whirlwind"
            },
            "4": {
                "Icon": "tree",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "windrunner_tangled"
            },
            "5": {
                "Icon": "execute",
                "Color": "Green",
                "GradientID": "0",
                "name": "windrunner_killshot"
            }
        }
    },
    "npc_dota_hero_zuus": {
        "Facets": {
            "1": {
                "Icon": "range",
                "Color": "Blue",
                "GradientID": "1",
                "name": "zuus_livewire"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Gray",
                "GradientID": "3",
                "name": "zuus_divine_rampage"
            }
        }
    },
    "npc_dota_hero_kunkka": {
        "Facets": {
            "1": {
                "Icon": "cooldown",
                "Color": "Blue",
                "GradientID": "2",
                "name": "kunkka_high_tide"
            },
            "2": {
                "Icon": "armor",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "kunkka_grog"
            }
        }
    },
    "npc_dota_hero_lina": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "lina_supercharge"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "name": "lina_dot",
                "AbilityName": "lina_slow_burn"
            }
        }
    },
    "npc_dota_hero_lich": {
        "Facets": {
            "1": {
                "Icon": "snowflake",
                "Color": "Blue",
                "GradientID": "0",
                "name": "lich_frostbound"
            },
            "2": {
                "Icon": "cooldown",
                "Color": "Gray",
                "GradientID": "0",
                "name": "lich_growing_cold"
            }
        }
    },
    "npc_dota_hero_lion": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Purple",
                "GradientID": "2",
                "name": "lion_essence_eater"
            },
            "2": {
                "Icon": "fist",
                "Color": "Red",
                "GradientID": "2",
                "name": "lion_fist_of_death"
            }
        }
    },
    "npc_dota_hero_shadow_shaman": {
        "Facets": {
            "1": {
                "Icon": "chicken",
                "Color": "Yellow",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "shadow_shaman_cluster_cluck"
            },
            "2": {
                "Icon": "chicken",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "shadow_shaman_voodoo_hands",
                "AbilityName": "shadow_shaman_voodoo_hands"
            },
            "3": {
                "Icon": "snake",
                "Color": "Red",
                "GradientID": "1",
                "name": "shadow_shaman_massive_serpent_ward"
            }
        }
    },
    "npc_dota_hero_slardar": {
        "Facets": {
            "1": {
                "Icon": "speed",
                "Color": "Red",
                "GradientID": "2",
                "name": "slardar_leg_day"
            },
            "2": {
                "Icon": "armor",
                "Color": "Purple",
                "GradientID": "1",
                "name": "slardar_brineguard"
            }
        }
    },
    "npc_dota_hero_tidehunter": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Green",
                "GradientID": "2",
                "name": "tidehunter_kraken_swell"
            },
            "2": {
                "Icon": "overshadow",
                "Color": "Green",
                "GradientID": "0",
                "KeyValueOverrides": {
                    "AttributeStrengthGain": "4.1"
                },
                "name": "tidehunter_sizescale",
                "AbilityName": "tidehunter_krill_eater"
            }
        }
    },
    "npc_dota_hero_witch_doctor": {
        "Facets": {
            "1": {
                "Icon": "ricochet",
                "Color": "Gray",
                "GradientID": "3",
                "name": "witch_doctor_headhunter"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "2",
                "Deprecated": "1",
                "name": "witch_doctor_voodoo_festeration"
            },
            "3": {
                "Icon": "death_ward",
                "Color": "Purple",
                "GradientID": "0",
                "name": "witch_doctor_cleft_death"
            }
        }
    },
    "npc_dota_hero_riki": {
        "Facets": {
            "1": {
                "Icon": "xp",
                "Color": "Gray",
                "GradientID": "3",
                "name": "riki_contract_killer"
            },
            "2": {
                "Icon": "agility",
                "Color": "Purple",
                "GradientID": "2",
                "name": "riki_exterminator"
            }
        }
    },
    "npc_dota_hero_enigma": {
        "Facets": {
            "1": {
                "Icon": "slow",
                "Color": "Gray",
                "GradientID": "3",
                "name": "enigma_gravity",
                "AbilityName": "enigma_event_horizon"
            },
            "2": {
                "Icon": "summons",
                "Color": "Purple",
                "GradientID": "0",
                "name": "enigma_fragment",
                "AbilityName": "enigma_splitting_image"
            }
        }
    },
    "npc_dota_hero_tinker": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Blue",
                "GradientID": "2",
                "name": "tinker_repair_bots"
            },
            "2": {
                "Icon": "movement",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "tinker_translocator"
            }
        }
    },
    "npc_dota_hero_sniper": {
        "Facets": {
            "1": {
                "Icon": "vision",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "sniper_ghillie_suit"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "name": "sniper_scattershot"
            }
        }
    },
    "npc_dota_hero_necrolyte": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "necrolyte_profane_potency"
            },
            "2": {
                "Icon": "speed",
                "Color": "Green",
                "GradientID": "3",
                "name": "necrolyte_rapid_decay"
            }
        }
    },
    "npc_dota_hero_warlock": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Red",
                "GradientID": "0",
                "name": "warlock_golem"
            },
            "2": {
                "Icon": "xp",
                "Color": "Gray",
                "GradientID": "3",
                "name": "warlock_grimoire",
                "AbilityName": "warlock_black_grimoire"
            }
        }
    },
    "npc_dota_hero_beastmaster": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Red",
                "GradientID": "1",
                "name": "beastmaster_wild_hunt"
            },
            "2": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "beastmaster_beast_mode"
            }
        }
    },
    "npc_dota_hero_queenofpain": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Blue",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "queenofpain_lifesteal",
                "AbilityName": "queenofpain_succubus"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "name": "queenofpain_selfdmg",
                "AbilityName": "queenofpain_masochist"
            },
            "3": {
                "Icon": "twin_hearts",
                "Color": "Blue",
                "GradientID": "0",
                "name": "queenofpain_facet_bondage",
                "AbilityName": "queenofpain_bondage"
            }
        }
    },
    "npc_dota_hero_venomancer": {
        "Facets": {
            "1": {
                "Icon": "snot",
                "Color": "Green",
                "GradientID": "0",
                "name": "venomancer_patient_zero"
            },
            "2": {
                "Icon": "summons",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "venomancer_plague_carrier"
            }
        }
    },
    "npc_dota_hero_faceless_void": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Green",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "faceless_void_temporal_impunity"
            },
            "2": {
                "Icon": "area_of_effect",
                "Color": "Green",
                "GradientID": "0",
                "name": "faceless_void_chronosphere",
                "AbilityName": "faceless_void_chronosphere"
            },
            "3": {
                "Icon": "chrono_cube",
                "Color": "Purple",
                "GradientID": "1",
                "name": "faceless_void_time_zone",
                "AbilityName": "faceless_void_time_zone"
            }
        }
    },
    "npc_dota_hero_skeleton_king": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "skeleton_king_facet_bone_guard",
                "AbilityName": "skeleton_king_bone_guard"
            },
            "2": {
                "Icon": "damage",
                "Color": "Red",
                "GradientID": "0",
                "name": "skeleton_king_facet_cursed_blade",
                "AbilityName": "skeleton_king_spectral_blade"
            }
        }
    },
    "npc_dota_hero_death_prophet": {
        "Facets": {
            "1": {
                "Icon": "slow",
                "Color": "Purple",
                "GradientID": "2",
                "Deprecated": "true",
                "name": "death_prophet_suppress"
            },
            "2": {
                "Icon": "spirit",
                "Color": "Green",
                "GradientID": "1",
                "name": "death_prophet_ghosts",
                "AbilityName": "death_prophet_spirit_collector"
            },
            "3": {
                "Icon": "healing",
                "Color": "Red",
                "GradientID": "1",
                "name": "death_prophet_delayed_damage",
                "AbilityName": "death_prophet_mourning_ritual"
            }
        }
    },
    "npc_dota_hero_phantom_assassin": {
        "Facets": {
            "1": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "3",
                "Deprecated": "1",
                "name": "phantom_assassin_veiled_one"
            },
            "2": {
                "Icon": "skull",
                "Color": "Gray",
                "GradientID": "0",
                "name": "phantom_assassin_methodical"
            },
            "3": {
                "Icon": "phantom_ass_dagger",
                "Color": "Red",
                "GradientID": "0",
                "name": "phantom_assassin_sweet_release"
            }
        }
    },
    "npc_dota_hero_pugna": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Green",
                "GradientID": "0",
                "name": "pugna_siphoning_ward"
            },
            "2": {
                "Icon": "siege",
                "Color": "Purple",
                "GradientID": "2",
                "name": "pugna_rewards_of_ruin"
            }
        }
    },
    "npc_dota_hero_templar_assassin": {
        "Facets": {
            "1": {
                "Icon": "ricochet",
                "Color": "Gray",
                "GradientID": "3",
                "name": "templar_assassin_voidblades"
            },
            "2": {
                "Icon": "damage",
                "Color": "Purple",
                "GradientID": "0",
                "name": "templar_assassin_refractor"
            },
            "3": {
                "Icon": "range",
                "Color": "Blue",
                "GradientID": "1",
                "name": "templar_assassin_hidden_reach"
            }
        }
    },
    "npc_dota_hero_viper": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Green",
                "GradientID": "0",
                "name": "viper_poison_burst"
            },
            "2": {
                "Icon": "armor",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "viper_caustic_bath"
            }
        }
    },
    "npc_dota_hero_luna": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "luna_lunar_orbit"
            },
            "2": {
                "Icon": "armor",
                "Color": "Gray",
                "GradientID": "3",
                "name": "luna_moonshield"
            },
            "3": {
                "Icon": "damage",
                "Color": "Blue",
                "GradientID": "1",
                "name": "luna_moonstorm"
            }
        }
    },
    "npc_dota_hero_dragon_knight": {
        "Facets": {
            "1": {
                "Icon": "dragon_fire",
                "Color": "Red",
                "GradientID": "1",
                "name": "dragon_knight_fire_dragon"
            },
            "2": {
                "Icon": "dragon_poison",
                "Color": "Green",
                "GradientID": "0",
                "name": "dragon_knight_corrosive_dragon"
            },
            "3": {
                "Icon": "dragon_frost",
                "Color": "Blue",
                "GradientID": "0",
                "name": "dragon_knight_frost_dragon"
            }
        }
    },
    "npc_dota_hero_dazzle": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Red",
                "GradientID": "1",
                "name": "dazzle_facet_nothl_boon",
                "AbilityName": "dazzle_nothl_boon"
            },
            "2": {
                "Icon": "ricochet",
                "Color": "Purple",
                "GradientID": "0",
                "name": "dazzle_poison_bloom"
            }
        }
    },
    "npc_dota_hero_rattletrap": {
        "Facets": {
            "1": {
                "Icon": "cooldown",
                "Color": "Gray",
                "GradientID": "2",
                "name": "rattletrap_hookup"
            },
            "2": {
                "Icon": "area_of_effect",
                "Color": "Red",
                "GradientID": "2",
                "name": "rattletrap_expanded_armature"
            }
        }
    },
    "npc_dota_hero_leshrac": {
        "Facets": {
            "1": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "1",
                "name": "leshrac_attacks_mana",
                "AbilityName": "leshrac_chronoptic_nourishment"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Purple",
                "GradientID": "0",
                "name": "leshrac_misanthropy"
            }
        }
    },
    "npc_dota_hero_furion": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Green",
                "GradientID": "0",
                "name": "furion_soothing_saplings"
            },
            "2": {
                "Icon": "siege",
                "Color": "Blue",
                "GradientID": "2",
                "name": "furion_ironwood_treant"
            }
        }
    },
    "npc_dota_hero_life_stealer": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Yellow",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "life_stealer_maxhp_gain",
                "AbilityName": "life_stealer_corpse_eater"
            },
            "2": {
                "Icon": "lifestealer_rage",
                "Color": "Yellow",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "life_stealer_rage",
                "AbilityName": "life_stealer_rage"
            },
            "3": {
                "Icon": "broken_chain",
                "Color": "Red",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "life_stealer_rage_dispell",
                "AbilityName": "life_stealer_unfettered"
            },
            "4": {
                "Icon": "full_heart",
                "Color": "Gray",
                "GradientID": "0",
                "name": "life_stealer_fleshfeast"
            },
            "5": {
                "Icon": "area_of_effect",
                "Color": "Red",
                "GradientID": "0",
                "name": "life_stealer_gorestorm"
            }
        }
    },
    "npc_dota_hero_dark_seer": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Gray",
                "GradientID": "3",
                "name": "dark_seer_atkspd",
                "AbilityName": "dark_seer_quick_wit"
            },
            "2": {
                "Icon": "speed",
                "Color": "Purple",
                "GradientID": "2",
                "KeyValueOverrides": {
                    "MovementSpeed": "275"
                },
                "name": "dark_seer_movespd",
                "AbilityName": "dark_seer_heart_of_battle"
            }
        }
    },
    "npc_dota_hero_clinkz": {
        "Facets": {
            "1": {
                "Icon": "no_vision",
                "Color": "Gray",
                "GradientID": "3",
                "name": "clinkz_suppressive_fire"
            },
            "2": {
                "Icon": "teleport",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "clinkz_engulfing_step"
            }
        }
    },
    "npc_dota_hero_omniknight": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Gray",
                "GradientID": "3",
                "name": "omniknight_omnipresent"
            },
            "2": {
                "Icon": "healing",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "omniknight_dmgheals",
                "AbilityName": "omniknight_healing_hammer"
            }
        }
    },
    "npc_dota_hero_enchantress": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Green",
                "GradientID": "0",
                "name": "enchantress_overprotective_wisps"
            },
            "2": {
                "Icon": "range",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "enchantress_spellbound"
            }
        }
    },
    "npc_dota_hero_huskar": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Red",
                "GradientID": "0",
                "Deprecated": "1",
                "name": "huskar_bloodbath"
            },
            "2": {
                "Icon": "healing",
                "Color": "Blue",
                "GradientID": "2",
                "Deprecated": "1",
                "name": "huskar_nothl_transfusion"
            },
            "3": {
                "Icon": "broken_chain",
                "Color": "Red",
                "GradientID": "0",
                "name": "huskar_cauterize"
            },
            "4": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "huskar_nothl_conflagration"
            }
        }
    },
    "npc_dota_hero_night_stalker": {
        "Facets": {
            "1": {
                "Icon": "no_vision",
                "Color": "Blue",
                "GradientID": "0",
                "Deprecated": "True",
                "name": "night_stalker_blinding_void"
            },
            "2": {
                "Icon": "moon",
                "Color": "Gray",
                "GradientID": "0",
                "name": "night_stalker_dayswap",
                "AbilityName": "night_stalker_night_reign"
            },
            "3": {
                "Icon": "area_of_effect",
                "Color": "Blue",
                "GradientID": "0",
                "MaxHeroAttributeLevel": "6",
                "name": "night_stalker_voidbringer"
            }
        }
    },
    "npc_dota_hero_broodmother": {
        "Facets": {
            "1": {
                "Icon": "web",
                "Color": "Gray",
                "GradientID": "0",
                "name": "broodmother_necrotic_webs"
            },
            "2": {
                "Icon": "summons",
                "Color": "Red",
                "GradientID": "0",
                "name": "broodmother_feeding_frenzy"
            }
        }
    },
    "npc_dota_hero_bounty_hunter": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "name": "bounty_hunter_shuriken"
            },
            "2": {
                "Icon": "gold",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "bounty_hunter_mugging",
                "AbilityName": "bounty_hunter_cutpurse"
            }
        }
    },
    "npc_dota_hero_weaver": {
        "Facets": {
            "1": {
                "Icon": "speed",
                "Color": "Red",
                "GradientID": "0",
                "name": "weaver_skitterstep"
            },
            "2": {
                "Icon": "xp",
                "Color": "Blue",
                "GradientID": "1",
                "name": "weaver_hivemind"
            }
        }
    },
    "npc_dota_hero_jakiro": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "jakiro_fire",
                "AbilityName": "jakiro_liquid_fire"
            },
            "2": {
                "Icon": "snowflake",
                "Color": "Blue",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "jakiro_ice",
                "AbilityName": "jakiro_liquid_ice"
            },
            "3": {
                "Icon": "damage",
                "Color": "Red",
                "GradientID": "0",
                "name": "jakiro_twin_terror"
            },
            "4": {
                "Icon": "snowflake",
                "Color": "Blue",
                "GradientID": "1",
                "name": "jakiro_ice_breaker",
                "AbilityName": "jakiro_ice_path_detonate"
            }
        }
    },
    "npc_dota_hero_batrider": {
        "Facets": {
            "1": {
                "Icon": "speed",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "batrider_buff_on_displacement",
                "AbilityName": "batrider_stoked"
            },
            "2": {
                "Icon": "siege",
                "Color": "Red",
                "GradientID": "0",
                "name": "batrider_arsonist"
            }
        }
    },
    "npc_dota_hero_chen": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Yellow",
                "GradientID": "3",
                "AbilityIconReplacements": {
                    "chen_summon_convert": "chen_summon_convert_centaur"
                },
                "name": "chen_centaur_convert"
            },
            "2": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "2",
                "Deprecated": "true",
                "AbilityIconReplacements": {
                    "chen_summon_convert": "chen_summon_convert_wolf"
                },
                "name": "chen_wolf_convert"
            },
            "3": {
                "Icon": "slow",
                "Color": "Red",
                "GradientID": "0",
                "AbilityIconReplacements": {
                    "chen_summon_convert": "chen_summon_convert_hellbear"
                },
                "name": "chen_hellbear_convert"
            },
            "4": {
                "Icon": "summons",
                "Color": "Green",
                "GradientID": "0",
                "AbilityIconReplacements": {
                    "chen_summon_convert": "chen_summon_convert_troll"
                },
                "name": "chen_troll_convert"
            },
            "5": {
                "Icon": "mana",
                "Color": "Purple",
                "GradientID": "1",
                "AbilityIconReplacements": {
                    "chen_summon_convert": "chen_summon_convert_satyr"
                },
                "name": "chen_satyr_convert"
            },
            "6": {
                "Icon": "bubbles",
                "Color": "Blue",
                "GradientID": "3",
                "AbilityIconReplacements": {
                    "chen_summon_convert": "chen_summon_convert_frog"
                },
                "name": "chen_frog_convert"
            }
        }
    },
    "npc_dota_hero_spectre": {
        "Facets": {
            "1": {
                "Icon": "spectre",
                "Color": "Gray",
                "GradientID": "0",
                "name": "spectre_forsaken"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Purple",
                "GradientID": "2",
                "name": "spectre_twist_the_knife"
            }
        }
    },
    "npc_dota_hero_doom_bringer": {
        "Facets": {
            "1": {
                "Icon": "meat",
                "Color": "Red",
                "GradientID": "0",
                "name": "doom_bringer_gluttony"
            },
            "2": {
                "Icon": "gold",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "doom_bringer_boost_selling",
                "AbilityName": "doom_bringer_devils_bargain"
            },
            "3": {
                "Icon": "cooldown",
                "Color": "Gray",
                "GradientID": "0",
                "name": "doom_bringer_impending_doom"
            }
        }
    },
    "npc_dota_hero_ancient_apparition": {
        "Facets": {
            "1": {
                "Icon": "debuff",
                "Color": "Gray",
                "GradientID": "3",
                "name": "ancient_apparition_bone_chill"
            },
            "2": {
                "Icon": "area_of_effect",
                "Color": "Blue",
                "GradientID": "0",
                "name": "ancient_apparition_exposure"
            }
        }
    },
    "npc_dota_hero_ursa": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Red",
                "GradientID": "0",
                "name": "ursa_grudge_bearer"
            },
            "2": {
                "Icon": "cooldown",
                "Color": "Blue",
                "GradientID": "0",
                "name": "ursa_debuff_reduce",
                "AbilityName": "ursa_bear_down"
            }
        }
    },
    "npc_dota_hero_spirit_breaker": {
        "Facets": {
            "1": {
                "Icon": "speed",
                "Color": "Red",
                "GradientID": "1",
                "name": "spirit_breaker_bull_rush"
            },
            "2": {
                "Icon": "movement",
                "Color": "Blue",
                "GradientID": "2",
                "Deprecated": "true",
                "name": "spirit_breaker_imbalanced"
            },
            "3": {
                "Icon": "rng",
                "Color": "Blue",
                "GradientID": "2",
                "name": "spirit_breaker_bulls_hit"
            }
        }
    },
    "npc_dota_hero_gyrocopter": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "name": "gyrocopter_secondary_strikes"
            },
            "2": {
                "Icon": "speed",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "gyrocopter_afterburner"
            }
        }
    },
    "npc_dota_hero_alchemist": {
        "Facets": {
            "1": {
                "Icon": "gold",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "alchemist_seed_money"
            },
            "2": {
                "Icon": "cooldown",
                "Color": "Purple",
                "GradientID": "2",
                "name": "alchemist_mixologist"
            },
            "3": {
                "Icon": "aghs",
                "Color": "Green",
                "GradientID": "2",
                "name": "alchemist_dividends"
            }
        }
    },
    "npc_dota_hero_invoker": {
        "Facets": {
            "1": {
                "Icon": "invoker_passive",
                "Color": "Purple",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "invoker_agnostic"
            },
            "2": {
                "Icon": "invoker_active",
                "Color": "Gray",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "invoker_elitist"
            },
            "3": {
                "Icon": "invoker_quas",
                "Color": "Blue",
                "GradientID": "0",
                "name": "invoker_quas_focus"
            },
            "4": {
                "Icon": "invoker_wex",
                "Color": "Purple",
                "GradientID": "0",
                "name": "invoker_wex_focus"
            },
            "5": {
                "Icon": "invoker_exort",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "invoker_exort_focus"
            }
        }
    },
    "npc_dota_hero_silencer": {
        "Facets": {
            "1": {
                "Icon": "silencer",
                "Color": "Purple",
                "GradientID": "1",
                "name": "silencer_irrepressible",
                "AbilityName": "silencer_irrepressible"
            },
            "2": {
                "Icon": "debuff",
                "Color": "Gray",
                "GradientID": "3",
                "name": "silencer_reverberating_silence"
            }
        }
    },
    "npc_dota_hero_obsidian_destroyer": {
        "Facets": {
            "1": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "0",
                "name": "obsidian_destroyer_obsidian_decimator"
            },
            "2": {
                "Icon": "healing",
                "Color": "Blue",
                "GradientID": "2",
                "name": "obsidian_destroyer_overwhelming_devourer"
            }
        }
    },
    "npc_dota_hero_lycan": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Gray",
                "GradientID": "1",
                "name": "lycan_pack_leader"
            },
            "2": {
                "Icon": "spirit",
                "Color": "Red",
                "GradientID": "0",
                "AbilityIconReplacements": {
                    "lycan_summon_wolves": "lycan_summon_spirit_wolves"
                },
                "name": "lycan_spirit_wolves"
            },
            "3": {
                "Icon": "wolf",
                "Color": "Green",
                "GradientID": "2",
                "name": "lycan_alpha_wolves"
            }
        }
    },
    "npc_dota_hero_brewmaster": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "1",
                "name": "brewmaster_roll_out_the_barrel"
            },
            "2": {
                "Icon": "speed",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "brewmaster_drunken_master"
            }
        }
    },
    "npc_dota_hero_shadow_demon": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Gray",
                "GradientID": "0",
                "name": "shadow_demon_promulgate"
            },
            "2": {
                "Icon": "illusion",
                "Color": "Purple",
                "GradientID": "0",
                "name": "shadow_demon_facet_soul_mastery",
                "AbilityName": "shadow_demon_shadow_servant"
            }
        }
    },
    "npc_dota_hero_lone_druid": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Green",
                "GradientID": "1",
                "name": "lone_druid_bear_with_me"
            },
            "2": {
                "Icon": "overshadow",
                "Color": "Yellow",
                "GradientID": "1",
                "Deprecated": "1",
                "name": "lone_druid_unbearable"
            },
            "3": {
                "Icon": "item",
                "Color": "Gray",
                "GradientID": "1",
                "name": "lone_druid_bear_necessities",
                "AbilityName": "lone_druid_bear_necessities"
            }
        }
    },
    "npc_dota_hero_chaos_knight": {
        "Facets": {
            "1": {
                "Icon": "illusion",
                "Color": "Red",
                "GradientID": "1",
                "Deprecated": "1",
                "name": "chaos_knight_strong_illusions",
                "AbilityName": "chaos_knight_phantasmagoria"
            },
            "2": {
                "Icon": "rng",
                "Color": "Gray",
                "GradientID": "0",
                "name": "chaos_knight_irrationality"
            },
            "3": {
                "Icon": "item",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "chaos_knight_facet_fundamental_forging",
                "AbilityName": "chaos_knight_fundamental_forging"
            },
            "4": {
                "Icon": "ricochet",
                "Color": "Red",
                "GradientID": "0",
                "name": "chaos_knight_cloven_chaos"
            }
        }
    },
    "npc_dota_hero_meepo": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Blue",
                "GradientID": "2",
                "MaxHeroAttributeLevel": "6",
                "name": "meepo_more_meepo"
            },
            "2": {
                "Icon": "illusion",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "meepo_codependent"
            },
            "3": {
                "Icon": "item",
                "Color": "Yellow",
                "GradientID": "1",
                "Deprecated": "1",
                "name": "meepo_pack_rat",
                "AbilityName": "meepo_pack_rat"
            }
        }
    },
    "npc_dota_hero_treant": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "treant_primeval_power"
            },
            "2": {
                "Icon": "tree",
                "Color": "Green",
                "GradientID": "2",
                "name": "treant_sapling"
            }
        }
    },
    "npc_dota_hero_ogre_magi": {
        "Facets": {
            "1": {
                "Icon": "rng",
                "Color": "Red",
                "GradientID": "0",
                "name": "ogre_magi_fat_chance"
            },
            "2": {
                "Icon": "ogre",
                "Color": "Blue",
                "GradientID": "1",
                "name": "ogre_magi_learning_curve"
            }
        }
    },
    "npc_dota_hero_undying": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Green",
                "GradientID": "4",
                "name": "undying_rotting_mitts"
            },
            "2": {
                "Icon": "strength",
                "Color": "Red",
                "GradientID": "1",
                "name": "undying_ripped"
            }
        }
    },
    "npc_dota_hero_rubick": {
        "Facets": {
            "1": {
                "Icon": "mana",
                "Color": "Purple",
                "GradientID": "2",
                "name": "rubick_frugal_filch"
            },
            "2": {
                "Icon": "area_of_effect",
                "Color": "Green",
                "GradientID": "0",
                "name": "rubick_arcane_accumulation"
            }
        }
    },
    "npc_dota_hero_disruptor": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Red",
                "GradientID": "1",
                "name": "disruptor_thunderstorm"
            },
            "2": {
                "Icon": "fence",
                "Color": "Blue",
                "GradientID": "1",
                "name": "disruptor_line_walls",
                "AbilityName": "disruptor_kinetic_fence"
            }
        }
    },
    "npc_dota_hero_nyx_assassin": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Blue",
                "GradientID": "3",
                "name": "nyx_assassin_burn_mana"
            },
            "2": {
                "Icon": "speed",
                "Color": "Red",
                "GradientID": "2",
                "name": "nyx_assassin_scuttle"
            }
        }
    },
    "npc_dota_hero_naga_siren": {
        "Facets": {
            "1": {
                "Icon": "armor_broken",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "naga_siren_passive_riptide",
                "AbilityName": "naga_siren_rip_tide"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Green",
                "GradientID": "2",
                "name": "naga_siren_active_riptide",
                "AbilityName": "naga_siren_deluge"
            }
        }
    },
    "npc_dota_hero_keeper_of_the_light": {
        "Facets": {
            "1": {
                "Icon": "slow",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "keeper_of_the_light_facet_solar_bind",
                "AbilityName": "keeper_of_the_light_radiant_bind"
            },
            "2": {
                "Icon": "teleport",
                "Color": "Gray",
                "GradientID": "3",
                "name": "keeper_of_the_light_facet_recall",
                "AbilityName": "keeper_of_the_light_recall"
            }
        }
    },
    "npc_dota_hero_wisp": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Blue",
                "GradientID": "3",
                "name": "wisp_kritzkrieg"
            },
            "2": {
                "Icon": "armor",
                "Color": "Gray",
                "GradientID": "3",
                "name": "wisp_medigun"
            }
        }
    },
    "npc_dota_hero_visage": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Gray",
                "GradientID": "0",
                "name": "visage_sepulchre"
            },
            "2": {
                "Icon": "summons",
                "Color": "Blue",
                "GradientID": "2",
                "name": "visage_faithful_followers"
            },
            "3": {
                "Icon": "gold",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "visage_gold_assumption"
            }
        }
    },
    "npc_dota_hero_slark": {
        "Facets": {
            "1": {
                "Icon": "agility",
                "Color": "Green",
                "GradientID": "2",
                "name": "slark_leeching_leash"
            },
            "2": {
                "Icon": "cooldown",
                "Color": "Blue",
                "GradientID": "2",
                "name": "slark_dark_reef_renegade"
            }
        }
    },
    "npc_dota_hero_medusa": {
        "Facets": {
            "1": {
                "Icon": "snake",
                "Color": "Green",
                "GradientID": "1",
                "name": "medusa_engorged"
            },
            "2": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "medusa_mana_pact"
            },
            "3": {
                "Icon": "slow",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "medusa_slow_attacks",
                "AbilityName": "medusa_venomed_volley"
            },
            "4": {
                "Icon": "speed",
                "Color": "Red",
                "GradientID": "0",
                "name": "medusa_undulation",
                "AbilityName": "medusa_undulation"
            }
        }
    },
    "npc_dota_hero_troll_warlord": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Blue",
                "GradientID": "2",
                "name": "troll_warlord_insensitive"
            },
            "2": {
                "Icon": "damage",
                "Color": "Red",
                "GradientID": "1",
                "name": "troll_warlord_bad_influence"
            }
        }
    },
    "npc_dota_hero_centaur": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "1",
                "name": "centaur_counter_strike"
            },
            "2": {
                "Icon": "speed",
                "Color": "Gray",
                "GradientID": "3",
                "name": "centaur_horsepower",
                "AbilityName": "centaur_horsepower"
            }
        }
    },
    "npc_dota_hero_magnataur": {
        "Facets": {
            "1": {
                "Icon": "movement",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "magnataur_run_through"
            },
            "2": {
                "Icon": "vortex_in",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "magnataur_reverse_polarity"
            },
            "3": {
                "Icon": "empower",
                "Color": "Gray",
                "GradientID": "1",
                "name": "magnataur_eternal_empowerment"
            },
            "4": {
                "Icon": "ricochet",
                "Color": "Blue",
                "GradientID": "2",
                "MaxHeroAttributeLevel": "6",
                "name": "magnataur_diminishing_return"
            },
            "5": {
                "Icon": "vortex_out",
                "Color": "Gray",
                "GradientID": "0",
                "Deprecated": "true",
                "AbilityIconReplacements": {
                    "magnataur_reverse_polarity": "magnataur_reversed_reverse_polarity"
                },
                "name": "magnataur_reverse_reverse_polarity"
            }
        }
    },
    "npc_dota_hero_shredder": {
        "Facets": {
            "1": {
                "Icon": "tree",
                "Color": "Green",
                "GradientID": "0",
                "name": "shredder_shredder"
            },
            "2": {
                "Icon": "spinning",
                "Color": "Red",
                "GradientID": "1",
                "name": "shredder_second_chakram",
                "AbilityName": "shredder_twisted_chakram"
            }
        }
    },
    "npc_dota_hero_bristleback": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "bristleback_berserk"
            },
            "2": {
                "Icon": "snot",
                "Color": "Green",
                "GradientID": "0",
                "name": "bristleback_snot_rocket"
            },
            "3": {
                "Icon": "no_vision",
                "Color": "Red",
                "GradientID": "0",
                "name": "bristleback_seeing_red"
            }
        }
    },
    "npc_dota_hero_tusk": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Blue",
                "GradientID": "3",
                "name": "tusk_facet_tag_team",
                "AbilityName": "tusk_tag_team"
            },
            "2": {
                "Icon": "movement",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "tusk_facet_fist_bump",
                "AbilityName": "tusk_drinking_buddies"
            }
        }
    },
    "npc_dota_hero_skywrath_mage": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Blue",
                "GradientID": "0",
                "name": "skywrath_mage_shield",
                "AbilityName": "skywrath_mage_shield_of_the_scion"
            },
            "2": {
                "Icon": "cooldown",
                "Color": "Yellow",
                "GradientID": "2",
                "name": "skywrath_mage_staff",
                "AbilityName": "skywrath_mage_staff_of_the_scion"
            }
        }
    },
    "npc_dota_hero_abaddon": {
        "Facets": {
            "1": {
                "Icon": "cooldown",
                "Color": "Gray",
                "GradientID": "0",
                "name": "abaddon_death_dude",
                "AbilityName": "abaddon_the_quickening"
            },
            "2": {
                "Icon": "barrier",
                "Color": "Blue",
                "GradientID": "1",
                "name": "abaddon_mephitic_shroud"
            }
        }
    },
    "npc_dota_hero_elder_titan": {
        "Facets": {
            "1": {
                "Icon": "armor_broken",
                "Color": "Blue",
                "GradientID": "2",
                "name": "elder_titan_deconstruction"
            },
            "2": {
                "Icon": "damage",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "elder_titan_boost_atkspd",
                "AbilityName": "elder_titan_momentum"
            }
        }
    },
    "npc_dota_hero_legion_commander": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "legion_commander_stonehall_plate"
            },
            "2": {
                "Icon": "damage",
                "Color": "Red",
                "GradientID": "0",
                "name": "legion_commander_spoils_of_war"
            }
        }
    },
    "npc_dota_hero_ember_spirit": {
        "Facets": {
            "1": {
                "Icon": "fist",
                "Color": "Red",
                "GradientID": "0",
                "name": "ember_spirit_double_impact"
            },
            "2": {
                "Icon": "debuff",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "ember_spirit_chain_gang"
            }
        }
    },
    "npc_dota_hero_earth_spirit": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Green",
                "GradientID": "0",
                "name": "earth_spirit_resonance"
            },
            "2": {
                "Icon": "cooldown",
                "Color": "Gray",
                "GradientID": "2",
                "name": "earth_spirit_stepping_stone"
            },
            "3": {
                "Icon": "spinning",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "earth_spirit_ready_to_roll"
            }
        }
    },
    "npc_dota_hero_terrorblade": {
        "Facets": {
            "1": {
                "Icon": "twin_hearts",
                "Color": "Gray",
                "GradientID": "0",
                "name": "terrorblade_condemned"
            },
            "2": {
                "Icon": "illusion",
                "Color": "Blue",
                "GradientID": "2",
                "name": "terrorblade_soul_fragment"
            }
        }
    },
    "npc_dota_hero_phoenix": {
        "Facets": {
            "1": {
                "Icon": "barrier",
                "Color": "Red",
                "GradientID": "2",
                "name": "phoenix_facet_immolate",
                "AbilityName": "phoenix_dying_light"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "1",
                "name": "phoenix_hotspot"
            }
        }
    },
    "npc_dota_hero_oracle": {
        "Facets": {
            "1": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "2",
                "name": "oracle_facet_dmg",
                "AbilityName": "oracle_clairvoyant_curse"
            },
            "2": {
                "Icon": "healing",
                "Color": "Green",
                "GradientID": "1",
                "name": "oracle_facet_heal",
                "AbilityName": "oracle_clairvoyant_cure"
            }
        }
    },
    "npc_dota_hero_techies": {
        "Facets": {
            "1": {
                "Icon": "range",
                "Color": "Gray",
                "GradientID": "0",
                "name": "techies_atk_range",
                "AbilityName": "techies_squees_scope"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Red",
                "GradientID": "0",
                "name": "techies_spleens_secret_sauce"
            },
            "3": {
                "Icon": "item",
                "Color": "Blue",
                "GradientID": "1",
                "name": "techies_backpack",
                "AbilityName": "techies_spoons_stash"
            }
        }
    },
    "npc_dota_hero_winter_wyvern": {
        "Facets": {
            "1": {
                "Icon": "mana",
                "Color": "Blue",
                "GradientID": "0",
                "Deprecated": "True",
                "name": "winter_wyvern_heal_mana",
                "AbilityName": "winter_wyvern_essence_of_the_blueheart"
            },
            "2": {
                "Icon": "damage",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "True",
                "name": "winter_wyvern_atk_range",
                "AbilityName": "winter_wyvern_dragon_sight"
            },
            "3": {
                "Icon": "tower",
                "Color": "Blue",
                "GradientID": "2",
                "name": "winter_wyvern_winterproof"
            },
            "4": {
                "Icon": "ricochet",
                "Color": "Blue",
                "GradientID": "0",
                "name": "winter_wyvern_recursive"
            }
        }
    },
    "npc_dota_hero_arc_warden": {
        "Facets": {
            "1": {
                "Icon": "arc_warden",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "arc_warden_order"
            },
            "2": {
                "Icon": "arc_warden_alt",
                "Color": "Gray",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "arc_warden_disorder"
            },
            "3": {
                "Icon": "arc_warden_alt",
                "Color": "Blue",
                "GradientID": "1",
                "name": "arc_warden_runed_replica"
            },
            "4": {
                "Icon": "rune",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "arc_warden_power_capture"
            }
        }
    },
    "npc_dota_hero_abyssal_underlord": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Green",
                "GradientID": "0",
                "name": "abyssal_underlord_demons_reach"
            },
            "2": {
                "Icon": "summons",
                "Color": "Yellow",
                "GradientID": "3",
                "name": "abyssal_underlord_summons",
                "AbilityName": "abyssal_underlord_abyssal_horde"
            }
        }
    },
    "npc_dota_hero_monkey_king": {
        "Facets": {
            "1": {
                "Icon": "summons",
                "Color": "Red",
                "GradientID": "2",
                "name": "monkey_king_wukongs_faithful"
            },
            "2": {
                "Icon": "tree",
                "Color": "Green",
                "GradientID": "4",
                "MaxHeroAttributeLevel": "6",
                "name": "monkey_king_simian_stride"
            }
        }
    },
    "npc_dota_hero_pangolier": {
        "Facets": {
            "1": {
                "Icon": "double_bounce",
                "Color": "Red",
                "GradientID": "1",
                "name": "pangolier_double_jump"
            },
            "2": {
                "Icon": "speed",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "pangolier_thunderbolt"
            }
        }
    },
    "npc_dota_hero_dark_willow": {
        "Facets": {
            "1": {
                "Icon": "damage",
                "Color": "Purple",
                "GradientID": "1",
                "name": "dark_willow_throwing_shade"
            },
            "2": {
                "Icon": "area_of_effect",
                "Color": "Green",
                "GradientID": "4",
                "Deprecated": "true",
                "name": "dark_willow_thorny_thicket"
            },
            "3": {
                "Icon": "barrier",
                "Color": "Green",
                "GradientID": "4",
                "name": "dark_willow_shattering_crown"
            }
        }
    },
    "npc_dota_hero_grimstroke": {
        "Facets": {
            "1": {
                "Icon": "area_of_effect",
                "Color": "Gray",
                "GradientID": "0",
                "name": "grimstroke_inkstigate"
            },
            "2": {
                "Icon": "brush",
                "Color": "Red",
                "GradientID": "1",
                "name": "grimstroke_fine_art"
            }
        }
    },
    "npc_dota_hero_mars": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Red",
                "GradientID": "2",
                "name": "mars_victory_feast"
            },
            "2": {
                "Icon": "no_vision",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "mars_arena"
            }
        }
    },
    "npc_dota_hero_void_spirit": {
        "Facets": {
            "1": {
                "Icon": "armor",
                "Color": "Purple",
                "GradientID": "1",
                "name": "void_spirit_sanctuary"
            },
            "2": {
                "Icon": "nuke",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "void_spirit_phys_barrier",
                "AbilityName": "void_spirit_symmetry"
            },
            "3": {
                "Icon": "illusion",
                "Color": "Gray",
                "GradientID": "3",
                "name": "void_spirit_aether_artifice"
            }
        }
    },
    "npc_dota_hero_snapfire": {
        "Facets": {
            "1": {
                "Icon": "ricochet",
                "Color": "Gray",
                "GradientID": "3",
                "name": "snapfire_ricochet_ii"
            },
            "2": {
                "Icon": "range",
                "Color": "Red",
                "GradientID": "0",
                "name": "snapfire_full_bore"
            }
        }
    },
    "npc_dota_hero_hoodwink": {
        "Facets": {
            "1": {
                "Icon": "range",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "hoodwink_hunter"
            },
            "2": {
                "Icon": "tree",
                "Color": "Green",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "hoodwink_treebounce_trickshot"
            },
            "3": {
                "Icon": "cooldown",
                "Color": "Green",
                "GradientID": "0",
                "name": "hoodwink_hipshot"
            }
        }
    },
    "npc_dota_hero_dawnbreaker": {
        "Facets": {
            "1": {
                "Icon": "cooldown",
                "Color": "Gray",
                "GradientID": "3",
                "name": "dawnbreaker_solar_charged"
            },
            "2": {
                "Icon": "dawnbreaker_hammer",
                "Color": "Yellow",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "dawnbreaker_gleaming_hammer"
            },
            "3": {
                "Icon": "fist",
                "Color": "Red",
                "GradientID": "1",
                "name": "dawnbreaker_blaze"
            },
            "4": {
                "Icon": "Speed",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "dawnbreaker_hearthfire"
            }
        }
    },
    "npc_dota_hero_marci": {
        "Facets": {
            "1": {
                "Icon": "healing",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "marci_sidekick",
                "AbilityName": "marci_guardian"
            },
            "2": {
                "Icon": "ricochet",
                "Color": "Blue",
                "GradientID": "1",
                "Deprecated": "true",
                "name": "marci_bodyguard",
                "AbilityName": "marci_bodyguard"
            },
            "3": {
                "Icon": "twin_hearts",
                "Color": "Blue",
                "GradientID": "1",
                "name": "marci_buddy_system"
            },
            "4": {
                "Icon": "ricochet",
                "Color": "Purple",
                "GradientID": "0",
                "name": "marci_pickmeup"
            },
            "5": {
                "Icon": "fist",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "marci_fleeting_fury"
            }
        }
    },
    "npc_dota_hero_primal_beast": {
        "Facets": {
            "1": {
                "Icon": "speed",
                "Color": "Red",
                "GradientID": "0",
                "Deprecated": "true",
                "name": "primal_beast_romp_n_stomp"
            },
            "2": {
                "Icon": "broken_chain",
                "Color": "Red",
                "GradientID": "0",
                "name": "primal_beast_provoke_the_beast"
            },
            "3": {
                "Icon": "area_of_effect",
                "Color": "Yellow",
                "GradientID": "3",
                "name": "primal_beast_ferocity"
            }
        }
    },
    "npc_dota_hero_muerta": {
        "Facets": {
            "1": {
                "Icon": "spirit",
                "Color": "Green",
                "GradientID": "1",
                "name": "muerta_dance_of_the_dead"
            },
            "2": {
                "Icon": "teleport",
                "Color": "Yellow",
                "GradientID": "0",
                "name": "muerta_ofrenda",
                "AbilityName": "muerta_ofrenda"
            }
        }
    },
    "npc_dota_hero_ringmaster": {
        "Facets": {
            "1": {
                "Icon": "item",
                "Color": "Gray",
                "GradientID": "3",
                "Deprecated": "true",
                "name": "ringmaster_default"
            },
            "2": {
                "Icon": "whoopee_cushion",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "ringmaster_carny_classics",

            },
            "3": {
                "Icon": "pie",
                "Color": "Red",
                "GradientID": "0",
                "name": "ringmaster_sideshow_secrets",

            }
        }
    },
    "npc_dota_hero_kez": {
        "Facets": {
            "1": {
                "Icon": "kez_flutter",
                "Color": "Yellow",
                "GradientID": "1",
                "name": "kez_flutter"
            },
            "2": {
                "Icon": "kez_shadowhawk",
                "Color": "Blue",
                "GradientID": "3",
                "name": "kez_shadowhawk_passive",
                "AbilityName": "kez_shadowhawk_passive"
            }
        }
    }
};












function printHeroFacetsNames() {
    let pythonDict = {};
    
    // 创建codeName到中文名的映射
    let heroNameMap = {};
    for (let id in heroData) {
        heroNameMap[heroData[id].codeName] = heroData[id].name;
    }
    
    // 先输出字典开始
    $.Msg("hero_facets = {");
    
    let isFirst = true;
    for (const heroKey in heroesFacets) {
        const heroCodename = heroKey.replace('npc_dota_hero_', '');
        const heroChineseName = heroNameMap[heroCodename];
        
        if (!isFirst) {
            $.Msg(",");
        }
        isFirst = false;
        
        // 输出英雄键
        $.Msg(`    "${heroCodename}": {`);
        $.Msg(`        "name": "${heroChineseName}",`);
        $.Msg(`        "facets": {`);
        
        const facets = heroesFacets[heroKey].Facets;
        let isFirstFacet = true;
        
        for (const facetNumber in facets) {
            if (!isFirstFacet) {
                $.Msg(",");
            }
            isFirstFacet = false;
            
            const facet = facets[facetNumber];
            const facetToken = "#DOTA_Tooltip_Facet_" + (facet.AbilityName || facet.name);
            const abilityToken = "#DOTA_Tooltip_Ability_" + (facet.AbilityName || facet.name);
            
            const facetLocalized = $.Localize(facetToken);
            let facetName;
            if (facetLocalized !== facetToken) {
                facetName = facetLocalized;
            } else {
                facetName = $.Localize(abilityToken);
            }
            
            $.Msg(`            "${facetNumber}": "${facetName}"`);
        }
        
        $.Msg("        }");
        $.Msg("    }");
    }
    
    // 输出字典结束
    $.Msg("}");
}

printHeroFacetsNames();

// function printNeutralCreepsLocalization() {
//     const creeps = [
//         "npc_dota_neutral_wildkin",
//         "npc_dota_neutral_enraged_wildkin",
//         "npc_dota_neutral_centaur_outrunner",
//         "npc_dota_neutral_centaur_khan",
//         "npc_dota_neutral_ogre_mauler",
//         "npc_dota_neutral_ogre_magi",
//         "npc_dota_neutral_satyr_trickster",
//         "npc_dota_neutral_satyr_soulstealer",
//         "npc_dota_neutral_satyr_hellcaller", 
//         "npc_dota_neutral_dark_troll",
//         "npc_dota_neutral_forest_troll_berserker",
//         "npc_dota_neutral_forest_troll_high_priest",
//         "npc_dota_neutral_dark_troll_warlord",
//         "npc_dota_neutral_polar_furbolg_ursa_warrior",
//         "npc_dota_neutral_polar_furbolg_champion",
//         "npc_dota_neutral_alpha_wolf",
//         "npc_dota_neutral_giant_wolf",
//         "npc_dota_neutral_harpy_scout",
//         "npc_dota_neutral_harpy_storm",
//         "npc_dota_neutral_kobold",
//         "npc_dota_neutral_kobold_tunneler",
//         "npc_dota_neutral_kobold_taskmaster",
//         "npc_dota_neutral_mud_golem",
//         "npc_dota_neutral_fel_beast",
//         "npc_dota_neutral_ghost",
//         "npc_dota_neutral_gnoll_assassin",
//         "npc_dota_neutral_warpine_raider",
//         "npc_dota_neutral_black_drake",
//         "npc_dota_neutral_black_dragon",
//         "npc_dota_neutral_granite_golem",
//         "npc_dota_neutral_rock_golem", 
//         "npc_dota_neutral_ice_shaman",
//         "npc_dota_neutral_elder_jungle_stalker",
//         "npc_dota_neutral_jungle_stalker",
//         "npc_dota_neutral_prowler_acolyte",
//         "npc_dota_neutral_prowler_shaman",
//         "npc_dota_neutral_small_thunder_lizard",
//         "npc_dota_neutral_big_thunder_lizard"
//     ];

//     for (const name of creeps) {
//         const localizedName = $.Localize(name);
//         $.Msg(`${name} - ${localizedName}`);
//     }
// }
// printNeutralCreepsLocalization()

// function findCorrectLocalizationKey() {
//     const testKeys = [
//         "npc_dota_wildkin",
//         "DOTA_Tooltip_neutral_wildkin",
//         "DOTA_Neutral_Wildkin",
//         "DOTA_Tooltip_ability_neutral_wildkin",
//         // 移除npc_dota_前缀的版本
//         "neutral_wildkin",
//         // 大写版本
//         "Wildkin",
//         "WILDKIN"
//     ];
    
//     for (const key of testKeys) {
//         const localizedName = $.Localize(key);
//         $.Msg(`Testing key: ${key} -> ${localizedName}`);
//     }
// }
// findCorrectLocalizationKey()