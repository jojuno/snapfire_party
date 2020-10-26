--created by EarthSalamander42
--reference: https://github.com/EarthSalamander42/dota_imba/blob/master/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_snapfire.lua

mortimer_kisses_base = class({})

LinkLuaModifier( "mortimer_kisses_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "magma_burn_slow_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function mortimer_kisses_base:GetAOERadius()
	return self:GetSpecialValueFor( "impact_radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function mortimer_kisses_base:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local duration = self:GetDuration()

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"mortimer_kisses_modifier", -- modifier name
		{
			duration = duration,
			pos_x = point.x,
			pos_y = point.y,
		} -- kv
	)
end

--------------------------------------------------------------------------------
-- Projectile
function mortimer_kisses_base:OnProjectileHit( target, location )
	if not target then return end

	-- load data
	local damage = self:GetSpecialValueFor( "damage_per_impact" )
	local duration = self:GetSpecialValueFor( "burn_ground_duration" )
	local impact_radius = self:GetSpecialValueFor( "impact_radius" )

	if target.secondary then
		impact_radius = self:GetSpecialValueFor("rings_radius")
	end
	local vision = self:GetSpecialValueFor( "projectile_vision" )

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		impact_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end

	-- start aura on thinker
	local mod = target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"mortimer_kisses_thinker_modifier", -- modifier name
		{
			duration = duration,
			slow = 1,
		} -- kv
	)

	-- destroy trees
	GridNav:DestroyTreesAroundPoint( location, impact_radius, true )

	-- create Vision
	AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision, duration, false )

	-- play effects
	self:PlayEffects( location )

	if target.secondary then return end

    --------------------------------------------------------------------------------------------------------
	-- Mortimer Hugs IMBAfication (unable to set ground blob pfx size, need custom one)
	--[[if target.mega_blob then
		local forward = target:GetForwardVector()
		local blob_rings_count = self:GetSpecialValueFor("blob_rings_count")
		local rings_distance = self:GetSpecialValueFor("rings_distance")
		local angle_diff = 360 / blob_rings_count
		local blob_pos = {}

		for i = 1, blob_rings_count do
			blob_pos[i] = RotatePosition(location, QAngle(0, angle_diff * i, 0), location + (forward * rings_distance))
	
			local target_pos = GetGroundPosition( blob_pos[i], nil )
			local travel_time = self:GetSpecialValueFor("rings_delay")
	
			-- create target thinker
			local thinker = CreateModifierThinker(
				self:GetCaster(), -- player source
				self, -- ability source
				"mortimer_kisses_thinker_modifier", -- modifier name
				{ travel_time = travel_time }, -- kv
				target_pos,
				self:GetCaster():GetTeamNumber(),
				false
			)
	
			thinker.secondary = true
	
			local min_range = self:GetSpecialValueFor( "min_range" )
			local max_range = self:GetCastRange( Vector(0,0,0), nil )
			local vec = (location - target_pos):Length2D()
	
			local info = {
				Target = thinker,
				Source = target,
				Ability = self,	
				iMoveSpeed = vec / travel_time,
				EffectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf",
				bDodgeable = false,                           -- Optional
	
				vSourceLoc = location,                -- Optional (HOW)
	
				bDrawsOnMinimap = false,                          -- Optional
				bVisibleToEnemies = true,                         -- Optional
				bProvidesVision = true,                           -- Optional
				iVisionRadius = self:GetSpecialValueFor( "projectile_vision" ),                              -- Optional
				iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
			}
	
			-- launch projectile
			ProjectileManager:CreateTrackingProjectile( info )
	
			-- create FOW
			AddFOWViewer( self:GetCaster():GetTeamNumber(), thinker:GetOrigin(), 100, 1, false )
	
			-- play sound
			EmitSoundOn( "Hero_Snapfire.MortimerBlob.Launch", target )
		end
    end]]
    --------------------------------------------------------------------------------------------------------
end

--------------------------------------------------------------------------------
function mortimer_kisses_base:PlayEffects( loc )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, self:GetCaster() )
end

--------------------------------------------------------------------------------
mortimer_kisses_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function mortimer_kisses_modifier:IsHidden()
	return false
end

