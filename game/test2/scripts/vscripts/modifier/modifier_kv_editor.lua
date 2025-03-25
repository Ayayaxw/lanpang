-- 添加打印表格的辅助函数
function PrintTable(t, indent, done)
    done = done or {}
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    
    for k, v in pairs(t) do
        if type(v) == "table" and not done[v] then
            done[v] = true
            print(prefix..tostring(k).." = {")
            PrintTable(v, indent + 1, done)
            print(prefix.."}")
        else
            print(prefix..tostring(k).." = "..tostring(v))
        end
    end
end

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

    local hero = ability:GetCaster()
    if not hero then return 0 end

    local hero_name = hero:GetUnitName()
    local ability_name = ability:GetAbilityName()
    
    -- 处理熊猫酒仙的元素分身
    if hero_name:find("npc_dota_brewmaster_") then
        hero_name = "npc_dota_hero_brewmaster" -- 使用熊猫酒仙的英雄名
    end
    if hero_name:find("caipan") then
        hero_name = "npc_dota_hero_faceless_void" -- 使用熊猫酒仙的英雄名
    end
    
    local ability_index = hero_name .. "_" .. ability_name
    
    local ability_data = CustomNetTables:GetTableValue("edit_kv", ability_index)
    
    if not ability_data then return 0 end

    local special_value_name = params.ability_special_value
    
    -- 修改：检查直接特殊值或AbilityValues中的特殊值
    if ability_data[special_value_name] ~= nil or 
       (ability_data.AbilityValues and ability_data.AbilityValues[special_value_name] ~= nil) then
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
    if not hero then 
        return base_value 
    end

    local hero_name = hero:GetUnitName()
    local ability_name = ability:GetAbilityName()
    
    -- 处理熊猫酒仙的元素分身
    local is_brew_spirit = false
    if hero_name:find("npc_dota_brewmaster_") then
        is_brew_spirit = true
        hero_name = "npc_dota_hero_brewmaster" -- 使用熊猫酒仙的英雄名
    end
    if hero_name:find("caipan") then
        is_brew_spirit = true
        hero_name = "npc_dota_hero_faceless_void" -- 使用熊猫酒仙的英雄名
    end

    local ability_index = hero_name .. "_" .. ability_name
    
    local ability_data = CustomNetTables:GetTableValue("edit_kv", ability_index)
    
    if not ability_data then 
        return base_value 
    end

    -- 从数据中获取实际覆盖值（直接值或AbilityValues中的值）
    local override_value = ability_data[special_value_name]
    if not override_value and ability_data.AbilityValues then
        override_value = ability_data.AbilityValues[special_value_name]
    end
    
    if not override_value then
        return base_value
    end

    -- 检查是否是特殊天赋加成值
    if special_value_name:find("special_bonus_") then
        if type(override_value) == "string" and override_value:sub(1,1) == "=" then
            local value = tonumber(override_value:sub(2))
            return value
        end
        return override_value
    end

    -- 对元素分身的特殊处理：跳过天赋和命石检查
    if is_brew_spirit then
        
        -- 简单值覆盖
        if type(override_value) ~= "table" then
            if type(override_value) == "string" then
                if override_value:sub(1,1) == "=" then
                    local value = tonumber(override_value:sub(2))
                    return value
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
        else
            -- 为元素分身处理复杂表格数据
            
            local value = override_value.value
            
            if type(value) == "string" then
                if value:sub(1,1) == "=" then
                    local result = tonumber(value:sub(2))
                    return result
                else
                    -- 处理多等级值
                    local values = {}
                    for number in value:gmatch("%S+") do
                        table.insert(values, tonumber(number))
                    end
                    
                    local level = ability_special_level + 1
                    
                    if values[level] then
                        return values[level]
                    else
                        return values[#values]
                    end
                end
            else
                return value or base_value
            end
        end
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

    -- 检查是否是复杂结构
    if type(override_value) == "table" then
        
        -- 首先检查命石要求
        if override_value.RequiresFacet then
            -- 获取当前英雄的命石ID
            local facet_id = hero:GetHeroFacetID()
            -- 获取英雄的命石配置
            local hero_facets = heroesFacets[hero_name]
            
            if not hero_facets or not hero_facets.Facets then
                return base_value
            end
            
            -- 检查当前命石ID对应的命石名称是否匹配需求
            local current_facet = hero_facets.Facets[facet_id]
            
            if not current_facet then
                return base_value
            end
            
            if current_facet.name ~= override_value.RequiresFacet then
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
    
        -- 处理各种加成
        for bonus_name, bonus_value in pairs(override_value) do
            -- 跳过已处理的关键字
            if bonus_name ~= "value" and bonus_name ~= "RequiresFacet" then
                -- 处理神杖加成
                if bonus_name == "special_bonus_scepter" and has_scepter then
                    local scepter_bonus = type(bonus_value) == "number" and bonus_value or tonumber(bonus_value:sub(2))
                    final_value = final_value + scepter_bonus
                -- 处理魔晶加成
                elseif bonus_name == "special_bonus_shard" and has_shard then
                    local shard_bonus = type(bonus_value) == "number" and bonus_value or tonumber(bonus_value:sub(2))
                    final_value = final_value + shard_bonus
                -- 处理命石特殊值
                elseif bonus_name:find("special_bonus_facet_") then
                    -- 处理字符串形式 (如 "=1500")
                    if type(bonus_value) == "string" and bonus_value:sub(1,1) == "=" then
                        final_value = tonumber(bonus_value:sub(2))
                    -- 处理数值类型 (如 1500)
                    elseif type(bonus_value) == "number" then
                        final_value = final_value + bonus_value
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
                    end
                end
            end
        end
        
        return final_value
    else
        -- 简单值覆盖
        
        if type(override_value) == "string" then
            if override_value:sub(1,1) == "=" then
                local result = tonumber(override_value:sub(2))
                return result
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

