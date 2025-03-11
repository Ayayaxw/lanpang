modifier_anti_invisible = class({})

function modifier_anti_invisible:IsHidden() return false end
function modifier_anti_invisible:IsDebuff() return true end
function modifier_anti_invisible:IsPurgable() return false end

function modifier_anti_invisible:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false  -- 强制禁用隐身状态
    }
end