function mortimer_kisses_modifier:IsDebuff()
	return false
end

function mortimer_kisses_modifier:IsStunDebuff()
	return false
end

function mortimer_kisses_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function mortimer_kisses_modifier:OnCreated( kv )
	-- references
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_range" )
	self.max_range = self:GetAbility():GetCastRange( Vector(0,0,0), nil )
	self.range = self.max_range-self.min_range

	self.min_travel = self:GetAbility():GetSpecialValueFor( "min_lob_travel_time" )
	self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
	self.travel_range = self.max_travel-self.min_travel

	local projectile_vision = self:GetAbility():GetSpecialValueFor( "projectile_vision" )

	self.turn_rate = self:GetAbility():GetSpecialValueFor( "turn_rate" )
	self.blob_count = 0

	if not IsServer() then return end

	-- load data
	local projectile_speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" ) + self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_1")
	local projectile_count = self:GetAbility():GetSpecialValueFor( "projectile_count" ) + self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_1")
	local interval = self:GetAbility():GetDuration() / projectile_count + 0.01 -- so it only have 8 projectiles instead of 9
	self:SetValidTarget( Vector( kv.pos_x, kv.pos_y, 0 ) )
	local projectile_start_radius = 0
	local projectile_end_radius = 0

	-- precache projectile
	self.info = {
		-- Target = target,
		Source = self:GetCaster(),
		Ability = self:GetAbility(),	
		
		EffectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf",
		iMoveSpeed = projectile_speed,
		bDodgeable = false,                           -- Optional
	
		vSourceLoc = self:GetCaster():GetOrigin(),                -- Optional (HOW)
		
		bDrawsOnMinimap = false,                          -- Optional
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = projectile_vision,                              -- Optional
		iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
	}

	-- Start interval
	self:StartIntervalThink( interval )
	self:OnIntervalThink()
end

function mortimer_kisses_modifier:OnRefresh( kv )
	
end

function mortimer_kisses_modifier:OnRemoved()
end

function mortimer_kisses_modifier:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function mortimer_kisses_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}

	return funcs
end

function mortimer_kisses_modifier:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	-- right click, switch position
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		self:SetValidTarget( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetValidTarget( params.target:GetOrigin() )

	-- stop or hold
	elseif 
		params.order_type==DOTA_UNIT_ORDER_STOP or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:Destroy()
	end
end

function mortimer_kisses_modifier:GetModifierMoveSpeed_Limit()
	return 0.1
end

function mortimer_kisses_modifier:GetModifierTurnRate_Percentage()
	return -self.turn_rate
end

--------------------------------------------------------------------------------
-- Status Effects
function mortimer_kisses_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function mortimer_kisses_modifier:OnIntervalThink()
	self:CreateBlob(kv)
end

function mortimer_kisses_modifier:CreateBlob(kv)
	if not kv then kv = {} end

	local travel_time = self.travel_time
	local target_pos = self.target

	if kv.pos then
		target_pos = GetGroundPosition( self.target + kv.pos, nil )
	end

	if kv.travel_time then
		travel_time = kv.travel_time
	end

    -- create target thinker
    
    
	local thinker = CreateModifierThinker(
		self:GetParent(), -- player source
		self:GetAbility(), -- ability source
        "mortimer_kisses_thinker_modifier", -- modifier name
		{ travel_time = travel_time }, -- kv
		target_pos,
		self:GetParent():GetTeamNumber(),
		false
	)

	self.blob_count = self.blob_count + 1

	--print(self.blob_count, self:GetAbility():GetSpecialValueFor("mini_blob_counter"))
	--[[if self.blob_count == self:GetAbility():GetSpecialValueFor("mini_blob_counter") then
		self.blob_count = 0
		thinker.mega_blob = true
	end]]

	-- set projectile
	self.info.iMoveSpeed = self.vector:Length2D() / travel_time
	self.info.Target = thinker

	-- launch projectile
	ProjectileManager:CreateTrackingProjectile( self.info )

	-- create FOW
	AddFOWViewer( self:GetParent():GetTeamNumber(), thinker:GetOrigin(), 100, 1, false )

	-- play sound
	EmitSoundOn( "Hero_Snapfire.MortimerBlob.Launch", self:GetParent() )
end

--------------------------------------------------------------------------------
-- Helper
function mortimer_kisses_modifier:SetValidTarget( location )
	local origin = self:GetParent():GetOrigin()
	local vec = location-origin
	local direction = vec
	direction.z = 0
	direction = direction:Normalized()

	if vec:Length2D()<self.min_range then
		vec = direction * self.min_range
	elseif vec:Length2D()>self.max_range then
		vec = direction * self.max_range
	end

	self.target = GetGroundPosition( origin + vec, nil )
	self.vector = vec
	self.travel_time = (vec:Length2D()-self.min_range)/self.range * self.travel_range + self.min_travel
end

--------------------------------------------------------------------------------
magma_burn_slow_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function magma_burn_slow_modifier:IsHidden()
	return false
end

function magma_burn_slow_modifier:IsDebuff()
	return true
end

function magma_burn_slow_modifier:IsStunDebuff()
	return false
end

function magma_burn_slow_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function magma_burn_slow_modifier:OnCreated( kv )
	-- references
	self.dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )
    local interval = self:GetAbility():GetSpecialValueFor( "burn_interval" )
    local slow_pct = self:GetAbility():GetSpecialValueFor("slow_pct")

	if not IsServer() then return end

	-- Fiery Slash Impact IMBAfication
	local distance = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
    -- local distance_travel = math.min(distance / self:GetCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()), 1)
	-- hardcoded for now
	local distance_travel = math.min(distance / 3000, 1)
	--local min_slow = self:GetAbility():GetSpecialValueFor("min_slow_pct") + self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_4")
	--local max_slow = self:GetAbility():GetSpecialValueFor("max_slow_pct") + self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_4")
    --self:SetStackCount(math.max(max_slow * distance_travel, min_slow))
    self:SetStackCount(slow_pct)

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.dps*interval,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}

	-- Start interval
	self:StartIntervalThink( interval )
	self:OnIntervalThink()
