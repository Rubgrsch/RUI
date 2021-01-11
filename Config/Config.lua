local addonName, rui = ...
local B, L, C = unpack(rui)

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
				for _,mover in pairs(C.mover) do
					local enable = mover.enable
					if not (enable and not enable()) then mover:Show() end
				end
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
		tooltip = {
			type = "toggle",
			name = L["Tooltip"].."*",
			desc = L["RequireReload"],
			order = 1,
			get = function() return C.db.tooltip.enable end,
			set = function(_, value) C.db.tooltip.enable = value end,
		},
		mapHeader = {
			type = "header",
			name = L["Maps"],
			order = 11,
		},
		coords = {
			type = "toggle",
			name = L["MapCoords"].."*",
			desc = L["MapCoordsTooltips"].."|n"..L["RequireReload"],
			order = 12,
			get = function(info) return C.db.maps[info[#info]] end,
			set = function(info, value) C.db.maps[info[#info]] = value end,
		},
		minimap = {
			type = "toggle",
			name = L["TweakMinimap"].."*",
			desc = L["RequireReload"],
			order = 13,
			get = function(info) return C.db.maps[info[#info]] end,
			set = function(info, value) C.db.maps[info[#info]] = value end,
		},
		minimapSize = {
			type = "range",
			name = L["MinimapSize"],
			order = 14,
			min = 50, max = 250, step = 1,
			get = function(info) return C.db.maps[info[#info]] end,
			set = function(info, value)
				C.db.maps[info[#info]] = value
				local frame = _G.Minimap
				frame:SetSize(value, value)
				B:ResizeMover(frame)
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
			desc = L["HideBossBannerTooltips"].."|n"..L["RequireReload"],
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
			desc = L["UndressTooltips"].."|n"..L["RequireReload"],
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
			name = L["ShowMPProgress"].."*",
			desc = L["ShowMPProgressTooltips"].."|n"..L["RequireReload"],
			order = 13,
		},
		autoReply = {
			type = "toggle",
			name = L["MPAutoReply"],
			desc = L["MPAutoReplyTooltips"],
			order = 14,
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
			desc = L["RequireReload"],
			order = 1,
		},
		enableRight = {
			type = "toggle",
			name = L["EnableRightDataPanel"].."*",
			desc = L["RequireReload"],
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
				[3] = format(B.MoneyString(123456789,3)),
			},
			set = function(info, value)
				C.db.dataPanel[info[#info]] = value
				local f = B.DP.panelList.Gold
				f.OnEvent(f)
			end,
		},
	},
}
local function BagDisabled() return not C.db.bags.enable end
local function BagSetSize(info, value)
	C.db.bags[info[#info]] = value
	C:ResizeBags()
end
options.args.bags = {
	type = "group",
	name = L["Bags"],
	order = 14,
	get = function(info) return C.db.bags[info[#info]] end,
	set = function(info, value) C.db.bags[info[#info]] = value end,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"].."*",
			order = 1,
		},
		autoSellJunk = {
			type = "toggle",
			name = L["AutoSellJunk"],
			order = 2,
			disabled = BagDisabled,
		},
		autoRepair = {
			type = "select",
			name = L["AutoRepair"],
			order = 3,
			values = {
				[0] = L["Disable"],
				[1] = L["OnlyPlayer"],
				[2] = L["GuildFirst"],
			},
			disabled = BagDisabled,
		},
		reverseLoot = { -- CVar option lootLeftmostBag
			type = "toggle",
			name = REVERSE_NEW_LOOT_TEXT,
			desc = OPTION_TOOLTIP_REVERSE_NEW_LOOT,
			order = 4,
			set = function(info, checked)
				C.db.bags[info[#info]] = checked
				SetInsertItemsLeftToRight(checked)
			end,
		},
		reverseCleanup = { -- CVar option reverseCleanupBags
			type = "toggle",
			name = REVERSE_CLEAN_UP_BAGS_TEXT,
			desc = OPTION_TOOLTIP_REVERSE_CLEAN_UP_BAGS,
			order = 5,
			set = function(info, checked)
				C.db.bags[info[#info]] = checked
				SetSortBagsRightToLeft(checked)
			end,
		},
		bagSlotSize = {
			type = "range",
			name = L["BagSlotSize"],
			order = 10,
			min = 10, max = 50, step = 2,
			set = BagSetSize,
			disabled = BagDisabled,
		},
		bagSlotsPerRow = {
			type = "range",
			name = L["BagSlotsPerRow"],
			order = 11,
			min = 1, max = 30, step = 1,
			softMin = 4, softMax = 20,
			set = BagSetSize,
			disabled = BagDisabled,
		},
		bankSlotSize = {
			type = "range",
			name = L["BankSlotSize"],
			order = 12,
			min = 10, max = 50, step = 2,
			set = BagSetSize,
			disabled = BagDisabled,
		},
		bankSlotsPerRow = {
			type = "range",
			name = L["BankSlotsPerRow"],
			order = 13,
			min = 1, max = 30, step = 1,
			softMin = 4, softMax = 20,
			set = BagSetSize,
			disabled = BagDisabled,
		},
	},
}
local function ActionBarsDisabled() return not C.roleDB.actionBars.enable end
local function ActoinBarsSet(info, value)
	C.roleDB.actionBars[info[#info]] = value
	local idx = tonumber(info[#info]:match("%d+"))
	if idx then
		C:SetupActionBarButtons(idx)
	else
		for i=1, 5 do C:SetupActionBarButtons(i) end
	end
end
options.args.actionBars = {
	type = "group",
	name = L["ActionBars"],
	order = 14,
	get = function(info) return C.roleDB.actionBars[info[#info]] end,
	set = function(info, value) C.roleDB.actionBars[info[#info]] = value end,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"].."*",
			desc = L["RequireReload"],
			order = 1,
		},
		menuBar = {
			type = "toggle",
			name = L["MenuBar"],
			order = 2,
			set = function(info, value)
				C.roleDB.actionBars[info[#info]] = value
				C:SetupMenuBar(value)
			end,
			disabled = ActionBarsDisabled,
		},
		acionBar1 = {
			type = "group",
			name = L["ActionBar1"],
			order = 11,
			set = ActoinBarsSet,
			args = {
				bar1SlotsNum = {
					type = "range",
					name = L["ActionBarSlotsNum"],
					desc = L["ActionBarSlotsNumTooltip"],
					order = 1,
					min = 0, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				bar1SlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 2,
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				actionBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["ActionBarSlotSizeTooltip"],
					order = 3,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		acionBar2 = {
			type = "group",
			name = L["ActionBar2"],
			order = 12,
			set = ActoinBarsSet,
			args = {
				bar2SlotsNum = {
					type = "range",
					name = L["ActionBarSlotsNum"],
					desc = L["ActionBarSlotsNumTooltip"],
					order = 1,
					min = 0, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				bar2SlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 2,
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				actionBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["ActionBarSlotSizeTooltip"],
					order = 3,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		acionBar3 = {
			type = "group",
			name = L["ActionBar3"],
			order = 13,
			set = ActoinBarsSet,
			args = {
				bar3SlotsNum = {
					type = "range",
					name = L["ActionBarSlotsNum"],
					desc = L["ActionBarSlotsNumTooltip"],
					order = 1,
					min = 0, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				bar3SlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 2,
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				actionBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["ActionBarSlotSizeTooltip"],
					order = 3,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		acionBar4 = {
			type = "group",
			name = L["ActionBar4"],
			order = 14,
			set = ActoinBarsSet,
			args = {
				bar4SlotsNum = {
					type = "range",
					name = L["ActionBarSlotsNum"],
					desc = L["ActionBarSlotsNumTooltip"],
					order = 1,
					min = 0, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				bar4SlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 2,
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				actionBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["ActionBarSlotSizeTooltip"],
					order = 3,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		acionBar5 = {
			type = "group",
			name = L["ActionBar5"],
			order = 15,
			set = ActoinBarsSet,
			args = {
				bar5SlotsNum = {
					type = "range",
					name = L["ActionBarSlotsNum"],
					desc = L["ActionBarSlotsNumTooltip"],
					order = 1,
					min = 0, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				bar5SlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 2,
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				actionBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["ActionBarSlotSizeTooltip"],
					order = 3,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		petBar = {
			type = "group",
			name = L["PetActionBar"],
			order = 16,
			set = function(info, value)
				C.roleDB.actionBars[info[#info]] = value
				C:SetupOtherActionBarBttons()
			end,
			args = {
				perBarSlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 1,
					min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				},
				otherBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["PetStanceBarSlotSizeTooltip"],
					order = 2,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		stanceBar = {
			type = "group",
			name = L["StanceBar"],
			order = 17,
			set = function(info, value)
				C.roleDB.actionBars[info[#info]] = value
				C:SetupOtherActionBarBttons()
			end,
			args = {
				stanceBarSlotsPerRow = {
					type = "range",
					name = L["ActionBarSlotsPerRow"],
					desc = L["ActionBarSlotsPerRowTooltip"],
					order = 1,
					min = 1, max = NUM_STANCE_SLOTS, step = 1,
				},
				otherBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					desc = L["PetStanceBarSlotSizeTooltip"],
					order = 2,
					min = 16, max = 60, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
		menuBarConfig = {
			type = "group",
			name = L["MenuBar"],
			order = 18,
			args = {
				menuBarSlotSize = {
					type = "range",
					name = L["ActionBarSlotSize"],
					order = 1,
					set = function(info, value)
						C.roleDB.actionBars[info[#info]] = value
						C:SetupMenuBar()
					end,
					min = 8, max = 48, step = 1,
				},
			},
			disabled = ActionBarsDisabled,
		},
	},
}
local function UFDisabled() return not C.roleDB.unitFrames.enable end
options.args.unitFrames = {
	type = "group",
	name = L["UnitFrames"],
	order = 14,
	get = function(info) return C.roleDB.unitFrames[info[#info]] end,
	set = function(info, value) C.roleDB.unitFrames[info[#info]] = value end,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"].."*",
			desc = L["RequireReload"],
			order = 1,
		},
		player = {
			type = "group",
			name = L["Player"],
			order = 11,
			get = function(info) return C.roleDB.unitFrames.player[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.player[info[#info]] = value
				C:UFUpdate("player")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				castbarWidth = {
					type = "range",
					name = L["CastbarWidth"],
					order = 5,
					min = 20, max = 1000, step = 5,
				},
				castbarHeight = {
					type = "range",
					name = L["CastbarHeight"],
					order = 6,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		target = {
			type = "group",
			name = L["Target"],
			order = 12,
			get = function(info) return C.roleDB.unitFrames.target[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.target[info[#info]] = value
				C:UFUpdate("target")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				castbarWidth = {
					type = "range",
					name = L["CastbarWidth"],
					order = 5,
					min = 20, max = 1000, step = 5,
				},
				castbarHeight = {
					type = "range",
					name = L["CastbarHeight"],
					order = 6,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		targettarget = {
			type = "group",
			name = L["TargetTarget"],
			order = 13,
			get = function(info) return C.roleDB.unitFrames.targettarget[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.targettarget[info[#info]] = value
				C:UFUpdate("targettarget")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 5,
					min = 1, max = 12, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		foucs = {
			type = "group",
			name = L["Focus"],
			order = 14,
			get = function(info) return C.roleDB.unitFrames.focus[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.focus[info[#info]] = value
				C:UFUpdate("focus")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				castbarHeight = {
					type = "range",
					name = L["CastbarHeight"],
					order = 6,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		pet = {
			type = "group",
			name = L["Pet"],
			order = 15,
			get = function(info) return C.roleDB.unitFrames.pet[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.pet[info[#info]] = value
				C:UFUpdate("pet")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				castbarHeight = {
					type = "range",
					name = L["CastbarHeight"],
					order = 6,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		boss = {
			type = "group",
			name = L["Boss"],
			order = 16,
			get = function(info) return C.roleDB.unitFrames.boss[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.boss[info[#info]] = value
				for i=1, MAX_BOSS_FRAMES do
					C:UFUpdate("boss"..i)
				end
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				castbarHeight = {
					type = "range",
					name = L["CastbarHeight"],
					order = 6,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		party = {
			type = "group",
			name = L["Party"],
			order = 17,
			get = function(info) return C.roleDB.unitFrames.party[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.party[info[#info]] = value
				C:UFGroupUpdate("party")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 1000, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 500, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 500, step = 1,
				},
				castbarHeight = {
					type = "range",
					name = L["CastbarHeight"],
					order = 6,
					min = 1, max = 500, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
				horizontal = {
					type = "toggle",
					name = L["Horizontal"],
					order = 8,
				},
				healthText = {
					type = "toggle",
					name = L["HealthText"],
					order = 11,
				},
				powerText = {
					type = "toggle",
					name = L["PowerText"],
					order = 12,
				},
				buffIndicatorsSize = {
					type = "range",
					name = L["BuffIndicatorsSize"],
					order = 13,
					min = 1, max = 20, step = 1,
				},
			},
			disabled = UFDisabled,
		},
		raid = {
			type = "group",
			name = L["Raid"],
			order = 18,
			get = function(info) return C.roleDB.unitFrames.raid[info[#info]] end,
			set = function(info, value)
				C.roleDB.unitFrames.raid[info[#info]] = value
				C:UFGroupUpdate("raid")
			end,
			args = {--[[
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},]]
				width = {
					type = "range",
					name = L["HealthWidth"],
					order = 2,
					min = 20, max = 200, step = 5,
				},
				height = {
					type = "range",
					name = L["HealthHeight"],
					order = 3,
					min = 5, max = 200, step = 1,
				},
				powerHeight = {
					type = "range",
					name = L["PowerHeight"],
					order = 4,
					min = 1, max = 200, step = 1,
				},
				aurasPerRow = {
					type = "range",
					name = L["AurasPerRow"].."*",
					desc = L["RequireReload"],
					order = 7,
					min = 1, max = 12, step = 1,
				},
				auraSize = {
					type = "range",
					name = L["AuraSize"].."*",
					desc = L["RequireReload"],
					order = 8,
					min = 4, max = 32, step = 1,
				},
				healthText = {
					type = "toggle",
					name = L["HealthText"],
					order = 11,
				},
				powerText = {
					type = "toggle",
					name = L["PowerText"],
					order = 12,
				},
				buffIndicatorsSize = {
					type = "range",
					name = L["BuffIndicatorsSize"],
					order = 13,
					min = 1, max = 20, step = 1,
				},
			},
			disabled = UFDisabled,
		},
	},
}
options.args.nameplates = {
	type = "group",
	name = L["Nameplates"],
	order = 13,
	get = function(info) return C.roleDB.nameplates[info[#info]] end,
	set = function(info, value)
		C.roleDB.nameplates[info[#info]] = value
		C:NPUpdate()
	end,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"].."*",
			desc = L["RequireReload"],
			order = 1,
		},
		width = {
			type = "range",
			name = L["HealthWidth"],
			order = 2,
			min = 20, max = 200, step = 5,
		},
		height = {
			type = "range",
			name = L["HealthHeight"],
			order = 3,
			min = 1, max = 100, step = 1,
		},
		aurasPerRow = {
			type = "range",
			name = L["AurasPerRow"].."*",
			desc = L["RequireReload"],
			order = 4,
			min = 1, max = 12, step = 1,
		},
		castbarHeight = {
			type = "range",
			name = L["CastbarHeight"],
			order = 5,
			min = 1, max = 500, step = 1,
		},
		deathTimerHeader = {
			type = "header",
			name = L["DeathTimer"],
			order = 20,
		},
		targetDT = {
			type = "toggle",
			name = L["Target"],
			order = 21,
			get = function(info) return C.db.nameplates.deathTimer.target end,
			set = function(info, value)
				C.db.nameplates.deathTimer.target = value
				C:SetupDeathTimer()
			end,
		},
		timeFormat = {
			type = "select",
			name = L["TimeFormat"],
			order = 22,
			values = {
				[1] = "67.3",
				[2] = "67",
				[3] = "01:07",
			},
			get = function(info) return C.db.nameplates.deathTimer[info[#info]] end,
			set = function(info, value)
				C.db.nameplates.deathTimer[info[#info]] = value
				C:SetupDeathTimer()
			end,
		},
		nameplateDT = {
			type = "toggle",
			name = L["Nameplate"],
			order = 23,
			get = function(info) return C.db.nameplates.deathTimer.nameplate end,
			set = function(info, value)
				C.db.nameplates.deathTimer.nameplate = value
				C:SetupDeathTimer()
			end,
		},
	},
}

LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RUI", options)
LibStub("AceConfigDialog-3.0"):SetDefaultSize("RUI", 800, 600)

B:AddInitScript(function()
	local button = CreateFrame("Button", "GameMenuFrameRUI", GameMenuFrame, "GameMenuButtonTemplate")
	button:SetText(L["RUI"])
	button:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -1)
	GameMenuFrame:HookScript("OnShow", function(self)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:SetPoint("TOP", button, "BOTTOM", 0, -11)
		self:SetHeight(self:GetHeight() + button:GetHeight() + 2)
	end)

	button:SetScript("OnClick", function()
		LibStub("AceConfigDialog-3.0"):Open("RUI")
		HideUIPanel(GameMenuFrame)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end)
end)
