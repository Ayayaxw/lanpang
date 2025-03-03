-- Generated from template
require("app/index")
require("hero_data")



function Precache(context)
    local heroParticlePath = "particles/units/heroes/hero_"
    local heroSoundPath = "soundevents/game_sounds_heroes/game_sounds_"
    local heroModelPath = "models/heroes/"

    -- 设置标识符来控制英雄的加载
    -- 1: 加载力量英雄
    -- 2: 加载敏捷英雄
    -- 4: 加载智力英雄
    -- 8: 加载全才英雄
    local loadType = 15  -- 例如，设置为3时将加载力量和敏捷英雄
    if IsInToolsMode() then 
        loadType = 15
    else
        loadType = 15
    end

    for _, hero in ipairs(heroes_precache) do
        -- 使用位运算来检查当前英雄是否应被加载
        if bit.band(loadType, hero.type) ~= 0 then
            -- 预加载英雄的粒子特效文件夹
            PrecacheResource("particle_folder", heroParticlePath .. hero.particleName, context)
            -- 预加载英雄的音效文件
            PrecacheResource("soundfile", heroSoundPath .. hero.soundName .. ".vsndevts", context)
            -- 预加载英雄的模型，使用name并去掉前缀
            PrecacheResource("model_folder", heroModelPath .. hero.model, context)
        end
    end
    
    PrecacheResource("model", "models/props_gameplay/fountain_of_life/fountain_of_life.vmdl", context)
    -- 预加载粒子特效
    PrecacheResource("particle", "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_legion_commander", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context)
    PrecacheResource("particle", "particles/econ/items/legion/legion_weapon_voth_domosh/legion_commander_duel_arcana.vpcf", context)
    PrecacheResource("particle", "particles/generic_gameplay/lasthit_coins.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", context)
    PrecacheResource("soundfile", "General.Coins", context)
    PrecacheResource("soundfile", "BodyImpact_Common.Heavy", context)
    PrecacheResource("soundfile", "BodyImpact_Common.Medium", context)

    PrecacheResource("soundfile", "endAegis.Timer", context)
    PrecacheResource("soundfile", "General.LevelUp", context)
    PrecacheResource("soundfile", "ui.ready_check.yes", context)
    PrecacheResource("soundfile", "PauseMinigame.TI10.Lose", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context)
    PrecacheResource("particle", "particles/econ/items/ogre_magi/ogre_2022_cc/ogre_2022_cc_wing_ice_flap.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/ogre_magi/ogre_2022_cc/ogre_2022_cc_wing_fire_flap.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/spring_2021/hero_levelup_spring_2021_godray.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_undying/undying_zombie_death_dirt01.vpcf", context)

    PrecacheResource("particle", "particles/units/heroes/hero_slardar/slardar_crush_entity_splash.vpcf", context)
    PrecacheResource("particle", "models/heroes/ringmaster/debut/particles/ringmaster_box_loadout_spawn_ground_debut.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ringmaster/ringmaster_spotlight_lightshaft_motes.vpcf", context)
    PrecacheResource("particle", "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", context)
    PrecacheResource("particle", "particles/events/ti6_teams/teleport_start_ti6_lvl3_mvp_phoenix.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/fall_2021/teleport_start_fall_2021_core.vpcf", context)
    PrecacheResource("particle", "particles/blue/teleport_start_ti7_lvl3.vpcf", context)
    PrecacheResource("particle", "particles/green/teleport_start_ti8_lvl2.vpcf", context)
    PrecacheResource("particle", "particles/purple/teleport_start_ti9_lvl2.vpcf", context)
    PrecacheResource("particle", "particles/red/teleport_start_ti6_lvl2.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_ringmaster/ringmaster_unicycle_spawn.vpcf", context)
    -- 预加载一些基础英雄模型
    PrecacheResource("model", "models/heroes/axe/axe.vmdl", context)
    PrecacheResource("model", "models/heroes/crystal_maiden/crystal_maiden.vmdl", context)
    PrecacheResource("model", "models/heroes/legion_commander/legion_commander.vmdl", context)
    PrecacheResource("model", "models/heroes/huskar/huskar.vmdl", context)
    PrecacheResource("model", "models/heroes/ogre_magi/ogre_magi.vmdl", context)
    PrecacheResource("model", "models/heroes/undying/undying.vmdl", context)
    PrecacheResource("model", "models/heroes/ringmaster/ringmaster_unicycle.vmdl", context)
    local particleFolders = {
        "particles/units/heroes",  -- 英雄特效
    }
    
    for _, folder in ipairs(particleFolders) do
        PrecacheResource("particle_folder", folder, context)
    end
    -- 预加载音效
end

function Activate()
	GameRules.AddonTemplate = Main()

	GameRules.AddonTemplate:InitGameMode()
end

