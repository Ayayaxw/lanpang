modifier_tethered = class({})

function modifier_tethered:IsHidden()
    return false
end

function modifier_tethered:IsDebuff()
    return true
end

function modifier_tethered:IsPurgable()
    return false
end

function modifier_tethered:GetTexture()
    return "modifier_tethered"
end

function modifier_tethered:CheckState()
    local state = {
        [MODIFIER_STATE_TETHERED] = true,
    }
    return state
end

