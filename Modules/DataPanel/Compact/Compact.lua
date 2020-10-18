local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local data = DP:CreateData("Compact")

local curState = nil
local statesData, revStates, stateOrder = {}, {}, {}

local function Validate(_, event)
	local state = revStates[event]
	if statesData[state].Validate() then
		if curState == nil or stateOrder[state] < stateOrder[curState] then
			DP:ApplyState(state)
		end
	end
end

function DP:AddState(state, tbl)
	if tbl.Validate and not tbl.Validate() then return end
	if tbl.Validate and tbl.validateEvents then
		for _, v in ipairs(tbl.validateEvents) do
			B:AddEventScript(v, Validate)
			revStates[v] = state
		end
	end
	stateOrder[state] = #stateOrder + 1
end

function DP:RegisterState(state, tbl)
	statesData[state] = tbl
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
	if not InCombatLockdown() then
		if btn == "RightButton" then
		elseif btn == "MiddleButton" then
			if not IsAddOnLoaded("Blizzard_EncounterJournal") then
				EncounterJournal_LoadUI()
			end
			ToggleEncounterJournal()
		else
			if curState ~= nil and statesData[curState].OnClick then
				statesData[curState].OnClick()
			end
		end
	end
end

B:AddInitScript(function()
	for state, tbl in pairs(statesData) do DP:AddState(state, tbl) end
	for state in pairs(stateOrder) do
		if not statesData[state].Validate or statesData[state].Validate() then
			if curState == nil or stateOrder[state] < stateOrder[curState] then
				DP:ApplyState(state)
			end
		end
	end
end)
