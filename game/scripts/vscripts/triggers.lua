function SumoOutOfBounds(trigger)
    local ent = trigger.activator
    if not ent then return end
    --triggered flag
    --loop through all players
    --if there's only one player left whose flag hasn't been triggered yet then
    --end game

    --stun
    ent:AddNewModifier(nil, nil, "modifier_stunned", {})
    --table of players
    --GameMode.teams[teamNum][playerID].sumoOutOfBounds
    GameMode.teams[ent:GetTeamNumber()][ent:GetPlayerID()].sumoOutOfBounds = true
    local numAlive = 0
    local winner = nil
    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID  = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                    if not GameMode.teams[teamNumber][playerID].sumoOutOfBounds then
                        numAlive = numAlive + 1
                        winner = GameMode.teams[teamNumber][playerID].hero
                    end
                end
            end
        end
    end
    if numAlive == 1 then
        GameMode:EndGame(winner)
        --reset
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
                for playerID  = 0, GameMode.maxNumPlayers - 1 do
                    if GameMode.teams[teamNumber][playerID] ~= nil then
                        GameMode.teams[teamNumber][playerID].sumoOutOfBounds = false
                    end
                end
            end
        end
    end
end
