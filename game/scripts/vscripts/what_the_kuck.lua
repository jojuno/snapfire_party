function GameMode:WhatTheKuck()
    GameRules:GetGameModeEntity():SetThink(function ()
        local delta = GameMode:Round(GameMode.endTime - GameRules:GetGameTime())

        --starting message
        if delta == 39 then
        EmitGlobalSound('gbuTheme')

        Notifications:BottomToAll({text="Warm Up Phase" , duration= 30, style={["font-size"] = "45px", color = "red"}})

        GameMode:SetUpRunes()
        
        return 1

        elseif delta > 9 then
        --sets the amount of seconds until SetThink is called again
        return 1

        elseif delta == 9 then
        GameMode.pregameBuffer = true
        GameMode:RemoveRunes()
        Notifications:ClearTopFromAll()
        Notifications:ClearBottomFromAll()
        Notifications:BottomToAll({text="GET READY!" , duration= 5.0, style={["font-size"] = "45px", color = "red"}})
        for playerID = 0, GameMode.maxNumPlayers do
            if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            heroEntity:SetBaseMagicalResistanceValue(0)
            heroEntity:SetPhysicalArmorBaseValue(0)
            heroEntity:SetBaseHealthRegen(0)
            heroEntity:ForceKill(true)
            end
        end
        --record damage done to compare it to the total damage done after the first round
        
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            GameMode.numTeams = GameMode.numTeams + 1
            local teamDamageDoneTotal = 0
            for playerID = 0, GameMode.maxNumPlayers do
                if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                --print("[GameMode:OnAllPlayersLoaded] playerID: " .. playerID)
                local playerDamageDoneTotal = 0
                for victimTeamNumber = 6, 13 do
                    if GameMode.teams[victimTeamNumber] ~= nil then
                    --print("[GameMode:OnAllPlayersLoaded] victimTeamNumber: " .. victimTeamNumber)
                    if victimTeamNumber == teamNumber then goto continue
                    else
                        for victimID = 0, 7 do
                        if GameMode.teams[victimTeamNumber][victimID] ~= nil then
                            --print("[GameMode:OnAllPlayersLoaded] victimID: " .. victimID)
                            playerDamageDoneTotal = playerDamageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                        end
                        end
                    end
                    ::continue::
                    end
                end
                GameMode.teams[teamNumber]["players"][playerID].totalDamageDealt = playerDamageDoneTotal
                teamDamageDoneTotal = teamDamageDoneTotal + playerDamageDoneTotal
                end
            end
            GameMode.teams[teamNumber].totalDamageDealt = teamDamageDoneTotal
            end
        end

        --same for kills
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
                local teamKillsTotal = 0
                for playerID  = 0, GameMode.maxNumPlayers do
                    if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                        GameMode.teams[teamNumber]["players"][playerID].totalKills = PlayerResource:GetKills(playerID)
                        teamKillsTotal = teamKillsTotal + PlayerResource:GetKills(playerID)
                    end
                end
                --assign teamKillsTotal to GameMode.teams[teamNumber].totalKills
                GameMode.teams[teamNumber].totalKills = teamKillsTotal
            end
        end
        return 5


        --play the starting sound
        --calculate the damage dealt for every hero against each other
        --rank them in descending order 
        --highest rank gets placed first; lowest rank gets placed last at the starting line
        elseif delta == 4 then
            GameMode.pregameActive = false
            GameMode.pregameBuffer = false
            --set up death match mode
            GameMode:WhatTheKuckStart()
        return 4
        
        else
        end
    end)
end

