local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local function LatencyString(latency)
	if latency < 50 then
		return "ff22ff22", latency
	elseif latency < 150 then
		return "ffffff22", latency
	else
		return "ffff2222", latency
	end
end

local data = DP:CreateData("Latency")
data.OnEnter = function(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()
	local _, _, latencyHome, latencyWorld = GetNetStats()
	tooltip:AddDoubleLine(L["LatencyHome:"], format("|c%s%d|rms", LatencyString(latencyHome)))
	tooltip:AddDoubleLine(L["LatencyWorld:"], format("|c%s%d|rms", LatencyString(latencyWorld)))
	self.text:SetFormattedText(L["Latency: %d"], LatencyString(max(latencyHome, latencyWorld)))
	tooltip:Show()
end
data.updateInterval = 30
data.OnUpdate = function()
	local _, _, latencyHome, latencyWorld = GetNetStats()
	data.text:SetFormattedText(L["Latency: %d"], LatencyString(max(latencyHome, latencyWorld)))
end
