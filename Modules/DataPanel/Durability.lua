local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local function UpdateDurability()
	local minimum = 1
	for i=1, 17 do
		local current, maximum = GetInventoryItemDurability(i)
		if maximum and maximum > 0 then
			minimum = min(minimum,current / maximum)
		end
	end
	return minimum
end

local data = DP:CreateData("Durability")
data.OnMouseUp = function(self)
	if not InCombatLockdown() then
		ToggleCharacter("PaperDollFrame")
	end
end
data.OnEvent = function(self)
	local durability = UpdateDurability()
	self.text:SetFormattedText(L["Durability: %d"], B.RGBStr(durability), durability*100)
end
data.events = {"PLAYER_ENTERING_WORLD", "UPDATE_INVENTORY_DURABILITY"}
