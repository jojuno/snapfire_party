scatterblast_base = class({})
--name, filepath, modifier type
LinkLuaModifier("scatterblast_base_modifier", "custom_abilities/scatterblast_base_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_base_modifier_spark_effect", "custom_abilities/scatterblast_base_modifier_spark_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_base_modifier_impact_effect", "custom_abilities/scatterblast_base_modifier_impact_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_blast_base_modifier_blood_effect", "custom_abilities/scatterblast_blast_base_modifier_blood_effect", LUA_MODIFIER_MOTION_NONE)




--1 projectile with narrow start radius and wide end radius

function scatterblast_base:OnAbilityPhaseStart()
    EmitSoundOn("Hero_Snapfire.Shotgun.Load", self:GetCaster())
    --return true for successful cast
    return true
end

function scatterblast_base:OnSpellStart()
    local caster = self:GetCaster()
    self.caster = caster
    self.damage = self:GetSpecialValueFor( "damage" ) 
    self.point_blank_range = self:GetSpecialValueFor( "point_blank_range" ) 
    self.point_blank_dmg_bonus_pct = self:GetSpecialValueFor( "point_blank_dmg_bonus_pct" ) 
    self.blast_width_initial = self:GetSpecialValueFor( "blast_width_initial" ) 
    self.blast_width_end = self:GetSpecialValueFor( "blast_width_end" ) 
    self.cast_loc = caster:GetAbsOrigin()
    --self.distance = self:GetSpecialValueFor( "distance" ) 
    
    print("[scatterblast_base:OnSpellStart] called")
    
    --A Liner Projectile must have a table with projectile info
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()
    local info = 
    { 
        Ability = self,
        EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 800,
        fStartRadius = 80,
        fEndRadius = 225,
        Source = caster,
        --bHasFrontalCone = true,

        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 3,
        bDeleteOnHit = false,
        vVelocity = direction * self:GetSpecialValueFor( "blast_speed" ) ,
        bProvidesVision = false,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    projectile1 = ProjectileManager:CreateLinearProjectile(info)

    if projectile then
        EmitSoundOn("Hero_Snapfire.Shotgun.Fire", self:GetCaster())
    end

    

    if self.caster:HasAbility("scatterblast_sawed_off") then


    --to the left 

        local cursorPtX = cursorPt.x - casterPt.x
        local cursorPtY = cursorPt.y - casterPt.y
        local cursorRad = math.atan(cursorPtY / cursorPtX)
        local cursorDeg = math.deg(cursorRad)

        --y/x
        --2pi radians = circle
        --(+)x-axis -> 0 radians
        --Q1 -> 0.72 radians -- x and y are both positive
        --(+)y-axis -> -1.52 radians
        --Q2 -> -0.82 radians -- x is negative, y is positive
        --(-)x-axis -> 0 radians
        --Q3 -> 0.74 -- x and y are both negative
        --(-)y-axis -> -1.52 radians
        --Q4 -> -0.99 -- x is positive, y is negative

        local radius = 1000
        local anglerad = math.rad(40)

        if (cursorPtX > 0 and cursorPtY > 0) then 
            leftCastPt = Vector(casterPt.x +  radius*math.cos(anglerad + cursorRad), casterPt.y + radius*math.sin(anglerad + cursorRad), casterPt.z)
        elseif (cursorPtX < 0 and cursorPtY > 0) then
            --pi + -80 = 100
            leftCastPt = Vector(casterPt.x + radius*math.cos(anglerad + cursorRad + math.pi), casterPt.y + radius*math.sin(anglerad + cursorRad + math.pi), casterPt.z)
        elseif (cursorPtX < 0 and cursorPtY < 0) then
            leftCastPt = Vector(casterPt.x +  radius*math.cos(anglerad + cursorRad + math.pi), casterPt.y + radius*math.sin(anglerad + cursorRad + math.pi), casterPt.z)
        else
            leftCastPt = Vector(casterPt.x +  radius*math.cos(anglerad + cursorRad + 2*math.pi), casterPt.y + radius*math.sin(anglerad + cursorRad + 2*math.pi), casterPt.z)
        end
        --leftCastPt = Vector(casterPt.x +  radius*math.cos(anglerad + cursorRad), casterPt.y + radius*math.sin(anglerad + cursorRad), casterPt.z)
        direction = leftCastPt - casterPt
        direction = direction:Normalized()

        local info_left = 
        { 
            Ability = self,
            EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", --particle effect
            --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = 800,
            fStartRadius = 80,
            fEndRadius = 225,
            Source = caster,
            --bHasFrontalCone = true,

            --bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 3,
            bDeleteOnHit = false,


            vVelocity = direction * self:GetSpecialValueFor( "blast_speed" ) ,
            bProvidesVision = false,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        projectile2 = ProjectileManager:CreateLinearProjectile(info_left)

        --to the right
        local radius = 1000
        local anglerad = math.rad(40)
    
        if (cursorPtX > 0 and cursorPtY > 0) then 
            leftCastPt = Vector(casterPt.x +  radius*math.cos(-anglerad + cursorRad), casterPt.y + radius*math.sin(-anglerad + cursorRad), casterPt.z)
        elseif (cursorPtX < 0 and cursorPtY > 0) then
            --pi + -80 = 100
            leftCastPt = Vector(casterPt.x + radius*math.cos(-anglerad + cursorRad + math.pi), casterPt.y + radius*math.sin(-anglerad + cursorRad + math.pi), casterPt.z)
        elseif (cursorPtX < 0 and cursorPtY < 0) then
            leftCastPt = Vector(casterPt.x +  radius*math.cos(-anglerad + cursorRad + math.pi), casterPt.y + radius*math.sin(-anglerad + cursorRad + math.pi), casterPt.z)
        else
            leftCastPt = Vector(casterPt.x +  radius*math.cos(-anglerad + cursorRad + 2*math.pi), casterPt.y + radius*math.sin(-anglerad + cursorRad + 2*math.pi), casterPt.z)
        end
        --leftCastPt = Vector(casterPt.x +  radius*math.cos(anglerad + cursorRad), casterPt.y + radius*math.sin(anglerad + cursorRad), casterPt.z)
        direction = leftCastPt - casterPt
        direction = direction:Normalized()
    
        local info_right = 
        { 
            Ability = self,
            EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", --particle effect
            --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = 800,
            fStartRadius = 80,
            fEndRadius = 225,
            Source = caster,
            --bHasFrontalCone = true,
    
            --bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 3,
            bDeleteOnHit = false,
    
    
            vVelocity = direction * self:GetSpecialValueFor( "blast_speed" ) ,
            bProvidesVision = false,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        projectile3 = ProjectileManager:CreateLinearProjectile(info_right)


        if projectile then
            EmitSoundOn("shotgun_fire", self:GetCaster())
        end
    end
end

--is not destroyed on hit
--if distance is less than a certain amount
--there is only one projectile
--by time instead of distance
--take time from projectile creation to projectile hit
--projectile travels point blank range first
--see how long it takes to expire

    --apply bonus damage

function scatterblast_base:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        --self.projectileExpiredTime = GameRules:GetGameTime()
        print("[scatterblast_base:OnProjectileHit] scatterblast expired")
        --print("[birdshot:OnProjectileHit] time it took: " .. self.projectileExpiredTime - self.projectileCreatedTime)
    else
        if hTarget == self:GetCaster() then
            --skip
        else
            --knockback
            if self.caster:HasAbility("scatterblast_stopping_power") then
                --print("[scatterblast_base:OnProjectileHit] called")
                knockback_ability = self.caster:FindAbilityByName("scatterblast_stopping_power")
                if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                    --print("[scatterblast_base:OnProjectileHit] applying knockback")
                    knockback_properties = {
                        center_x 			= self.cast_loc.x,
                        center_y 			= self.cast_loc.y,
                        center_z 			= self.cast_loc.z,
                        duration 			= knockback_ability:GetSpecialValueFor("duration") * (1 - hTarget:GetStatusResistance()),
                        knockback_duration = knockback_ability:GetSpecialValueFor("knockback_duration") * (1 - hTarget:GetStatusResistance()),
                        knockback_distance = knockback_ability:GetSpecialValueFor("knockback_distance"),
                        knockback_height 	= knockback_ability:GetSpecialValueFor("knockback_height"),
                   }
                   
                   knockback_modifier = hTarget:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback_properties)
                end
            end
                
            --apply damage

            --point blank range is the full range if caster has the upgrade
            if self.caster:HasAbility("scatterblast_fullrange_pointblank") then

                self.point_blank_range = 3000
            end
                --if in point blank range,

            if (self.cast_loc - vLocation):Length() < self.point_blank_range then
                --apply multiplier
                if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                    local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.damage + (self.damage * 0.01 * self.point_blank_dmg_bonus_pct),
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = self
                    }
            
                    ApplyDamage( damage )
                    --sparks
                    hTarget:AddNewModifier(self:GetCaster(), self, "scatterblast_base_modifier_spark_effect", { duration = 1.0 })
                end
            else
                --apply normal damage
                if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                    local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = self
                    }
            
                    ApplyDamage( damage )
                    
                    --apply slow and attack slow
                end
            end
            
            --impact

            hTarget:AddNewModifier(self:GetCaster(), self, "scatterblast_base_modifier_impact_effect", { duration = 1.0 })
            hTarget:AddNewModifier(self:GetCaster(), self, "scatterblast_base_modifier", { duration = 1.0 })
        end
    end
    return false
end

