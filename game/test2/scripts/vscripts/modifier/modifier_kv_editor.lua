modifier_kv_editor = class({})

function modifier_kv_editor:IsHidden()
    return true
end

function modifier_kv_editor:IsPurgable()
    return false
end

function modifier_kv_editor:IsDebuff()
    return false
end

function modifier_kv_editor:RemoveOnDeath()
    return false
end



function modifier_kv_editor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    }
end

function modifier_kv_editor:GetModifierOverrideAbilitySpecial(params)
    local ability = params.ability
    if not ability then return 0 end

    if ability_name == "lion_finger_of_death" then
        print("\n========== 龙尾技能详细信息 ==========")
    end

    local hero = ability:GetCaster()
    if not hero then return 0 end

    local hero_name = hero:GetUnitName()
    local ability_name = ability:GetAbilityName()
    local ability_index = hero_name .. "_" .. ability_name

    local ability_data = CustomNetTables:GetTableValue("edit_kv", ability_index)
    if not ability_data then return 0 end

    local special_value_name = params.ability_special_value
    if ability_data[special_value_name] ~= nil then
        return 1
    end

    return 0
end

function modifier_kv_editor:GetModifierOverrideAbilitySpecialValue(params)
    local ability = params.ability
    if not ability then return 0 end

    local special_value_name = params.ability_special_value
    local ability_special_level = params.ability_special_level
    local base_value = ability:GetLevelSpecialValueNoOverride(special_value_name, ability_special_level)

    local hero = ability:GetCaster()
    if not hero or not hero:IsRealHero() then return base_value end

    local hero_name = hero:GetUnitName()
    local ability_name = ability:GetAbilityName()

    -- 添加龙骑士龙尾的调试信息
    if ability_name == "lion_finger_of_death" then
        print("\n========== 龙尾技能详细信息 ==========")
        print("特殊值名称:", special_value_name)
        print("基础值:", base_value)
        print("英雄名称:", hero_name)
    end

    local ability_index = hero_name .. "_" .. ability_name
    local ability_data = CustomNetTables:GetTableValue("edit_kv", ability_index)

    if ability_name == "lion_finger_of_death" then
        print("\n技能数据:")
        if ability_data then
            DeepPrintTable(ability_data)
        else
            print("没有找到技能数据")
        end
    end

    if not ability_data then 
        return base_value 
    end

    -- 检查是否是特殊天赋加成值
    if special_value_name:find("special_bonus_") then
        if ability_data[special_value_name] then
            if type(ability_data[special_value_name]) == "string" and ability_data[special_value_name]:sub(1,1) == "=" then
                return tonumber(ability_data[special_value_name]:sub(2))
            end
            return ability_data[special_value_name]
        end
        return base_value
    end

    -- 对于神杖和魔晶的检查
    local has_scepter = hero:HasScepter()
    local has_shard = hero:HasModifier("modifier_item_aghanims_shard")

    if special_value_name:find("scepter") and not has_scepter then
        return base_value
    end
    if special_value_name:find("shard") and not has_shard then
        return base_value
    end

    -- 检查基础值是否需要覆盖
    if ability_data[special_value_name] then
        local override_value = ability_data[special_value_name]

        if ability_name == "lion_finger_of_death" then
            print("\n覆盖值信息:")
            print("特殊值类型:", type(override_value))
            if type(override_value) == "table" then
                DeepPrintTable(override_value)
            else
                print("覆盖值:", override_value)
            end
        end

        -- 检查是否是复杂结构
        if type(override_value) == "table" then
            -- 首先检查命石要求
            if override_value.RequiresFacet then
                -- 获取当前英雄的命石ID
                local facet_id = hero:GetHeroFacetID()
                -- 获取英雄的命石配置
                local hero_facets = heroesFacets[hero_name]
        
                if ability_name == "lion_finger_of_death" then
                    print("\n命石检查信息:")
                    print("需求的命石:", override_value.RequiresFacet)
                    print("当前命石ID:", facet_id)
                    print("英雄命石配置:")
                    if hero_facets then
                        DeepPrintTable(hero_facets)
                    else
                        print("未找到英雄命石配置")
                    end
                end
        
                if not hero_facets or not hero_facets.Facets then
                    if ability_name == "lion_finger_of_death" then
                        print("未找到有效的命石配置")
                    end
                    return base_value
                end
                
                -- 检查当前命石ID对应的命石名称是否匹配需求
                local current_facet = hero_facets.Facets[facet_id]
                
                if ability_name == "lion_finger_of_death" then
                    print("\n命石匹配检查:")
                    if current_facet then
                        print("当前命石名称:", current_facet.name)
                        print("是否匹配:", current_facet.name == override_value.RequiresFacet)
                    else
                        print("未找到当前命石信息")
                    end
                end
        
                if not current_facet or current_facet.name ~= override_value.RequiresFacet then
                    if ability_name == "lion_finger_of_death" then
                        print("命石要求不满足，返回基础值")
                    end
                    return base_value
                end
            end
        
            local value = override_value.value
            local final_value = base_value
        
            if type(value) == "string" then
                if value:sub(1,1) == "=" then
                    final_value = tonumber(value:sub(2))
                else
                    -- 处理多等级值
                    local values = {}
                    for number in value:gmatch("%S+") do
                        table.insert(values, tonumber(number))
                    end
                    local level = ability_special_level + 1
                    if values[level] then
                        final_value = values[level]
                    else
                        final_value = values[#values]
                    end
                end
            else
                final_value = value or final_value  -- 确保有值
            end
            
            if ability_name == "lion_finger_of_death" then
                print("\n计算基础值:")
                print("初始值:", final_value)
            end
        
            -- 处理各种加成
            for bonus_name, bonus_value in pairs(override_value) do
                -- 跳过已处理的关键字
                if bonus_name ~= "value" and bonus_name ~= "RequiresFacet" then
                    if ability_name == "lion_finger_of_death" then
                        print("\n处理加成:", bonus_name)
                        print("加成值:", bonus_value)
                    end
        
                    -- 处理神杖加成
                    if bonus_name == "special_bonus_scepter" and has_scepter then
                        local scepter_bonus = type(bonus_value) == "number" and bonus_value or tonumber(bonus_value:sub(2))
                        final_value = final_value + scepter_bonus
                        if ability_name == "lion_finger_of_death" then
                            print("应用神杖加成:", scepter_bonus)
                        end
                    -- 处理魔晶加成
                    elseif bonus_name == "special_bonus_shard" and has_shard then
                        local shard_bonus = type(bonus_value) == "number" and bonus_value or tonumber(bonus_value:sub(2))
                        final_value = final_value + shard_bonus
                        if ability_name == "lion_finger_of_death" then
                            print("应用魔晶加成:", shard_bonus)
                        end
                    -- 处理命石特殊值
                    elseif bonus_name:find("special_bonus_facet_") then
                        -- 处理字符串形式 (如 "=1500")
                        if type(bonus_value) == "string" and bonus_value:sub(1,1) == "=" then
                            final_value = tonumber(bonus_value:sub(2))
                            print("应用命石特殊值(覆盖):", final_value)
                        -- 处理数值类型 (如 1500)
                        elseif type(bonus_value) == "number" then
                            final_value = final_value + bonus_value  -- 或者直接覆盖: final_value = bonus_value
                            print("应用命石特殊值(数值加成):", bonus_value)
                        end
                    -- 处理天赋加成
                    elseif bonus_name:find("special_bonus_") then
                        local bonus_ability = hero:FindAbilityByName(bonus_name)
                        if bonus_ability and bonus_ability:GetLevel() > 0 then
                            local bonus_amount = 0
                            if type(bonus_value) == "string" then
                                if bonus_value:sub(1,1) == "=" then
                                    bonus_amount = tonumber(bonus_value:sub(2))
                                elseif bonus_value:sub(1,1) == "+" then
                                    bonus_amount = tonumber(bonus_value:sub(2))
                                elseif bonus_value:sub(1,1) == "-" then
                                    bonus_amount = -tonumber(bonus_value:sub(2))
                                end
                            else
                                bonus_amount = bonus_value
                            end
                            final_value = final_value + bonus_amount
                            if ability_name == "lion_finger_of_death" then
                                print("应用天赋加成:", bonus_amount)
                            end
                        end
                    end
                end
            end
            
            if ability_name == "lion_finger_of_death" then
                print("\n最终值:", final_value)
                print("====================================")
            end
            
            return final_value
        else
            -- 简单值覆盖
            if type(override_value) == "string" then
                if override_value:sub(1,1) == "=" then
                    return tonumber(override_value:sub(2))
                end
                local values = {}
                for number in override_value:gmatch("%S+") do
                    table.insert(values, tonumber(number))
                end
                local level = ability_special_level + 1
                
                if values[level] then
                    return values[level]
                else
                    return values[#values]
                end
            else
                return override_value
            end
        end
    end

    return base_value
end

