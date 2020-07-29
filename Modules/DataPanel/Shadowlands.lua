local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local data = DP:CreateData("Shadowlands")
--[[
data.OnEnter = function(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()

	tooltip:Show()
end]]
data.OnMouseUp = function(self,btn)
	if not InCombatLockdown() then
		if btn == "RightButton" then
		elseif btn == "MiddleButton" then
			if not IsAddOnLoaded("Blizzard_EncounterJournal") then
				EncounterJournal_LoadUI()
			end
			ToggleEncounterJournal()
		else
		end
	end
end
--[[
data.OnEvent = function()
end
data.events = {}
]]
