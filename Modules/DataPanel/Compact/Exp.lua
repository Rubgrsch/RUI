local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local function OnEvent(self)
	local exp, maxExp = UnitXP("player"), UnitXPMax("player")
	self.text:SetFormattedText(L["LVL %d:%f"], UnitLevel("player"), exp/maxExp*100)
end

local function OnEnter(tooltip)
	tooltip:AddLine(L["Exp"])
	local exp, maxExp, restExp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	tooltip:AddDoubleLine(L["CurrentProgress:"], format("%s/%s (%.0f%%)",L["NumUnitFormat"](exp),L["NumUnitFormat"](maxExp),exp/maxExp*100))
	if restExp and restExp > 0 then tooltip:AddDoubleLine(L["RestExp:"],format("%s (%.0f%%)",L["NumUnitFormat"](restExp),restExp/maxExp*100)) end
end

local function Check() return UnitLevel("player") < MAX_PLAYER_LEVEL end

local compactData = {
	OnEvent = OnEvent,
	events = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
	},
	OnEnter = OnEnter,
	Validate = Check,
	validateEvents = {"PLAYER_LEVEL_UP"},
}
DP:RegisterState("exp", compactData)
