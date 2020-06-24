local _, rui = ...
local B, L, C = unpack(rui)

-- DataPanel
L["Friends: %d"] = L["Friends: %d"]:gsub("%%d", "|cff22ff22%%d|r")
L["Guild: %d"] = L["Guild: %d"]:gsub("%%d", "|cff22ff22%%d|r")
L["FPS: %d"] = L["FPS: %d"]:gsub("%%d", "|c%%s%%d|r")
L["Latency: %d"] = L["Latency: %d"]:gsub("%%d", "|c%%s%%d|r")
L["Durability: %d"] = L["Durability: %d"]:gsub("%%d", "%%s%%d%%%%|r")
L["Spec: %d"] = L["Spec: %d"]:gsub("%%d", "|T%%d:0|t")
L["Loot: %d"] = L["Loot: %d"]:gsub("%%d", "|T%%d:0|t")
L["[DND]"] = "[|cffff0000"..L["DND"].."|r]"
L["[AFK]"] = "[|cffff0000"..L["AFK"].."|r]"
