modifier_invisible = class({})

function modifier_invisible:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = true,
	}
	return state
end
