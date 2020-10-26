------------------------------------------------
--for future version
------------------------------------------------
modifier_ai = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1
local AI_STATE_RETURNING = 2

local AI_THINK_INTERVAL = 1

function modifier_ai:OnCreated(params)
    print('in [OnCreated] function.')
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "modifier_ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = params.aggroRange
        self.leashRange = params.leashRange

        -- Store unit handle so we don't have to call self:GetParent() every time
        --this is HScript
        self.unit = self:GetParent()

        -- Set state -> action mapping
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink,
            [AI_STATE_RETURNING] = self.ReturningThink,
        }

        -- Start thinking
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai:OnIntervalThink()
    -- Execute action corresponding to the current state
    self.stateActions[self.state](self)    
end

function modifier_ai:IdleThink()
    -- Find any enemy units around the AI unit inside the aggroRange
    --print('a neutral creep is in an idle state.')
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)
    --[[local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)]]

    -- If one or more units were found, start attacking the first one
    if #units > 0 then
        self.spawnPos = self.unit:GetAbsOrigin() -- Remember position to return to
        self.aggroTarget = units[1] -- Remember who to attack
        --check what self.unit is // HScript
        --print(self.aggroTarget)
        self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
        self.state = AI_STATE_AGGRESSIVE --State transition
        return -- Stop processing this state
    end

    -- Nothing else to do in Idle state
end

function modifier_ai:AggressiveThink()
    


    if GridNav:FindPathLength(self.spawnPos, self.unit:GetAbsOrigin()) > self.leashRange then
        print("centaur returning to its spawn position.")
        self.unit:MoveToPosition(self.spawnPos) --Move back to the spawnpoint
        self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
        return -- Stop processing this state
    end
    
    -- Check if the target has died
    if not self.aggroTarget:IsAlive() then
        self.unit:MoveToPositionAggressive(self.spawnPos) --Move back to the spawnpoint
        self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
        return -- Stop processing this state
    end
    
    -- Still in the aggressive state, so do some aggressive stuff.
    self.unit:MoveToTargetToAttack(self.aggroTarget)

        -- Check if the unit has walked outside its leash range
    --call "FindPathLength" with GridNav
    --for centaur khans, stun when enemy is in range
    
    --print("location of aggroTarget: " .. tostring(self.aggroTarget:GetAbsOrigin()))
    --print("path length between aggroTarget and unit: " .. tostring(GridNav:FindPathLength(self.aggroTarget:GetAbsOrigin(), self.unit:GetAbsOrigin())))
    if GridNav:FindPathLength(self.aggroTarget:GetAbsOrigin(), self.unit:GetAbsOrigin()) < 300 then
        -- Check if the game time has passed our random time for next order

        
        --set delay to cast spell initially
        if self.unit.initial_cast then 
            --print("initial cast being set to false")
            self.unit.NextOrderTime = GameRules:GetGameTime() + math.random(3, 5) 
            --print("Next order time: " .. tostring(self.unit.NextOrderTime))
            --print("game time: " .. tostring(GameRules:GetGameTime()))
            --print("[modifier_ai:AggressiveThink()] [INITIAL CAST] the name of the unit that's aggressive is "..self.unit:GetUnitName())
            self.unit.initial_cast = false
            return
        elseif GameRules:GetGameTime() > self.unit.NextOrderTime then
            --print("NOT initial cast")
            --print("Next order time: " .. tostring(self.unit.NextOrderTime))
            --print("game time: " .. tostring(GameRules:GetGameTime()))
            --print("[modifier_ai:AggressiveThink()] [NOT INITIAL CAST] the name of the unit that's aggressive is "..self.unit:GetUnitName())
            --added parentheses to the conditional evaluator
            if self.unit:GetUnitName() == "npc_dota_neutral_centaur_khan" then
                --print("casting ability " .. EntIndexToHScript(self.unit.CastAbilityIndex):GetName())
                local ability = self.unit:GetAbilityByIndex(0)
                --use next two lines to make centaur cast spells
                self.unit:SetCursorCastTarget(self.aggroTarget)
                --this will ignore cooldown and status (like stun) and cast the spell
                ability:OnSpellStart()
                -- Add a random amount to the game time to randomise the behaviour a bit
                self.unit.NextOrderTime = GameRules:GetGameTime() + math.random(3, 5) 
                --[[local order = {
                    UnitIndex = self.unit:entindex(),
                    AbilityIndex = self.unit.CastAbilityIndex,
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    Queue = false
                }
                ExecuteOrderFromTable(order)]]
            end
        end
    end
end

function modifier_ai:ReturningThink()
    --print('a neutral creep is in a returning state.')
    -- Check if the AI unit has reached its spawn location yet
    if (self.spawnPos - self.unit:GetAbsOrigin()):Length() < 10 then
        self.state = AI_STATE_IDLE -- Transition the state to the 'Idle' state(!)
        return -- Stop processing this state
    end

    -- If not at return position yet, try to move there again
    self.unit:MoveToPositionAggressive(self.spawnPos)
    
end