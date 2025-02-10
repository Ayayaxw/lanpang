modifier_custom_out_of_game = class({})

function modifier_custom_out_of_game:CheckState()
	local state = { 
		--[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
	}
	return state
end

function modifier_custom_out_of_game:IsPurgable()
	return false
end

function modifier_custom_out_of_game:IsStunDebuff()
	return false
end

function modifier_custom_out_of_game:IsPurgeException()
	return false
end

function modifier_custom_out_of_game:IsHidden()
	return true
end