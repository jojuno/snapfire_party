my_slug = class({})



function my_slug:OnSpellStart()
    local caster = self:GetCaster()
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    dummy = CreateUnitByName("dummy", cursorPt, true, caster, caster, caster:GetTeamNumber())
    --even if the dummy is killed right after it's created, OnProjectileHit will still trigger when it reaches where it was
    dummy:ForceKill(false)
    local info = 
    {
        Target = dummy,
        Source = caster,
        Ability = self,	
        EffectName = "particles/sniper_assassinate_buckshot.vpcf",
        iMoveSpeed = 1000,
        vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
        bDrawsOnMinimap = false,                          -- Optional
            bDodgeable = false,                                -- Optional
            bIsAttack = false,                                -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bReplaceExisting = false,                         -- Optional
            flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
        bProvidesVision = false,                           -- Optional
        iVisionRadius = 400,                              -- Optional
        iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
    }
    projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function my_slug:OnProjectileHit(hTarget, vLocation)
    --hTarget:ForceKill(false)
    local cookie_bomb_range = 300
    local units = FindUnitsInRadius(DOTA_TEAM_CUSTOM_1 +DOTA_TEAM_CUSTOM_2+DOTA_TEAM_CUSTOM_3+DOTA_TEAM_CUSTOM_4
    +DOTA_TEAM_CUSTOM_5+DOTA_TEAM_CUSTOM_6+DOTA_TEAM_CUSTOM_7+DOTA_TEAM_CUSTOM_8 , hTarget:GetAbsOrigin(), nil, 
    cookie_bomb_range, DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false)
    --if there's no units found, it still exists, but it's empty
    PrintTable(units)
    for key, unit in pairs(units) do
        print("[chain_cookie:OnProjectileHit] unit's key: ")
        print(key)
        print("[chain_cookie:OnProjectileHit] unit's name: ")
        print(unit:GetUnitName())
    end
    --[[if #units>0 then
        for key, unit in pairs(units) do
            print("[bomb_cookie:OnProjectileHit] looping through units")
            local ability = unit:FindAbilityByName("snapfire_firesnap_cookie_arrow")
            print("[bomb_cookie:OnProjectileHit] ability's name: " .. ability:GetAbilityName())
            unit:SetCursorCastTarget(unit)
            ability:OnSpellStart()
        end
    end]]
    return true
end