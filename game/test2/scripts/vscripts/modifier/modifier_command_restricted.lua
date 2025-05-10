modifier_command_restricted = class({})

function modifier_command_restricted:IsHidden()
    return false
end

function modifier_command_restricted:IsPurgable()
    return true
end

function modifier_command_restricted:IsDebuff()
    return true
end

function modifier_command_restricted:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
end
