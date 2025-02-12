function CommonAI:isSelfCastAbility(abilityName)
    local selfCastSkills = {
        
        ["techies_reactive_tazer"] = true,  -- 工程师反应型电击器
        ["meepo_poof"] =true,
        ["juggernaut_healing_ward"]= true,
        ["snapfire_firesnap_cookie"] = true,
        ["invoker_sun_strike"] = true,
        ["doom_bringer_doom"] = true,
        ["bloodseeker_bloodrage"] = true, --血魔嗜血
        --["pugna_decrepify"] = true,  -- 帕格纳虚化
        --["rubick_telekinesis"] = true,  -- 拉比克隔空取物
    }

    if self:containsStrategy(self.hero_strategy, "对自己放雷云") then
        selfCastSkills["zuus_cloud"] = true
    end
    if self:containsStrategy(self.hero_strategy, "对自己放魔晶") then
        selfCastSkills["necrolyte_death_seeker"] = true
    end

    if self:containsStrategy(self.hero_strategy, "对自己放火雨") then
        selfCastSkills["abyssal_underlord_firestorm"] = true
    end
    if abilityName == "doom_bringer_doom" then

        if self.entity:HasScepter() then
            selfCastSkills["doom_bringer_doom"] = true
        else
            selfCastSkills["doom_bringer_doom"] = false
        end
        if self:containsStrategy(self.hero_strategy, "不大自己") then
            selfCastSkills["doom_bringer_doom"] = false
        end
    end



    -- ES跳判定
    if abilityName == "earthshaker_enchant_totem" then
        local totemAbility = self.entity:FindAbilityByName("earthshaker_enchant_totem")
        local totemRadius = 500 -- 默认值
        
        if totemAbility then
            print("[Debug] 用图腾的范围代替")
            totemRadius = self:GetSkillAoeRadius(totemAbility)
            print("[Debug] 图腾范围:", totemRadius)
        end
        
        if self.target and self.entity and (self.target:GetAbsOrigin() - self.entity:GetAbsOrigin()):Length2D() < totemRadius then
            return true
        elseif self:containsStrategy(self.hero_strategy, "边走边图腾") or self:containsStrategy(self.hero_strategy, "原地图腾") then
            return true
        else
            return false
        end
    end

    if selfCastSkills[abilityName] then
        return true
    else
        return false
    end
end


function CommonAI:isSelfCastAbilityWithRange(abilityName)
    local selfCastSkillsWithRange = {
        ["meepo_poof"] =true, --忽悠
        ["abyssal_underlord_firestorm"] = true, --火雨
        ["omniknight_purification"] = true, --
        ["earthshaker_enchant_totem"] = true,
        ["phoenix_supernova"] = true,
        ["snapfire_firesnap_cookie"] = true,
        ["slark_depth_shroud"] = true,
    }

    if self:containsStrategy(self.hero_strategy, "半路大") then
        selfCastSkillsWithRange["doom_bringer_doom"] = true
    end
    if self:containsStrategy(self.hero_strategy, "贴脸放盾") then
        selfCastSkillsWithRange["abaddon_aphotic_shield"] = true
    end



    return selfCastSkillsWithRange[abilityName] or false
end