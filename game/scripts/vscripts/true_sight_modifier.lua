true_sight_modifier = class({})

--------------------------------------------------------------------------------

function true_sight_modifier:OnOwnerDied()
    print("[true_sight_modifier:OnOwnerDied] called")
    local owner = self:GetParent()
    local teammateAlive = false    
    if GameMode.teams[owner:GetTeamNumber()] ~= nil then
        for playerID  = 0, GameMode.maxNumPlayers do
            if GameMode.teams[owner:GetTeamNumber()][playerID] ~= nil then
                if GameMode.teams[owner:GetTeamNumber()][playerID].hero:IsAlive() then
                    teammateAlive = true
                else
                    --teammateAlive = false
                end
            end
        end
    end
    if not teammateAlive then

    end
end

--------------------------------------------------------------------------------

function modifier_vengefulspirit_magic_missile_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
