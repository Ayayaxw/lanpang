ANIMATIONS_VERSION = "1.00"

--[[
  由BMD开发的Lua控制动画库

  安装方法
  -在你的代码中"require"这个文件以获取StartAnmiation和EndAnimation全局函数的访问权限。
  -另外，确保该文件放置在vscripts/libraries路径下，且vscripts/libraries/modifiers/modifier_animation.lua、modifier_animation_translate.lua、modifier_animation_translate_permanent.lua和modifier_animation_freeze.lua文件存在并位于正确的路径中

  使用方法
  -可以为任何单位启动动画，通过向StartAnimation调用提供信息表
  -对同一单位重复调用StartAnimation将取消正在运行的动画并开始新动画
  -可以调用EndAnimation取消正在运行的动画
  -动画由一个表指定，该表具有以下潜在参数：
    -duration: 播放动画的持续时间。无论动画进行到哪，在持续时间结束时都会取消。
    -activity: 作为动画基础活动的活动代码，例如DOTA_ACT_RUN、DOTA_ACT_ATTACK等。
    -rate: 可选参数（如未指定则为1.0），用于播放此动画的动画速率。
    -translate: 可选的转换活动修饰符字符串，可用于修改动画序列。
      示例：对于ACT_DOTA_RUN+haste，这应该是"haste"
    -translate2: 第二个可选的转换活动修饰符字符串，可用于进一步修改动画序列。
      示例：对于ACT_DOTA_ATTACK+sven_warcry+sven_shield，这应该是"sven_warcry"或"sven_shield"，而translate属性则是另一个转换修饰符
  -可以通过为单位调用AddAnimationTranslate应用永久活动转换。这允许永久性的"受伤"或"攻击性"动画姿态。
  -可以使用RemoveAnimationTranslate移除永久活动转换修饰符。
  -可以随时通过调用FreezeAnimation(unit[, duration])冻结动画。不指定持续时间将导致动画冻结，直到调用UnfreezeAnimation。
  -可以随时通过调用UnfreezeAnimation(unit)解冻动画。

  注意事项
  -动画只能为单位使用的模型所拥有的有效活动/序列播放。
  -目前此库不支持需要3个以上活动修饰符转换的序列（如"stun+fear+loadout"或类似）。
  -调用EndAnimation并尝试在动画结束后约2个服务器帧内为同一单位StartAnimation新动画可能会失败。
    在不结束前一个动画的情况下直接调用StartAnimation将自动添加此延迟并取消前一个动画。
  -可以使用的最大动画速率为12.75，且动画速率只能以0.05为分辨率存在（即1.0、1.05、1.1，而不是1.06）
  -StartAnimation和EndAnimation函数也可以通过GameRules作为GameRules.StartAnimation和GameRules.EndAnimation访问，以在作用域Lua文件中使用（触发器、vscript ai等）
  -该库要求"libraries/timers.lua"存在于您的vscripts目录中。

  示例：
  --以2.5速率开始一个运行动画，持续2.5秒
    StartAnimation(unit, {duration=2.5, activity=ACT_DOTA_RUN, rate=2.5})

  --结束一个运行动画
    EndAnimation(unit)

  --以0.8速率开始一个奔跑+急速动画，持续5秒
    StartAnimation(unit, {duration=5, activity=ACT_DOTA_RUN, rate=0.8, translate="haste"})

  --为斯温开始一个带变速的盾牌猛击动画
    StartAnimation(unit, {duration=1.5, activity=ACT_DOTA_ATTACK, rate=RandomFloat(.5, 1.5), translate="sven_warcry", translate2="sven_shield"})

  --添加一个永久受伤转换修饰符
    AddAnimationTranslate(unit, "injured")

  --移除一个永久活动转换修饰符
    RemoveAnimationTranslate(unit)

  --冻结动画4秒
    FreezeAnimation(unit, 4)

  --解冻动画
    UnfreezeAnimation(unit)

]]

LinkLuaModifier( "modifier_animation", "libraries/modifiers/modifier_animation.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_animation_translate", "libraries/modifiers/modifier_animation_translate.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_animation_translate_permanent", "libraries/modifiers/modifier_animation_translate_permanent.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_animation_freeze", "libraries/modifiers/modifier_animation_freeze.lua", LUA_MODIFIER_MOTION_NONE )

require('libraries/timers')

