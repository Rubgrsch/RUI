local _, rui = ...
local B, L, C = unpack(rui)

local defaults = {
	["instance"] = {
		["autoLog"] = false,
		["mythicPlus"] = {
			["timer"] = true,
			["hideTracker"] = true,
			["progress"] = true,
			["autoReply"] = true,
			["scores"] = false,
			["scoreData"] = {},
		},
	},
	["general"] = {
		["hideBossBanner"] = true,
		["autoScreenshot"] = true,
		["undress"] = true,
	},
	["mover"] = {
		MythicPlusTimerFrame = {"CENTER",-575,175},
		Minimap = {"TOPRIGHT",0,0},
		DataPanelLeft = {"BOTTOMLEFT",0,0},
		DataPanelRight = {"BOTTOMRIGHT",0,0},
		ExtraActionBarButton = {"BOTTOM",0,96},
	},
	["dataPanel"] = {
		["enableLeft"] = true,
		["enableRight"] = true,
		["tooltipInCombat"] = false,
		["moneyFormat"] = 2,
	},
	["maps"] = {
		["coords"] = true,
		["minimap"] = true,
		["minimapSize"] = 170,
	},
	["tooltip"] = {
		["enable"] = true,
	},
	["bags"] = {
		["enable"] = true,
		["autoSellJunk"] = true,
		["reverseLoot"] = function() return GetInsertItemsLeftToRight() end, -- controlled by CVar
		["reverseCleanup"] = function() return GetSortBagsRightToLeft() end, -- controlled by CVar
		["autoRepair"] = 2,
		["bagSlotSize"] = 30,
		["bagSlotsPerRow"] = 10,
		["bankSlotSize"] = 30,
		["bankSlotsPerRow"] = 12,
	},
}

local defaultRoleDB = {
	["mover"] = {
		ActionBar1 = {"BOTTOM",-100,0},
		ActionBar2 = {"BOTTOM",-100,32},
		ActionBar3 = {"BOTTOM",188,0},
		ActionBar4 = {"RIGHT",0,0},
		ActionBar5 = {"RIGHT",-32,0},
		PetActionBar = {"BOTTOM",0,64},
	},
	["actionBars"] = {
		["enable"] = true,
		["bar1"] = true,
		["bar2"] = true,
		["bar3"] = true,
		["bar4"] = true,
		["bar5"] = true,
	},
}

local roleDB = {
	["DAMAGER"] = {},
	["TANK"] = {},
	["HEALER"] = {},
}

local function CopyTable(source,dest)
	for k,v in pairs(source) do
		if dest[k] == nil then dest[k] = v end
		if type(v) == "table" then CopyTable(v,dest[k]) end
		if type(v) == "function" then dest[k] = v() end
	end
end

local lastRole
B:AddInitScript(function()
	if type(ruiDB) ~= "table" or next(ruiDB) == nil then ruiDB = defaults end
	C.db = ruiDB
	CopyTable(defaults,C.db)
	if type(ruiRoleDB) ~= "table" or next(ruiRoleDB) == nil then ruiRoleDB = roleDB end
	local role = GetSpecializationRole(GetSpecialization())
	lastRole = role
	C.roleDB = ruiRoleDB[role]
	CopyTable(defaultRoleDB,C.roleDB)
	-- remove old keys
	for k in pairs(C.db) do if defaults[k] == nil then C.db[k] = nil end end
	for k in pairs(C.roleDB) do if defaultRoleDB[k] == nil then C.roleDB[k] = nil end end
	-- Set frame points
	for frame,mover in pairs(C.mover) do
		if frame and mover then
			mover:ClearAllPoints()
			mover:SetPoint(unpack(C[mover.isRole and "roleDB" or "db"].mover[mover.moverName]))
		end
	end
end)

B:AddEventScript("PLAYER_SPECIALIZATION_CHANGED", function()
	local role = GetSpecializationRole(GetSpecialization())
	if lastRole == role then return end
	lastRole = role
	C.roleDB = ruiRoleDB[role]
	-- Set role mover points
	for frame,mover in pairs(C.mover) do
		if frame and mover and mover.isRole then
			mover:ClearAllPoints()
			mover:SetPoint(unpack(C.roleDB.mover[mover.moverName]))
		end
	end
end)