function GameMode:WhatTheKuckStart()
    print("[GameMode:WhatTheKuckStart] called")
    --intro sound
    EmitGlobalSound('snapfireOlympics.introAndBackground3')
    GameRules:SetHeroRespawnEnabled( true )
    --do the announcement
    Timers:CreateTimer({
        callback = function()
        Notifications:BottomToAll({text="3..." , duration= 1.0, style={["font-size"] = "45px"}})
        end
    })
    Timers:CreateTimer({
        endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
        Notifications:BottomToAll({text="2..." , duration= 1.0, style={["font-size"] = "45px"}})
        end
    })
    Timers:CreateTimer({
        endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
        Notifications:BottomToAll({text="1..." , duration= 1.0, style={["font-size"] = "45px"}})
        end
    })
    Timers:CreateTimer({
        endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
        Notifications:BottomToAll({text="GO!" , duration= 5.0, style={["font-size"] = "45px"}})
        end
    })
    --set up runes
    --repeat every minute
    Timers:CreateTimer(0, function()
        GameMode:SetUpRunes()
        return 60.0
        end
    )
    Timers:CreateTimer(59.5, function()
        GameMode:RemoveRunes()
        return 60.0
    end
    )
    

    
    --reset cooldowns
    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers do
                if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                    if PlayerResource:IsValidPlayerID(playerID) then
                        heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                        print("[GameMode:RoundStart] playerID: " .. playerID)
                        for itemIndex = 0, 5 do
                            if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                                heroEntity:GetItemInSlot(itemIndex):EndCooldown()
                            end
                        end
                        for abilityIndex = 0, 5 do
                            abil = heroEntity:GetAbilityByIndex(abilityIndex)
                            abil:EndCooldown()
                        end
            
                        --[[Timers:CreateTimer(function()
                        for i = 0, 10 do
                            print("[GameMode:RoundStart] hero of playerID " .. playerID .. "has a modifier: " .. heroEntity:GetModifierNameByIndex(i))
                        end
                        return 1.0
                        end)]]
                        heroEntity:Stop()
                        heroEntity:ForceKill(false)
                        GameMode:Restore(heroEntity)
                        --heroEntity:AddNewModifier(nil, nil, "modifier_specially_deniable", {})
                        --set camera to hero because when the hero is relocated, the camera stays still
                        --use global variable 'PlayerResource' to call the function
                        PlayerResource:SetCameraTarget(playerID, heroEntity)
                        --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
                        --set entity to 'nil' to undo setting the camera
                        heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
                    end
                end
            end
        end
    end
    Timers:CreateTimer({
        endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()            
        for playerID = 0, GameMode.maxNumPlayers do
            if PlayerResource:IsValidPlayerID(playerID) then
            PlayerResource:SetCameraTarget(playerID, nil)
            end
        end
    end})
end

