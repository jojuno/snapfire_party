--------------------------------------------------------------------------------
lil_shredder_base_debuff_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function lil_shredder_base_debuff_modifier:IsHidden()
	return false
end

function lil_shredder_base_debuff_modifier:IsDebuff()
	return true
end

function lil_shredder_base_debuff_modifier:IsStunDebuff()
	return false
end

function lil_shredder_base_debuff_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function lil_shredder_base_debuff_modifier:OnCreated( kv )
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor( "attack_speed_slow_per_stack" )

	if not IsServer() then return end
	self:SetStackCount( 1 )
end

function lil_shredder_base_debuff_modifier:OnRefresh( kv )
	if not IsServer() then return end
	self:IncrementStackCount()
end

function lil_shredder_base_debuff_modifier:OnRemoved()
end

function lil_shredder_base_debuff_modifier:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function lil_shredder_base_debuff_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function lil_shredder_base_debuff_modifier:GetModifierAttackSpeedBonus_Constant()
	return self.slow * self:GetStackCount()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function lil_shredder_base_debuff_modifier:GetEffectName()
	-- return "particles/units/heroes/hero_snapfire/hero_snapfire_slow_debuff.vpcf"
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function lil_shredder_base_debuff_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end