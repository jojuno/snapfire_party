
scatterblast_base_modifier_impact_effect = class({})

--------------------------------------------------------------------------------

function scatterblast_base_modifier_impact_effect:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_impact.vpcf"
end

--------------------------------------------------------------------------------

function scatterblast_base_modifier_impact_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

