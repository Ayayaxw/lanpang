-- 通用技能增强modifier
modifier_special_bonus_spell_amplify = class({})

function modifier_special_bonus_spell_amplify:IsHidden()
    return false
end

function modifier_special_bonus_spell_amplify:IsDebuff()
    return false
end

function modifier_special_bonus_spell_amplify:IsPurgable()
    return false
end

function modifier_special_bonus_spell_amplify:GetTexture()
    return "item_kaya"
end

function modifier_special_bonus_spell_amplify:OnCreated(kv)
    if IsServer() then
        -- 获取传入的增强数值参数，默认为50%
        self.bonus_value = kv.bonus_value or 50
        print("创建技能增强modifier，增强值: " .. self.bonus_value .. "%")
    else
        -- 确保客户端也能获取到数值
        self.bonus_value = kv.bonus_value or 50
    end
end

function modifier_special_bonus_spell_amplify:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function modifier_special_bonus_spell_amplify:GetModifierSpellAmplify_Percentage()
    return self.bonus_value
end

function modifier_special_bonus_spell_amplify:GetEffectName()
    return "particles/items4_fx/spirit_vessel_damage.vpcf"
end

function modifier_special_bonus_spell_amplify:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

-- 自定义描述
function modifier_special_bonus_spell_amplify:OnTooltip()
    return self.bonus_value
end

function modifier_special_bonus_spell_amplify:OnTooltip2()
    return "法术增强"
end 