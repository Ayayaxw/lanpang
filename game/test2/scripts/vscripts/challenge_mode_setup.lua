require("challenges/hero_display")  
require("challenges/monkey_king")  
require("challenges/CreepChallenge_100Creeps")  
require("challenges/HeroChaos")  
require("challenges/HeroChallenge_illusion")  
require("challenges/cd0_1skill")  
require("challenges/hero_special_check")  
require("challenges/Fall_Flat")  
require("challenges/TestMode")  
require("challenges/Five_Times_Attribute")  
require("challenges/movie_mode")  
require("challenges/Save_Mor")  
require("challenges/Work_Work")  
require("challenges/Upside_Down")  
require("challenges/cd0_2skill")  
require("challenges/Illusion_3X")  
require("challenges/super_hero_chaos")  
require("challenges/Level1_Duel")  
require("challenges/DeathRandom")  
require("challenges/Upside_Down_attribute")  
require("challenges/Ursa800")  
require("challenges/Courier800")  
require("challenges/Magnataur5")  
require("challenges/Double_on_death")  
require("challenges/MAG_DREAM")  
require("challenges/SnipeHunt")  
require("challenges/Duel_1VS30")  
require("challenges/MillGrinding")  
require("challenges/SuperCreepChallenge90CD")  
require("challenges/mode_5v5")  
require("challenges/mode_5v5_2")  
require("challenges/mode_10v10")  
require("challenges/MeepoChaos")  
require("challenges/CreepChaos")  
require("challenges/Aoe_10X")  
require("challenges/Level7Dazzle")  
require("challenges/waterfall_hero_chaos")  
require("challenges/award_ceremony")  
require("challenges/SoulOut")  
require("challenges/SoulOut_Sniper")  
require("challenges/Golem_100")  

Main.Challenges = {}
Main.ModeConfig = {}
Main.GameModes = {
    -- Test modes (0000-0999)
    {
        id = "HeroChaos",
        code = 0000,
        name = "大乱斗",
        menuConfig = {},
        category = "test"
    },
    {
        id = "HeroDisplay", 
        code = 0001,
        name = "英雄展示",
        menuConfig = {},
        category = "test"
    },
    {
        id = "movie_mode",
        code = 0003,
        name = "电影模式",
        menuConfig = {},
        category = "test"
    },
    {
        id = "Save_Mor",
        code = 0004,
        name = "拯救水人",
        menuConfig = {"SelfHeroRow"},
        category = "test"
    },
    {
        id = "Level1_Duel",
        code = 0005,
        name = "一级单挑",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "test"
    },
    {
        id = "Work_Work_2",
        code = 0006,
        name = "打螺丝之殇2",
        menuConfig = {"SelfHeroRow"},
        category = "test"
    },
    {
        id = "DeathRandom",
        code = 0007,
        name = "死亡随机",
        menuConfig = {},
        category = "test"
    },
    {
        id = "super_hero_chaos",
        code = 0008,
        name = "超级大乱斗",
        menuConfig = {},
        category = "test"
    },
    {
        id = "mode_10v10",
        code = 0009,
        name = "10v10对决",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "test"
    },
    {
        id = "waterfall_hero_chaos",
        code = 0010,
        name = "瀑布大乱斗",
        menuConfig = {},
        category = "test"
    },
    {
        id = "award_ceremony",
        code = 0011,
        name = "颁奖模式",
        menuConfig = {},
        category = "test"
    },

    -- Creep Challenge modes (1000-1999)
    {
        id = "CreepChallenge_100Creeps",
        code = 1001,
        name = "100远程兵挑战",
        menuConfig = {"SelfHeroRow"},
        category = "creep"
    },
    {
        id = "SuperCreepChallenge90CD",
        code = 1002,
        name = "90%减CD击杀大赛",
        menuConfig = {"SelfHeroRow"},
        category = "creep"
    },

    -- Multiplayer modes (2000-2999)
    {
        id = "CD0_1skill",
        code = 2001,
        name = "一技能无CD",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Fall_Flat",
        code = 2003,
        name = "斗蛆蛆",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Five_Times_Attribute",
        code = 2004,
        name = "五倍属性",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "TestMode",
        code = 2005,
        name = "单挑",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Upside_Down",
        code = 2006,
        name = "反转了",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Upside_Down_attribute",
        code = 2007,
        name = "属性反转",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "CD0_2skill",
        code = 2008,
        name = "二技能无CD",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Illusion_3X",
        code = 2009,
        name = "三倍镜像",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Duel_1VS30",
        code = 2010,
        name = "1级还是30级?",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "mode_5v5",
        code = 2011,
        name = "5v5对决-三倍属性版",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "mode_5v5_2",
        code = 2012,
        name = "5v5对决",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "MeepoChaos",
        code = 2013,
        name = "超级米波大乱斗",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },
    {
        id = "Level7Dazzle",
        code = 2014,
        name = "对战7级戴泽",
        menuConfig = {"SelfHeroRow", "OpponentHeroRow"},
        category = "multiplayer"
    },

    -- Single player modes (3000-3999)
    {
        id = "HeroChallenge_illusion",
        code = 3003,
        name = "幻象对决",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Work_Work",
        code = 3004,
        name = "打螺丝之殇",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Ursa800",
        code = 3005,
        name = "300拍拍",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Courier800",
        code = 3006,
        name = "抓小鸡",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Magnataur5",
        code = 3007,
        name = "猛犸冲锋",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Double_on_death",
        code = 3008,
        name = "死亡翻倍",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "MAG_DREAM",
        code = 3009,
        name = "猛犸梦想",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "SnipeHunt",
        code = 3010,
        name = "狙击猎杀",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "MillGrinding",
        code = 3011,
        name = "人马拉磨",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "CreepChaos",
        code = 3012,
        name = "超级野怪合体",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Aoe_10X",
        code = 3013,
        name = "10倍技能范围",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "SoulOut",
        code = 3014,
        name = "灵魂出窍生存",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "SoulOut_Sniper",
        code = 3015,
        name = "灵魂出窍狙击",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    },
    {
        id = "Golem_100",
        code = 3016,
        name = "100地狱火",
        menuConfig = {"SelfHeroRow"},
        category = "single"
    }
}

