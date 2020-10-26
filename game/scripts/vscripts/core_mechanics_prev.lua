-- This function runs to save the location and particle spawn upon hero killed
function GameMode:HeroKilled(hero, attacker, ability)
    --hero = GameMode.playerEnts[hero:GetPlayerID()]["hero"]
    hero.isAlive = false
    if GameMode.pregameActive then
        if GameMode.pregameBuffer == false then
            Timers:CreateTimer({
                endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                callback = function()
                    --start the next round
                    GameMode:Restore(hero)
                    hero.isAlive = true
                end
            })
        end            
    elseif GameMode.tiebreakerActive then
        GameMode.numAlive = GameMode.numAlive - 1
        if GameMode.numAlive == 1 then
            for playerID = 0, 9 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if GameMode.playerEnts[playerID]["hero"].isAlive == true then
                        GameMode.roundActive = false
                        GameMode.playerEnts[playerID]["hero"].score = GameMode.playerEnts[playerID]["hero"].score + 1
                        GameRules:SetCustomVictoryMessage(string.format("%s wins!", PlayerResource:GetPlayerName(playerID)))
                        --end game
                        GameRules:SetGameWinner(GameMode.playerEnts[playerID]["hero"]:GetTeamNumber())
                        GameRules:SetSafeToLeave(true)
                        break
                    end
                end
            end
        end
    elseif GameMode.roundActive then
        --local item = CreateItem("item_gem", hero, hero)
        --hero:AddItem(item)
        print("[GameMode:HeroKilled] number of players alive: " .. GameMode.numAlive)
        GameMode.numAlive = GameMode.numAlive - 1
        
        print("[GameMode:HeroKilled] number of players alive after subtracting 1: " .. GameMode.numAlive)
        if GameMode.numAlive == 1 then
            local damageList = {}
            local damageRanking = {}
            --assign scores
            --one for most damage dealt
            --make a list of damage dealt for everyone for the round
            for playerID = 0, 9 do
                --check if playerID exists
                if PlayerResource:IsValidPlayerID(playerID) then
                    --calculate the damage dealt for every hero against each other
                    local damageDoneTotal = 0
                    local damageDonePrev = GameMode.playerEnts[playerID]["hero"].damageDealt
                    for victimID = 0, 9 do
                        if PlayerResource:IsValidPlayerID(victimID) then
                            if victimID == playerID then goto continue
                            else
                                damageDoneTotal = damageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                            end
                            ::continue::
                        end
                    end
                    GameMode.playerEnts[playerID]["hero"].damageDealt = damageDoneTotal
                    local damageDoneThisRound = damageDoneTotal - damageDonePrev
                    damageList[playerID] = damageDoneThisRound
                end
            end
            
            function spairs(t, order)
                -- collect the keys
                local keys = {}
                for k in pairs(t) do keys[#keys+1] = k end
        
                -- if order function given, sort by it by passing the table and keys a and b
                -- otherwise just sort the keys 
                if order then
                    table.sort(keys, function(a,b) return order(t, a, b) end)
                else
                    table.sort(keys)
                end
        
                -- return the iterator function
                local i = 0
                return function()
                    i = i + 1
                    if keys[i] then
                        return keys[i], t[keys[i]]
                    end
                end
            end
            
            
            --save the top damage
            --if there's other entries with the same value, give them scores too
            -- this uses a custom sorting function ordering by damageDone, descending
            local rank = 1
            for k,v in spairs(damageList, function(t,a,b) return t[b] < t[a] end) do
                damageRanking[rank] = k 
                rank = rank + 1
            end
            local topDamage = damageList[damageRanking[1]]
            Notifications:BottomToAll({text="Most damage dealt: ", duration= 5.0, style={["font-size"] = "35px", color = "white"}})
            local firstLine = true
            for playerID in pairs(damageList) do
                if damageList[playerID] == topDamage then
                    GameMode.playerEnts[playerID]["hero"].score = GameMode.playerEnts[playerID]["hero"].score + 1
                    Notifications:BottomToAll({text=string.format("%s, ", PlayerResource:GetPlayerName(playerID)), duration= 5.0, style={["font-size"] = "35px", color = "red"}, continue = not firstLine})
                    Notifications:BottomToAll({text=string.format("total: %s ", GameMode.playerEnts[playerID]["hero"].score), duration= 5.0, style={["font-size"] = "35px", color = "white"}, continue = true})
                
                    firstLine = false
                end
            end




            --one for most kills
            local killList = {}
            local killRanking = {}
            for playerID = 0, 9 do
                --check if playerID exists
                if PlayerResource:IsValidPlayerID(playerID) then
                    --calculate the damage dealt for every hero against each other
                    local killsThisRound = 0
                    local killsPrev = GameMode.playerEnts[playerID]["hero"].kills
                    killsThisRound = PlayerResource:GetKills(playerID) - killsPrev
                    GameMode.playerEnts[playerID]["hero"].kills = PlayerResource:GetKills(playerID)
                    killList[playerID] = killsThisRound
                end
            end

            -- this uses a custom sorting function ordering by kills, descending
            local rank = 1
            for k,v in spairs(killList, function(t,a,b) return t[b] < t[a] end) do
                killRanking[rank] = k 
                rank = rank + 1
            end
            local topKill = killList[killRanking[1]]
            Notifications:BottomToAll({text="Most kills: ", duration= 5.0, style={["font-size"] = "35px", color = "white"}})
            firstLine = true
            for playerID in pairs(killList) do
                if killList[playerID] == topKill then
                    GameMode.playerEnts[playerID]["hero"].score = GameMode.playerEnts[playerID]["hero"].score + 1
                    
                    Notifications:BottomToAll({text=string.format("%s, ", PlayerResource:GetPlayerName(playerID)), duration= 5.0, style={["font-size"] = "35px", color = "red"}, continue = not firstLine})
                    Notifications:BottomToAll({text=string.format("total: %s ", GameMode.playerEnts[playerID]["hero"].score, GameMode.playerEnts[playerID]["hero"].score), duration= 5.0, style={["font-size"] = "35px", color = "white"}, continue = true})
                    firstLine = false
                end
            end



            --one for being the last man standing
            --find who's still alive
            for playerID = 0, 9 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if GameMode.playerEnts[playerID]["hero"].isAlive == true then
                        GameMode.roundActive = false
                        GameMode.playerEnts[playerID]["hero"].score = GameMode.playerEnts[playerID]["hero"].score + 1
                        Notifications:BottomToAll({text="Last Man Standing: ", duration= 5.0, style={["font-size"] = "35px", color = "white"}})
                        Notifications:BottomToAll({text=string.format("%s, ", PlayerResource:GetPlayerName(playerID)), duration= 5.0, style={["font-size"] = "35px", color = "red"}})
                        Notifications:BottomToAll({text=string.format("total: %s", GameMode.playerEnts[playerID]["hero"].score), duration= 5.0, style={["font-size"] = "35px", color = "white"}, continue = true})
                        break
                    end
                end
            end
            local winners = {}
            local numWinners = 0
            for playerID = 0, 9 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if GameMode.playerEnts[playerID]["hero"].score >= 7 then
                        winners[playerID] = {}
                        numWinners = numWinners + 1
                        winners[playerID]["hero"] = GameMode.playerEnts[playerID]["hero"]
                    end
                end
            end

            --tiebreaker
            if numWinners > 1 then
                Notifications:BottomToAll({text="There's a tie!", duration= 5.0, style={["font-size"] = "45px", color = "red"}})
                for playerID = 0, 9 do
                    if PlayerResource:IsValidPlayerID(playerID) then
                      heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                      heroEntity:ForceKill(true)
                    end
                end

                GameMode.numPlayers = numWinners
                --delay 5 seconds
                GameMode.tiebreakerActive = true
                Timers:CreateTimer({
                    endTime = 5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                    callback = function()
                        --start the next round
                        GameMode:RoundStart(winners)
                    end
                })
            --one winner
            elseif numWinners == 1 then
                print("there is one winner!")
                
                PrintTable(winners)
                --ipairs doesn't work
                --perhaps it can't start from 0, which is the first playerID
                for playerID in pairs(winners) do 
                    print("in the for loop for the winners block")
                    GameRules:SetCustomVictoryMessage(string.format("%s wins!", PlayerResource:GetPlayerName(playerID)))
                    --end game
                    GameRules:SetGameWinner(GameMode.playerEnts[playerID]["hero"]:GetTeamNumber())
                    GameRules:SetSafeToLeave(true)
                end
            --no winners
            else
                --delay 5 seconds
                Timers:CreateTimer({
                    endTime = 5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                    callback = function()
                        --start the next round
                        GameMode:RoundStart(GameMode.playerEnts)
                    end
                })
            end
        end
    end
    -- A timer running every second that starts 5 seconds in the future, respects pauses
    Timers:CreateTimer(0, function()
        if hero.isAlive == false then
            AddFOWViewer(hero:GetTeamNumber(), hero:GetAbsOrigin(), 10000, 1, false )
            local centerVectorEnt = Entities:FindByName(nil, "island_center")

            -- GetAbsOrigin() is a function that can be called on any entity to get its location
            local centerVector = centerVectorEnt:GetAbsOrigin()
            hero:SetAbsOrigin(centerVector)
            return 1.0
        else
            return nil
        end
    end)
    --get a list of players who are dead
    --apply "makeVisibletoTeam" to the players who are alive
end