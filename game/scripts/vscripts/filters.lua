-- Modifier gained filter function
function GameMode:ModifierFilter( keys )
    if IsServer() then
        --print("[GameMode:ModifierFilter] inside the function")
        --PrintTable(keys)
        local modifier_owner = EntIndexToHScript(keys.entindex_parent_const)
		local modifier_name = keys.name_const
		local modifier_caster
		local modifier_class
        local modifier_ability
        if IMBA_RUNE_SYSTEM == false then
            if string.find(modifier_name, "modifier_rune_") then
                --print("[GameMode:ModifierFilter] inside the string.find(modifier_name, 'modifier_rune_') block")
                local rune_name = string.gsub(modifier_name, "modifier_rune_", "")
                --print("[GameMode:ModifierFilter] rune_name: " .. rune_name)
				ImbaRunes:PickupRune(rune_name, modifier_owner, false)
				return false
            end
        end
        return true
    end
end

-- Item added to inventory filter
function GameMode:ItemAddedFilter( keys )
    local unit = EntIndexToHScript(keys.inventory_parent_entindex_const)
	if unit == nil then return end
	local item = EntIndexToHScript(keys.item_entindex_const)
    if item == nil then return end
    local item_name = nil
    if item:GetName() then
		item_name = item:GetName()
    end
    	-- Custom Rune System
	if string.find(item_name, "item_imba_rune_") and unit:IsRealHero() then
		ImbaRunes:PickupRune(item_name, unit)
		return false
    end
    return true
end