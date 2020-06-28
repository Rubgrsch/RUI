local _, rui = ...
local B, L, C = unpack(rui)

B.playerFaction = UnitFactionGroup("player")
B.playerName, B.playerServer = GetUnitName("player"), GetRealmName()
B.UnlocalizedClassNames = {}
do
	for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do B.UnlocalizedClassNames[v] = k end
	for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do B.UnlocalizedClassNames[v] = k end
end
B.formatName = function(name, full)
	if full then
		return name:find("%-") and name or name.."-"..B.playerServer
	else
		return name:match("%-(.+)$") == B.playerServer and name:match("^(.+)%-") or name
	end
end
B.RGBStr = function(part)
	local r, g, b = (1-part)*0.8+0.2, part*0.8+0.2, 0.2
	return format("|cff%02x%02x%02x",r*255,g*255,b*255)
end

B.MoneyString = function(money, fmt)
	local b = money % 100
	local s = floor(money / 100) % 100
	local g = floor(money / 10000)
	if fmt == 1 then -- coloredString, no icon
		return "|cffffdd00%d|cffe0e0e0%02d|cffff7f00%02d|r", g, s, b
	elseif fmt == 2 then -- icon, short if gold > 1000
		if money > 1e7 then return "%d|T237618:0|t", g
		else return "%d|T237618:0|t%d|T237620:0|t%d|T237617:0|t", g, s, b end
	elseif fmt == 3 then -- icon, full
		return "%d|T237618:0|t%d|T237620:0|t%d|T237617:0|t", g, s, b
	end
end

B.easyMenu = CreateFrame("Frame", "RUIEasyMenu", UIParent, "UIDropDownMenuTemplate")
