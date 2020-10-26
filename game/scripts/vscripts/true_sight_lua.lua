true_sight_lua = class({})
LinkLuaModifier("true_sight_modifier", LUA_MODIFIER_MOTION_NONE)

--add ability on spawn
--OnCreated, attach modifier
--on owner died
--if everyone on the team is dead
    --spawn a unit with sentry ward
    --cast sentry ward in the center of the stage
    --kill the unit
--at the end of the game, kill the sentry ward
--remove ability
--add ability on start of next round


function true_sight_lua:OnCreated()
    print("[true_sight_lua:OnCreated] called")
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "true_sight_modifier", {})
end