local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local data = DP:CreateData("Compact")

local curState = nil
local statesData, stateNum = {}, 0

local validateFrame = CreateFrame("Frame")
validateFrame:SetScript("OnEvent", function(self,event)
	for state, tbl in pairs(statesData) do
		if tbl.validateEvents and tbl.validateEvents[event] then
			if tbl.Validate() then DP:FindState(state) end
		end
	end
end)

function DP:RegisterState(state, tbl)
	stateNum = stateNum+1
	tbl.idx = stateNum
	statesData[state] = tbl
	if tbl.validateEvents then
		for event in pairs(tbl.validateEvents) do
			if not validateFrame:IsEventRegistered(event) then
				validateFrame:RegisterEvent(event)
			end
		end
	end
end

-- call without para: find a state to display
-- call with a newState: newState updated and should check newState and curState
function DP:FindState(newState)
	if not newState then
		local nextState, nextIdx
		for state,tbl in pairs(statesData) do
			if (not nextIdx or nextIdx > tbl.idx) and (not tbl.Validate or tbl.Validate()) then
				nextIdx = tbl.idx
				nextState = state
			end
		end
		return nextState
	else
		if statesData[newState].idx < statesData[curState].idx then
			return statesData[newState].idx < statesData[curState].idx and newState or curState
		end
	end
end

function DP:ApplyState(state)
	local frame = data
	local tbl = statesData[state]
	frame:UnregisterAllEvents()
	curState = state
	if tbl.OnEvent and tbl.events then
		for _, v in ipairs(tbl.events) do frame:RegisterEvent(v) end
		frame:SetScript("OnEvent", tbl.OnEvent)
		tbl.OnEvent(frame)
	end
end

-- DataPanel
data.OnEnter = function(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	if curState ~= nil and statesData[curState].OnEnter then
		local tooltip = GameTooltip
		tooltip:SetOwner(self, "ANCHOR_NONE")
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
		tooltip:ClearLines()

		statesData[curState].OnEnter(tooltip)

		tooltip:Show()
	end
end
data.OnMouseUp = function(self,btn)
	if InCombatLockdown() then return end
	if btn == "LeftButton" then
		if curState ~= nil and statesData[curState].OnClick then
			statesData[curState].OnClick()
		end
	else
		if not IsAddOnLoaded("Blizzard_EncounterJournal") then
			EncounterJournal_LoadUI()
		end
		ToggleEncounterJournal()
	end
end

B:AddInitScript(function()
	local state = DP:FindState()
	DP:ApplyState(state)
end)
