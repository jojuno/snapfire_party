modifier_fiery_soul_on_kill_lua = class({})
--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:IsHidden()
	return ( self:GetStackCount() == 0 )
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:OnCreated( kv )
	self.fiery_soul_on_kill_attack_speed_bonus = self:GetAbility():GetSpecialValueFor( "fiery_soul_on_kill_attack_speed_bonus" )
	self.fiery_soul_on_kill_move_speed_bonus = self:GetAbility():GetSpecialValueFor( "fiery_soul_on_kill_move_speed_bonus" )
	self.fiery_soul_on_kill_max_stacks = self:GetAbility():GetSpecialValueFor( "fiery_soul_on_kill_max_stacks" )
	self.duration_tooltip = self:GetAbility():GetSpecialValueFor( "duration_tooltip" )
	self.flFierySoulDuration = 0

	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:OnRefresh( kv )
	self.fiery_soul_on_kill_attack_speed_bonus = self:GetAbility():GetSpecialValueFor( "fiery_soul_on_kill_attack_speed_bonus" )
	self.fiery_soul_on_kill_move_speed_bonus = self:GetAbility():GetSpecialValueFor( "fiery_soul_on_kill_move_speed_bonus" )
	self.fiery_soul_on_kill_max_stacks = self:GetAbility():GetSpecialValueFor( "fiery_soul_on_kill_max_stacks" )
	self.duration_tooltip = self:GetAbility():GetSpecialValueFor( "duration_tooltip" )

	if IsServer() then
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) ) 
	end
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_DEATH,

	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:OnIntervalThink()
	if IsServer() then
		self:StartIntervalThink( -1 )
		self:SetStackCount( 0 )
		--ParticleManager:DestroyParticle(self.nFXIndex, false)
	end
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetStackCount() * self.fiery_soul_on_kill_move_speed_bonus
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:GetModifierAttackSpeedBonus_Constant( params )
	return self:GetStackCount() * self.fiery_soul_on_kill_attack_speed_bonus
end

--------------------------------------------------------------------------------

function modifier_fiery_soul_on_kill_lua:OnHeroKilled( params )
	if IsServer() then
		if params.unit == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

            local attacker = params.attacker
			local target = params.target
			if params.unit ~= target then
				if self:GetStackCount() < self.fiery_soul_on_kill_max_stacks then
					self:IncrementStackCount()
				else
					self:SetStackCount( self:GetStackCount() )
					self:ForceRefresh()
				end

				self:SetDuration( self.duration_tooltip, true )
				self:StartIntervalThink( self.duration_tooltip )
			end
		end
	end

	return 0
end 

--------------------------------------------------------------------------------

--if not done, effect will linger even after death
function modifier_fiery_soul_on_kill_lua:OnDeath( params )
	if IsServer() then
		if params.unit == self:GetParent() then
			self:SetStackCount( 0 )
		end
	end
	return 0
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------