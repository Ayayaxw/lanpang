function CommonAI:GetSkillNumberMapping()


end

--返回随机的一个一技能
function CommonAI:GetRandomFirstSkill(unit)
    
    local unitName = unit:GetUnitName()
    --print("单位名字: " .. unitName)
    
    -- doom的特殊处理：从索引为0、3和4的技能中随机选择一个，排除包含"doom_bringer_empty"的技能
    if unitName == "npc_dota_hero_doom_bringer" then
        local validIndices = {0, 3, 4}
        local validAbilities = {}
        
        -- 检查每个索引位置的技能
        for _, index in ipairs(validIndices) do
            local ability = unit:GetAbilityByIndex(index)
            if ability and not ability:IsNull() then
                local abilityName = ability:GetAbilityName()
                -- 只添加不包含"doom_bringer_empty"且不是被动技能和切换类技能的技能
                if not string.find(abilityName, "doom_bringer_empty") and 
                   not ability:IsPassive() and 
                   not ability:IsToggle() then
                    table.insert(validAbilities, ability)
                end
            end
        end
        
        -- 如果找到有效技能，随机返回一个
        if #validAbilities > 0 then
            local randomAbility = validAbilities[RandomInt(1, #validAbilities)]
            --print("Doom有效技能数: " .. #validAbilities .. ", 选中技能: " .. randomAbility:GetAbilityName())
            return randomAbility
        end
    end
    
    -- 特殊英雄的一技能映射
    local specialFirstSkills = {
        npc_dota_hero_primal_beast = {"primal_beast_onslaught"},
        npc_dota_hero_nevermore = {"nevermore_shadowraze3", "nevermore_shadowraze1", "nevermore_shadowraze2"},
        npc_dota_hero_invoker = {"invoker_cold_snap", "invoker_ghost_walk", "invoker_ice_wall"},
        npc_dota_hero_kez = {"kez_echo_slash", "kez_falcon_rush"},
        npc_dota_hero_rubick = {"rubick_telekinesis"},
        npc_dota_hero_hoodwink = {"hoodwink_acorn_shot"},
        npc_dota_hero_keeper_of_the_light = {"keeper_of_the_light_illuminate"},
        npc_dota_hero_ringmaster = {"ringmaster_tame_the_beasts"},
    }
    
    -- 如果是特殊英雄，随机返回一个特定的一技能
    if specialFirstSkills[unitName] then
        local skills = specialFirstSkills[unitName]
        local randomIndex = RandomInt(1, #skills)
        return unit:FindAbilityByName(skills[randomIndex])
    end
    
    -- 对于大多数英雄，获取索引为0的技能（一技能）
    if unit:GetAbilityCount() > 0 then
        local ability = unit:GetAbilityByIndex(0)
        if ability and not ability:IsNull() then
            --print("技能名字: " .. ability:GetAbilityName())
            return ability
        end
    end
    
    return nil
end