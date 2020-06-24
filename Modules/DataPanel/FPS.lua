local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local function MemoryUsageString(memory)
	if memory < 1024 then
		return "|cff22ff22%d|rKB", memory
	elseif memory < 10240 then
		return "|cffffff22%.2f|rMB", memory/1024
	else
		return "|cffff2222%.1f|rMB", memory/1024
	end
end

local function FPSString(fps)
	if fps < 20 then
		return "ffff2222", fps
	elseif fps < 40 then
		return "ffffff22", fps
	else
		return "ff22ff22", fps
	end
end

local addonsList, lastNum = {}, -1

local function SortAddons(a,b)
	return a[3] > b[3]
end

local function UpdateAddonsInfo()
	local num = GetNumAddOns()
	if num ~= lastNum then
		wipe(addonsList)
		for i=1, num do
			if IsAddOnLoaded(i) then
				local name = GetAddOnInfo(i)
				addonsList[#addonsList+1] = {name, i, 0}
			end
		end
	end
end

local function UpdateAddonsUsage()
	UpdateAddOnMemoryUsage()
	local sum = 0
	for _, v in ipairs(addonsList) do
		local i = v[2]
		local usage = GetAddOnMemoryUsage(i)
		v[3] = usage
		sum = sum + usage
	end
	sort(addonsList,SortAddons)
	return sum
end

local data = DP:CreateData("FPS")
local function OnEnter(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()
	UpdateAddonsInfo()
	local total = UpdateAddonsUsage()
	for _, info in ipairs(addonsList) do
		tooltip:AddDoubleLine(info[1],format(MemoryUsageString(info[3])),1,1,1,1,1,1)
	end
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine(L["Total:"],format(MemoryUsageString(total)),1,1,1,1,1,1)
	tooltip:Show()
	self.isTTShown = true
end
data.OnEnter = OnEnter
data.OnMouseUp = function(self)
	if not InCombatLockdown() and IsModifierKeyDown() then
		collectgarbage()
		UpdateAddonsUsage()
		if self.isTTShown then OnEnter(self) end
	end
end
data.updateInterval = 1
data.OnUpdate = function()
	local f = data
	f.text:SetFormattedText(L["FPS: %d"], FPSString(GetFramerate()))
	if f.isTTShown then OnEnter(f) end
end
