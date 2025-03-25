
require("challenge_mode_setup")
require("createhero")           --创建命石英雄的函数
require("GameEventListeners/ProcessHeroChangeRequest") --监听输入
require("GameEventListeners/OnPlayerChat") --监听输入
require("GameEventListeners/OnAbilityUsed") --监听英雄血量
require("GameEventListeners/OnHeroHealth") --监听英雄血量
require("GameEventListeners/OnAttack") --监听英雄血量
require("GameEventListeners/OnUnitKilled") --监听英雄血量
require("GameEventListeners/OnNPCSpawned") --监听单位出生

require("battle/hero_benefits")          --这里放的
require("battle/game_end_animations")
require("battle/coordinates")           --放置重要的地图坐标
require("battle/hero_kv_overrides")           --处理英雄kv覆盖
require("battle/api_extensions")           --自己实现的一些API没有的功能
require("battle/ui_event_manager")           --前端信息展示的一些功能
require("battle/camera_focus_manager")           --相机视角管理

require("ai/core/ai_core")
require("ai/core/AIstrategies")
require("ai/core/common_ai")
require("hero_duel")

require("game_setup")

require('modifier/modifier_global_ability_listener')
require('print_manager')

require('libraries/vector_targeting')
require("libraries/timers")
require("libraries/animations")

--require('ai_script')
require("trigger/quanshui")
require("spawn_manager") 
require("hero_spawn") 
require("hero_chaos") 
require("sandbox") 


require('components/tormentor/init')


LinkLuaModifier("modifier_judu", "modifier/judu.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_full_restore", "modifier/modifier_full_restore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_naibangren", "modifier/naibangren.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shebangren", "modifier/shebangren.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sibangren", "modifier/sibangren.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_global_ability_listener", "modifier/modifier_global_ability_listener.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_no_cooldown_FirstSkill", "modifier/modifier_no_cooldown_FirstSkill.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_no_cooldown_all", "modifier/modifier_no_cooldown_all.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_attribute_transfer", "modifier/modifier_damage_attribute_transfer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_decrease_attribute", "modifier/modifier_decrease_attribute.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_increase_attribute", "modifier/modifier_increase_attribute.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_illusion_death_listener", "modifier/modifier_illusion_death_listener.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_reduction_100", "modifier/modifier_damage_reduction_100.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kv_editor", "modifier/modifier_kv_editor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_luosi_damage_limiter", "modifier/modifier_luosi_damage_limiter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("attribute_stack_modifier", "modifier/attribute_stack_modifier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_constant_height_adjustment", "modifier/modifier_constant_height_adjustment.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attribute_reversal", "modifier/modifier_attribute_reversal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_no_cooldown_SecondSkill", "modifier/modifier_no_cooldown_SecondSkill.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attribute_amplifier", "modifier/modifier_attribute_amplifier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attribute_amplifier_100x", "modifier/modifier_attribute_amplifier_100x.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attribute_amplifier_5x", "modifier/modifier_attribute_amplifier_5x.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attribute_amplifier_3x", "modifier/modifier_attribute_amplifier_3x.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attribute_amplifier_2x", "modifier/modifier_attribute_amplifier_2x.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_health_regen_7", "modifier/modifier_health_regen_7.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_double_on_death", "modifier/modifier_double_on_death.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_caipan", "modifier/modifier_caipan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_auto_elevation", "modifier/modifier_auto_elevation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_auto_elevation_large", "modifier/modifier_auto_elevation_large.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_auto_elevation_small", "modifier/modifier_auto_elevation_small.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_auto_elevation_waterfall", "modifier/modifier_auto_elevation_waterfall.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sniper_kill_bonus", "modifier/modifier_sniper_kill_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maximum_attack", "modifier/modifier_maximum_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wearable", "modifier/modifier_wearable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_truesight_vision", "modifier/modifier_truesight_vision.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_global_truesight", "modifier/modifier_global_truesight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_rolling", "modifier/modifier_custom_rolling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_coil", "modifier/modifier_custom_coil.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zero_speed", "modifier/modifier_zero_speed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_out_of_game", "modifier/modifier_custom_out_of_game.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_auto_bullwhip", "modifier/modifier_auto_bullwhip.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_reduced_ability_cost", "modifier/modifier_reduced_ability_cost.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_unicycle", "modifier/modifier_custom_unicycle.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aoe_bonus_percentage", "modifier/modifier_aoe_bonus_percentage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_reduction_dynamic", "modifier/modifier_damage_reduction_dynamic.lua", LUA_MODIFIER_MOTION_NONE)    
LinkLuaModifier("modifier_damage_amplification", "modifier/modifier_damage_amplification.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_health_bonus_percentage", "modifier/modifier_health_bonus_percentage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_damage_percentage", "modifier/modifier_attack_damage_percentage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anti_invisible", "modifier/modifier_anti_invisible.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_auto_cast_ability", "modifier/modifier_attack_auto_cast_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_reset_passive_ability_cooldown", "modifier/modifier_reset_passive_ability_cooldown.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_extra_health_bonus", "modifier/modifier_extra_health_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_neutral_upgrade", "modifier/modifier_custom_neutral_upgrade.lua", LUA_MODIFIER_MOTION_NONE)