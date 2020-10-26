modifier_attack_immune = class({})

function modifier_attack_immune:CheckState()
	local state = {
	[MODIFIER_STATE_ATTACK_IMMUNE] = true
	}
	return state
end


function modifier_attack_immune:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_attack_immune:IsHidden()
	return false
end


function modifier_attack_immune:OnDeath(keys)
	print("[modifier_attack_immune:OnDeath] keys: ")
	PrintTable(keys)
end