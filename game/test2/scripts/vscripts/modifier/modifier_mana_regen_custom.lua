modifier_mana_regen_custom = class({})

function modifier_mana_regen_custom:IsHidden()
    return true
end

function modifier_mana_regen_custom:IsDebuff()
    return false
end

function modifier_mana_regen_custom:IsPurgable()
    return false
end


function modifier_mana_regen_custom:OnCreated(kv)
    if IsServer() then
        self.regen_amount = kv.regen_amount or 3000  -- 默认值为7，如果没有传入参数
    end
end

function modifier_mana_regen_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
end

function modifier_mana_regen_custom:GetModifierConstantManaRegen()
    return self.regen_amount or 3000  -- 为任何情况提供默认值
end

function modifier_mana_regen_custom:AllowIllusionDuplicate()
    return false
end 