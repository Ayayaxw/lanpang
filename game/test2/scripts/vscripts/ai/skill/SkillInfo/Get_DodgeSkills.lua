function CommonAI:Init_DodgeSkills()
    self.DodgeSkills = {
        ability_blink = {
            attributes = {"blink", "movement"},
        },
        ability_phase_shift = {
            attributes = {"invulnerable"},
        },
        ability_strong_dispel = {
            attributes = {"dispel_strong"},
        },
        shadow_demon_disruption = {
            attributes = {"invulnerable"},
        },
        oracle_false_promise = {
            attributes = {"invulnerable", "dispel_strong"},
        },
        juggernaut_blade_fury = {
            attributes = {"spell_immune"},
        },
        -- 添加一些常见的位移技能
        antimage_blink = {
            attributes = {"blink", "movement"},
        },
        queen_of_pain_blink = {
            attributes = {"blink", "movement"},
        },
        faceless_void_time_walk = {
            attributes = {"movement"},
        },
        mirana_leap = {
            attributes = {"movement"},
        },
        slark_pounce = {
            attributes = {"movement"},
        },
        storm_spirit_ball_lightning = {
            attributes = {"movement"},
        },
        earth_spirit_rolling_boulder = {
            attributes = {"movement"},
        },
        ember_spirit_fire_remnant = {
            attributes = {"movement"},
        },
        void_spirit_astral_step = {
            attributes = {"movement"},
        },
        zuus_heavenly_jump = {
            attributes = {"movement"},
        },
        -- 可以继续添加更多技能...
    }
end

-- 定义躲避类型的层级关系
CommonAI.DodgeHierarchy = {
    invulnerable = {"all"},  -- 无敌可以躲避所有类型
    spell_immune = {"dispel_strong", "dispel_weak", "magical"},  -- 技能免疫可以躲避驱散和魔法
    dispel_strong = {"dispel_strong", "dispel_weak"},  -- 强驱散可以躲避强驱散和弱驱散
    dispel_weak = {"dispel_weak"},  -- 弱驱散只能躲避弱驱散
    blink = {"blink"},
    movement = {"movement"},
    -- 可以添加更多类型...
}

function CommonAI:CanDodge(dodgeSkillName, targetSkillName)
    if not dodgeSkillName or not targetSkillName then
        print("Error: dodgeSkillName or targetSkillName is nil")
        return false
    end

    if not self.DodgeSkills or not self.DodgeSkills[dodgeSkillName] then
        print("Error: DodgeSkill not found:", dodgeSkillName)
        return false
    end

    if not self.DodgableSkills or not self.DodgableSkills[targetSkillName] then
        print("Error: DodgableSkill not found:", targetSkillName)
        return false
    end

    local dodgeAttributes = self.DodgeSkills[dodgeSkillName].attributes
    local targetDodgeTypes = self.DodgableSkills[targetSkillName].dodgeType

    for _, dodgeAttr in ipairs(dodgeAttributes) do
        for _, targetType in ipairs(targetDodgeTypes) do
            if dodgeAttr == targetType then
                return true
            end
            if self.DodgeHierarchy[dodgeAttr] then
                for _, hierType in ipairs(self.DodgeHierarchy[dodgeAttr]) do
                    if hierType == "all" or hierType == targetType then
                        return true
                    end
                end
            end
        end
    end

    return false
end