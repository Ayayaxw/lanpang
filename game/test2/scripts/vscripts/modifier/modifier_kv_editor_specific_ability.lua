modifier_kv_editor_specific_ability = class({})

function modifier_kv_editor_specific_ability:IsHidden()
    return true
end

function modifier_kv_editor_specific_ability:IsPurgable()
    return false
end

function modifier_kv_editor_specific_ability:IsDebuff()
    return false
end

function modifier_kv_editor_specific_ability:RemoveOnDeath()
    return false
end

function modifier_kv_editor_specific_ability:GetTexture()
    return "ad_psd"
end

function modifier_kv_editor_specific_ability:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, 
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_HEROFACET_OVERRIDE
    }
end

function modifier_kv_editor_specific_ability:GetModifierOverrideAbilitySpecial(params)
    local parent = self:GetParent()
    if not parent or not params.ability then
        return 0
    end

    local ability_data = CustomNetTables:GetTableValue("edit_kv", tostring(params.ability:GetEntityIndex()))

    if ability_data then
        local special_value_name = params.ability_special_value
        if ability_data[special_value_name] then
            return 1
        end
    end

    return 0
end

function modifier_kv_editor_specific_ability:GetModifierOverrideAbilitySpecialValue(params)
    local special_value_name = params.ability_special_value
    local base_value = params.ability:GetLevelSpecialValueNoOverride(special_value_name, params.ability_special_level)

    local ability_data = CustomNetTables:GetTableValue("edit_kv", tostring(params.ability:GetEntityIndex()))
    if ability_data then
        if ability_data[special_value_name] then
            return ability_data[special_value_name]
        end
    end

    return base_value
end

function modifier_kv_editor_specific_ability:GetModifierHeroFacetOverride(params)
    print("GetModifierHeroFacetOverride")
    DeepPrintTable(params)

    return 1
end
