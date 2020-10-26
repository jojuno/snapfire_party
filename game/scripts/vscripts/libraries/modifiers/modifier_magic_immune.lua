modifier_magic_immune = class({})

function modifier_magic_immune:CheckState()
	local state = {
	[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end