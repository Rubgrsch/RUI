local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local function OnEvent(self)
	local exp, maxExp = UnitHonor("player"), UnitHonorMax("player")
	self.text:SetFormattedText(L["LVL %d:%f"], UnitHonorLevel("player"), exp/maxExp*100)
end

local function OnEnter(tooltip)
	local exp, maxExp = UnitHonor("player"), UnitHonorMax("player")
	tooltip:AddDoubleLine(L["CurrentExp:"], format("%s/%s (%.0f%%)",L["NumUnitFormat"](exp),L["NumUnitFormat"](maxExp),exp/maxExp*100))
end

local compactData = {
	OnEvent = OnEvent,
	events = {
		"HONOR_XP_UPDATE",
	},
	OnEnter = OnEnter,
	OnClick = TogglePVPUI,
}
DP:RegisterState("honor", compactData)
