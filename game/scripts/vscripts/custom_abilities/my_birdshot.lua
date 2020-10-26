my_birdshot = class({})
--LinkLuaModifier("birdshot_modifier", LUA_MODIFIER_MOTION_NONE)

--1 projectile with narrow start radius and wide end radius

function my_birdshot:OnSpellStart()
    --EmitSoundOn(soundName: string, entity: CBaseEntity): nil
    self.damage = self:GetSpecialValueFor( "damage" ) 
    self.point_blank_range = self:GetSpecialValueFor( "point_blank_range" ) 
    self.point_blank_dmg_bonus_pct = self:GetSpecialValueFor( "point_blank_dmg_bonus_pct" ) 
    self.blast_width_initial = self:GetSpecialValueFor( "blast_width_initial" ) 
    self.blast_width_end = self:GetSpecialValueFor( "blast_width_end" ) 
    --self.distance = self:GetSpecialValueFor( "distance" ) 
    
    print("[birdshot:OnSpellStart] called")
    local caster = self:GetCaster()
    --A Liner Projectile must have a table with projectile info
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()
    local info = 
    { 
        Ability = self,
        EffectName = "particles/hero_snapfire_shotgun_test.vpcf", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = self.point_blank_range,
        fStartRadius = self.blast_width_initial,
        fEndRadius = self.blast_width_end,
        Source = caster,
        bHasFrontalCone = true,

        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = false,
        vVelocity = direction * 1500,
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

function my_birdshot:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        --self.projectileExpiredTime = GameRules:GetGameTime()
        print("[birdshot:OnProjectileHit] scatterblast expired")
        --print("[birdshot:OnProjectileHit] time it took: " .. self.projectileExpiredTime - self.projectileCreatedTime)
    else
        if hTarget == self:GetCaster() then
            --skip
        else
            --apply damage

            if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                local damage = {
                    victim = hTarget,
                    attacker = self:GetCaster(),
                    damage = self.damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                }
        
                ApplyDamage( damage )
            end
        end
    end

    return false
end

--cursor
