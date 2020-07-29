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
		scores = {
			type = "toggle",
			name = L["ShowMPScores"].."*",
			desc = L["ShowMPScoresTooltips"].."|n"..L["RequireReload"],
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
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RUI", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RUI")