-- 自动生成 Challenges 和 ModeConfig
for _, mode in ipairs(Main.GameModes) do
    Main.Challenges[mode.id] = mode.code
    Main.ModeConfig[mode.code] = mode.menuConfig
end

Main.currentChallenge = nil

function Main:SendGameModesData()
    local gameModes = {}
    
    for _, mode in ipairs(Main.GameModes) do
        -- 非工具模式下过滤测试类模式
        if not IsInToolsMode() and mode.category == "test" then
            goto continue
        end

        local modeData = {
            code = mode.code,
            name = mode.name,
            menuConfig = mode.menuConfig,
            menuConfigType = "array",
            category = mode.category
        }

        table.insert(gameModes, modeData)

        ::continue::
    end

    CustomGameEventManager:Send_ServerToAllClients("initialize_game_modes", gameModes)
end





function Main:RequestStrategyData()
    local global_strategies = {
        {
            name = "默认策略",
            id = "default_standard"
        },
        {
            name = "防守策略",
            id = "defensive_mode"
        },
        {
            name = "原地不动",
            id = "stay_position"
        },
        {
            name = "攻击无敌单位",
            id = "attack_invulnerable"
        },
        {
            name = "不允许对非英雄释放控制",
            id = "no_control_non_hero"
        },
        {
            name = "辅助模式",
            id = "support_mode"
        },
        {
            name = "禁用普攻",
            id = "disable_normal_attack"
        },
        {
            name = "满血开撒旦",
            id = "full_hp_satanic"
        },
        {
            name = "贴脸放电锤",
            id = "close_range_mjollnir"
        },
        {
            name = "不要优先拆墓碑、棒子",
            id = "priority_structure_destroy"
        },
        {
            name = "优先打小僵尸",
            id = "priority_minion_zombie"
        },
        {
            name = "禁用一技能",
            id = "ability_1_disable"
        },
        {
            name = "禁用二技能",
            id = "ability_2_disable"
        },
        {
            name = "禁用三技能",
            id = "ability_3_disable"
        },
        {
            name = "禁用四技能",
            id = "ability_4_disable"
        },
        {
            name = "禁用五技能",
            id = "ability_5_disable"
        },
        {
            name = "禁用大招",
            id = "ultimate_disable"
        },
        {
            name = "不到半血绝不放大",
            id = "half_hp_ultimate_lock"
        },
        {
            name = "不到80%血绝不放大",
            id = "hp_80_ultimate_lock"
        },
        {
            name = "不在骨法棒子里放技能",
            id = "no_skill_in_death_ward"
        },
        {
            name = "超大米波模式",
            id = "super_meepo_mode"
        },
        {
            name = "留控打断",
            id = "keep_control_interrupt"
        },
        {
            name = "谁近打谁",
            id = "who_near_attack_who"
        },
    }

    --if self:containsStrategy(self.hero_strategy, "躲避模式") then
    local hero_strategies = {
        npc_dota_hero_dawnbreaker = {  -- 天怒法师
        {
            name = "满血开大",
            id = "full_hp_ultimate"
        },

    },
        npc_dota_hero_skywrath_mage = {  -- 天怒法师
            {
                name = "大招弹射",
                id = "mystic_flare_bounce"
            },
            {
                name = "优先开大",
                id = "prioritize_mystic_flare"
            },
            {
                name = "优先沉默",
                id = "prioritize_silence"
            },
        },
        npc_dota_hero_puck = {  -- 帕克
            {
                name = "沉默赶路",
                id = "silence_move"
            },
            {
                name = "相位转移打伤害",
                id = "phase_shift_damage"
            },
            {
                name = "优先放大",
                id = "prioritize_ult"
            },
            {
                name = "飞身后",
                id = "phase_shift_behind"
            },
            {
                name = "贴脸才相位转移",
                id = "close_range_phase_shift"
            },
        },
        npc_dota_hero_monkey_king = {  -- 齐天大圣 
            {
                name = "BUFF板",
                id = "jingu_mastery_board"
            },
            {
                name = "先开大",
                id = "prioritize_ultimate"
            },
        },
        npc_dota_hero_oracle = {  -- 齐天大圣 
        {
            name = "满血开大",
            id = "full_hp_ultimate"
        },
    },
        npc_dota_hero_mirana = {  -- 米拉娜
            {
                name = "优先跳",
                id = "prioritize_leap"
            },
            {
                name = "随机跳",
                id = "random_leap"
            },
            {
                name = "有人贴脸就跳",
                id = "close_range_leap"
            },

        },
        npc_dota_hero_dazzle = {  -- 戴泽
            {
                name = "剩1秒续薄葬",
                id = "grave_refresh_1sec"
            },
            {
                name = "剩2秒续薄葬",
                id = "grave_refresh_2sec"
            },
            {
                name = "剩3秒续薄葬",
                id = "grave_refresh_3sec"
            },
            {
                name = "剩4秒续薄葬", 
                id = "grave_refresh_4sec"
            },
            {
                name = "无限薄葬",
                id = "infinite_grave"
            },
            {
                name = "半血薄葬",
                id = "3"
            },
            {
                name = "20%血薄葬",
                id = "1"
            },
            {
                name = "10%血薄葬",
                id = "2"
            },
            {
                name = "不学薄葬",
                id = "4"
            },
            {
                name = "主学治疗波",
                id = "5"
            },
            {
                name = "满血治疗波",
                id = "6"
            },
            {
                name = "治疗波打伤害",
                id = "7"
            },
            {
                name = "满血薄葬",
                id = "full_hp_grave"
            },
        },
        npc_dota_hero_kez = {  -- 凯
            {
                name = "禁用隐身大招",
                id = "disable_invisible_ultimate"
            },
            {
                name = "禁用回音重斩",
                id = "disable_echo_slash"
            },
            {
                name = "禁用沉默",
                id = "disable_silence"
            },
            {
                name = "天隼冲击优先",
                id = "prioritize_falcon_strike"
            },
            {
                name = "半血开大",
                id = "half_hp_ult"
            },
            {
                name = "丝血开大",
                id = "low_hp_ult"
            },
            {
                name = "远距离冲刺",
                id = "long_range_sprint"
            },
            {
                name = "冲刺后不切形态",
                id = "no_form_change"
            },
            {
                name = "优先开大",
                id = "prioritize_ult"
            },
            {
                name = "沉默接大",
                id = "silence_into_ult"
            },
            {
                name = "标记暴击",
                id = "mark_crit"
            },
            {
                name = "拖延",
                id = "delay_tactics"
            },
            {
                name = "驱散禁锢",
                id = "dispel_root"
            },
            {
                name = "优先盾反",
                id = "prioritize_shield_counter"
            },
        },
        npc_dota_hero_terrorblade = {  -- 熊战士
            {
                name = "满血开恐惧",
                id = "full_hp_terror"
            },
        },
        npc_dota_hero_warlock = {  -- 熊战士
            {
                name = "先给自己奶",
                id = "self_heal_first"
            },
        },
        npc_dota_hero_obsidian_destroyer = {  -- 熊战士
            {
                name = "满血开大",
                id = "full_hp_ultimate"
            },
        },
        npc_dota_hero_witch_doctor = {  -- 熊战士
            {
                name = "满血开魔晶",
                id = "full_hp_shard"
            },
        },
        npc_dota_hero_dark_willow = {  -- 熊战士
            {
                name = "暗影之境直接开",
                id = "instant_shadow_realm"
            },
            {
                name = "主动靠近作祟",
                id = "active_terrorize"
            },
        },
        npc_dota_hero_furion = {  -- 熊战士
            {
                name = "先招小树人",
                id = "prioritize_treants"
            },
        },
        npc_dota_hero_ursa = {  -- 熊战士
            {
                name = "用跳赶路",
                id = "jump_move"
            },
            {
                name = "秒解控",
                id = "instant_enrage"
            },
        },
        npc_dota_hero_rattletrap = {  -- 发条技师
            {
                name = "用框弹人",
                id = "cogs_push"
            },
            {
                name = "出门放齿轮",
                id = "start_with_battery"
            },
        },
        npc_dota_hero_windrunner = {  -- 风行者
            {
                name = "贴脸不射箭",
                id = "no_close_powershot"
            },
        },
        npc_dota_hero_phoenix = {  -- 风行者
            {
                name = "满血开大",
                id = "1"
            },
            {
                name = "半血开大",
                id = "2"
            },
        },
        npc_dota_hero_nevermore = {  -- 风行者
            {
                name = "满血开大",
                id = "1"
            },
            {
                name = "全图摇大",
                id = "2"
            },
        },
        npc_dota_hero_pangolier = {  -- 石鳞剑士
            {
                name = "靠近就魔晶",
                id = "shard_when_close"
            },
            {
                name = "出门不放魔晶",
                id = "start_with_shard"
            },
            {
                name = "不要优先放魔晶",
                id = "prioritize_shard"
            },
            {
                name = "禁止连跳",
                id = "1"
            },
        },
        npc_dota_hero_bane = {  -- 祸乱之源
            {
                name = "优先虚弱",
                id = "prioritize_enfeeble"
            },
        },
        npc_dota_hero_batrider = {  -- 蝙蝠骑士
            {
                name = "弹开",
                id = "flamebreak_push"
            },
        },
        npc_dota_hero_void_spirit = {  -- 虚无之灵
            {
                name = "异化赶路",
                id = "dissimilate_move"
            },
            {
                name = "续沉默",
                id = "refresh_silence"
            },
        },
        npc_dota_hero_visage = {  -- 维萨吉
            {
                name = "残血坐鸟",
                id = "low_hp_stone_form"
            },
            {
                name = "禁止鸟自主坐下",
                id = "no_auto_stone_form"
            },
            {
                name = "小鸟挡箭",
                id = "familiars_block"
            },
            {
                name = "满血石化",
                id = "1"
            },
        },
        npc_dota_hero_enigma = {  -- 谜团
            {
                name = "小谜团上限",
                id = "eidolon_limit"
            },
            {
                name = "招到80%血",
                id = "convert_at_80hp"
            },
        },
        npc_dota_hero_abaddon = {  -- 亚巴顿
            {
                name = "贴脸放盾",
                id = "melee_shield"
            },
            {
                name = "无限续盾",
                id = "refresh_no_shield"
            },
            {
                name = "手动开大",
                id = "1"
            },
        },
        npc_dota_hero_sand_king = {  -- 沙王
            {
                name = "提前摇大",
                id = "early_epicenter"
            },
        },

        npc_dota_hero_storm_spirit = {  -- 风暴之灵
            {
                name = "折叠飞",
                id = "storm_combo"
            },
            {
                name = "飞脸前",
                id = "storm_initiate"
            },
        },
        npc_dota_hero_doom_bringer = {  -- 末日使者
            {
                name = "给予枭兽",
                id = "devour_wildkin"
            },
            {
                name = "给予枭兽撕裂者",
                id = "devour_wildkin_ripper"
            },
            {
                name = "给予半人马猎手",        -- 改
                id = "devour_centaur_small"
            },
            {
                name = "给予半人马撕裂者",      -- 改
                id = "devour_centaur_large"
            },
            {
                name = "给予食人魔拳手",        -- 改
                id = "devour_ogre_small"
            },
            {
                name = "给予食人魔冰霜法师",    -- 改
                id = "devour_ogre_large"
            },
            {
                name = "给予萨特放逐者",
                id = "devour_satyr_small"
            },
            {
                name = "给予萨特窃神者",        -- 改
                id = "devour_satyr_medium"
            },
            {
                name = "给予萨特苦难使者",      -- 改
                id = "devour_satyr_large"
            },
            {
                name = "给予丘陵巨魔",
                id = "devour_troll_small"
            },
            {
                name = "给予丘陵巨魔狂战士",
                id = "devour_troll_berserker"
            },
            {
                name = "给予丘陵巨魔牧师",
                id = "devour_troll_priest"
            },
            {
                name = "给予黑暗巨魔召唤法师",  -- 改
                id = "devour_troll_large"
            },
            {
                name = "给予地狱熊怪",
                id = "devour_furbolg_medium"
            },
            {
                name = "给予地狱熊怪粉碎者",    -- 改
                id = "devour_furbolg_large"
            },
            {
                name = "给予巨狼",
                id = "devour_wolf_small"
            },
            {
                name = "给予头狼",              -- 改
                id = "devour_wolf_large"
            },
            {
                name = "给予鹰身女妖侦察者",    -- 改
                id = "devour_harpy_small"
            },
            {
                name = "给予鹰身女妖风暴巫师",  -- 改
                id = "devour_harpy_storm"
            },
            {
                name = "给予狗头人",            -- 改
                id = "devour_kobold_small"
            },
            {
                name = "给予狗头人士兵",        -- 改
                id = "devour_kobold_medium"
            },
            {
                name = "给予狗头人长官",        -- 改
                id = "devour_kobold_large"
            },
            {
                name = "给予泥土傀儡",
                id = "devour_mud_golem"
            },
            {
                name = "给予魔能之魂",          -- 改
                id = "devour_fel_beast"
            },
            {
                name = "给予鬼魂",              -- 改
                id = "devour_ghost"
            },
            {
                name = "给予豺狼人刺客",
                id = "devour_gnoll"
            },
            {
                name = "给予斗松掠夺者",        -- 改
                id = "devour_warpine"
            },
            -- 远古野怪
            {
                name = "给予远古黑蜉蝣",        -- 改
                id = "devour_black_drake"
            },
            {
                name = "给予远古黑龙",
                id = "devour_black_dragon"
            },
            {
                name = "给予远古花岗岩傀儡",    -- 改
                id = "devour_granite_golem"
            },
            {
                name = "给予远古岩石傀儡",      -- 改
                id = "devour_rock_golem"
            },
            {
                name = "给予远古寒冰萨满",      -- 改
                id = "devour_ice_shaman"
            },
            {
                name = "给予远古霜害傀儡",      -- 改
                id = "devour_frost_golem"
            },
            {
                name = "给予远古潜行者长老",    -- 改
                id = "devour_elder_jungle_stalker"
            },
            {
                name = "给予远古潜行者",        -- 改
                id = "devour_jungle_stalker"
            },
            {
                name = "给予远古侍僧潜行者",    -- 改
                id = "devour_prowler_acolyte"
            },
            {
                name = "给予远古萨满潜行者",    -- 改
                id = "devour_prowler_shaman"
            },
            {
                name = "给予远古岚肤兽",        -- 改
                id = "devour_small_thunder_lizard"
            },
            {
                name = "给予远古雷肤兽",        -- 改
                id = "devour_big_thunder_lizard"
            },
    
            {
                name = "不大自己",
                id = "doom_self"
            },
            {
                name = "半路大",
                id = "doom_on_way"
            }
        },
        npc_dota_hero_luna = {  -- 露娜
            {
                name = "大招封走位",
                id = "eclipse_block_path"
            },
            {
                name = "大招确保罩到自己",
                id = "eclipse_self_coverage"
            },
        },
        npc_dota_hero_brewmaster = {  -- 酒仙
            {
                name = "满血开大",
                id = "full_hp_split"
            },
            {
                name = "无限灌酒",
                id = "infinite_drink"
            },
        },
        npc_dota_hero_nyx_assassin = {  -- 司夜刺客
            {
                name = "出门开壳",
                id = "start_with_shell"
            },
            {
                name = "掉血开壳",
                id = "low_hp_shell"
            },
            {
                name = "出门埋地",
                id = "start_with_burrow"
            },
        },
        npc_dota_hero_earthshaker = {  -- 撼地者
            {
                name = "自定义",
                id = "2"
            },
            {
                name = "原地图腾",
                id = "1"
            },
            {
                name = "图腾赶路",
                id = "totem_move"
            },
            {
                name = "沟壑连招",
                id = "fissure_combo"
            },
            {
                name = "边走边图腾",
                id = "move_with_totem"
            },
            {
                name = "远程余震",
                id = "long_range_aftershock"
            },
            {
                name = "朝面前沟壑",
                id = "3"
            },
        },
        npc_dota_hero_omniknight = {  -- 全能骑士
            {
                name = "满血开大",
                id = "half_hp_guardian"
            },

        },
        npc_dota_hero_pugna = {  
            {
                name = "虚无自己",
                id = "1"
            },
            {
                name = "不虚无自己",
                id = "2"
            },
        },
        npc_dota_hero_meepo = {  
            {
                name = "满血合体",
                id = "1"
            },
        },
        npc_dota_hero_weaver = {  
            {
                name = "满血开大",
                id = "1"
            },
        },
        npc_dota_hero_hoodwink = {  -- 松鼠
            {
                name = "对地板放栗子",
                id = "acorn_on_ground"
            },
            {
                name = "必须弹射栗子",
                id = "must_bounce_acorn"
            },
        },
        npc_dota_hero_slark = {  -- 斯拉克
            {
                name = "出门直接跳",
                id = "pounce_on_spawn"
            },
            {
                name = "100层后不用跳",
                id = "no_pounce_after_100"
            },
            {
                name = "200层后不用跳",
                id = "no_pounce_after_200"
            },
            {
                name = "出门直接放大",
                id = "ult_on_spawn"
            },
            {
                name = "提前开C",
                id = "early_shadow_dance"
            },
            {
                name = "跳慢点",
                id = "1"
            },
            {
                name = "魔晶只给自己",
                id = "2"
            },
        },
        npc_dota_hero_zuus = {  -- 宙斯
            {
                name = "主动进攻",
                id = "aggressive_lightning"
            },
            {
                name = "对自己放雷云",
                id = "self_nimbus"
            },
            {
                name = "对琼英碧灵专用",
                id = "counter_puck"
            },
        },
        npc_dota_hero_keeper_of_the_light = {  -- 宙斯
            {
                name = "查克拉只给自己",
                id = "1"
            },
        },
        npc_dota_hero_naga_siren = {  -- 娜迦海妖
            {
                name = "满血唱歌",
                id = "song_full_hp"
            },
            {
                name = "残血唱歌",
                id = "song_low_hp"
            },
        },
        npc_dota_hero_lina = {  
            {
                name = "优先神灭斩",
                id = "1"
            },
        },
        npc_dota_hero_juggernaut = {  -- 主宰
            {
                name = "半血无敌斩",
                id = "blade_fury_half_hp"
            },
            {
                name = "80%血放奶棒",
                id = "healing_ward_80hp"
            },
            {
                name = "无限斩",
                id = "1"
            },
            {
                name = "出门开转",
                id = "2"
            },
        },
        npc_dota_hero_morphling = {  -- 变体精灵
            {
                name = "波赶路",
                id = "wave_move"
            },
            {
                name = "走两步波",
                id = "1"
            },
            {
                name = "优先力量打击",
                id = "2"
            },
            {
                name = "无缝波",
                id = "3"
            },
            {
                name = "波最远",
                id = "4"
            },
            {
                name = "圆形波",
                id = "5"
            },
            {
                name = "反复横跳波",
                id = "6"
            },
            {
                name = "不变回去",
                id = "7"
            },

            {
                name = "500开始转血",
                id = "morph_at_500hp"
            },
            {
                name = "1000开始转血",
                id = "morph_at_1000hp"
            },
            {
                name = "2000开始转血",
                id = "morph_at_2000hp"
            },
        },
        npc_dota_hero_leshrac = {  -- 拉席克
            {
                name = "省蓝",
                id = "save_mana"
            },
        },
        npc_dota_hero_templar_assassin = {  -- 圣堂刺客
            {
                name = "陷阱不自动引爆",
                id = "auto_detonate_trap"
            },
            {
                name = "允许传送",
                id = "1"
            },

        },
        npc_dota_hero_viper = {  -- 冥界亚龙
            {
                name = "优先开大",
                id = "disable_nose_dive"
            },
        },
        npc_dota_hero_disruptor = {  -- 干扰者
            {
                name = "防帕克",
                id = "counter_puck"
            },
        },
        npc_dota_hero_muerta = {  -- 穆尔塔
            {
                name = "防帕克",
                id = "counter_puck"
            },
            {
                name = "铺满",
                id = "full_coverage"
            },
            {
                name = "连发",
                id = "rapid_fire"
            },
        },
        npc_dota_hero_legion_commander = {  -- 军团指挥官
            {
                name = "续魔免",
                id = "refresh_bkb"
            },
            {
                name = "满血强攻",
                id = "1"
            },
        },
        npc_dota_hero_invoker = {  -- 祈求者
            {
                name = "神罗天征",
                id = "deafening_blast"
            },
            {
                name = "优先吹风",
                id = "prioritize_tornado"
            },
            {
                name = "帕金森",
                id = "parkinsons"
            },
            {
                name = "吹起来招小火人-二技能无CD专用",
                id = "summon_forge_after_lift"
            },
            {
                name = "吹起来放磁暴",
                id = "1"
            },
            {
                name = "磁暴炸自己",
                id = "2"
            },
            {
                name = "灵动迅捷优先给队友",
                id = "1"
            },
            {
                name = "火人-灵动迅捷-吹风-磁暴-天火",
                id = "4"
            },
            {
                name = "火人-灵动迅捷-吹风-天火-磁暴",
                id = "5"
            },
            {
                name = "极速冷却-吹风-磁暴-天火",
                id = "6"
            },
            {
                name = "正面冰墙",
                id = "7"
            },
            {
                name = "推波、陨石、冰墙",
                id = "8"
            },
            {
                name = "常驻火球",
                id = "9"
            },
            {
                name = "常驻冰球",
                id = "10"
            },
            {
                name = "常驻雷球",
                id = "11"
            },

            {
                name = "禁用极速冷却",
                id = "disable_cold_snap"
            },
            {
                name = "禁用幽灵漫步",
                id = "disable_ghost_walk"
            },
            {
                name = "禁用吹风",
                id = "disable_tornado"
            },
            {
                name = "禁用磁暴",
                id = "disable_emp"
            },
            {
                name = "禁用灵动迅捷",
                id = "disable_alacrity"
            },
            {
                name = "禁用陨石",
                id = "disable_chaos_meteor"
            },
            {
                name = "禁用天火",
                id = "disable_sun_strike"
            },
            {
                name = "禁用火元素",
                id = "disable_forge_spirit"
            },
            {
                name = "禁用冰墙",
                id = "disable_ice_wall"
            },



        },
        npc_dota_hero_shadow_shaman = {  -- 暗影萨满
            {
                name = "优先变羊",
                id = "prioritize_hex"
            },
        },
        npc_dota_hero_phantom_lancer = {  -- 幻影长矛手
            {
                name = "优先丢矛",
                id = "prioritize_lance"
            },
        },
        npc_dota_hero_necrolyte = {  -- 瘟疫法师
            {
                name = "满血直接斩",
                id = "scythe_full_hp"
            },
            {
                name = "对自己放魔晶",
                id = "1"
            },
        },
        npc_dota_hero_faceless_void = {
            {
                name = "贴脸才放大",
                id = "1"
            },
            {
                name = "满血跳",
                id = "2"
            },
        },
        npc_dota_hero_arc_warden = {  -- 天穹守望者
            {
                name = "优先沉默",
                id = "prioritize_silence"
            },
            {
                name = "分身放身边",
                id = "1"
            },
        },
        npc_dota_hero_bloodseeker = {  -- 血魔
            {
                name = "血祭封走位",
                id = "rupture_block_path"
            },
            {
                name = "血祭脚底下",
                id = "rupture_at_feet"
            },
        },
        npc_dota_hero_ember_spirit = {  -- 灰烬之灵
            {
                name = "躲避模式",
                id = "evasive_mode"
            },
            {
                name = "躲避模式1000码",
                id = "evasive_mode800"
            },
            {
                name = "禁止连飞",
                id = "1"
            },
            {
                name = "飞魂期间不放无影拳",
                id = "2"
            },
        },
        npc_dota_hero_tusk = {  -- 巨牙海民
            {
                name = "秒放雪球",
                id = "instant_snowball"
            },
        },
        npc_dota_hero_bristleback = {  -- 刚背兽
            {
                name = "远距离针刺",
                id = "long_range_quill"
            },
            {
                name = "提前转身",
                id = "early_turn"
            },
        },
        npc_dota_hero_slardar = {  -- 斯拉达
            {
                name = "踩水洼",
                id = "puddle_crush"
            },
        },
        npc_dota_hero_tiny = {  -- 小小
            {
                name = "优先拔树",
                id = "prioritize_tree_grab"
            },
            {
                name = "原地山崩",
                id = "stationary_avalanche"
            },
        },
        npc_dota_hero_chaos_knight = {  -- 混沌骑士
            {
                name = "先晕再大",
                id = "stun_before_ult"
            },
            {
                name = "先手晕",
                id = "initiate_stun"
            },
            {
                name = "刷沉默",
                id = "refresh_silence"
            },
        },
        npc_dota_hero_abyssal_underlord = {  -- 深渊领主
            {
                name = "对自己放火雨",
                id = "self_firestorm"
            },
        },
        npc_dota_hero_life_stealer = {  -- 噬魂鬼
            {
                name = "秒解控",
                id = "instant_rage"
            },
        },
        npc_dota_hero_mars = {  -- 玛尔斯
            {
                name = "先大后矛",
                id = "arena_before_spear"
            },
        },
        npc_dota_hero_marci = {  -- 玛尔斯
            {
                name = "出门开大",
                id = "1"
            },
        },
        npc_dota_hero_alchemist = {  -- 炼金术士
            {
                name = "半血开大",
                id = "rage_at_half_hp"
            },
            {
                name = "残血开大",
                id = "rage_at_low_hp"
            },
        },
        npc_dota_hero_troll_warlord = {  -- 巨魔战将
            {
                name = "远距离飞斧",
                id = "long_range_axes"
            },
            {
                name = "秒解控",
                id = "instant_battle_trance"
            },
            {
                name = "出门开大",
                id = "ult_on_spawn"
            },
        },
        npc_dota_hero_drow_ranger = {  -- 巨魔战将
        {
            name = "出门放冰川",
            id = "1"
        },

    },
            
    }

    --if self:containsStrategy(self.hero_strategy, "躲避模式") then
    -- 将英雄名转换为英雄ID
    local hero_id_strategies = {}
    for hero_name, strategies in pairs(hero_strategies) do
        local hero_id = DOTAGameManager:GetHeroIDByName(hero_name)
        if hero_id then
            hero_id_strategies[hero_id] = strategies
        end
    end

    local strategy_data = {
        global_strategies = global_strategies,
        hero_strategies = hero_id_strategies
    }

    CustomGameEventManager:Send_ServerToAllClients("initialize_strategy_data", strategy_data)
    print("英雄策略数据已发送到前端")
