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
		MythicPlusTimerFrame = {"CENTER","CENTER",-575,175},
		Minimap = {"TOPRIGHT","TOPRIGHT",0,0},
		DataPanelLeft = {"BOTTOMLEFT","BOTTOMLEFT",0,0},
		DataPanelRight = {"BOTTOMRIGHT","BOTTOMRIGHT",0,0},
		ExtraActionBarButton = {"BOTTOM","BOTTOM",0,96},
		ObjectiveTrackerFrame = {"TOPRIGHT","TOPRIGHT",-50,-200},
		VehicleSeatIndicator = {"TOPLEFT","TOPLEFT",20,-400},
		PlayerPowerBarAlt = {"TOP","TOP",0,-100},
		--BuffFrame = {"TOPRIGHT","TOPRIGHT",-190,-5},
		TargetDeathTimer = {"TOP","TOP",0,0},
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
	["auras"] = {
		["blackList"] = {},
		["whiteList"] = {},
		["raidBuffs"] = {},
		["raidDebuffs"] = {},
		["playerBuffs"] = {},
		["defenseBuffs"] = {},
		["pvpDebuffs"] = {},
	},
	["nameplates"] = {
		["deathTimer"] = {
			["target"] = true,
			["nameplate"] = true,
			["timeFormat"] = 1,
		},
	},
	["chat"] = {
		["frame1Width"] = 416,
		["frame1Height"] = 160,
	},
}

local defaultRoleDB = {
	["mover"] = {
		-- ActionBar
		ActionBar1 = {"BOTTOM","BOTTOM",-100,0},
		ActionBar2 = {"BOTTOM","BOTTOM",-100,32},
		ActionBar3 = {"BOTTOM","BOTTOM",188,0},
		ActionBar4 = {"RIGHT","RIGHT",0,0},
		ActionBar5 = {"RIGHT","RIGHT",-32,0},
		PetActionBar = {"BOTTOM","BOTTOM",0,64},
		LeaveVehicleButton = {"BOTTOM","BOTTOM",-264,64},
		StanceBar = {"BOTTOM","BOTTOM",-108,64},
		MenuBar = {"TOPLEFT","TOPLEFT",0,0},
		-- UF
		PlayerFrame = {"TOPLEFT","TOPLEFT",50,-20},
		PlayerCastBar = {"TOPLEFT","TOPLEFT",50,-50},
		TargetFrame = {"TOPLEFT","TOPLEFT",280,-20},
		TargetCastBar = {"TOPLEFT","TOPLEFT",280,-50},
		TargetTargetFrame = {"TOPLEFT","TOPLEFT",500,-20},
		PetFrame = {"TOPLEFT","TOPLEFT",50,-60},
		BossFrame = {"TOPRIGHT","TOPRIGHT",-50,-200},
		PartyFrame = {"TOPLEFT","TOPLEFT",50,-300},
		RaidFrame = {"TOPLEFT","TOPLEFT",50,-300},
		TotemFrame = {"TOPLEFT","TOPLEFT",50,-62},
	},
	["actionBars"] = {
		["enable"] = true,
		["menuBar"] = false,
		["actionBarSlotSize"] = 32,
		["otherBarSlotSize"] = 28,
		["menuBarSlotSize"] = 24,
		["bar1SlotsNum"] = 12,
		["bar1SlotsPerRow"] = 12,
		["bar2SlotsNum"] = 12,
		["bar2SlotsPerRow"] = 12,
		["bar3SlotsNum"] = 12,
		["bar3SlotsPerRow"] = 6,
		["bar4SlotsNum"] = 12,
		["bar4SlotsPerRow"] = 1,
		["bar5SlotsNum"] = 12,
		["bar5SlotsPerRow"] = 1,
		["perBarSlotsPerRow"] = 10,
		["stanceBarSlotsPerRow"] = 10,
	},
	["unitFrames"] = {
		["enable"] = true,
		["player"] = {
			["enable"] = true,
			["width"] = 200,
			["height"] = 30,
			["powerHeight"] = 4,
			["castbarWidth"] = 200,
			["castbarHeight"] = 12,
			["aurasPerRow"] = 8,
		},
		["target"] = {
			["enable"] = true,
			["width"] = 200,
			["height"] = 30,
			["powerHeight"] = 4,
			["castbarWidth"] = 200,
			["castbarHeight"] = 12,
			["aurasPerRow"] = 8,
		},
		["targettarget"] = {
			["enable"] = true,
			["width"] = 100,
			["height"] = 30,
			["powerHeight"] = 4,
			["aurasPerRow"] = 6,
		},
		["pet"] = {
			["enable"] = true,
			["width"] = 100,
			["height"] = 30,
			["powerHeight"] = 3,
			["castbarHeight"] = 12,
			["aurasPerRow"] = 6,
		},
		["boss"] = {
			["enable"] = true,
			["width"] = 200,
			["height"] = 30,
			["powerHeight"] = 4,
			["castbarHeight"] = 12,
			["aurasPerRow"] = 8,
		},
		["party"] = {
			["enable"] = true,
			["width"] = 200,
			["height"] = 40,
			["powerHeight"] = 4,
			["castbarHeight"] = 12,
			["aurasPerRow"] = 8,
			["healthText"] = true,
			["powerText"] = true,
			["buffIndicatorsSize"] = 10,
		},
		["raid"] = {
			["enable"] = true,
			["width"] = 100,
			["height"] = 40,
			["powerHeight"] = 4,
			["auraSize"] = 18,
			["aurasPerRow"] = 6,
			["healthText"] = true,
			["powerText"] = true,
			["buffIndicatorsSize"] = 10,
		},
	},
	["nameplates"] = {
		["enable"] = true,
		["width"] = 100,
		["height"] = 4,
		["aurasPerRow"] = 6,
		["castbarHeight"] = 12,
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

local function OnPlayerSpecChanged()
	local role = GetSpecializationRole(GetSpecialization())
	if lastRole == role then return end
	lastRole = role
	C.roleDB = ruiRoleDB[role]
	B.role = role
	-- Set role mover points
	for frame,mover in pairs(C.mover) do
		if frame and mover and mover.isRole then
			mover:ClearAllPoints()
			local point, secondaryPoint, x, y = unpack(C.roleDB.mover[mover.moverName])
			mover:SetPoint(point, UIParent, secondaryPoint, x, y)
		end
	end
end

B:AddEventScript("PLAYER_SPECIALIZATION_CHANGED", OnPlayerSpecChanged)

B:AddInitScript(function()
	if type(ruiDB) ~= "table" or next(ruiDB) == nil then ruiDB = defaults end
	C.db = ruiDB
	CopyTable(defaults,C.db)
	-- Set non-role mover points
	for frame,mover in pairs(C.mover) do
		if frame and mover and not mover.isRole then
			mover:ClearAllPoints()
			local point, secondaryPoint, x, y = unpack(C.db.mover[mover.moverName])
			mover:SetPoint(point, UIParent, secondaryPoint, x, y)
		end
	end
	if type(ruiRoleDB) ~= "table" or next(ruiRoleDB) == nil then ruiRoleDB = roleDB end
	for role in pairs(roleDB) do CopyTable(defaultRoleDB,ruiRoleDB[role]) end
	OnPlayerSpecChanged()
	-- remove old keys
	for k in pairs(C.db) do if defaults[k] == nil then C.db[k] = nil end end
	for k in pairs(C.roleDB) do if defaultRoleDB[k] == nil then C.roleDB[k] = nil end end
end)
