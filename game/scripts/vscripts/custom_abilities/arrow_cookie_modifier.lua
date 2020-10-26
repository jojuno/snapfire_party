arrow_cookie_modifier = class({})

function arrow_cookie_modifier:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function arrow_cookie_modifier:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function arrow_cookie_modifier:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

--------------------------------------------------------------------------------

function arrow_cookie_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

function arrow_cookie_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function arrow_cookie_modifier:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function arrow_cookie_modifier:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
