modifier_specially_deniable = class({})

--runs multiple times a second
function modifier_specially_deniable:CheckState()
    
    --print("[modifier_specially_deniable:CheckState] inside the function")
    if self.active then
        --print("[modifier_specially_deniable:CheckState] self.active == true")
        local state = {
            [MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
            }
        return state
    end
    --[[if self:GetParent():GetHealthPercent() < 10 then
        print("[modifier_specially_deniable:CheckState] self:GetParent():GetHealthPercent() < 10")
        local state = {
            [MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
            }
        return state
    end]]
end

function modifier_specially_deniable:OnCreated( kv )
    if IsServer() then
        --print("[modifier_specially_deniable:OnCreated] kv: ")
        PrintTable(kv)
        self:StartIntervalThink( 1 )
        --flag to apply the deniable state
        self.active = false
		--[[if params.unit == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

            local attacker = params.attacker
			local target = params.target
			if params.unit ~= target then
				if self:GetStackCount() < self.fiery_soul_on_kill_max_stacks then
					self:IncrementStackCount()
				else
					self:SetStackCount( self:GetStackCount() )
					self:ForceRefresh()
				end

				self:SetDuration( self.duration_tooltip, true )
				self:StartIntervalThink( self.duration_tooltip )
			end
		end]]
	end

	return 0
end

function modifier_specially_deniable:OnIntervalThink()
    --print("[modifier_specially_deniable:OnIntervalThink] inside the function")
    if self:GetParent():GetHealthPercent() < 10 then
        --print("[modifier_specially_deniable:OnIntervalThink] self:GetParent():GetHealthPercent() < 10")
        self.active = true
    else
        self.active = false
    end
end


--apply modifier only when health drops below 10%
