------------------------------------------------
--for future version
------------------------------------------------
modifier_silenced = class({})

function modifier_silenced:CheckState()
    local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_silenced.vpcf", PATTACH_OVERHEAD_FOLLOW, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin())
	local state = {
	[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end
