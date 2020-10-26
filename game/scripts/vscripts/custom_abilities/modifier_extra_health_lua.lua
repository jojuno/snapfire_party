modifier_extra_health_lua = class({})
--------------------------------------------------------------------------------

function modifier_extra_health_lua:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_extra_health_lua:OnCreated( kv )
    print("[modifier_extra_health_lua:OnCreated] kv: ")
    --doesn't work
    --PrintTable(kv)
    self.extra_health_bonus = 300000
    --self:GetParent():Heal(200000, nil)
end


--------------------------------------------------------------------------------

function modifier_extra_health_lua:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end


--------------------------------------------------------------------------------

function modifier_extra_health_lua:GetModifierExtraHealthBonus( params )
	return self.extra_health_bonus
end

--------------------------------------------------------------------------------

--if not done, effect will linger even after death
function modifier_extra_health_lua:OnDeath( params )
	if IsServer() then
        if params.unit == self:GetParent() then
			self:GetParent():RemoveModifierByName("modifier_extra_health_lua")
		end
	end
	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------