end

function magma_burn_slow_modifier:OnRefresh( kv )
	
end

function magma_burn_slow_modifier:OnRemoved()
end

function magma_burn_slow_modifier:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function magma_burn_slow_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function magma_burn_slow_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * (-1)
end

--------------------------------------------------------------------------------
-- Interval Effects
function magma_burn_slow_modifier:OnIntervalThink()
	-- apply damage
	ApplyDamage( self.damageTable )

	-- play overhead
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function magma_burn_slow_modifier:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function magma_burn_slow_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function magma_burn_slow_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function magma_burn_slow_modifier:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

--------------------------------------------------------------------------------
mortimer_kisses_thinker_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications

--------------------------------------------------------------------------------
-- Initializations
function mortimer_kisses_thinker_modifier:OnCreated( kv )
    print("[mortimer_kisses_thinker_modifier:OnCreated( kv )] called")
    print("[mortimer_kisses_thinker_modifier:OnCreated( kv )] ability that called this function: " .. self:GetAbility():GetAbilityName())
	-- references
	self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
	self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
	self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

	if not IsServer() then return end

	-- dont start aura right off
	self.start = false

    -- create aoe finder particle
    if self:GetAbility():GetAbilityName() == "mortimer_kisses_base" then
        self:PlayEffects( kv.travel_time )
    end
end

function mortimer_kisses_thinker_modifier:OnRefresh( kv )
	-- references
	self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
	self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
	self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

	if not IsServer() then return end

	-- start aura
	self.start = true

	-- stop aoe finder particle
	self:StopEffects()
end

function mortimer_kisses_thinker_modifier:OnRemoved()
end

function mortimer_kisses_thinker_modifier:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function mortimer_kisses_thinker_modifier:IsAura()
	return self.start
end

function mortimer_kisses_thinker_modifier:GetModifierAura()
	return "magma_burn_slow_modifier"
end

function mortimer_kisses_thinker_modifier:GetAuraRadius()
	return self.radius
end

function mortimer_kisses_thinker_modifier:GetAuraDuration()
	return self.linger
end

function mortimer_kisses_thinker_modifier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function mortimer_kisses_thinker_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function mortimer_kisses_thinker_modifier:PlayEffects( time )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end

function mortimer_kisses_thinker_modifier:StopEffects()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end


