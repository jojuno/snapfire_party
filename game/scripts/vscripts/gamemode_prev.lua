-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end


-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')



-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')
require('internal/util')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
-- core_mechanics.lua is where you can specify how the game works
require('core_mechanics')
-- modifier_ai.lua is where you can specify how the non-player controlled units will behave
require('libraries/modifiers/modifier_ai')
-- modifier_ai_ult_creep specifies how the creeps in the last zone will behave
require('libraries/modifiers/modifier_ai_ult_creep')
-- modifier_ai_ult_creep specifies how drow will behave
require('libraries/modifiers/modifier_ai_drow')
-- modifier_stunned.lua stuns the entity on creation
require('libraries/modifiers/modifier_stunned')
-- modifier_invulnerable.lua adds the invulnerability modifier
require('libraries/modifiers/modifier_invulnerable')
-- modifier_invulnerable.lua adds the magic immunity modifier
require('libraries/modifiers/modifier_magic_immune')
-- modifier_silenced.lua adds the silenced modifier
require('libraries/modifiers/modifier_silenced')
-- modifier_attack_immune.lua adds the attack immunity modifier
require('libraries/modifiers/modifier_attack_immune')
-- modifier_attack_immune.lua adds the bloodlust modifier that speeds up the hero when it kills another hero
require('modifier_fiery_soul_on_kill_lua')

-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]


