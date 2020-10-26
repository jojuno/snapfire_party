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
-- This library contains the function that checks if a player's talent has been activated
require('libraries/player')


-- Rune system override
require('components/runes') 
require('filters')
require('libraries/keyvalues')



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
-- modifier_attack_immune.lua adds the attack immunity modifier
require('libraries/modifiers/modifier_specially_deniable')
-- modifier_invisible.lua adds the invisibility modifier
require('libraries/modifiers/modifier_invisible')
-- modifier_attack_immune.lua adds the bloodlust modifier that speeds up the hero when it kills another hero
require('modifier_fiery_soul_on_kill_lua')

-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "what_the_kuck" then
  require("what_the_kuck")
  GameMode.mapName = "what_the_kuck"
end

---------------------------------------------------------------
--helper functions
---------------------------------------------------------------

--ordering
function GameMode:spairs(t, order)
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

--rounding numbers
function GameMode:Round (num)
  return math.floor(num + 0.5)
end

--pass in a function
--block that loops through every player in the game
function GameMode:ApplyToAllPlayers(do_this)
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
        for playerID  = 0, GameMode.maxNumPlayers - 1 do
            if GameMode.teams[teamNumber][playerID] ~= nil then
                do_this(GameMode.teams[teamNumber][playerID])
            end
        end
    end
  end
end

--freeze players
function GameMode:FreezePlayers()
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
          heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
          heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 5})
          heroEntity:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 5})
        end
      end
    end
  end
end

--4 seconds
function GameMode:CountDown()
  --do the announcement
  Timers:CreateTimer({
    callback = function()
      Notifications:BottomToAll({text="4... " , duration= 8.0, style={["font-size"] = "45px"}})
    end
  })
  Timers:CreateTimer({
    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="3... " , duration= 1.0, style={["font-size"] = "45px"}, continue=true})
    end
  })
  Timers:CreateTimer({
    endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="2... " , duration= 1.0, style={["font-size"] = "45px"}, continue=true})
    end
  })
  Timers:CreateTimer({
    endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="1... " , duration= 1.0, style={["font-size"] = "45px"}, continue=true})
    end
  })
  Timers:CreateTimer({
    endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      Notifications:BottomToAll({text="GO!" , duration= 1.0, style={["font-size"] = "45px", color = "red"}, continue=true})
    end
  })
end

function GameMode:RemoveAllAbilities(hero)
  for abilityIndex = 0, 10 do
    abil = hero:GetAbilityByIndex(abilityIndex)
    if abil ~= nil then
      hero:RemoveAbilityByHandle(abil)
    end
  end
end

function GameMode:RemoveAllItems(hero)
  for itemIndex = 0, 10 do
    if hero:GetItemInSlot(itemIndex) ~= nil then
      hero:RemoveItem(hero:GetItemInSlot(itemIndex))
    end
  end
end

function GameMode:AddAllOriginalAbilities(hero)
  --check by hero name
  if hero:GetUnitName() == "npc_dota_hero_snapfire" then
    --add all her abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    --"gobble up" is hidden by default
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    --level them up
        local abil = hero:GetAbilityByIndex(0)
        abil:SetLevel(4)
        abil = hero:GetAbilityByIndex(1)
        abil:SetLevel(4)
        abil = hero:GetAbilityByIndex(2)
        abil:SetLevel(4)
        abil = hero:GetAbilityByIndex(3)
        abil:SetLevel(1)
        abil = hero:GetAbilityByIndex(4)
        abil:SetLevel(1)
        abil = hero:GetAbilityByIndex(5)
        abil:SetLevel(3)

  elseif hero:GetUnitName() == "npc_dota_hero_chen" then
    --add all his abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  elseif hero:GetUnitName() == "npc_dota_hero_mirana" then
    --add all her abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  elseif hero:GetUnitName() == "npc_dota_hero_batrider" then
    --add all his abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  elseif hero:GetUnitName() == "npc_dota_hero_luna" then
    --add all her abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  elseif hero:GetUnitName() == "npc_dota_hero_gyrocopter" then
    --add all his abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  elseif hero:GetUnitName() == "npc_dota_hero_disruptor" then
    --add all his abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  elseif hero:GetUnitName() == "npc_dota_hero_abaddon" then
    --add all of kotl's abilities
    hero:AddAbility("snapfire_scatterblast")
    hero:AddAbility("snapfire_firesnap_cookie")
    hero:AddAbility("snapfire_lil_shredder")
    hero:AddAbility("snapfire_gobble_up")
    hero:GetAbilityByIndex(3):SetHidden(false)
    hero:AddAbility("snapfire_spit_creep")
    hero:AddAbility("snapfire_mortimer_kisses")
    hero:AddAbility("fiery_soul_on_kill_lua")
  end
end

