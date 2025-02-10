function CommonAI:Init_DodgableSkills()
    self.DodgableSkills = {
        ability_fireball = {
            dodgeType = {"invulnerable", "blink", "dispel_weak"},
        },
        ability_lightning_strike = {
            dodgeType = {"invulnerable", "dispel_strong"},
        },
        -- 更多技能...
        razor_plasma_field = {
            dodgeType = {"invulnerable", "blink"},
        },
        meepo_megameepo = {
            dodgeType = {"invulnerable"},
        },
        shredder_reactive_armor = {
            dodgeType = {"dispel_strong"},
        },
        ursa_enrage = {
            dodgeType = {"invulnerable", "dispel_strong"},
        },
        muerta_dead_shot = {
            dodgeType = { "movement", "debuff_immune"},
        },
        -- 可以继续添加更多技能...
    }
end