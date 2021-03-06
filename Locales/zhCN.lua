local _, rui = ...
local _, L = unpack(rui)

--if GetLocale() ~= "zhCN" then return end

L["NumUnitFormat"] = function(value)
	if value > 1e8 then
		return format("%.1f亿",value/1e8)
	elseif value > 1e4 then
		return format("%.1f万",value/1e4)
	else
		return format("%.0f",value)
	end
end

-- config
-- config - common
L["Enable"] = "启用"
L["Disable"] = "禁用"
L["General"] = "常规"
L["RequireReload"] = "(重载界面后生效)"
-- config - blz
L["BlzUI"] = "暴雪界面"
-- config - blz - maps
L["Maps"] = "地图"
L["WorldMap"] = "世界地图"
L["MapCoords"] = "世界地图坐标"
L["MapCoordsTooltips"] = "在世界地图上显示玩家和鼠标的坐标"
L["TweakMinimap"] = "优化小地图"
L["MinimapSize"] = "小地图尺寸"
-- config - blz - tooltip
L["Tooltip"] = "优化鼠标提示"
-- config - blz - others
L["Others"] = "其它"
L["HideBossBanner"] = "隐藏首领拾取弹窗"
L["HideBossBannerTooltips"] = "隐藏击败首领后在屏幕中央的战利品弹窗"
L["AutoScreenshot"] = "自动截图"
L["AutoScreenshotTooltips"] = "在完成成就或者史诗钥石后自动截图"
L["Undress"] = "隐藏无关幻化装备"
L["UndressTooltips"] = "预览幻化时隐藏其他部位只显示该物品"
-- config - instance
L["Instance"] = "副本"
L["AutoLog"] = "自动战斗日志"
L["AutoLogTooltips"] = "在普通难度以上团本以及史诗/史诗钥石地下城里自动打开战斗日志"
L["MythicPlus"] = "史诗钥石"
L["Mover"] = "移动位置"
L["MoverTooltips"] = "点击后移动框体位置"
L["moverMsg"] = "左键拖动: 调整框体位置; 右键: 锁定位置."
L["ShowMPTimer"] = "计时器"
L["ShowMPTimerTooltips"] = "显示一个包含当前时间和进度的计时器"
L["HideTracker"] = "隐藏任务追踪"
L["HideTrackerTooltips"] = "在史诗钥石中自动隐藏任务追踪框体及系统自带的计时器"
L["ShowMPProgress"] = "怪物进度"
L["ShowMPProgressTooltips"] = "在鼠标提示里显示怪物进度"
L["MPAutoReply"] = "自动回复"
L["MPAutoReplyTooltips"] = "自动回复好友和工会成员当前史诗钥石的进度"
L["ShowMPScores"] = "为队友打分"
L["ShowMPScoresTooltips"] = "在完成一个史诗钥石后, 弹出一个窗口来为队友打分. 下次组队时在鼠标提示或者聊天框显示他们的状态."
-- config - Datapanel
L["DataPanel"] = "信息条"
L["EnableLeftDataPanel"] = "启用左侧信息条"
L["EnableRightDataPanel"] = "启用右侧信息条"
L["DataPanelInCombatTooltips"] = "允许在战斗中与信息条互动. 但为避免冲突, 某些信息即使在开启后仍然无法在战斗中进行互动."
L["TooltipInCombat"] = "战斗中鼠标提示"
L["GoldFormat"] = "金币格式"
-- config - bags
L["Bags"] = "背包"
L["AutoSellJunk"] = "自动出售垃圾"
L["AutoRepair"] = "自动修理"
L["OnlyPlayer"] = "仅玩家"
L["GuildFirst"] = "工会优先"
L["BagSlotSize"] = "背包格子大小"
L["BagSlotsPerRow"] = "背包每行格子数"
L["BankSlotSize"] = "银行格子大小"
L["BankSlotsPerRow"] = "银行每行格子数"
-- config - actionbars
L["ActionBars"] = "动作条"
L["ActionBar%d"] = "动作条%d"
L["ActionBarSlotSize"] = "动作条按钮大小"
L["ActionBarSlotSizeTooltip"] = "设置该动作条按钮大小, 该选项会对所有主要动作条生效!"
L["ActionBarSlotsNum"] = "按钮总数"
L["ActionBarSlotsNumTooltip"] = "设置该动作条的按钮数,设为0以禁用"
L["ActionBarSlotsPerRow"] = "每行按钮数"
L["ActionBarSlotsPerRowTooltip"] = "设置该动作条每一行的按钮数"
L["PetStanceBarSlotSizeTooltip"] = "设置该动作条按钮大小, 该选项会对宠物动作条和姿态条生效!"
-- config - UF
L["UnitFrames"] = "团队框架"
L["HealthWidth"] = "生命条宽度"
L["HealthHeight"] = "生命条高度"
L["PowerHeight"] = "能量条高度"
L["CastbarWidth"] = "施法条宽度"
L["CastbarHeight"] = "施法条高度"
L["AurasPerRow"] = "每行光环数目"
L["Player"] = "玩家"
L["Target"] = "目标"
L["TargetTarget"] = "目标的目标"
L["Pet"] = "宠物"
L["Boss"] = "首领"
L["Party"] = "小队"
L["Raid"] = "团队"
L["HealthText"] = "生命值"
L["PowerText"] = "能量值"
L["BuffIndicatorsSize"] = "增益指示器大小"
L["AuraSize"] = "光环大小"