function GameMode:MaxAllAbilities(hero)
  for index = 0, 30 do
    if hero:GetAbilityByIndex(index) ~= nil then
      --it's okay if argument is above the max level
      hero:GetAbilityByIndex(index):SetLevel(10)
    end
  end
  if hero:GetUnitName() == "npc_dota_hero_invoker" then
    --deafening blast talent
    for i = 0, 29 do
      hero:HeroLevelUp(false)
    end
  end
end

function GameMode:AddAllOriginalItems(hero)
  local item = CreateItem("item_greater_crit", hero, hero)
  hero:AddItem(item)
  local item = CreateItem("item_greater_crit", hero, hero)
  hero:AddItem(item)
  --local item = CreateItem("item_black_king_bar", hero, hero)
  --hero:AddItem(item)
  local item = CreateItem("item_greater_crit", hero, hero)
  hero:AddItem(item)
  local item = CreateItem("item_monkey_king_bar", hero, hero)
  hero:AddItem(item)
  local item = CreateItem("item_ultimate_scepter", hero, hero)
  hero:AddItem(item)
  local item = CreateItem("item_octarine_core", hero, hero)
  hero:AddItem(item)
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
  GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierFilter"), self)
  GameMode.COUNT_DOWN_FROM = 20
  GameMode.endTime = GameMode:Round(GameRules:GetGameTime() + GameMode.COUNT_DOWN_FROM)
  GameMode:GameThinker()
  GameRules:GetGameModeEntity():SetThink(function ()
    --regular
    local delta = GameMode:Round(GameMode.endTime - GameRules:GetGameTime())

    --starting message
    if delta == 19 then
      EmitGlobalSound('gbuTheme')
      Notifications:BottomToAll({text="Warm Up Phase" , duration= 30, style={["font-size"] = "45px", color = "red"}})

    


      return 1

    elseif delta > 6 then
      --sets the amount of seconds until SetThink is called again
      return 1

    elseif delta == 6 then
      --set pregame buffer so people don't resurrect when they die
      GameMode.pregameBuffer = true
      --kill everybody
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID  = 0, GameMode.maxNumPlayers-1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                  GameMode.teams[teamNumber][playerID].hero:ForceKill(false)
                end
            end
        end
      end
      
      Notifications:ClearTopFromAll()
      Notifications:ClearBottomFromAll()
      --oh no, i'm finished..
      --and i'm taking my friends with me!
      Notifications:BottomToAll({text="I'm... DEAD?!" , duration= 2.0, style={["font-size"] = "45px", color = "red"}})
      Timers:CreateTimer({
        endTime = 2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
          Notifications:BottomToAll({text="I'M TAKING EVERYONE WITH ME!" , duration= 2.0, style={["font-size"] = "45px", color = "red"}})
        end
      })
      return 6

    
    elseif delta == 0 then
      --start first game
      --players choose the first game they want to play
      GameMode.pregameActive = false
      
      --game thinker
      --start game
      --end game
      --after some seconds, start another one
    end
  end)
end

function GameMode:GameThinker()
  Timers:CreateTimer("uniqueTimerString3", {
    useGameTime = true,
    callback = function()
      --if a game is not active
        --after some time
        --start one
      --if a game is finished,
        --turn game active false
      --if a game is running,
        --nothing
      if GameMode.gameActive == true then
        return 1
      else
        --select random game
        game_index = math.random(2)
        GameMode.gameActive = true
        Timers:CreateTimer({
          endTime = 20,
          callback = function()
            GameMode:PickGame(3)
            GameMode.numGamesPlayed = GameMode.numGamesPlayed + 1
          end
        })
        return 20
      end
    end
  })
end

--game start
--after 20 seconds
--start game
--when game ends, come back to stage
--

