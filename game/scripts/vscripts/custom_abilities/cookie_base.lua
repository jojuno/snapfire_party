--base cookie
--on cast
--if unit has baker's dozen then
--cast it on target

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/modifiers/generic/modifier_generic_knockback_lua.lua

--------------------------------------------------------------------------------
cookie_base = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function cookie_base:GetCastPoint()
	if IsServer() and self:GetCursorTarget()==self:GetCaster() then
		return self:GetSpecialValueFor( "self_cast_delay" )
	end
	return 0.2
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function cookie_base:CastFilterResultTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    end
    
    --if unit has raisin firesnap then
        --cast to all
    --else
        --cast to friendly
    local nResult
    if self:GetCaster():HasAbility("raisin_firesnap") then

        nResult = UnitFilter(
            hTarget,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0,
            self:GetCaster():GetTeamNumber()
        )
    else
        nResult = UnitFilter(
            hTarget,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0,
            self:GetCaster():GetTeamNumber()
        )
    end
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function cookie_base:GetCustomCastErrorTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function cookie_base:OnAbilityPhaseInterrupted()

end
function cookie_base:OnAbilityPhaseStart()
	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function cookie_base:OnSpellStart()
    self.secondary_projectiles = {}
	-- unit identifier
    local caster = self:GetCaster()
    self.caster = caster
    local target = self:GetCursorTarget()
    self.target = target
    

	-- load data
    local projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf"
    self.projectile_name = projectile_name
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    self.projectile_speed = projectile_speed

	--[[if caster:GetTeam() ~= target:GetTeam() then
		projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_enemy_projectile.vpcf"
	end]]

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = false,                           -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)

	-- Play sound
	local sound_cast = "Hero_Snapfire.FeedCookie.Cast"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