local _ANIMATION_TRANSLATE_TO_CODE = {
  abysm= 13,
  admirals_prow= 307,
  agedspirit= 3,
  aggressive= 4,
  agrressive= 163,
  am_blink= 182,
  ancestors_edge= 144,
  ancestors_pauldron= 145,
  ancestors_vambrace= 146,
  ancestral_scepter= 67,
  ancient_armor= 6,
  anvil= 7,
  arcana= 8,
  armaments_set= 20,
  axes= 188,
  backstab= 41,
  backstroke_gesture= 283,
  backward= 335,
  ball_lightning= 231,
  batter_up= 43,
  bazooka= 284,
  belly_flop= 180,
  berserkers_blood= 35,
  black= 44,
  black_hole= 194,
  bladebiter= 147,
  blood_chaser= 134,
  bolt= 233,
  bot= 47,
  brain_sap= 185,
  broodmother_spin= 50,
  burning_fiend= 148,
  burrow= 229,
  burrowed= 51,
  cat_dancer_gesture= 285,
  cauldron= 29,
  charge= 97,
  charge_attack= 98,
  chase= 246,
  chasm= 57,
  chemical_rage= 2,
  chicken_gesture= 258,
  come_get_it= 39,
  corpse_dress= 104,
  corpse_dresstop= 103,
  corpse_scarf= 105,
  cryAnimationExportNode= 341,
  crystal_nova= 193,
  culling_blade= 184,
  dagger_twirl= 143,
  dark_wraith= 174,
  darkness= 213,
  dc_sb_charge= 107,
  dc_sb_charge_attack= 108,
  dc_sb_charge_finish= 109,
  dc_sb_ultimate= 110,
  deadwinter_soul= 96,
  death_protest= 94,
  demon_drain= 116,
  desolation= 55,
  digger= 176,
  dismember= 218,
  divine_sorrow= 117,
  divine_sorrow_loadout= 118,
  divine_sorrow_loadout_spawn= 119,
  divine_sorrow_sunstrike= 120,
  dizzying_punch= 343,
  dog_of_duty= 342,
  dogofduty= 340,
  dominator= 254,
  dryad_tree= 311,
  dualwield= 14,
  duel_kill= 121,
  earthshock= 235,
  emp= 259,
  enchant_totem= 313,
  ["end"]= 243,
  eyeoffetizu= 34,
  f2p_doom= 131,
  face_me= 286,
  faces_hakama= 111,
  faces_mask= 113,
  faces_wraps= 112,
  fast= 10,
  faster= 11,
  fastest= 12,
  fear= 125,
  fiends_grip= 186,
  fiery_soul= 149,
  finger= 200,
  firefly= 190,
  fish_slap= 123,
  fishstick= 339,
  fissure= 195,
  flying= 36,
  focusfire= 124,
  forcestaff_enemy= 122,
  forcestaff_friendly= 15,
  forward= 336,
  fountain= 49,
  freezing_field= 191,
  frost_arrow= 37,
  frostbite= 192,
  frostiron_raider= 150,
  frostivus= 54,
  ftp_dendi_back= 126,
  gale= 236,
  get_burned= 288,
  giddy_up_gesture= 289,
  glacier= 101,
  glory= 345,
  good_day_sir= 40,
  great_safari= 267,
  greevil_black_hole= 58,
  greevil_blade_fury= 59,
  greevil_bloodlust= 60,
  greevil_cold_snap= 61,
  greevil_decrepify= 62,
  greevil_diabolic_edict= 63,
  greevil_echo_slam= 64,
  greevil_fatal_bonds= 65,
  greevil_ice_wall= 66,
  greevil_laguna_blade= 68,
  greevil_leech_seed= 69,
  greevil_magic_missile= 70,
  greevil_maledict= 71,
  greevil_miniboss_black_brain_sap= 72,
  greevil_miniboss_black_nightmare= 73,
  greevil_miniboss_blue_cold_feet= 74,
  greevil_miniboss_blue_ice_vortex= 75,
  greevil_miniboss_green_living_armor= 76,
  greevil_miniboss_green_overgrowth= 77,
  greevil_miniboss_orange_dragon_slave= 78,
  greevil_miniboss_orange_lightstrike_array= 79,
  greevil_miniboss_purple_plague_ward= 80,
  greevil_miniboss_purple_venomous_gale= 81,
  greevil_miniboss_red_earthshock= 82,
  greevil_miniboss_red_overpower= 83,
  greevil_miniboss_white_purification= 84,
  greevil_miniboss_yellow_ion_shell= 85,
  greevil_miniboss_yellow_surge= 86,
  greevil_natures_attendants= 87,
  greevil_phantom_strike= 88,
  greevil_poison_nova= 89,
  greevil_purification= 90,
  greevil_shadow_strike= 91,
  greevil_shadow_wave= 92,
  groove_gesture= 305,
  ground_pound= 128,
  guardian_angel= 215,
  guitar= 290,
  hang_loose_gesture= 291,
  happy_dance= 293,
  harlequin= 129,
  haste= 45,
  hook= 220,
  horn= 292,
  immortal= 28,
  impale= 201,
  impatient_maiden= 100,
  impetus= 138,
  injured= 5,
  ["injured rare"]= 247,
  injured_aggressive= 130,
  instagib= 21,
  iron= 255,
  iron_surge= 99,
  item_style_2= 133,
  jump_gesture= 294,
  laguna= 202,
  leap= 206,
  level_1= 140,
  level_2= 141,
  level_3= 142,
  life_drain= 219,
  loadout= 0,
  loda= 173,
  lodestar= 114,
  loser= 295,
  lsa= 203,
  lucentyr= 158,
  lute= 296,
  lyreleis_breeze= 159,
  mace= 160,
  mag_power_gesture= 298,
  magic_ends_here= 297,
  mana_drain= 204,
  mana_void= 183,
  manias_mask= 135,
  manta= 38,
  mask_lord= 299,
  masquerade= 25,
  meld= 162,
  melee= 334,
  miniboss= 164,
  moon_griffon= 166,
  moonfall= 165,
  moth= 53,
  nihility= 95,
  obeisance_of_the_keeper= 151,
  obsidian_helmet= 132,
  odachi= 32,
  offhand_basher= 42,
  omnislash= 198,
  overpower1= 167,
  overpower2= 168,
  overpower3= 169,
  overpower4= 170,
  overpower5= 171,
  overpower6= 172,
  pegleg= 248,
  phantom_attack= 16,
  pinfold= 175,
  plague_ward= 237,
  poison_nova= 238,
  portrait_fogheart= 177,
  poundnpoint= 300,
  powershot= 242,
  punch= 136,
  purification= 216,
  pyre= 26,
  qop_blink= 221,
  ravage= 225,
  red_moon= 30,
  reincarnate= 115,
  remnant= 232,
  repel= 217,
  requiem= 207,
  roar= 187,
  robot_gesture= 301,
  roshan= 181,
  salvaged_sword= 152,
  sandking_rubyspire_burrowstrike= 52,
  sb_bracers= 251,
  sb_helmet= 250,
  sb_shoulder= 252,
  sb_spear= 253,
  scream= 222,
  serene_honor= 153,
  shadow_strike= 223,
  shadowraze= 208,
  shake_moneymaker= 179,
  sharp_blade= 303,
  shinobi= 27,
  shinobi_mask= 154,
  shinobi_tail= 23,
  shrapnel= 230,
  silent_ripper= 178,
  slam= 196,
  slasher_chest= 262,
  slasher_mask= 263,
  slasher_offhand= 261,
  slasher_weapon= 260,
  sm_armor= 264,
  sm_head= 56,
  sm_shoulder= 265,
  snipe= 226,
  snowangel= 17,
  snowball= 102,
  sonic_wave= 224,
  sparrowhawk_bow= 269,
  sparrowhawk_cape= 270,
  sparrowhawk_hood= 272,
  sparrowhawk_quiver= 271,
  sparrowhawk_shoulder= 273,
  spin= 199,
  split_shot= 1,
  sprint= 275,
  sprout= 209,
  staff_swing= 304,
  stalker_exo= 93,
  start= 249,
  stinger= 280,
  stolen_charge= 227,
  stolen_firefly= 189,
  strike= 228,
  sugarrush= 276,
  suicide_squad= 18,
  summon= 210,
  sven_shield= 256,
  sven_warcry= 257,
  swag_gesture= 287,
  swordonshoulder= 155,
  taunt_fullbody= 19,
  taunt_killtaunt= 139,
  taunt_quickdraw_gesture= 268,
  taunt_roll_gesture= 302,
  techies_arcana= 9,
  telebolt= 306,
  teleport= 211,
  thirst= 137,
  tidebringer= 24,
  tidehunter_boat= 22,
  tidehunter_toss_fish= 312,
  tidehunter_yippy= 347,
  timelord_head= 309,
  tinker_rollermaw= 161,
  torment= 279,
  totem= 197,
  transition= 278,
  trapper= 314,
  tree= 310,
  trickortreat= 277,
  triumphant_timelord= 127,
  turbulent_teleport= 308,
  twinblade_attack= 315,
  twinblade_attack_b= 316,
  twinblade_attack_c= 317,
  twinblade_attack_d= 318,
  twinblade_attack_injured= 319,
  twinblade_death= 320,
  twinblade_idle= 321,
  twinblade_idle_injured= 322,
  twinblade_idle_rare= 323,
  twinblade_injured_attack_b= 324,
  twinblade_jinada= 325,
  twinblade_jinada_injured= 326,
  twinblade_shuriken_toss= 327,
  twinblade_shuriken_toss_injured= 328,
  twinblade_spawn= 329,
  twinblade_stun= 330,
  twinblade_track= 331,
  twinblade_track_injured= 332,
  twinblade_victory= 333,
  twister= 274,
  unbroken= 106,
  vendetta= 337,
  viper_strike= 239,
  viridi_set= 338,
  void= 214,
  vortex= 234,
  wall= 240,
  ward= 241,
  wardstaff= 344,
  wave= 205,
  web= 48,
  whalehook= 156,
  whats_that= 281,
  when_nature_attacks= 31,
  white= 346,
  windrun= 244,
  windy= 245,
  winterblight= 157,
  witchdoctor_jig= 282,
  with_item= 46,
  wolfhound= 266,
  wraith_spin= 33,
  wrath= 212,

  rampant= 348,
  overload= 349,

  surge=350,
  es_prosperity=351,
  Espada_pistola=352,
  overload_injured=353,
  ss_fortune=354,
  liquid_fire=355,
  jakiro_icemelt=356,
  jakiro_roar=357,

  chakram=358,
  doppelwalk=359,
  enrage=360,
  fast_run=361,
  overpower=362,
  overwhelmingodds=363,
  pregame=364,
  shadow_dance=365,
  shukuchi=366,
  strength=367,
  twinblade_run=368,
  twinblade_run_injured=369,
  windwalk=370,  

}

