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
    local special_value_name = params.ability_special_value
    local ability_special_level = params.ability_special_level
    local base_value = ability:GetLevelSpecialValueNoOverride(special_value_name, ability_special_level)

    local hero = ability:GetCaster()
    if not hero then return base_value end

    local hero_name = hero:GetUnitName()
    local ability_name = ability:GetAbilityName()
    local ability_index = hero_name .. "_" .. ability_name

    local ability_data = CustomNetTables:GetTableValue("edit_kv", ability_index)
    if ability_data and ability_data[special_value_name] ~= nil then
        local override_value = ability_data[special_value_name]
        if type(override_value) == "string" then
            -- Parse multi-level value string
            local values = {}
            for number in override_value:gmatch("%S+") do
                table.insert(values, tonumber(number))
            end
            -- Get the value for the current ability level
            local level = ability_special_level + 1  -- Levels in Dota start from 1
            if values[level] then
                return values[level]
            else
                -- If level is out of bounds, return the last value
                return values[#values]
            end
        elseif type(override_value) == "number" then
            return override_value
        end
    end

    return base_value
end

