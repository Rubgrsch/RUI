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
L["LVL %d:%f"] = L["LVL %d:%f"]:gsub("%%d","|cffffff22%%d|r"):gsub("%%.0f","|cff22ff22%%.0f%%%%|r")

-- ActionBar
for i=1, 5 do L["ActionBar"..i] = format(L["ActionBar%d"],i) end
