local _, rui = ...
local _, L = unpack(rui)

--if GetLocale() ~= "zhCN" then return end

-- config
-- config - common
L["Enable"] = "启用"
L["General"] = "常规"
L["RequireReload"] = "|n(重载界面后生效)"
-- config - blz
L["BlzUI"] = "暴雪界面"
-- config - blz - maps
L["Maps"] = "地图"
L["WorldMap"] = "世界地图"
L["MapCoords"] = "世界地图坐标"
L["MapCoordsTooltips"] = "在世界地图上显示玩家和鼠标的坐标"
L["Minimap"] = "优化小地图"
L["MinimapSize"] = "小地图尺寸"
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

-- DataPanel
L["Friends: %d"] = "好友: %d"
L["Guild: %d"] = "工会: %d"
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

-- Maps
L["Mouse"] = "鼠标"
L["Player"] = "玩家"

-- Instance
L["StartLogging"] = "开始战斗记录"
L["StopLogging"] = "停止战斗记录"
-- MP
--autoreply
L["MPAutoreply"] = "正在进行史诗钥石 +%d %s | 首领%d/%d | 进度%.0f%%"
-- Timer
L["Death"] = "死亡"
L["MythicPlusTimer"] = "史诗钥石计时器"
-- MPB
L["MPB:LV1"] = "优秀"
L["MPB:LV2"] = "一般"
L["MPB:LV3"] = "差劲"
L["MPB:LV4"] = "坑"
L["MPB:LV5"] = "好友"
L["MPB:Anounce_Chat"] = "MPB: %s曾经被评价为 %s."
L["MPB:Anounce_Tooltips"] = " MPB评价为 %s|r"
L["Reset"] = "重置"
L["Confirm"] = "确认"
L["Close"] = "关闭"
