local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local useLocalTime, useMilitaryTime = true, true

local function GetCurrentTime(useLocal, useMilitary)
	if useLocal then
		if useMilitary then return date("%H:%M") else return date("%I:%M %p") end
	else
		local hour, minute = GetGameTime()
		if useMilitary then
			return "%02d:%02d", hour, minute
		else
			if hour > 12 then
				hour = hour - 12
				return "%02d:%02dPM", hour, minute
			else
				return "%02d:%02dAM", hour, minute
			end
		end
	end
end

local data = DP:CreateData("Time")
data.OnEnter = function(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()
	tooltip:AddLine(date("%m-%d ")..CALENDAR_WEEKDAY_NAMES[tonumber(date("%w"))+1])
	tooltip:AddDoubleLine(L["LocalTime:"], format(GetCurrentTime(true,useMilitaryTime)))
	tooltip:AddDoubleLine(L["ServerTime:"], format(GetCurrentTime(false,useMilitaryTime)))
	tooltip:Show()
end
data.OnMouseUp = function(self,btn)
	if not InCombatLockdown() then
		if btn == "RightButton" then
			ToggleTimeManager()
		else
			ToggleCalendar()
		end
	end
end
data.updateInterval = 1
data.OnUpdate = function()
	data.text:SetFormattedText(GetCurrentTime(useLocalTime, useMilitaryTime))
end
data.OnEvent = function()
	useLocalTime = GetCVarBool("timeMgrUseLocalTime")
	useMilitaryTime = GetCVarBool("timeMgrUseMilitaryTime")
end
data.events = {"CVAR_UPDATE", "PLAYER_ENTERING_WORLD"}
