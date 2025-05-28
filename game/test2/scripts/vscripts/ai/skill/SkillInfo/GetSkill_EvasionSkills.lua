function CommonAI:Init_EvasionSkills()
    -- self.EvasionSkills = {
    --     -- 无敌类技能（最强躲避能力）
    --     ability_phase_shift = {
    --         attributes = {"invulnerable"},
    --     },
    --     shadow_demon_disruption = {
    --         attributes = {"invulnerable"},
    --     },
    --     oracle_false_promise = {
    --         attributes = {"invulnerable", "dispel_strong"},
    --     },
    --     puck_phase_shift = {
    --         attributes = {"invulnerable"},
    --     },
    --     obsidian_destroyer_astral_imprisonment = {
    --         attributes = {"invulnerable"},
    --     },
        
    --     -- 魔法免疫类技能
    --     juggernaut_blade_fury = {
    --         attributes = {"spell_immune"},
    --     },
    --     lifestealer_rage = {
    --         attributes = {"spell_immune"},
    --     },
    --     omniknight_repel = {
    --         attributes = {"spell_immune"},
    --     },
        
    --     -- 强驱散类技能
    --     ability_strong_dispel = {
    --         attributes = {"dispel_strong"},
    --     },
    --     oracle_purifying_flames = {
    --         attributes = {"dispel_strong"},
    --     },
    --     abaddon_aphotic_shield = {
    --         attributes = {"dispel_strong"},
    --     },
        
    --     -- 闪烁类技能（瞬间位移）
    --     ability_blink = {
    --         attributes = {"blink", "movement"},
    --     },
    --     antimage_blink = {
    --         attributes = {"blink", "movement"},
    --     },
    --     queen_of_pain_blink = {
    --         attributes = {"blink", "movement"},
    --     },
        
    --     -- 位移类技能
    --     faceless_void_time_walk = {
    --         attributes = {"movement"},
    --     },
    --     mirana_leap = {
    --         attributes = {"movement"},
    --     },
    --     slark_pounce = {
    --         attributes = {"movement"},
    --     },
    --     storm_spirit_ball_lightning = {
    --         attributes = {"movement"},
    --     },
    --     earth_spirit_rolling_boulder = {
    --         attributes = {"movement"},
    --     },
    --     ember_spirit_fire_remnant = {
    --         attributes = {"movement"},
    --     },
    --     void_spirit_astral_step = {
    --         attributes = {"movement"},
    --     },
    --     zuus_heavenly_jump = {
    --         attributes = {"movement"},
    --     },
        
    --     -- 弱驱散类技能
    --     ability_weak_dispel = {
    --         attributes = {"dispel_weak"},
    --     },
        
    --     -- 添加更多常见的躲避技能
    --     -- 无敌技能
    --     brewmaster_primal_split = {
    --         attributes = {"invulnerable"},
    --     },
    --     phoenix_supernova = {
    --         attributes = {"invulnerable"},
    --     },
        
    --     -- 魔免技能
    --     naix_rage = {
    --         attributes = {"spell_immune"},
    --     },
        
    --     -- 位移技能
    --     phantom_assassin_phantom_strike = {
    --         attributes = {"movement"},
    --     },
    --     riki_blink_strike = {
    --         attributes = {"movement"},
    --     },
    --     morphling_waveform = {
    --         attributes = {"movement"},
    --     },
    --     spectre_spectral_dagger = {
    --         attributes = {"movement"},
    --     },
        
    --     -- 特殊躲避技能
    --     templar_assassin_refraction = {
    --         attributes = {"damage_block"},
    --     },
    --     nyx_assassin_spiked_carapace = {
    --         attributes = {"damage_reflect"},
    --     },
        
    --     -- 可以继续添加更多技能...
    -- }

    self.evasionSkills = {
        npc_dota_hero_storm_spirit = {"storm_spirit_ball_lightning"},
    }
end




-- 定义躲避类型的层级关系
CommonAI.DodgeHierarchy = {
    invulnerable = {"all"},  -- 无敌可以躲避所有类型
    spell_immune = {"dispel_strong", "dispel_weak", "magical", "debuff_immune"},  -- 技能免疫可以躲避驱散和魔法
    dispel_strong = {"dispel_strong", "dispel_weak"},  -- 强驱散可以躲避强驱散和弱驱散
    dispel_weak = {"dispel_weak"},  -- 弱驱散只能躲避弱驱散
    blink = {"blink", "movement"},  -- 闪烁也算位移
    movement = {"movement"},  -- 位移技能
    damage_block = {"damage_block"},  -- 伤害格挡
    damage_reflect = {"damage_reflect"},  -- 伤害反射
    debuff_immune = {"debuff_immune"},  -- 负面状态免疫
    -- 可以添加更多类型...
}

function CommonAI:CanDodge(dodgeSkillName, targetSkillName)
    if not dodgeSkillName or not targetSkillName then
        print("Error: dodgeSkillName or targetSkillName is nil")
        return false
    end

    if not self.EvasionSkills or not self.EvasionSkills[dodgeSkillName] then
        print("Error: EvasionSkill not found:", dodgeSkillName)
        return false
    end

    if not self.AvoidableSkills or not self.AvoidableSkills[targetSkillName] then
        print("Error: AvoidableSkill not found:", targetSkillName)
        return false
    end

    local dodgeAttributes = self.EvasionSkills[dodgeSkillName].attributes
    local targetDodgeTypes = self.AvoidableSkills[targetSkillName].dodgeType

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

-- 注意：以下函数已被简化的躲避系统替代，不再使用
-- HandleDodgeSkill, SelectBestDodgeSkill, CheckDodgeSkillConditions, 
-- ExecuteDodgeSkill, CalculateDodgePosition, IsValidDodgeTiming 等函数
-- 现在躲避逻辑在 CommonAI:ShouldDodgeSkill() 中处理

-- 获取当前可用的躲避技能
function CommonAI:GetAvailableEvasionSkills(entity)
    local availableSkills = {}
    local heroName = entity:GetUnitName()
    
    -- 目前只处理风暴之灵
    if heroName == "npc_dota_hero_storm_spirit" then
        local ball_lightning = entity:FindAbilityByName("storm_spirit_ball_lightning")
        if ball_lightning and ball_lightning:IsFullyCastable() then
            table.insert(availableSkills, "storm_spirit_ball_lightning")
        end
    end
    
    return availableSkills
end