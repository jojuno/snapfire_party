scatterblast_base_modifier = class({})

function scatterblast_base_modifier:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function scatterblast_base_modifier:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function scatterblast_base_modifier:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

--------------------------------------------------------------------------------

function scatterblast_base_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

function scatterblast_base_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end


--------------------------------------------------------------------------------

function scatterblast_base_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor( "movement_slow_pct" ) * -1
end

--------------------------------------------------------------------------------

function scatterblast_base_modifier:GetModifierAttackSpeedBonus_Constant( params )
	return self:GetAbility():GetSpecialValueFor( "attack_speed_slow" ) * -1
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
