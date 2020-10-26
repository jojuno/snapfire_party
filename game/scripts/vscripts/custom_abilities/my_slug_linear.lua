my_slug_linear = class({})
--LinkLuaModifier("birdshot_modifier", LUA_MODIFIER_MOTION_NONE)

--1 projectile with narrow start radius and wide end radius

function my_slug_linear:OnSpellStart()
    --EmitSoundOn(soundName: string, entity: CBaseEntity): nil
    self.damage = self:GetSpecialValueFor( "damage" ) 
    self.point_blank_range = self:GetSpecialValueFor( "point_blank_range" ) 
    self.point_blank_dmg_bonus_pct = self:GetSpecialValueFor( "point_blank_dmg_bonus_pct" ) 
    self.blast_width_initial = self:GetSpecialValueFor( "blast_width_initial" ) 
    self.blast_width_end = self:GetSpecialValueFor( "blast_width_end" ) 
    --self.distance = self:GetSpecialValueFor( "distance" ) 
    

    print("[my_slug_linear:OnSpellStart] called")
    local caster = self:GetCaster()
    --A Liner Projectile must have a table with projectile info
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()
    --emit sound on caster
    --end sound when stopped
    caster:EmitSound("shotgun_sound_effect_slug")
    local info = 
    { 
        Ability = self,
        EffectName = "particles/sniper_assassinate_buckshot.vpcf", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 1500,
        fStartRadius = 100,
        fEndRadius = 100,
        Source = caster,
        bHasFrontalCone = true,

        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = direction * 3000,
        bProvidesVision = false,
        iVisionRadius = 500,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)
    --self.projectileCreatedTime = GameRules:GetGameTime()
end

--is not destroyed on hit
--if distance is less than a certain amount
--there is only one projectile
--by time instead of distance
--take time from projectile creation to projectile hit
--projectile travels point blank range first
--see how long it takes to expire

    --apply bonus damage

function my_slug_linear:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        --self.projectileExpiredTime = GameRules:GetGameTime()
        print("[my_slug_linear:OnProjectileHit] scatterblast expired")
        --print("[birdshot:OnProjectileHit] time it took: " .. self.projectileExpiredTime - self.projectileCreatedTime)
    else
        if hTarget == self:GetCaster() then
            --skip
        else
            --create blood and sparks
            dummy = CreateUnitByName("dummy_blood_and_sparks", vLocation, true, hTarget, hTarget, hTarget:GetTeamNumber())
            --even if the dummy is killed right after it's created, OnProjectileHit will still trigger when it reaches where it was
            local abil = dummy:FindAbilityByName("blood_and_sparks")
            abil:SetLevel(1)
            abil:OnSpellStart()
            

            --dummy:ForceKill(false)

            --apply damage

            if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                local damage = {
                    victim = hTarget,
                    attacker = self:GetCaster(),
                    damage = 500,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                }
        
                ApplyDamage( damage )
            end
        end
    end

    return true
end

--cursor



--create spell with blood and sparks
--on hit, create dummy
--dummy casts a spell