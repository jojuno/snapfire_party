--------------------------------------------------------------------------------
lil_shredder_base = class({})
LinkLuaModifier( "lil_shredder_base_modifier", "custom_abilities/lil_shredder_base_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lil_shredder_base_debuff_modifier", "custom_abilities/lil_shredder_base_debuff_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function lil_shredder_base:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetDuration()

	-- addd buff
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"lil_shredder_base_modifier", -- modifier name
		{ duration = duration } -- kv
	)
end