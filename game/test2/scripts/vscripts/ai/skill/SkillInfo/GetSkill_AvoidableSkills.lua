function CommonAI:Init_AvoidableSkills()
    self.AvoidableSkills = {
        -- 延迟生效类技能（无敌可以躲避）
        ability_fireball = {
            dodgeType = {"invulnerable", "blink", "dispel_weak"},
            delay = 1.0, -- 延迟时间
        },
        ability_lightning_strike = {
            dodgeType = {"invulnerable", "dispel_strong"},
            delay = 0.8,
        },
        
        -- 弹道类技能（弹道到达前可躲避）
        razor_plasma_field = {
            dodgeType = {"invulnerable", "blink"},
            projectile = true,
        },
        
        -- 范围AOE技能（位移可躲避）
        meepo_megameepo = {
            dodgeType = {"invulnerable", "movement"},
            aoe = true,
        },
        
        -- 不无视魔免类技能
        shredder_reactive_armor = {
            dodgeType = {"dispel_strong", "spell_immune"},
        },
        ursa_enrage = {
            dodgeType = {"invulnerable", "dispel_strong"},
        },
        muerta_dead_shot = {
            dodgeType = {"movement", "debuff_immune"},
            projectile = true,
        },
        
        -- 添加更多常见的可躲避技能
        -- 延迟生效类
        invoker_sun_strike = {
            dodgeType = {"invulnerable", "movement"},
            delay = 1.7,
        },
        lina_light_strike_array = {
            dodgeType = {"invulnerable", "movement"},
            delay = 0.5,
        },
        kunkka_torrent = {
            dodgeType = {"invulnerable", "movement"},
            delay = 1.6,
        },
        jakiro_ice_path = {
            dodgeType = {"invulnerable", "movement"},
            delay = 0.5,
        },
        
        -- 弹道类
        pudge_meat_hook = {
            dodgeType = {"invulnerable", "blink", "movement"},
            projectile = true,
        },
        mirana_sacred_arrow = {
            dodgeType = {"invulnerable", "blink", "movement"},
            projectile = true,
        },
        windrunner_powershot = {
            dodgeType = {"invulnerable", "blink", "movement"},
            projectile = true,
        },
        
        -- 持续施法类
        crystal_maiden_freezing_field = {
            dodgeType = {"invulnerable", "movement", "spell_immune"},
            channeled = true,
        },
        enigma_black_hole = {
            dodgeType = {"invulnerable", "blink"},
            channeled = true,
        },
        
        -- 范围伤害类
        earthshaker_echo_slam = {
            dodgeType = {"invulnerable", "spell_immune"},
            instant = true,
        },
        tidehunter_ravage = {
            dodgeType = {"invulnerable", "spell_immune"},
            instant = true,
        },
        
        -- 单体目标技能
        lion_finger_of_death = {
            dodgeType = {"invulnerable", "spell_immune"},
            instant = true,
        },
        lina_laguna_blade = {
            dodgeType = {"invulnerable", "spell_immune"},
            instant = true,
        },
        
        -- 可以继续添加更多技能...
    }
end





