extra_health_lua = class({})
LinkLuaModifier( "custom_abilities/modifier_extra_health_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function extra_health_lua:GetIntrinsicModifierName()
	return "modifier_extra_health_lua"
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