--------------------------------------------------------------------------------
-- Projectile
function cookie_base:OnProjectileHit( target, location )
    --cast on friend
    --jump
    --on land, if caster has baker's dozen then
        --everyone around the friend who is a friend of the caster gets a cookie
        --they jump in place
    --cast on enemy
    --jump in place
    --on land, if caster has baker's dozen then
        --everyone around the enemy who is a friend of the caster gets a cookie
        --they jump in place

    -- load data
    local duration = self:GetSpecialValueFor( "jump_duration" )
    local height = self:GetSpecialValueFor( "jump_height" )
    local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
    local distance_secondary
    if self:GetCaster():HasAbility("bakers_dozen") then
        local distance_secondary = self:GetCaster():FindAbilityByName("bakers_dozen"):GetSpecialValueFor( "horizontal_jump_distance" )
    end
    local stun = self:GetSpecialValueFor( "impact_stun_duration" )
    local damage = self:GetSpecialValueFor( "impact_damage" )
    local radius = self:GetSpecialValueFor( "impact_radius" )
    if not target then return end
    --receiving cookie effect
    -- play effects2
    local effect_cast = self:PlayEffects2( target )
    --secondary units
    if target ~= self.target then
        --targets get knocked in the air
        --load data

        -- knockback
        -- describes the "jumping" motion
        local knockback_secondary = target:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
    
            "modifier_knockback_custom", -- modifier name
            {
                distance = distance_secondary,
                height = height,
                duration = duration,
                direction_x = target:GetForwardVector().x,
                direction_y = target:GetForwardVector().y,
                IsStun = true,
            } -- kv
        )
        -- on landing
        local callback = function()
            print("[cookie_base:OnProjectileHit] callback called")
            -- precache damage
            local damageTable = {
                -- victim = target,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }

            -- find enemies
            local enemies = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                target:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            for _,enemy in pairs(enemies) do
                print("[cookie_base:OnProjectileHit] enemy found")
                -- apply damage
                damageTable.victim = enemy
                ApplyDamage(damageTable)

                    -- stun
                    enemy:AddNewModifier(
                        self:GetCaster(), -- player source
                        self, -- ability source
                        "modifier_stunned", -- modifier name
                        { duration = stun } -- kv
                    )
            end

            -- destroy trees
            GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

            -- play effects
            ParticleManager:DestroyParticle( effect_cast, false )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            self:PlayEffects3( target, radius )

            --cast on allies
            --cast on enemies
            --cast on allies after jump

            --if raisin firesnap active then
            if self:GetCaster():HasAbility("raisin_firesnap") then
                print("[cookie_base:OnProjectileHit( target, location )] caster has raisin_firesnap")
                local mortimer_kisses_abil = self:GetCaster():FindAbilityByName("mortimer_kisses_base")
                --create particle
                --[[local mod = target:AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "mortimer_kisses_thinker_modifier", -- modifier name
                    {
                        duration = mortimer_kisses_abil:GetSpecialValueFor("burn_ground_duration"),
                        slow = 1,
                    } -- kv
                )]]

                --create projectile
                -- create target thinker
                local thinker = CreateModifierThinker(
                    self:GetCaster(), -- player source
                    self:GetCaster():FindAbilityByName("mortimer_kisses_base"), -- ability source
                    "mortimer_kisses_thinker_modifier", -- modifier name
                    { travel_time = 0 }, -- kv
                    target:GetAbsOrigin(),
                    self:GetCaster():GetTeamNumber(),
                    false
                )
        
                --explosion only happens for the mortimer kisses ability
                local info = {
                    Target = thinker,
                    Source = target,
                    Ability = self:GetCaster():FindAbilityByName("mortimer_kisses_base"),	
                    iMoveSpeed = 1000,
                    EffectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf",
                    bDodgeable = false,                           -- Optional
        
                    vSourceLoc = target:GetAbsOrigin(),                -- Optional (HOW)
        
                    bDrawsOnMinimap = false,                          -- Optional
                    bVisibleToEnemies = true,                         -- Optional
                    bProvidesVision = true,                           -- Optional
                    iVisionRadius = self:GetSpecialValueFor( "projectile_vision" ),                              -- Optional
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
                }
        
                -- launch projectile
                ProjectileManager:CreateTrackingProjectile( info )
                --cookie_base:PlayEffectsKisses(target:GetAbsOrigin(), self:GetCaster())
                --cookie_base:PlayEffectsCalldown( 1, target )
                --apply magma burn modifier
            end
        end
        knockback_secondary:SetEndCallback( callback )
    --primary targets
    else
        --on caster without upgrade
        --if target's team is not the same as the caster's
        if target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
            -- knockback
            -- describes the "jumping" motion
            local knockback = target:AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = distance_secondary,
                    height = height,
                    duration = duration,
                    direction_x = target:GetForwardVector().x,
                    direction_y = target:GetForwardVector().y,
                    IsStun = true,
                } -- kv
            )
            -- on landing
            local callback = function()
                print("[cookie_base:OnProjectileHit] callback called")
                -- precache damage
                local damageTable = {
                    -- victim = target,
                    attacker = self:GetCaster(),
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self, --Optional.
                }

                -- find enemies
                local enemies = FindUnitsInRadius(
                    self:GetCaster():GetTeamNumber(),	-- int, your team number
                    target:GetOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                    0,	-- int, flag filter
                    0,	-- int, order filter
                    false	-- bool, can grow cache
                )

                for _,enemy in pairs(enemies) do
                    print("[cookie_base:OnProjectileHit] enemy found")
                    -- apply damage
                    damageTable.victim = enemy
                    ApplyDamage(damageTable)

                        -- stun
                        enemy:AddNewModifier(
                            self:GetCaster(), -- player source
                            self, -- ability source
                            "modifier_stunned", -- modifier name
                            { duration = stun } -- kv
                        )
                end

                -- destroy trees
                GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

                -- play effects
                ParticleManager:DestroyParticle( effect_cast, false )
                ParticleManager:ReleaseParticleIndex( effect_cast )
                self:PlayEffects3( target, radius )

                if self.caster:HasAbility("bakers_dozen") then
                    local bakers_dozen_ability = self.caster:FindAbilityByName("bakers_dozen")
                    --find friends around location
                    local spread_radius = bakers_dozen_ability:GetSpecialValueFor("range")
                    local friends = FindUnitsInRadius(
                        self:GetCaster():GetTeamNumber(),	-- int, your team number
                        target:GetOrigin(),	-- point, center point
                        nil,	-- handle, cacheUnit. (not known)
                        spread_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                        0,	-- int, flag filter
                        0,	-- int, order filter
                        false	-- bool, can grow cache
                    )
                    --create tracking projectiles to them
                    
                    for i,friend in pairs(friends) do
                        print("[cookie_base:OnProjectileHit] friend found")
                        -- create projectile
                        if friend ~= target then
                            local info = {
                                Target = friend,
                                Source = target,
                                Ability = self,	
                                
                                EffectName = self.projectile_name,
                                iMoveSpeed = self.projectile_speed,
                                bDodgeable = false,                           -- Optional
                            }
                            self.secondary_projectiles[i] = ProjectileManager:CreateTrackingProjectile(info)
                        end
                    end
                end
            end
            knockback:SetEndCallback( callback )
        else
            -- knockback
            -- describes the "jumping" motion
            local knockback = target:AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = distance,
                    height = height,
                    duration = duration,
                    direction_x = target:GetForwardVector().x,
                    direction_y = target:GetForwardVector().y,
                    IsStun = true,
                } -- kv
            )
            -- on landing
            local callback = function()
                print("[cookie_base:OnProjectileHit] callback called")
                -- precache damage
                local damageTable = {
                    -- victim = target,
                    attacker = self:GetCaster(),
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self, --Optional.
                }

                -- find enemies
                local enemies = FindUnitsInRadius(
                    self:GetCaster():GetTeamNumber(),	-- int, your team number
                    target:GetOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                    0,	-- int, flag filter
                    0,	-- int, order filter
                    false	-- bool, can grow cache
                )

                for _,enemy in pairs(enemies) do
                    print("[cookie_base:OnProjectileHit] enemy found")
                    -- apply damage
                    damageTable.victim = enemy
                    ApplyDamage(damageTable)

                        -- stun
                        enemy:AddNewModifier(
                            self:GetCaster(), -- player source
                            self, -- ability source
                            "modifier_stunned", -- modifier name
                            { duration = stun } -- kv
                        )
                end

                -- destroy trees
                GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

                -- play effects
                ParticleManager:DestroyParticle( effect_cast, false )
                ParticleManager:ReleaseParticleIndex( effect_cast )
                self:PlayEffects3( target, radius )

                
                if self.caster:HasAbility("bakers_dozen") then

                    local bakers_dozen_ability = self.caster:FindAbilityByName("bakers_dozen")
                    --find friends around location
                    local spread_radius = bakers_dozen_ability:GetSpecialValueFor("range")
                    local friends = FindUnitsInRadius(
                        self:GetCaster():GetTeamNumber(),	-- int, your team number
                        target:GetOrigin(),	-- point, center point
                        nil,	-- handle, cacheUnit. (not known)
                        spread_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                        0,	-- int, flag filter
                        0,	-- int, order filter
                        false	-- bool, can grow cache
                    )
                    --create tracking projectiles to them
                    
                    for i,friend in pairs(friends) do
                        print("[cookie_base:OnProjectileHit] friend found")
                        -- create projectile
                        if friend ~= target or friend ~= self:GetCaster() then
                            local info = {
                                Target = friend,
                                Source = target,
                                Ability = self,	
                                
                                EffectName = self.projectile_name,
                                iMoveSpeed = self.projectile_speed,
                                bDodgeable = false,                           -- Optional
                            }
                            self.secondary_projectiles[i] = ProjectileManager:CreateTrackingProjectile(info)
                        end
                    end
                end
            end
            --returns when knockback is finished
            knockback:SetEndCallback( callback )
        end
    end
        

	if target:IsChanneling() or target:IsOutOfGame() then return end

	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:GetTeam() ~= self:GetCaster():GetTeam() then
		if target:TriggerSpellAbsorb(self) then
			return nil
		end
	end

	-- Firesnap Cookie heals
	if self:GetCaster():HasTalent("special_bonus_unique_snapfire_5") then
		if target:GetTeam() == self:GetCaster():GetTeam() then
			target:Heal(self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_5"), self:GetCaster())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_5"), nil)
		end
	end





	
end

--------------------------------------------------------------------------------
function cookie_base:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_base:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
	local sound_target = "Hero_Snapfire.FeedCookie.Consume"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target )

	-- Create Sound
	EmitSoundOn( sound_target, target )

	return effect_cast
end

function cookie_base:PlayEffects3( target, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
	local sound_location = "Hero_Snapfire.FeedCookie.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_location, target )
end

--------------------------------------------------------------------------------
function cookie_base:PlayEffectsKisses( loc, owner )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, owner )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, owner )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, owner )
end


--------------------------------------------------------------------------------
function cookie_base:PlayEffectsCalldown( time, owner )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, owner, owner:GetTeamNumber() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, owner:GetOrigin() )
    --ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 500, 0, -500*(2/time) ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end


--create projectile
--hit the spot the target lands at


