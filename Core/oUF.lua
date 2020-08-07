local addonName, rui = ...
local B, L, C = unpack(rui)

local oUF = rui.oUF
local oUFFunc = {}
B.oUFFunc = oUFFunc

-- Tags
oUF.Tags.Methods["hpperc"] = function(unit)
	local max = UnitHealthMax(unit)
	local cur = UnitHealth(unit)
	local str
	if cur < max then
		str = format("%s - %.1f%%",L["NumUnitFormat"](cur),cur/max*100)
	else
		str = L["NumUnitFormat"](cur)
	end
	return str
end
oUF.Tags.Events["hpperc"] = "UNIT_HEALTH UNIT_MAXHEALTH"

oUF.Tags.Methods["power"] = function(unit)
	local cur = UnitPower(unit)
	return L["NumUnitFormat"](cur)
end
oUF.Tags.Events["power"] = "UNIT_POWER_UPDATE"

oUF.Tags.Methods["hpcolor"] = function(unit)
	local max = UnitHealthMax(unit)
	local cur = UnitHealth(unit)
	local per = cur/max
	return B.RGBStr(per/2+0.25)
end
oUF.Tags.Events["hpcolor"] = "UNIT_HEALTH UNIT_MAXHEALTH"

oUF.Tags.Methods["colorlvl"] = function(unit)
	local level, diffColor
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
		diffColor = GetRelativeDifficultyColor(C_PetJournal.GetPetTeamAverageLevel() or 1, level)
	else
		level = UnitLevel(unit)
		diffColor = GetCreatureDifficultyColor(level)
	end
	return format("|cff%02x%02x%02x%s|r", diffColor.r*255,diffColor.g*255,diffColor.b*255, level > 0 and level or "??")
end
oUF.Tags.Events["colorlvl"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["colorname"] = function(unit)
	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		local classColor = RAID_CLASS_COLORS[class].colorStr
		local name = UnitName(unit)
		return format("|c%s%s",classColor,name)
	else
		local reactionColor = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		local name = UnitName(unit)
		return format("|cff%02x%02x%02x%s",reactionColor.r*255,reactionColor.g*255,reactionColor.b*255,name)
	end
end
oUF.Tags.Events["colorname"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["status"] = function(unit)
	if UnitIsDead(unit) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(unit) and GetNumArenaOpponentSpecs() == 0 then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end
oUF.Tags.Events["status"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"