function StartAnimation(unit, table)
  local duration = table.duration
  local activity = table.activity
  local translate = table.translate
  local translate2 = table.translate2
  local rate = table.rate or 1.0

  rate = math.floor(math.max(0,math.min(255/20, rate)) * 20 + .5)

  local stacks = activity + bit.lshift(rate,11)

  if translate ~= nil then
    if _ANIMATION_TRANSLATE_TO_CODE[translate] == nil then
      print("[ANIMATIONS.lua] ERROR, no translate-code found for '" .. translate .. "'.  This translate may be misspelled or need to be added to the enum manually.")
      return
    end
    stacks = stacks + bit.lshift(_ANIMATION_TRANSLATE_TO_CODE[translate],19)
  end

  if translate2 ~= nil and _ANIMATION_TRANSLATE_TO_CODE[translate2] == nil then
    print("[ANIMATIONS.lua] ERROR, no translate-code found for '" .. translate2 .. "'.  This translate may be misspelled or need to be added to the enum manually.")
    return
  end

  if unit:HasModifier("modifier_animation") or (unit._animationEnd ~= nil and unit._animationEnd + .067 > GameRules:GetGameTime()) then
    EndAnimation(unit)
    Timers:CreateTimer(.066, function() 
      if translate2 ~= nil then
        unit:AddNewModifier(unit, nil, "modifier_animation_translate", {duration=duration, translate=translate2})
        unit:SetModifierStackCount("modifier_animation_translate", unit, _ANIMATION_TRANSLATE_TO_CODE[translate2])
      end

      unit._animationEnd = GameRules:GetGameTime() + duration
      unit:AddNewModifier(unit, nil, "modifier_animation", {duration=duration, translate=translate})
      unit:SetModifierStackCount("modifier_animation", unit, stacks)
    end)
  else
    if translate2 ~= nil then
      unit:AddNewModifier(unit, nil, "modifier_animation_translate", {duration=duration, translate=translate2})
      unit:SetModifierStackCount("modifier_animation_translate", unit, _ANIMATION_TRANSLATE_TO_CODE[translate2])
    end

    unit._animationEnd = GameRules:GetGameTime() + duration
    unit:AddNewModifier(unit, nil, "modifier_animation", {duration=duration, translate=translate})
    unit:SetModifierStackCount("modifier_animation", unit, stacks)
  end
