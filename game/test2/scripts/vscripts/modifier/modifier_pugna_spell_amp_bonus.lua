-- 帕格纳法术伤害增强modifier
modifier_pugna_spell_amp_bonus = class({})

function modifier_pugna_spell_amp_bonus:IsHidden()
    return false
end

function modifier_pugna_spell_amp_bonus:IsDebuff()
    return false
end

function modifier_pugna_spell_amp_bonus:IsPurgable()
    return false
end

function modifier_pugna_spell_amp_bonus:GetTexture()
    return "pugna_oblivion_savant"
end

function modifier_pugna_spell_amp_bonus:OnCreated()
    if IsServer() then
        print("创建帕格纳法术伤害增强modifier")
    end
end

function modifier_pugna_spell_amp_bonus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function modifier_pugna_spell_amp_bonus:GetModifierSpellAmplify_Percentage()
    return 1000 -- 增加1000%的法术伤害
    
end

function modifier_pugna_spell_amp_bonus:GetEffectName()
    return "particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf"
end

function modifier_pugna_spell_amp_bonus:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end 