function GameMode:HeroKilledWhatTheKuck(hero, attacker, ability)
    if GameMode.pregameActive then
        if GameMode.pregameBuffer == false then
            Timers:CreateTimer({
                endTime = 1, -- respawn in 1 second
                callback = function()
                    GameMode:Restore(hero)
                end
            })
        end
    else
        --cookie off
        if GameMode.cookieOffActive then
            --if everyone is dead
            --in conditionals, comparing to nil is buggy
            if GameMode:CheckTeamsRemaining() > 0 then
                local winningTeamNum = GameMode:CheckTeamsRemaining()
                --declare winning team
                EmitGlobalSound("duel_end")
                --fire taunt
                Notifications:BottomToAll({text=string.format("%s wins!", GameMode.teamNames[winningTeamNum]), duration=10.0, style={["font-size"] = "45px", color = "white"}})
                Notifications:BottomToAll({text="Waiting for gods to descend...", duration= 10.0, style={["font-size"] = "45px", color = "white"}})
                
                --how long between mini games at minimum
                Timers:CreateTimer({
                    endTime = 120,
                    callback = function()
                        GameMode.specialGameCooldown = false
                    end
                })

                
                for teamNumber = 6, 13 do
                    if GameMode.teams[teamNumber] ~= nil then
                        if teamNumber == winningTeamNum then
                            for playerID = 0, GameMode.maxNumPlayers do
                                if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                                    --send js event
                                    --chooses which cookie to be
                                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "special_game_end", {})
                                    --if none picked, pick random
                                    --when everyone's picked or when 10 seconds are up,
                                    --winning team spawns in arena
                                    --invulnerable
                                end
                            end
                        else
                            --losing teams return back
                            --can move around
                            --invulnerable
                            for playerID = 0, GameMode.maxNumPlayers do
                                if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                                    GameMode.teams[teamNumber]["players"][playerID].hero:ForceKill(false)
                                    GameMode:Restore(GameMode.teams[teamNumber]["players"][playerID].hero)
                                    GameMode:RemoveAllAbilities(GameMode.teams[teamNumber]["players"][playerID].hero)
                                    GameMode:AddAllAbilities(GameMode.teams[teamNumber]["players"][playerID].hero)
                                    GameMode:MaxAllAbilities(GameMode.teams[teamNumber]["players"][playerID].hero)
                                    GameMode.teams[teamNumber]["players"][playerID].hero:SetAbsOrigin(GameMode.teams[teamNumber]["players"][playerID].previousPosition)
                                    if GameMode.teams[teamNumber]["players"][playerID].previousHealth == 0 then
                                        --don't reset health
                                    else
                                        GameMode.teams[teamNumber]["players"][playerID].hero:SetHealth(GameMode.teams[teamNumber]["players"][playerID].previousHealth)
                                    end
                                    --delay; otherwise, one of the heroes will not be invulnerable
                                    Timers:CreateTimer({
                                        endTime = 0.06, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                                        callback = function()
                                            GameMode.teams[teamNumber]["players"][playerID].hero:AddNewModifier(nil, nil, "modifier_invulnerable", {})
                                        end
                                    })
                                    GameRules:SetHeroRespawnEnabled(true)
                                    --when does camera reset on respawn?
                                    PlayerResource:SetCameraTarget(playerID, GameMode.teams[teamNumber]["players"][playerID].hero)
                                    Timers:CreateTimer({
                                        endTime = 0.5,
                                        callback = function()
                                            PlayerResource:SetCameraTarget(playerID, nil)
                                        end
                                    })
                                end
                            end
                        end
                    end       
                end
                --remove invulnerablility after delay
                GameMode.cookieOffActive = false
            end
        --regular death
        else

            local respawnPosX = math.random() + math.random(-1323, 571)
            local respawnPosY = math.random() + math.random(-1011, 826)
            hero:SetRespawnPosition(Vector(respawnPosX, respawnPosY, 128))
            --check if there's a winner
            for teamNumber = 6, 13 do
                if GameMode.teams[teamNumber] ~= nil then 
                    if PlayerResource:GetTeamKills(teamNumber) == GameMode.pointsToWin then
                        GameRules:SetCustomVictoryMessage(string.format("%s wins!", GameMode.teamNames[teamNumber]))
                        --end game
                        GameRules:SetGameWinner(teamNumber)
                        GameRules:SetSafeToLeave(true)
                    end
                end
            end
            --if there's no winner, this block will run
            if not GameMode.specialGameCooldown then
                local killsList = {}
                local killsRanking = {}
                for teamNumber = 6, 13 do
                    if GameMode.teams[teamNumber] ~= nil then
                        killsList[teamNumber] = PlayerResource:GetTeamKills(teamNumber)
                    end
                end
                local rank = 1
                for k, v in GameMode:spairs(killsList, function(t,a,b) return t[b] < t[a] end) do
                    print("[GameMode:HeroKilledWhatTheKuck] in the block to rank the teams by kills")
                    killsRanking[rank] = k
                    rank = rank + 1
                end
                print("[GameMode:HeroKilledWhatTheKuck] killsList: ")
                PrintTable(killsList)
                print("[GameMode:HeroKilledWhatTheKuck] killsRanking: ")
                PrintTable(killsRanking)
                local topKills = killsList[killsRanking[1]]
                local secondTopKills = killsList[killsRanking[2]]
                local bottomKills = killsList[killsRanking[#killsRanking]]
                if topKills - secondTopKills >= 3 then
                    print("[GameMode:HeroKilledWhatTheKuck] running special game")
                    EmitGlobalSound('duel_start')
                    Notifications:BottomToAll({text="WHAT THE KUCK?", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                    GameMode:FreezePlayers()
                    GameRules:SetHeroRespawnEnabled(false)
                    Timers:CreateTimer({
                        endTime = 5,

                        callback = function()
                            --GameMode.specialGame = math.random(4)
                            --for testing
                            GameMode.specialGame = 1
                            if GameMode.specialGame == 1 then
                                GameMode:CookieOffAll()
                                Notifications:BottomToAll({text="COOKIE OFF", duration=5.0, style={["font-size"] = "45px", color = "white"}})
                                Notifications:BottomToAll({text="Feed your opponents a cookie", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                            elseif GameMode.specialGame == 2 then
                                GameMode:ButtonMashAll()
                                Notifications:BottomToAll({text="SCATTERBLAST MASH", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                                Notifications:BottomToAll({text="QQQQQQQQ", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                            elseif GameMode.specialGame == 3 then
                                GameMode:MazeAll()
                                Notifications:BottomToAll({text="MAZE", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                                Notifications:BottomToAll({text="Find and kill the golem", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                            else
                                GameMode:DashAll()
                                Notifications:BottomToAll({text="100M DASH", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                                Notifications:BottomToAll({text="MOVE MOVE MOVE!", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
                            end
                            if GameMode.specialGame == 5 then
                                GameMode.specialGame = 1
                            end
                            GameMode:CountDown()
                        end
                    })
                    GameMode.specialGameCooldown = true
                    --store players' positions and health
                    for teamNumber = 6, 13 do
                        if GameMode.teams[teamNumber] ~= nil then
                            for playerID  = 0, GameMode.maxNumPlayers do
                                if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                                    GameMode.teams[teamNumber]["players"][playerID].previousHealth = GameMode.teams[teamNumber]["players"][playerID].hero:GetHealth()
                                    GameMode.teams[teamNumber]["players"][playerID].previousPosition = GameMode.teams[teamNumber]["players"][playerID].hero:GetAbsOrigin()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function GameMode:CookieOffAll()
    GameMode.cookieOffActive = true
    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers do
                if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                    heroEntity = GameMode.teams[teamNumber]["players"][playerID].hero
                    local cookie_off_center_spawn_ent = Entities:FindByName(nil, "cookie_off_center")
                    local cookie_off_center_spawn_vector = cookie_off_center_spawn_ent:GetAbsOrigin()
                    cookie_off_center_spawn_x = cookie_off_center_spawn_vector.x + RandomFloat(-400, 400)
                    cookie_off_center_spawn_y = cookie_off_center_spawn_vector.y + RandomFloat(-400, 400)
                    FindClearSpaceForUnit(heroEntity, Vector(cookie_off_center_spawn_x, cookie_off_center_spawn_y, 128), true)
                    heroEntity:SetRespawnPosition(Vector(cookie_off_center_spawn_x, cookie_off_center_spawn_y, 128))
                    GameMode:Restore(heroEntity)
                    --should set camera on respawn
                    GameMode:RemoveAllAbilities(heroEntity)
                    heroEntity:AddAbility("dummy_spell")
                    heroEntity:AddAbility("cookie_cookie_off_custom")
                    local abil = heroEntity:GetAbilityByIndex(0)
                    abil:SetLevel(1)
                    local abil = heroEntity:GetAbilityByIndex(1)
                    abil:SetLevel(1)
                    if heroEntity:FindItemInInventory("item_cheese") then
                        heroEntity:RemoveItem(heroEntity:FindItemInInventory("item_cheese"))
                    end
                    heroEntity:Stop()
                    --set camera target
                    PlayerResource:SetCameraTarget(playerID, heroEntity)
                    Timers:CreateTimer({
                        endTime = 0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                        callback = function()            
                        for playerID = 0, GameMode.maxNumPlayers do
                            if PlayerResource:IsValidPlayerID(playerID) then
                            PlayerResource:SetCameraTarget(playerID, nil)
                            end
                        end
                    end})
                    --add graphic 
                    --ParticleManager:SetParticleControl(goldenParticle, 0, heroEntity:GetAbsOrigin())
                    heroEntity:AddAbility("invulnerable")
                    local abil = heroEntity:FindAbilityByName("invulnerable")
                    --only 1 level by default
                    abil:SetLevel(1)
                    heroEntity:RemoveAbility("invulnerable")
                    --heroEntity:AddNewModifier(nil, nil, "modifier_magic_immune", {duration = 4})
                    --destroyed on death
                    heroEntity:AddNewModifier(nil, nil, "modifier_attack_immune", {})
                    --goldenParticle = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_overhead.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, heroEntity)
                    --ParticleManager:SetParticleControlEnt(goldenParticle, 1, heroEntity, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", heroEntity:GetAbsOrigin(), true)
                    
                end
            end
        end
    end
end


--selection screen appears
--player chooses hero
function OnJSPlayerSelectCookieGod(event, keys) 
    local player_id = keys["PlayerID"]
    local cookie_god_name = keys["cookie_god_name"]
    --teleport to arena
    --respawn as cookie god
    --invulnerability to all for 4 sec
    --countdown

    local selected_cookie_god = PlayerResource:ReplaceHeroWith(player_id, string.format("npc_dota_hero_%s", cookie_god_name), PlayerResource:GetGold(player_id), 0)

    local item = CreateItem("item_ultimate_scepter", selected_cookie_god, selected_cookie_god)
    selected_cookie_god:AddItem(item)
    GameMode:MaxAllAbilities(selected_cookie_god)
    local player = PlayerResource:GetPlayer(player_id)
    if player ~= nil then
        CustomGameEventManager:Send_ServerToPlayer(player, "cookie_god_selection_end", {})
    end
    --if everyone selected, respawn them and restore their health and position
    GameMode.cookieGodNumPicked = GameMode.cookieGodNumPicked + 1
    --there are other fields besides "playerID" so the length will be longer than the number of players
    if GameMode.cookieGodNumPicked == GameMode.teams[PlayerResource:GetTeam(player_id)].numPlayers then
        print("[OnJSPlayerSelectCookieGod] number of players who picked a cookie god equals the number of players in the winning team")
        for playerID, player in pairs(GameMode.teams[PlayerResource:GetTeam(player_id)]["players"]) do
            print("[OnJSPlayerSelectCookieGod] doing something to each player")
            --"GetSelectedHeroEntity" returns current hero
            local cookieGod = PlayerResource:GetSelectedHeroEntity(playerID)
            player.cookieGodActive = true
            player.hero = cookieGod
            GameMode:Restore(cookieGod)
            --potential conflict: if moved after setting health, the hero might die
            --set position on one of the hills
            --randomly
            local island_centerVectorEnt = Entities:FindByName(nil, "island_center")
            local island_centerVector = island_centerVectorEnt:GetAbsOrigin()
            FindClearSpaceForUnit(cookieGod, island_centerVector, true)
            --make invulnerable
            cookieGod:AddNewModifier(nil, nil, "modifier_invulnerable", {})
            cookieGod:AddAbility("cookie_god_spawn")
            cookieGod:FindAbilityByName("cookie_god_spawn"):SetLevel(1)
            cookieGod:RemoveAbility("cookie_god_spawn")

        end
        --alert players who lost that they will be restored to their previous position and health

        for teamNumber = 6, 13 do
            if teamNumber == PlayerResource:GetTeam(player_id) then goto continue
            elseif GameMode.teams[teamNumber] ~= nil then
                Notifications:BottomToTeam(teamNumber, {text="Restoring to previous health...", duration=4, class="NotificationMessage"})
            end
            ::continue::
        end
        
        --Notifications:BottomToAll({text="Waiting for gods to descend...", duration= 10.0, style={["font-size"] = "45px", color = "white"}})
        --countdown
        GameMode:CountDown()
        --remove invulnerability on countdown end
        Timers:CreateTimer({
            endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
                for teamNumber = 6, 13 do
                    if GameMode.teams[teamNumber] ~= nil then
                        for playerID  = 0, GameMode.maxNumPlayers do
                            if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
                                GameMode.teams[teamNumber]["players"][playerID].hero:RemoveModifierByName("modifier_invulnerable")

                            end
                        end
                    end
                end
            end
          })
        
    end
end


