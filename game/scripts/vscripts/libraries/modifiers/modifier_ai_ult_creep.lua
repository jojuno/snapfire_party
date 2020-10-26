modifier_ai_ult_creep = class({})

local AI_STATE_IDLE = 0 -- running
local AI_STATE_AGGRESSIVE = 1
local AI_STATE_RETURNING = 2

local AI_THINK_INTERVAL = 1

function modifier_ai_ult_creep:OnCreated(params)
    if IsServer() then 
        self.state = AI_STATE_IDLE
        self.aggroRange = params.aggroRange
        self.unit = self:GetParent()
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink,
            [AI_STATE_RETURNING] = self.ReturningThink
        }

        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai_ult_creep:OnIntervalThink()
    self.stateActions[self.state](self)
end

function modifier_ai_ult_creep:IdleThink()
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil, self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 
                    DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    if #units > 0 then
        self.aggroTarget = units[1]
        self.state = AI_STATE_AGGRESSIVE
        return
    end
end

function modifier_ai_ult_creep:AggressiveThink()
    --(vA - vB):Length() returns the length of the vector between the two points
    --GridNav:FindPathLength does the same thing, but returns -1 if there's no traversible path
    --if aggroTarget moves out of aggro range
    if (self.unit:GetAbsOrigin() - self.aggroTarget:GetAbsOrigin()):Length() > self.aggroRange then
        self.unit:MoveToPositionAggressive(self.unit.spawnPos)
        self.state = AI_STATE_RETURNING
        return
    --if aggroTarget died
    elseif not self.aggroTarget:IsAlive() then
        self.unit:MoveToPositionAggressive(self.unit.spawnPos)
        self.state = AI_STATE_RETURNING
        return
    --if creep died, that's handled in the "UltCreepThinker" in "GameMode"
    end

    --none of the above, so do some aggressive stuff
    self.unit:MoveToTargetToAttack(self.aggroTarget)
end


function modifier_ai_ult_creep:ReturningThink()
    if (self.unit.spawnPos - self.unit:GetAbsOrigin()):Length() < 50 then
        self.state = AI_STATE_IDLE
        return
    end
    --if not at return position, issue move command there again
    self.unit:MoveToPositionAggressive(self.unit.spawnPos)
end