-- Tooltip
L["ID %d"] = "ID %d"
L["Bag: %d"] = "背包: %d"
L["Bank: %d"] = "银行: %d"

-- ActionBar
L["PetActionBar"] = "宠物动作条"
L["LeaveVehicleButton"] = "离开载具按钮"
L["StanceBar"] = "姿态条"
L["ExtraActionBarButton"] = "额外动作条按钮"
L["MenuBar"] = "菜单栏"

-- Bags
L["Sort Bags"] = "背包排序"
L["Purchase Bags"] = "购买背包"
L["Sort Bank"] = "银行排序"
L["Reagent"] = "材料银行"
L["Deposit Reagent"] = "导入材料"

-- DataPanel
L["Friends: %d"] = "好友: %d"
L["Guild: %d"] = "公会: %d"
L["FPS: %d"] = "帧率: %d"
L["Latency: %d"] = "延迟: %d"
L["LatencyHome:"] = "本地延迟:"
L["LatencyWorld:"] = "世界延迟:"
L["Total:"] = "总计:"
L["DND"] = "忙碌"
L["AFK"] = "离开"
L["LocalTime:"] = "本地时间:"
L["ServerTime:"] = "服务器时间:"
L["Durability: %d"] = "耐久度: %d"
L["Spec: %d"] = "专精: %d"
L["Loot: %d"] = "拾取: %d"
L["ThisSession:"] = "本次登录: "
L["LeftDataPanel"] = "左侧信息条"
L["RightDataPanel"] = "右侧信息条"
L["LVL %d:%f"] = "%d级: %.0f"
L["CurrentProgress:"] = "当前进度:"
L["RestExp:"] = "精力充沛:"
L["Exp"] = "经验值"
L["Honor"] = "荣誉"
L["Completed:"] = "已完成:"
L["iLvl %d"] = "装等 %d"
L["Next Reward:"] = "下一奖励:"

-- Maps
L["Mouse"] = "鼠标"
L["Minimap"] = "小地图"

-- Instance
L["StartLogging"] = "开始战斗记录"
L["StopLogging"] = "停止战斗记录"
-- MP
--autoreply
L["MPAutoreply"] = "正在进行+%d %s | 首领%d/%d | 进度%.0f%%"
-- Timer
L["Death"] = "死亡"
L["MythicPlusTimer"] = "史诗钥石计时器"
L["Pride"] = "傲慢"

-- UF
L["PlayerCastbar"] = "玩家施法条"
L["TargetCastBar"] = "目标施法条"
L["PlayerFrame"] = "玩家框架"
L["TargetFrame"] = "目标框架"
L["TargetTargetFrame"] = "目标的目标框架"
L["PetFrame"] = "宠物框架"
L["BossFrame"] = "首领框架"
L["PartyFrame"] = "小队框架"
L["RaidFrame"] = "团队框架"
L["PlayerPowerBarAlt"] = "特殊能量条"