end

function FreezeAnimation(unit, duration)
  if duration then
    unit:AddNewModifier(unit, nil, "modifier_animation_freeze", {duration=duration})
  else
    unit:AddNewModifier(unit, nil, "modifier_animation_freeze", {})
  end
end

function UnfreezeAnimation(unit)
  unit:RemoveModifierByName("modifier_animation_freeze")
end

function EndAnimation(unit)
  unit._animationEnd = GameRules:GetGameTime()
  unit:RemoveModifierByName("modifier_animation")
  unit:RemoveModifierByName("modifier_animation_translate")
end

function AddAnimationTranslate(unit, translate)
  if translate == nil or _ANIMATION_TRANSLATE_TO_CODE[translate] == nil then
    print("[ANIMATIONS.lua] ERROR, no translate-code found for '" .. translate .. "'.  This translate may be misspelled or need to be added to the enum manually.")
    return
  end

  unit:AddNewModifier(unit, nil, "modifier_animation_translate_permanent", {duration=duration, translate=translate})
  unit:SetModifierStackCount("modifier_animation_translate_permanent", unit, _ANIMATION_TRANSLATE_TO_CODE[translate])
end

function RemoveAnimationTranslate(unit)
  unit:RemoveModifierByName("modifier_animation_translate_permanent")
end

GameRules.StartAnimation = StartAnimation
GameRules.EndAnimation = EndAnimation
GameRules.AddAnimationTranslate = AddAnimationTranslate
GameRules.RemoveAnimationTranslate = RemoveAnimationTranslate