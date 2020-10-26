modifier_ai_drow = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1

local AI_THINK_INTERVAL = 0.1

function modifier_ai_drow:OnCreated(params)
    if IsServer() then 
        self.state = AI_STATE_IDLE
        self.aggroRange = params.aggroRange
        self.leashRange = params.leashRange
        self.unit = self:GetParent()
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink
        }
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai_drow:OnIntervalThink()
    self.stateActions[self.state](self)
end

function modifier_ai_drow:IdleThink()
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil, 
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false)
    if #units > 0 then
        self.spawnPos = self.unit:GetAbsOrigin()
        self.aggroTarget = units[1]
        self.state = AI_STATE_AGGRESSIVE
        return 
    end
end

function modifier_ai_drow:AggressiveThink()
    if (self.unit:GetAbsOrigin() - self.aggroTarget:GetAbsOrigin()):Length() > self.aggroRange then
        self.state = AI_STATE_IDLE
        return
    elseif not self.aggroTarget:IsAlive() then
        self.state = AI_STATE_IDLE
        return
    end
    local abil = self.unit:FindAbilityByName("drow_ranger_wave_of_silence_custom")
    --use ~= to compare two values; "not" only works on one boolean value
    if self.unit.spawn_loc_name ~= "spawn_drow_5" then
        if self.aggroTarget:GetAbsOrigin().x > self.unit:GetAbsOrigin().x then
            self.unit:CastAbilityOnPosition(self.aggroTarget:GetAbsOrigin(), abil, -1)
        end
    else
        self.unit:CastAbilityOnPosition(self.aggroTarget:GetAbsOrigin(), abil, -1)
    end
end