function GameMode:OnAllPlayersLoaded()

  --for the countdown function
  function round (num)
    return math.floor(num + 0.5)
  end

  local COUNT_DOWN_FROM = 30
  local endTime = round(GameRules:GetGameTime() + COUNT_DOWN_FROM)

  GameRules:GetGameModeEntity():SetThink(function ()
    
    local delta = round(endTime - GameRules:GetGameTime())

    --starting message
    if delta == 29 then
      Notifications:BottomToAll({text="Battle Royale" , duration= 20, style={["font-size"] = "30px", color = "white"}})
      Notifications:BottomToAll({text="First to 7 points wins" , duration= 20, style={["font-size"] = "30px", color = "white"}})
      Notifications:BottomToAll({text="Categories: Last Man Standing, Most Damage, Most Kills" , duration= 20, style={["font-size"] = "30px", color = "white"}})
      Notifications:BottomToAll({text="Warm Up Phase" , duration= 20, style={["font-size"] = "45px", color = "red"}})
      return 1

    elseif delta > 9 then
      --sets the amount of seconds until SetThink is called again
      return 1

    elseif delta == 9 then
      GameMode.pregameBuffer = true
      Notifications:BottomToAll({text="Get ready!" , duration= 5.0, style={["font-size"] = "45px", color = "red"}})
      for playerID = 0, 9 do
        if PlayerResource:IsValidPlayerID(playerID) then
          heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
          heroEntity:ForceKill(true)
        end
      end
      return 5


    --play the starting sound
    --calculate the damage dealt for every hero against each other
    --rank them in descending order
    --highest rank gets placed first; lowest rank gets placed last at the starting line
    elseif delta == 4 then
      EmitGlobalSound('snapfireOlympics.introAndBackground3')
      GameMode.pregameActive = false
      GameRules:SetHeroRespawnEnabled( false )
      GameMode:RoundStart(GameMode.playerEnts)
      return 4
    elseif delta == 0 then
    end
  end)
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  --local item = CreateItem("item_ultimate_scepter", hero, hero)
  --hero:AddItem(item)
  local item = CreateItem("item_force_staff", hero, hero)
  hero:AddItem(item)
  --local item = CreateItem("item_black_king_bar", hero, hero)
  --hero:AddItem(item)
  local item = CreateItem("item_cyclone", hero, hero)
  hero:AddItem(item)
  local item = CreateItem("item_glimmer_cape", hero, hero)
  hero:AddItem(item)

  --for future version
  --hero:GetPlayerOwner():SetMusicStatus(0, 0)
  


  --get ability
  --set its level to max
  --index starts from 0
  local abil = hero:GetAbilityByIndex(0)
  abil:SetLevel(4)
  abil = hero:GetAbilityByIndex(1)
  abil:SetLevel(4)
  abil = hero:GetAbilityByIndex(2)
  abil:SetLevel(4)
  abil = hero:GetAbilityByIndex(3)
  abil:SetLevel(4)
  --offset because of scepter
  abil = hero:GetAbilityByIndex(5)
  abil:SetLevel(3)
  if hero:GetPlayerID() == 0 then

    abil = hero:GetAbilityByIndex(6)
    abil:SetLevel(1)
  end

  --abil = hero:GetAbilityByIndex(6)
  --abil:SetLevel(1)
  --abil = hero:GetAbilityByIndex(7)
  --abil:SetLevel(4)
  
  GameMode.playerEnts[hero:GetPlayerID()] = {}
  GameMode.playerEnts[hero:GetPlayerID()]["hero"] = hero
  GameMode.playerEnts[hero:GetPlayerID()]["hero"].isAlive = true
  GameMode.playerEnts[hero:GetPlayerID()]["hero"].damageDealt = 0
  GameMode.playerEnts[hero:GetPlayerID()]["hero"].kills = 0
  GameMode.playerEnts[hero:GetPlayerID()]["hero"].score = 0
  GameMode.numPlayers = GameMode.numPlayers + 1
  
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  --use "print" and "PrintTable" to print messages in the debugger
  DebugPrint("[BAREBONES] The game has officially begun")
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  --make file in modifiers folder
  --link it to the class (this is the modifier for neutral creeps' AI)
  LinkLuaModifier("modifier_ai", "libraries/modifiers/modifier_ai.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_ai_ult_creep", "libraries/modifiers/modifier_ai_ult_creep.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_ai_drow", "libraries/modifiers/modifier_ai_drow.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_invulnerable", "libraries/modifiers/modifier_invulnerable.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_silenced", "libraries/modifiers/modifier_silenced.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_attack_immune", "libraries/modifiers/modifier_attack_immune.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_magic_immune", "libraries/modifiers/modifier_magic_immune.lua", LUA_MODIFIER_MOTION_NONE)
  --change game title in addon_english.txt
  --remove items in shops.txt to remove them from the shop
  --remove items completely by disabling them in npc_abilities_custom.txt
  
  --disable the in game announcer
  --GameMode:SetAnnouncerDisabled(true)
  --GameMode:SetBuybackEnabled(false)

  

  
  

  --call this which is located in the internal/gamemode file to initialize the basic settings provided by barebones 
  GameMode:_InitGameMode()


  -- SEEDING RNG IS VERY IMPORTANT
  math.randomseed(Time())
  
  GameMode.playerEnts = {}
  GameMode.numPlayers = 0
  GameMode.numAlive = 0
  GameMode.currentRound = 0
  GameMode.pregameActive = true
  GameMode.pregameBuffer = false
  GameMode.tieBreakerActive = false
  GameMode.roundActive = false


  --[[DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  
  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')]]
end



-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end




function GameMode:Restore(hero)
  --Purge stuns and debuffs from pregame
  --set "bFrameOnly" to maintain the purged state
  hero:Purge(true, true, false, true, true)
  --heal health and mana to full
  hero:Heal(8000, nil)
  hero:GiveMana(8000)
  hero:RemoveModifierByName("modifier_truesight")
  if not hero:IsAlive() then
    hero:RespawnHero(false, false)
    hero.isAlive = true
  end
  print("[GameMode:Restore] hero.isAlive: " .. tostring(hero.isAlive))
end

--play the starting sound
--calculate the damage dealt for every hero against each other
--rank them in descending order
--highest rank gets placed first; lowest rank gets placed last at the starting line
function GameMode:RoundStart(players)
  EmitGlobalSound('snapfireOlympics.introAndBackground3')      
  GameMode.currentRound = GameMode.currentRound + 1
  GameMode.numAlive = GameMode.numPlayers
  Notifications:BottomToAll({text=string.format("Round %s", GameMode.currentRound), duration= 5.0, style={["font-size"] = "45px", color = "white"}})  

  for playerID in pairs(players) do
    if PlayerResource:IsValidPlayerID(playerID) then
      heroEntity = players[playerID]["hero"]
      
      print("[GameMode:RoundStart] team for this hero: " .. heroEntity:GetTeamNumber())
      for itemIndex = 0, 5 do
        if heroEntity:GetItemInSlot(itemIndex) ~= nil then
          heroEntity:GetItemInSlot(itemIndex):EndCooldown()
        elseif heroEntity:GetItemInSlot(itemIndex) == "item_gem" then
          heroEntity:RemoveItem(itemIndex)
        end
      end
      for abilityIndex = 0, 5 do
        abil = heroEntity:GetAbilityByIndex(abilityIndex)
        abil:EndCooldown()
      end
      heroEntity:Stop()
      heroEntity:ForceKill(false)
      heroEntity.isAlive = false
      GameMode:Restore(heroEntity)
      --set camera to hero because when the hero is relocated, the camera stays still
      --use global variable 'PlayerResource' to call the function
      PlayerResource:SetCameraTarget(playerID, heroEntity)
      --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
      --set entity to 'nil' to undo setting the camera
      PlayerResource:GetSelectedHeroEntity(playerID):AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
    end
  end
  
  GameMode.roundActive = true
  -- 10 second delayed, run once using gametime (respect pauses)
  Timers:CreateTimer({
    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()            
      for playerID = 0, 9 do
        if PlayerResource:IsValidPlayerID(playerID) then
          PlayerResource:SetCameraTarget(playerID, nil)
        end
      end
    end
  })
  
end

--CustomGameEventManager:Send_ServertoAllPlayers("scores_create_scoreboard", {name = "This is lua!", desc="This is also LUA!", max= 5, id= 5})