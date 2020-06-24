local addonName, rui = ...
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
}

local function CopyTable(source,dest)
	for k,v in pairs(source) do
		if dest[k] == nil then dest[k] = v end
		if type(v) == "table" then CopyTable(v,dest[k]) end
	end
end

B:AddInitScript(function()
	if type(ruiDB) ~= "table" or next(ruiDB) == nil then ruiDB = defaults end
	C.db = ruiDB
	CopyTable(defaults,C.db)
	for k in pairs(C.db) do if defaults[k] == nil then C.db[k] = nil end end -- remove old keys
	-- Set frame points
	for frame,mover in pairs(C.mover) do
		if frame and mover then
			mover:ClearAllPoints()
			mover:SetPoint(unpack(C.db.mover[mover.moverName]))
		end
	end
end)

local options = {
	type = "group",
	name = addonName.." "..GetAddOnMetadata(addonName, "Version"),
	childGroups = "tab",
	args = {
		mover = {
			type = "execute",
			name = L["Mover"],
			desc = L["MoverTooltips"],
			order = 1,
			func = function()
				InterfaceOptionsFrame:Hide()
				HideUIPanel(GameMenuFrame)
				for _,mover in pairs(C.mover) do mover:Show() end
				print(L["moverMsg"])
			end,
		},
	},
}
options.args.BlzUI = {
	type = "group",
	name = L["BlzUI"],
	order = 11,
	args = {
		mapHeader = {
			type = "header",
			name = L["Maps"],
			order = 1,
		},
		coords = {
			type = "toggle",
			name = L["MapCoords"].."*",
			desc = L["MapCoordsTooltips"]..L["RequireReload"],
			order = 2,
			get = function(info) return C.db.maps[info[#info]] end,
			set = function(info, value) C.db.maps[info[#info]] = value end,
		},
		minimap = {
			type = "toggle",
			name = L["Minimap"].."*",
			desc = L["RequireReload"],
			order = 3,
			get = function(info) return C.db.maps[info[#info]] end,
			set = function(info, value) C.db.maps[info[#info]] = value end,
		},
		minimapSize = {
			type = "range",
			name = L["MinimapSize"],
			order = 4,
			min = 50, max = 250, step = 1,
			get = function(info) return C.db.maps[info[#info]] end,
			set = function(info, value)
				C.db.maps[info[#info]] = value
				local frame = _G.Minimap
				frame:SetSize(value, value)
				local mover = C.mover[frame]
				mover:SetSize(value, value)
			end,
			disabled = function() return not C.mover[_G.Minimap] end,
		},
		others = {
			type = "header",
			name = L["Others"],
			order = 20,
		},
		hideBossBanner = {
			type = "toggle",
			name = L["HideBossBanner"].."*",
			desc = L["HideBossBannerTooltips"]..L["RequireReload"],
			order = 21,
			get = function(info) return C.db.general[info[#info]] end,
			set = function(info, value) C.db.general[info[#info]] = value end,
		},
		autoScreenshot = {
			type = "toggle",
			name = L["AutoScreenshot"],
			desc = L["AutoScreenshotTooltips"],
			order = 22,
			get = function(info) return C.db.general[info[#info]] end,
			set = function(info, value) C.db.general[info[#info]] = value end,
		},
		undress = {
			type = "toggle",
			name = L["Undress"].."*",
			desc = L["UndressTooltips"]..L["RequireReload"],
			order = 23,
			get = function(info) return C.db.general[info[#info]] end,
			set = function(info, value) C.db.general[info[#info]] = value end,
		},
	},
}
options.args.instance = {
	type = "group",
	name = L["Instance"],
	order = 12,
	get = function(info) return C.db.instance.mythicPlus[info[#info]] end,
	set = function(info, value) C.db.instance.mythicPlus[info[#info]] = value end,
	args = {
		instance = {
			type = "header",
			name = L["Instance"],
			order = 0,
		},
		autoLog = {
			type = "toggle",
			name = L["AutoLog"],
			desc = L["AutoLogTooltips"],
			order = 1,
			get = function(_) return C.db.instance.autoLog end,
			set = function(_, value) C.db.instance.autoLog = value end,
		},
		mythicPlus = {
			type = "header",
			name = L["MythicPlus"],
			order = 10,
		},
		timer = {
			type = "toggle",
			name = L["ShowMPTimer"],
			desc = L["ShowMPTimerTooltips"],
			order = 11,
		},
		hideTracker = {
			type = "toggle",
			name = L["HideTracker"],
			desc = L["HideTrackerTooltips"],
			order = 12,
			disabled = function() return not C.db.instance.mythicPlus.timer end,
		},
		progress = {
			type = "toggle",
			name = L["ShowMPProgress"],
			desc = L["ShowMPProgressTooltips"],
			order = 13,
		},
		autoReply = {
			type = "toggle",
			name = L["MPAutoReply"],
			desc = L["MPAutoReplyTooltips"],
			order = 14,
		},
		scores = {
			type = "toggle",
			name = L["ShowMPScores"].."*",
			desc = L["ShowMPScoresTooltips"]..L["RequireReload"],
			order = 15,
		},
	},
}
options.args.dataPanel = {
	type = "group",
	name = L["DataPanel"],
	order = 13,
	get = function(info) return C.db.dataPanel[info[#info]] end,
	set = function(info, value) C.db.dataPanel[info[#info]] = value end,
	args = {
		enableLeft = {
			type = "toggle",
			name = L["EnableLeftDataPanel"].."*",
			order = 1,
		},
		enableRight = {
			type = "toggle",
			name = L["EnableRightDataPanel"].."*",
			order = 2,
		},
		tooltipInCombat = {
			type = "toggle",
			name = L["TooltipInCombat"],
			desc = L["DataPanelInCombatTooltips"],
			order = 3,
		},
		moneyFormat = {
			type = "select",
			name = L["GoldFormat"],
			order = 4,
			values = {
				[1] = format(B.MoneyString(123456789,1)),
				[2] = format(B.MoneyString(123456789,2)),
			},
			set = function(info, value)
				C.db.dataPanel[info[#info]] = value
				local f = B.DP.panelList.Gold
				f.OnEvent(f)
			end,
		},
	},
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RUI", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RUI")
