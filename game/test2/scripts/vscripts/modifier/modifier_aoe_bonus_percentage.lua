modifier_aoe_bonus_percentage = class({})

function modifier_aoe_bonus_percentage:IsHidden()
    return false
end

function modifier_aoe_bonus_percentage:IsDebuff()
    return false
end

function modifier_aoe_bonus_percentage:IsPurgable()
    return false
end

function modifier_aoe_bonus_percentage:RemoveOnDeath()
    return false
end

function modifier_aoe_bonus_percentage:GetTexture()
    return "item_gungir"
end

function modifier_aoe_bonus_percentage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL
    }
    return funcs
end

function modifier_aoe_bonus_percentage:GetModifierOverrideAbilitySpecial(keys)
    local ability = self:GetAbility()
    if not ability or not keys.ability or not keys.ability_special_value then
        return 0
    end

    -- 检测是否是范围相关的属性（如半径、范围等）
    if self.affected_specials[keys.ability_special_value] == nil then
        local ability_kv = GetAbilityKeyValuesByName(keys.ability:GetAbilityName())
        if ability_kv.AbilityValues and ability_kv.AbilityValues[keys.ability_special_value] then
            -- 假设技能KV中标记了affected_by_aoe_increase的属性需要加成
            if ability_kv.AbilityValues[keys.ability_special_value].affected_by_aoe_increase then
                self.affected_specials[keys.ability_special_value] = true
            end
        end
    end

    -- 如果是要修改的属性则返回1
    return self.affected_specials[keys.ability_special_value] and 1 or 0
end

function modifier_aoe_bonus_percentage:GetModifierOverrideAbilitySpecialValue(keys)
    local szSpecialValueName = keys.ability_special_value
    local nSpecialLevel = keys.ability_special_level
    local flBaseValue = keys.ability:GetLevelSpecialValueNoOverride(szSpecialValueName, nSpecialLevel)
    
    -- 直接增加固定1000范围
    return flBaseValue + 1000
end

-- 在modifier创建时初始化记录表
function modifier_aoe_bonus_percentage:OnCreated()
    self.affected_specials = {}
end