end




function Main:RequestItemData()
    local itemList = {}
    local itemListKV = LoadKeyValues('scripts/npc/items.txt')
    local customItemListKV = LoadKeyValues('scripts/npc/npc_items_custom.txt')
    
    -- 检查 itemListKV 是否成功加载
    if itemListKV then
        for itemName, itemData in pairs(itemListKV) do
            if type(itemData) == "table" and not string.find(itemName:lower(), "recipe") then
                local displayName = itemData.ItemAliases or itemName
                local isNeutralDrop = (itemData.ItemIsNeutralDrop == 1)
                local isPurchasable = (itemData.ItemPurchasable ~= 0)
                local itemCost = tonumber(itemData.ItemCost) or 0  -- 添加物品价格
                
                table.insert(itemList, {
                    name = itemName,
                    id = itemName,
                    displayName = displayName,
                    isNeutralDrop = isNeutralDrop,
                    isCustomItem = false,
                    isSpecialItem = not isPurchasable and not isNeutralDrop,
                    cost = itemCost  -- 添加价格字段
                })
            end
        end
    else
        print("警告: 无法加载 items.txt 文件")
    end

    -- 检查 customItemListKV 是否成功加载
    if customItemListKV then
        for itemName, itemData in pairs(customItemListKV) do
            if type(itemData) == "table" and not string.find(itemName:lower(), "recipe") then
                local displayName = itemData.ItemAliases or itemName
                local isPurchasable = (itemData.ItemPurchasable ~= 0)
                local itemCost = tonumber(itemData.ItemCost) or 0  -- 添加物品价格
                
                table.insert(itemList, {
                    name = itemName,
                    id = itemName,
                    displayName = displayName,
                    isNeutralDrop = false,
                    isCustomItem = true,
                    isSpecialItem = not isPurchasable,
                    cost = itemCost  -- 添加价格字段
                })
            end
        end
    else
        print("警告: 无法加载 npc_items_custom.txt 文件")
    end

    CustomGameEventManager:Send_ServerToAllClients("send_item_list", { items = itemList })
end