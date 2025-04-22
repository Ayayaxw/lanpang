function CommonAI:Ini_SkillBehavior()

    self.skillBehavior = {
        riki_tricks_of_the_trade = DOTA_ABILITY_BEHAVIOR.POINT,
        warlock_upheaval = DOTA_ABILITY_BEHAVIOR.POINT,
        death_prophet_carrion_swarm = DOTA_ABILITY_BEHAVIOR.POINT,
        sandking_burrowstrike = DOTA_ABILITY_BEHAVIOR.POINT,
        venomancer_plague_ward = DOTA_ABILITY_BEHAVIOR.POINT,
        earthshaker_enchant_totem = DOTA_ABILITY_BEHAVIOR.POINT,
        abyssal_underlord_firestorm = DOTA_ABILITY_BEHAVIOR.POINT,
        undying_tombstone = DOTA_ABILITY_BEHAVIOR.POINT,

        phoenix_supernova = DOTA_ABILITY_BEHAVIOR.NO_TARGET,
        invoker_deafening_blast = DOTA_ABILITY_BEHAVIOR.NO_TARGET,
        luna_eclipse = DOTA_ABILITY_BEHAVIOR.POINT,
        earth_spirit_geomagnetic_grip = DOTA_ABILITY_BEHAVIOR.POINT,
        phoenix_icarus_dive = DOTA_ABILITY_BEHAVIOR.POINT,
        dragon_knight_breathe_fire = DOTA_ABILITY_BEHAVIOR.POINT,
        jakiro_dual_breath = DOTA_ABILITY_BEHAVIOR.POINT,

        furion_wrath_of_nature = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET,
        dawnbreaker_solar_guardian = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET,
        hoodwink_acorn_shot = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET,

        morphling_waveform = DOTA_ABILITY_BEHAVIOR.POINT,
    }
end


function CommonAI:GetSkill_Behavior(skill, distance, aoeRadius)
    local abilityName = skill:GetAbilityName()
    local abilityBehavior = skill:GetBehavior()



    -- 检查ES跳距离并修改behavior
    local finalAbilityBehavior = self.skillBehavior[abilityName] or abilityBehavior

    if abilityName == "phoenix_supernova" and self.Ally and self.entity:HasScepter() then
        finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
    end



    if abilityName == "tidehunter_gush" and self.Ally and self.entity:HasScepter() then
        finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
    end


    -- 只有当前技能是ES图腾时才检查
    if abilityName == "earthshaker_enchant_totem" and distance and aoeRadius then
        if distance < aoeRadius or self:containsStrategy(self.hero_strategy, "边走边图腾") then
            print("施法距离够了")
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
        elseif self:containsStrategy(self.hero_strategy, "原地图腾") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
        else
            print("图腾起飞")
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end

    end

    -- 只有当前技能是火雨时才检查
    if abilityName == "abyssal_underlord_firestorm" then
        if self:containsStrategy(self.hero_strategy, "对自己放火雨") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.TARGET
        end
    end

    -- 只有当前技能是松鼠技能时才检查
    if abilityName == "hoodwink_acorn_shot" then
        if self:containsStrategy(self.hero_strategy, "对地板放栗子") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end
    end

    -- 只有当前技能是树人技能时才检查
    if abilityName == "treant_leech_seed" then
        if self:containsStrategy(self.global_strategy, "防守策略") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end
    end

    -- 检查是否为 disruptor_thunder_strike
    if abilityName == "disruptor_thunder_strike" then
        local caster = skill:GetCaster()
        if caster:HasModifier("modifier_item_aghanims_shard") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end
    end

    return finalAbilityBehavior
end