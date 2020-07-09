local _, rui = ...
local B, L, C = unpack(rui)

local TT = {}
B.TT = TT

local handlerList = {}

function TT:HookScript(handler, func)
	if not handlerList[handler] then
		handlerList[handler] = {}
		GameTooltip:HookScript(handler, function(self, ...)
			if self:IsForbidden() then return end
			for _,f in ipairs(handlerList[handler]) do f(self, ...) end
		end)
	end
	local t = handlerList[handler]
	t[#t+1] = func
end

local shouldRemoveLines = {
	[FACTION_HORDE] = true,
	[FACTION_ALLIANCE] = true,
	[PVP] = true,
}

local classifications = {
	worldboss = BOSS,
	rareelite = ITEM_QUALITY3_DESC,
	elite = ELITE,
	rare = ITEM_QUALITY3_DESC,
}

local function OnTooltipSetUnit(tooltip)
	local _, unit = tooltip:GetUnit()
	if not unit then return end
	if UnitIsPlayer(unit) then
		-- Players
		-- Color name and Add AFK/DND tag
		local localeClass, class = UnitClass(unit)
		local classColor = RAID_CLASS_COLORS[class].colorStr
		local name, realm = UnitName(unit)
		local titleName = UnitPVPName(unit) or name
		if realm ~= B.playerRealm then titleName = titleName.."-"..realm end
		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r%s",classColor,titleName,(UnitIsAFK(unit) and L["[AFK]"] or "")..(UnitIsDND(unit) and L["[DND]"] or ""))
		-- Add [] to guild
		local currentLine = 2
		local guildName = GetGuildInfo(unit)
		if guildName then
			local guildColor = ChatTypeInfo.GUILD
			GameTooltipTextLeft2:SetFormattedText("[|cff%02x%02x%02x%s|r]", guildColor.r*255,guildColor.g*255,guildColor.b*255, guildName)
			currentLine = currentLine + 1
		end
		-- Color Lvl line and add faction icon
		for i=currentLine, tooltip:NumLines() do
			local line = _G["GameTooltipTextLeft"..i]
			local text = line:GetText()
			if text and text:find(LEVEL) then
				local faction = UnitFactionGroup(unit)
				local factionIcon = faction == "Horde" and "|T374221:0|t" or faction == "Alliance" and "|T374217:0|t" or " "
				local level = UnitLevel(unit)
				local diffColor = GetCreatureDifficultyColor(level)
				local race = UnitRace(unit)
				line:SetFormattedText("|cff%02x%02x%02x%s|r%s%s |c%s%s|r", diffColor.r*255,diffColor.g*255,diffColor.b*255, level > 0 and level or "??", factionIcon, race, classColor, localeClass)
				-- Remove faction line
			elseif shouldRemoveLines[text] then
				line:SetText("")
			end
		end
	else
		-- NPC
		local guid = UnitGUID(unit)
		local unitType, _, _, _, _, id = strsplit("-", guid)
		-- Color name
		local reactionColor = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		local name = UnitName(unit)
		GameTooltipTextLeft1:SetFormattedText("|cff%02x%02x%02x%s|r",reactionColor.r*255,reactionColor.g*255,reactionColor.b*255,name)
		-- Color Lvl line and add faction icon
		for i=2, tooltip:NumLines() do
			local line = _G["GameTooltipTextLeft"..i]
			local text = line:GetText()
			if text and text:find(LEVEL) then
				local level, type, diffColor
				-- battle pet level and type
				if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
					level = UnitBattlePetLevel(unit)
					type = _G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)]
					diffColor = GetRelativeDifficultyColor(C_PetJournal.GetPetTeamAverageLevel() or 1, level)
				else
					level = UnitLevel(unit)
					type = classifications[UnitClassification(unit)]
					diffColor = GetCreatureDifficultyColor(level)
				end
				local pvp = UnitIsPVP(unit)
				line:SetFormattedText("|cff%02x%02x%02x%s|r %s %s", diffColor.r*255,diffColor.g*255,diffColor.b*255, level > 0 and level or "??", type or "", pvp and PVP or "")
				-- Remove PvP line
			elseif shouldRemoveLines[text] then
				line:SetText("")
			end
		end
		if unitType == "Creature" and id then
			-- Add NPC ID
			tooltip:AddLine(format(L["ID %d"],id))
		end
	end
end

local function OnTooltipSetSpell(tooltip)
	local _,id = tooltip:GetSpell()
	if id then tooltip:AddDoubleLine(" ",format(L["ID %d"],id)) end
end

local function OnTooltipSetItem(tooltip)
	local _, link = tooltip:GetItem()
	if link then
		local id = link:match("item:(%d+)")
		if id then
			local bagNum = GetItemCount(link)
			local bankNum = GetItemCount(link,true) - bagNum
			tooltip:AddDoubleLine(format(L["Bag: %d"], bagNum), format(L["ID %d"], id))
			if bankNum > 0 then tooltip:AddLine(format(L["Bank: %d"], bankNum)) end
		end
	end
end

local function SetCurrencyToken(tooltip, index)
	if tooltip:IsForbidden() then return end
	local id = GetCurrencyListLink(index):match("currency:(%d+)")
	if id then
		tooltip:AddDoubleLine(" ",format(L["ID %d"],id))
		tooltip:Show()
	end
end

local function SetUnitAura(tooltip, unit, index, filter)
	if not tooltip or tooltip:IsForbidden() then return end
	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)
	if id then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local classColor = RAID_CLASS_COLORS[class].colorStr
			tooltip:AddDoubleLine(format("|c%s%s|r", classColor, name), format(L["ID %d"],id))
		else
			tooltip:AddDoubleLine(" ",format(L["ID %d"],id))
		end
		tooltip:Show()
	end
end

B:AddInitScript(function()
	if C.db.tooltip.enable then
		TT:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
		TT:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
		TT:HookScript("OnTooltipSetItem", OnTooltipSetItem)
		hooksecurefunc(GameTooltip, "SetCurrencyToken", SetCurrencyToken)
		hooksecurefunc(GameTooltip, "SetUnitAura", SetUnitAura)
		hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitAura)
		hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitAura)
	end
end)