function GameMode:EndGame(winner)
  --give point to the winner
  --find winner
  --kill everyone
  --return them back to the warm up stage
  GameMode.gameActive = false
  Notifications:BottomToAll({text=string.format("WINNER! %s", PlayerResource:GetPlayerName(winner:GetPlayerID())), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID  = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if GameMode.teams[teamNumber][playerID].hero == winner then
            GameMode.teams[teamNumber].score = GameMode.teams[teamNumber].score + 1
          end
          GameMode.teams[teamNumber][playerID].hero:ForceKill(false)
          local start_center_ent = Entities:FindByName(nil, "start_center")
          local start_center_ent_vector = start_center_ent:GetAbsOrigin()
          GameMode.teams[teamNumber][playerID].hero:SetRespawnPosition(start_center_ent_vector)
          GameMode:Restore(GameMode.teams[teamNumber][playerID].hero)
          GameMode:RemoveAllAbilities(GameMode.teams[teamNumber][playerID].hero)
          --remove all abilities
          GameMode:AddAllOriginalAbilities(GameMode.teams[teamNumber][playerID].hero)
          --remove all items
          GameMode:RemoveAllItems(GameMode.teams[teamNumber][playerID].hero)
          --restore all original items
          GameMode:AddAllOriginalItems(GameMode.teams[teamNumber][playerID].hero)
        end
      end
    end
  end
  Notifications:BottomToAll({text = "Selecting random game in 20 seconds", duration= 20.0, style={["font-size"] = "45px", color = "white"}}) 
end

--cookie sumo
--cookie or scatterblast to push them out
--invis, bkb
--dodgeable
--phase boots (fast enough to avoid click)


function GameMode:Sumo() 
  Notifications:BottomToAll({text = "Cookie Sumo", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  Notifications:BottomToAll({text = "Cookie your opponents to throw them off stage", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  --spawn everyone on the maze
  --remove their items
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers-1 do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            for itemIndex = 0, 10 do
              if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                heroEntity:RemoveItem(heroEntity:GetItemInSlot(itemIndex))
              end
            end
            local item = CreateItem("item_phase_boots", heroEntity, heroEntity)
            heroEntity:AddItem(item)
            item = CreateItem("item_black_king_bar", heroEntity, heroEntity)
            heroEntity:AddItem(item)
            GameMode:RemoveAllAbilities(heroEntity)
            local sumo_center_ent = Entities:FindByName(nil, "sumo_center")
            local sumo_center_ent_vector = sumo_center_ent:GetAbsOrigin()
            heroEntity:SetRespawnPosition(sumo_center_ent_vector)
            GameMode:Restore(heroEntity)
            PlayerResource:SetCameraTarget(playerID, heroEntity)
            --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
            --set entity to 'nil' to undo setting the camera
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
            heroEntity:AddNewModifier(nil, nil, "modifier_attack_immune", {})
            heroEntity:AddAbility("dummy_spell")
            local abil = heroEntity:GetAbilityByIndex(0)
            abil:SetLevel(1)
            heroEntity:AddAbility("cookie_sumo")
            abil = heroEntity:GetAbilityByIndex(1)
            abil:SetLevel(1)
            --shotgun
            --force staff
            --bkb
            Timers:CreateTimer({
              endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
              callback = function()            
                PlayerResource:SetCameraTarget(playerID, nil)
              end
            })
          end
        end
      end
    end
  end
  --if player steps off the stage
    --trigger stun
    --add FOW vision on a hill
    --if there's one player remaining
      --end game with remaining player
  --hills
end


--dash
--high speed
--little curves
--force staff to run / push others
--"hoops" (make it VERY easy)
--movespeed fast
--few obstacles
--cookie, scatterblast, kisses that last longer and slows more
function GameMode:Dash()
  Notifications:BottomToAll({text = "Dash", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  Notifications:BottomToAll({text = "Run!", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  --spawn everyone on the maze
  --remove their items
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers-1 do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            GameMode:RemoveAllItems(heroEntity)
            GameMode:RemoveAllAbilities(heroEntity)
            --add force staff
            local item = CreateItem("item_force_staff", heroEntity, heroEntity)
            heroEntity:AddItem(item)
            local dash_start_ent = Entities:FindByName(nil, "dash_start")
            local dash_start_ent_vector = dash_start_ent:GetAbsOrigin()
            heroEntity:SetRespawnPosition(dash_start_ent_vector)
            GameMode:Restore(heroEntity)
            PlayerResource:SetCameraTarget(playerID, heroEntity)
            --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
            --set entity to 'nil' to undo setting the camera
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
            Timers:CreateTimer({
              endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
              callback = function()            
                PlayerResource:SetCameraTarget(playerID, nil)
              end
            })
          end
        end
      end
    end
  end
end


--skirmish
--kill each other
--easy
--maze
function GameMode:Maze() 
  Notifications:BottomToAll({text = "Maze", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  Notifications:BottomToAll({text = "Find the golem and kill it", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  --spawn everyone on the maze
  --remove their items
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers-1 do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            for itemIndex = 0, 10 do
              if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                heroEntity:RemoveItem(heroEntity:GetItemInSlot(itemIndex))
              end
            end
            GameMode:RemoveAllAbilities(heroEntity)
            local maze_center_ent = Entities:FindByName(nil, "maze_center")
            local maze_center_ent_vector = maze_center_ent:GetAbsOrigin()
            heroEntity:SetRespawnPosition(maze_center_ent_vector)
            GameMode:Restore(heroEntity)
            PlayerResource:SetCameraTarget(playerID, heroEntity)
            --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
            --set entity to 'nil' to undo setting the camera
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
            Timers:CreateTimer({
              endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
              callback = function()            
                PlayerResource:SetCameraTarget(playerID, nil)
              end
            })
          end
        end
      end
    end
  end
  spawn_index = math.random(10)
  GameMode.maze.mazeTarget = GameMode:SpawnNeutral(string.format("maze_target_spawn_%s", spawn_index), "npc_dota_warlock_golem_1") 

  --scatterblast slows them
  --set thinker
  --if golem is dead
  --announce winner
  --meet back at the starting zone
  --can kill again
  --give it 20 seconds
  --start next game
end

function GameMode:Mash() 
  Notifications:BottomToAll({text = "Mash", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  Notifications:BottomToAll({text = "QQQQQQQQQQQQQ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  --spawn everyone on the maze
  --remove their items

  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers-1 do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            for itemIndex = 0, 10 do
              if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                heroEntity:RemoveItem(heroEntity:GetItemInSlot(itemIndex))
              end
            end
            GameMode:RemoveAllAbilities(heroEntity)
            local mash_center_ent = Entities:FindByName(nil, "mash_center")
            local mash_center_ent_vector = mash_center_ent:GetAbsOrigin()
            heroEntity:SetRespawnPosition(mash_center_ent_vector)
            GameMode:Restore(heroEntity)
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
            heroEntity:AddAbility("snapfire_scatterblast_button_mash")
            local abil = heroEntity:GetAbilityByIndex(0)
            abil:SetLevel(1)
            heroEntity:AddAbility("extra_health")
            local abil = heroEntity:GetAbilityByIndex(1)
            abil:SetLevel(1)
            heroEntity:Heal(310000, nil)
            PlayerResource:SetCameraTarget(playerID, heroEntity)
            --must delay the undoing of the SetCameraTarget by a second; if they're back to back, the camera will not move
            --set entity to 'nil' to undo setting the camera

            Timers:CreateTimer({
              endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
              callback = function()            
                PlayerResource:SetCameraTarget(playerID, nil)
              end
            })
          end
        end
      end
    end
  end

  -----------------------------------------------------
  -- game logic

  --record everyone's damage
  --19 seconds later (15 + 4 stun duration)
  --record everyone's damage against each other
  Timers:CreateTimer({
    endTime = 19, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      EmitGlobalSound("duel_end")
      --rank by damage dealt in this game
      local damageList = {}
      local damageRanking = {}
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
          for playerID = 0, GameMode.maxNumPlayers - 1 do
            if GameMode.teams[teamNumber][playerID] ~= nil then
              local playerDamageDoneTotal = 0
              local playerDamageDonePrev = 0 
              local playerDamageDoneThisRound = 0
              playerDamageDonePrev = GameMode.teams[teamNumber][playerID].totalDamageDealt
              --calculate the damage dealt for every team against each other
              --damage dealt for pregame
              for victimTeamNumber = 6, 13 do
                  if GameMode.teams[victimTeamNumber] ~= nil then
                      if victimTeamNumber == teamNumber then goto continue
                      else
                          for victimID = 0, GameMode.maxNumPlayers do
                              if GameMode.teams[victimTeamNumber][victimID] ~= nil then
                                  playerDamageDoneTotal = playerDamageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                              end
                          end
                      end
                      ::continue::
                  end
              end
              playerDamageDoneThisRound = playerDamageDoneTotal - playerDamageDonePrev
              damageList[playerID] = playerDamageDoneThisRound
            end
          end    
        end
      end

      --save the top damage
      --if there's other entries with the same value, give them scores too
      -- this uses a custom sorting function ordering by damageDone, descending
      local rank = 1
      for k,v in GameMode:spairs(damageList, function(t,a,b) return t[b] < t[a] end) do
          damageRanking[rank] = k 
          rank = rank + 1
      end
      local topDamage = damageList[damageRanking[1]]
      local winningPlayerID
      for playerID = 0, GameMode.maxNumPlayers - 1 do
        if damageList[playerID] == topDamage then
          GameMode:EndGame(GameMode.teams[PlayerResource:GetTeam(playerID)][playerID].hero)
        end
      end
    end
  })

  --set up
  --record how much damage was dealt before 
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      GameMode.numTeams = GameMode.numTeams + 1
      local teamDamageDoneTotal = 0
      for playerID = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          print("[GameMode:OnAllPlayersLoaded] playerID: " .. playerID)
          local playerDamageDoneTotal = 0
          for victimTeamNumber = 6, 13 do
            if GameMode.teams[victimTeamNumber] ~= nil then
              print("[GameMode:OnAllPlayersLoaded] victimTeamNumber: " .. victimTeamNumber)
              if victimTeamNumber == teamNumber then goto continue
              else
                for victimID = 0, 7 do
                  if GameMode.teams[victimTeamNumber][victimID] ~= nil then
                    print("[GameMode:OnAllPlayersLoaded] victimID: " .. victimID)
                    playerDamageDoneTotal = playerDamageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                  end
                end
              end
              ::continue::
            end
          end
          GameMode.teams[teamNumber][playerID].totalDamageDealt = playerDamageDoneTotal
          teamDamageDoneTotal = teamDamageDoneTotal + playerDamageDoneTotal
        end
      end
      GameMode.teams[teamNumber].totalDamageDealt = teamDamageDoneTotal
    end
  end
  
  --add custom scatterblast ability
  --on end game, remove all abilities and add original ones

end

--functions with same names canNOT exit
--will pick one of them
function GameMode:SpawnNeutral(spawn_loc_name, spawn_name)
  --Start an iteration finding each entity with this name
  --If you've named everything with a unique name, this will return your entity on the first go
  --dynamically assign spawn to entity location via argument passed into the function

  local spawnVectorEnt = Entities:FindByName(nil, spawn_loc_name)

  -- GetAbsOrigin() is a function that can be called on any entity to get its location
  local spawnVector = spawnVectorEnt:GetAbsOrigin()

  -- Spawn the unit at the location on the dire team
  -- if set to neutral team, when hero dies, their death timer gets added 26 seconds to the fixed resurrection time
  local spawnedUnit = CreateUnitByName(spawn_name, spawnVector, true, nil, nil, DOTA_TEAM_BADGUYS)
  

  spawnedUnit.spawn_loc_name = spawn_loc_name
  spawnedUnit.spawn_name = spawn_name
  return spawnedUnit
end


--shotgun and cookie
--more than the number of players spots to hide
--if killed, respawn at the center
--mash
--scatterblast
--top damage wins
--15 seconds

--click on player portrait?

--hack and slash
--god
--projectile avoiding
--different based on character
--for example, when jugg omnis, must turn invis / scepter
--sound to know what to prepare for
--jugg, cm, bb, axe
--cm ice blasts randomly around her
--invoker is the supreme god
--if everyone is dead at the same time, lose
--shotgun game
--three guns -- birdshot, buckshot, slug
--bkb
--2hp
--can choose to have players on separate teams
--choose your horse
--give them everything
--attacking with lil shredder -- counter with blade mail; when you have blademail on, you take no damage



--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  --this is called every time a new hero is introduced in the game
  --for example, when you enter the game, this is called. then, when you change to a new hero, it's called again
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
  local playerID = hero:GetPlayerID()
  local teamNum = PlayerResource:GetTeam(playerID)
  local heroName = hero:GetUnitName()

  --check if the hero's player has picked a hero before
  --cookie god, regular player
  --regular player

  if GameMode.regularHeroes[heroName] ~= nil then

    -- This line for example will set the starting gold of every hero to 500 unreliable gold
    --hero:SetGold(500, false)

    GameMode:AddAllOriginalItems(hero)

    --for future version
    --hero:GetPlayerOwner():SetMusicStatus(0, 0)
    

    --depends on whether the hero is a cookie god or normal hero
    --get ability
    --set its level to max
    --index starts from 0
    --[[		"Ability1"				"snapfire_scatterblast"
      "Ability2"				"snapfire_firesnap_cookie"
      "Ability3"				"snapfire_lil_shredder"
      "Ability4"				"snapfire_gobble_up"
      "Ability5"				"snapfire_spit_creep"
      "Ability6"				"snapfire_mortimer_kisses"
      "Ability7"				"fiery_soul_on_kill_lua"
      "Ability8"				"true_sight"]]
    --hero:AddAbility("snapfire_gobble_up")
    --hero:AddAbility("snapfire_scatterblast")
    --stock abilities
    local abil = hero:GetAbilityByIndex(0)
    abil:SetLevel(4)
    abil = hero:GetAbilityByIndex(1)
    abil:SetLevel(4)
    abil = hero:GetAbilityByIndex(2)
    abil:SetLevel(4)
    abil = hero:GetAbilityByIndex(3)
    abil:SetLevel(1)
    --"gobble up" is hidden by default
    abil:SetHidden(false)
    abil = hero:GetAbilityByIndex(4)
    abil:SetLevel(1)
    --offset because of scepter
    abil = hero:GetAbilityByIndex(5)
    abil:SetLevel(3)

    if GameMode.teams[teamNum] == nil then
      GameMode.teams[teamNum] = {}
      GameMode.teams[teamNum].numPlayers = 0
      GameMode.teams[teamNum].score = 0
      GameMode.teams[teamNum].totalDamageDealt = 0
    end
    --because people spawn as snap, this was called when they spawn and then again when they choose a new hero; snap is in the list of heroes
    GameMode.teams[teamNum][playerID] = {}
    GameMode.teams[teamNum][playerID].hero = hero
    GameMode.teams[teamNum][playerID].heroName = hero:GetUnitName()
    GameMode.teams[teamNum][playerID].totalDamageDealt = 0
    GameMode.teams[teamNum][playerID].sumoOutOfBounds = false

  elseif hero:GetUnitName() == "npc_dota_hero_wisp" then
    hero:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 40})
  end
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
  LinkLuaModifier("modifier_specially_deniable", "libraries/modifiers/modifier_specially_deniable.lua", LUA_MODIFIER_MOTION_NONE)
  LinkLuaModifier("modifier_invisible", "libraries/modifiers/modifier_invisible.lua", LUA_MODIFIER_MOTION_NONE)
  --change game title in addon_english.txt
  --remove items in shops.txt to remove them from the shop
  --remove items completely by disabling them in npc_abilities_custom.txt
  
  --disable the in game announcer
  --GameMode:SetAnnouncerDisabled(true)
  --GameMode:SetBuybackEnabled(false)

  
  CustomGameEventManager:RegisterListener("js_player_select_type", OnJSPlayerSelectType)
  CustomGameEventManager:RegisterListener("js_player_select_points", OnJSPlayerSelectPoints)
  CustomGameEventManager:RegisterListener("js_player_select_hero", OnJSPlayerSelectHero)
  CustomGameEventManager:RegisterListener("js_player_select_cookie_god", OnJSPlayerSelectCookieGod)
  
  

  --call this which is located in the internal/gamemode file to initialize the basic settings provided by barebones 
  GameMode:_InitGameMode()


  -- SEEDING RNG IS VERY IMPORTANT
  math.randomseed(Time())
  
  GameMode.pregameActive = true
  GameMode.pregameBuffer = false
  GameMode.teams = {}
  GameMode.maze = {}
  GameMode.maze.mazeTarget = nil
  GameMode.numTeams = 0
  GameMode.teamNames = {}
  GameMode.teamNames[6] = "Blue Team"
  GameMode.teamNames[7] = "Red Team"
  GameMode.teamNames[8] = "Pink Team"
  GameMode.teamNames[9] = "Green Team"
  GameMode.teamNames[10] = "Brown Team"
  GameMode.teamNames[11] = "Cyan Team"
  GameMode.teamNames[12] = "Olive Team"
  GameMode.teamNames[13] = "Purple Team"
  GameMode.maxNumPlayers = 8
  GameMode.pointsToWin = 5
  GameMode.pointsChosen = "short"
  GameMode.pointsVote = {}
  GameMode.pointsVote["short"] = 0
  GameMode.pointsVote["medium"] = 0
  GameMode.pointsVote["long"] = 0
  GameMode.pointsNumVoted = 0
  GameMode.numPlayers = 0
  --for testing
  GameMode.typeNumVoted = 0
  --GameMode.typeNumVoted = 3
  GameMode.wantedEnabled = true
  GameMode.firstBlood = true
  GameMode.specialGame = 0
  GameMode.specialGameCooldown = false
  GameMode.cookieGodNumPicked = 0

  -----------------------------------------------------------
  --heroes that can be in the game
  GameMode.regularHeroes = {}
  GameMode.regularHeroes["npc_dota_hero_chen"] = true
  GameMode.regularHeroes["npc_dota_hero_disruptor"] = true
  GameMode.regularHeroes["npc_dota_hero_abaddon"] = true
  GameMode.regularHeroes["npc_dota_hero_snapfire"] = true
  GameMode.regularHeroes["npc_dota_hero_mirana"] = true
  GameMode.regularHeroes["npc_dota_hero_luna"] = true
  GameMode.regularHeroes["npc_dota_hero_gyrocopter"] = true
  GameMode.regularHeroes["npc_dota_hero_batrider"] = true

  -----------------------------------------------------------
  --cookie gods
  GameMode.cookieGods = {}
  GameMode.cookieGods["npc_dota_hero_bristleback"] = true
  GameMode.cookieGods["npc_dota_hero_lina"] = true
  GameMode.cookieGods["npc_dota_hero_ogre"] = true
  GameMode.cookieGods["npc_dota_hero_invoker"] = true
  GameMode.cookieGods["npc_dota_hero_axe"] = true
  GameMode.cookieGods["npc_dota_hero_crystal_maiden"] = true
  GameMode.cookieGods["npc_dota_hero_juggernaut"] = true
  GameMode.cookieGods["npc_dota_hero_mortimer"] = true

  -----------------------------------------------------------
  --games
  GameMode.games = {}
  GameMode.games["maze"] = false
  GameMode.games["mash"] = false
  GameMode.games["sumo"] = false
  GameMode.numGamesPlayed = 0
  
  


  --[[DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  
  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')]]
end

function GameMode:PickGame(gameIndex)
  --kill everybody
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
        for playerID  = 0, GameMode.maxNumPlayers-1 do
            if GameMode.teams[teamNumber][playerID] ~= nil then
              GameMode.teams[teamNumber][playerID].hero:ForceKill(false)
            end
        end
    end
  end
  if gameIndex == 1 then
    GameMode:Maze()
  elseif gameIndex == 2 then
    GameMode:Mash()
  elseif gameIndex == 3 then
    GameMode:Sumo()
  elseif gameIndex == 4 then
    GameMode:Dash()
  elseif gameIndex == 5 then
    GameMode:Shotgun()
  elseif gameIndex == 6 then
    GameMode:Horde()
  elseif gameIndex == 7 then
    GameMode:Escape()
  elseif gameIndex == 8 then
    GameMode:Mole()
  elseif gameIndex == 9 then
    GameMode:God()
  end
end

function OnJSPlayerSelectType(event, keys)
  print("[OnJSPlayerSelectType] someone voted")
  
	local player_id = keys["PlayerID"]
  local type = keys["type"]
  print("[OnJSPlayerSelectType] type: " .. type)

  local player = PlayerResource:GetPlayer(player_id)
  if player ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "type_selection_end", {})
  end

  --decide type of gamemode after everyone votes
  
  if GameMode.typeVote[type] == nil then
    GameMode.typeVote[type] = 1
  else
    GameMode.typeVote[type] = GameMode.typeVote[type] + 1
  end
  print("[OnJSPlayerSelectType] GameMode.typeVote[type]: " .. GameMode.typeVote[type])

  --check if everyone has voted
  GameMode.typeNumVoted = GameMode.typeNumVoted + 1
  print("[OnJSPlayerSelectType] GameMode.typeNumVoted: " .. GameMode.typeNumVoted)
  if GameMode.typeNumVoted == PlayerResource:NumPlayers() then
    print("[OnJSPlayerSelectType] everyone voted for the game mode")
    local typeVoteRanking = {}

  
  
    local rank = 1
    for k,v in GameMode:spairs(GameMode.typeVote, function(t,a,b) return t[b] < t[a] end) do
        typeVoteRanking[rank] = k 
        rank = rank + 1
    end
    local topTypeVote = GameMode.typeVote[typeVoteRanking[1]]

    --ipairs?
    for type, votes in pairs(GameMode.typeVote) do
      if GameMode.typeVote[type] == topTypeVote then
          --GameMode.type = "battleRoyale"
          GameMode.type = type
          if type == "battleRoyale" then
            Notifications:TopToAll({text="Mode: Battle Royale", duration= 35.0, style={["font-size"] = "35px", color = "white"}})
          else
            Notifications:TopToAll({text="Mode: Death Match", duration= 35.0, style={["font-size"] = "35px", color = "white"}})
          end
          --subsequent lines get displayed below
          --Notifications:TopToAll({text=string.format("Game Mode: %s", "Battle Royale"), duration= 35.0, style={["font-size"] = "35px", color = "white"}})
          
        --[[else
        print("[OnJSPlayerSelectType] everyone voted for the game mode deathMatch block")
        GameMode.type = "deathMatch"
        Notifications:TopToAll({text=string.format("Game Mode: %s", "Death Match"), duration= 35.0, style={["font-size"] = "35px", color = "white"}})]]
      end
    end
  end
end

function OnJSPlayerSelectPoints(event, keys)
  local pointsTable = {}
  pointsTable["deathMatch"] = {}
  pointsTable["battleRoyale"] = {}
  pointsTable["deathMatch"]["short"] = 15
  pointsTable["deathMatch"]["medium"] = 30
  pointsTable["deathMatch"]["long"] = 45
  pointsTable["battleRoyale"]["short"] = 3
  pointsTable["battleRoyale"]["medium"] = 5
  pointsTable["battleRoyale"]["long"] = 7
	local player_id = keys["PlayerID"]
  local points = keys["points"]

  local player = PlayerResource:GetPlayer(player_id)
  if player ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "points_selection_end", {})
  end

  --decide points to win after everyone votes
  
  if GameMode.pointsVote[points] == nil then
    GameMode.pointsVote[points] = 1
  else
    GameMode.pointsVote[points] = GameMode.pointsVote[points] + 1
  end

  --check if everyone has voted
  GameMode.pointsNumVoted = GameMode.pointsNumVoted + 1
  if GameMode.pointsNumVoted == PlayerResource:NumPlayers() then
    local pointsVoteRanking = {}
  
  
    local rank = 1
    for k,v in GameMode:spairs(GameMode.pointsVote, function(t,a,b) return t[b] < t[a] end) do
        pointsVoteRanking[rank] = k 
        rank = rank + 1
    end
    local topPointsVote = GameMode.pointsVote[pointsVoteRanking[1]]
    for key, points in pairs({"short", "medium", "long"}) do
      if GameMode.pointsVote[points] == topPointsVote then
        GameMode.pointsToWin = pointsTable[GameMode.type][points]
        Notifications:TopToAll({text=string.format("Number of Points to Win: %s", GameMode.pointsToWin), duration= 35.0, style={["font-size"] = "35px", color = "white"}})
        break
      end
    end
  end
end

function OnJSPlayerSelectHero(event, keys)
	local player_id = keys["PlayerID"]
	local hero_name = keys["hero_name"]
	
	local current_hero_name = PlayerResource:GetSelectedHeroName(player_id)
	if current_hero_name == nil then
		return
	end

	if current_hero_name == "npc_dota_hero_wisp" then
    local selectedHero = PlayerResource:ReplaceHeroWith(player_id, hero_name, PlayerResource:GetGold(player_id), 0)
    --selectedHero:AddAbility("dummy_unit")
    --local abil = selectedHero:GetAbilityByIndex(4)
    --abil:SetLevel(1)
		if selectedHero == nil then
			return
		end
	end

	local player = PlayerResource:GetPlayer(player_id)
	if player ~= nil then
		CustomGameEventManager:Send_ServerToPlayer(player, "hero_selection_end", {})
	end
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
  if not hero:IsAlive() then
    hero:RespawnHero(false, false)
  end
end


--play the starting sound
--calculate the damage dealt for every hero against each other
--rank them in descending order
--highest rank gets placed first; lowest rank gets placed last at the starting line
function GameMode:RoundStart(teams)
  EmitGlobalSound('snapfireOlympics.introAndBackground3')      
  GameMode.currentRound = GameMode.currentRound + 1
  
  Notifications:BottomToAll({text=string.format("ROUND %s", GameMode.currentRound), duration= 5.0, style={["font-size"] = "45px", color = "white"}})  
  for teamNumber = 6, 13 do
    if teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers do
        if teams[teamNumber]["players"][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            print("[GameMode:RoundStart] playerID: " .. playerID)
            for itemIndex = 0, 10 do
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
            --heroEntity:AddNewModifier(nil, nil, "modifier_truesight", {})
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

  GameMode:SetUpRunes()
  
  GameMode.roundActive = true
  -- 1 second delayed, run once using gametime (respect pauses)
  Timers:CreateTimer({
    endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()            
      for playerID = 0, GameMode.maxNumPlayers do
        if PlayerResource:IsValidPlayerID(playerID) then
          PlayerResource:SetCameraTarget(playerID, nil)
        end
      end
    end
  })
  
end

function GameMode:DeathMatchStart()
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
  --runes every 1 minute
  --[[Timers:CreateTimer(0, function()
      GameMode:RemoveRunes()
      return 60.0
    end
  )]]
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
    end
  })
  
  --run an event every 30 seconds
    --arrow cookie
    --bomb cookie
    --mortimer
end


function GameMode:CheckTeamsRemaining()
  print("[GameMode:CheckTeamsRemaining] inside the function")
  local teamsRemaining = 0
  local winningTeamNumber = 0
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber]["players"][playerID] ~= nil then
          heroEntity = GameMode.teams[teamNumber]["players"][playerID].hero
          if heroEntity:IsAlive() then
            teamsRemaining = teamsRemaining + 1
            winningTeamNumber = teamNumber
            break
          end
        end
      end
    end
  end
  print("[GameMode:CheckTeamsRemaining] teamsRemaining: " .. teamsRemaining)
  print("[GameMode:CheckTeamsRemaining] winningTeamNumber: " .. winningTeamNumber)
  if teamsRemaining == 1 then
    return winningTeamNumber
  else
    return 0
  end
end

function GameMode:SpawnItem(item_name, item_x, item_y)
  --for i = 0, 3 do
    --randomly generate a number between x1 and x2
    --randomly generate a number between y1 and y2
    --place a potion there
  --create the item
  --it returns a handle; store it in a variable
  --pass this variable to the function
  local item_a = CreateItem(item_name, nil, nil)
  --item_a:SetCastOnPickup(true)

  
  --print("[GameMode:SpawnItem] item_y: " .. item_y)
  --what happens when an item is spawned on the hill?
  --island bottom layer's z = 128
  local item_z = 128
  --print("[GameMode:SpawnItem] item_vector: " .. tostring(Vector(item_x, item_y, item_z)))
  item_handle = CreateItemOnPositionSync(Vector(item_x, item_y, item_z), item_a)
  --print("[GameMode:SpawnItem] item_handle: ")
  --PrintTable(item_a)
  return item_handle
  --spawn 4 items
  --put them in a table
  --add a field "item_used"
  --when item is used,
    --set "item_used" to true
  --at the start of rounds
  --if item_used == true then
    --spawn new item
  --else
    --do nothing
  --
end

function GameMode:SpawnRune(rune_number, item_x, item_y)
  --local item_a = CreateItem("item_imba_rune_doubledamage", nil, nil)

  local item_z = 128
  --print("[GameMode:SpawnItem] rune_vector: " .. tostring(Vector(item_x, item_y, item_z)))

  local rune_handle = CreateRune(Vector(item_x, item_y, item_z), rune_number)
  --rune_handle = CreateItemOnPositionSync(Vector(item_x, item_y, item_z), item_a)
  --print("[GameMode:SpawnItem] rune_handle: ")
  --PrintTable(item_a)
  return rune_handle
  --spawn 4 items
  --put them in a table
  --add a field "item_used"
  --when item is used,
    --set "item_used" to true
  --at the start of rounds
  --if item_used == true then
    --spawn new item
  --else
    --do nothing
  --
end

--CustomGameEventManager:Send_ServertoAllPlayers("scores_create_scoreboard", {name = "This is lua!", desc="This is also LUA!", max= 5, id= 5})

--[[function GameMode:NeutralThinker(unit)
    -- A timer running every second that starts 5 seconds in the future, respects pauses
    Timers:CreateTimer(5, function()
      unit:StartGesture(ACT_DOTA_TAUNT)
      return 1.0
    end
  )
end]]