local _, rui = ...
local B, L, C = unpack(rui)

local oUF = rui.oUF

oUF.colors.power.MANA = {0, 0.2, 1}

local function CreateHealth(self)
	local upperFrame = self.upperFrame
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	health:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	health:SetStatusBarColor(0.25,0.25,0.25)
	self.Health = health
	local healthbg = health:CreateTexture(nil, "BACKGROUND")
	healthbg:SetAllPoints()
	healthbg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	healthbg:SetVertexColor(0.1,0.1,0.1,0.7)

	local healthText = upperFrame:CreateFontString()
	healthText:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	self:Tag(healthText, "[hpcolor][hpperc]")
	self.healthValue = healthText

	-- healthpredict
	local healthPredict = CreateFrame("StatusBar", nil, health)
	healthPredict:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT")
	healthPredict:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	healthPredict:SetStatusBarColor(0, 0.8, 0.5, 0.5)
	local otherHealthPredict = CreateFrame("StatusBar", nil, health)
	otherHealthPredict:SetPoint("TOPLEFT", healthPredict:GetStatusBarTexture(), "TOPRIGHT")
	otherHealthPredict:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	otherHealthPredict:SetStatusBarColor(0, 0.8, 0.5, 0.5)
	local absorb = CreateFrame("StatusBar", nil, health)
	absorb:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT")
	absorb:SetAlpha(0.5)
	absorb:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	absorb:SetStatusBarColor(0.9, 1, 1, 0.5)
	local healAbsorb = CreateFrame("StatusBar", nil, health)
	healAbsorb:SetPoint("TOPRIGHT", healthPredict:GetStatusBarTexture())
	healAbsorb:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	local overAbsorb = health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetPoint("TOPLEFT", health, "TOPRIGHT", -4, 0)
	overAbsorb:SetAlpha(0.8)
	self.HealthPrediction = {
		myBar = healthPredict,
		otherBar = otherHealthPredict,
		absorbBar = absorb,
		healAbsorbBar = healAbsorb,
		overAbsorb = overAbsorb,
	}

	return health, healthText, healthPredict, otherHealthPredict, absorb, healAbsorb, overAbsorb
end

local function CreatePower(self)
	local upperFrame = self.upperFrame
	local power = CreateFrame("StatusBar", nil, self)
	power:SetPoint("BOTTOMLEFT", self)
	power:SetPoint("BOTTOMRIGHT", self)
	power:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	power.colorPower = true
	local powerbg = power:CreateTexture(nil, "BACKGROUND")
	powerbg:SetAllPoints()
	powerbg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    powerbg.multiplier = 0.2
	power.bg = powerbg
	self.Power = power

	local powerText = upperFrame:CreateFontString()
	powerText:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	self:Tag(powerText, "[powercolor][power]")
	self.healthValue = powerText
	return power, powerText
end

local function PostCreateIcon(element, icon)
	local cooldown = _G[icon:GetName().."Cooldown"]
	B:SetupCooldown(cooldown,13)
	cooldown:SetReverse(true)
	icon.cooldown = cooldown
end

local function PostUpdateBuff(self)
	self:SetHeight(self.visibleBuffs == 0 and 0.00001 or self.size * ceil(self.visibleBuffs / self.iconsPerRow))
end

local function CreateAuras(self)
	local buffs = CreateFrame("Frame", nil, self)
	buffs.PostCreateIcon = PostCreateIcon
	buffs.PostUpdate = PostUpdateBuff

	local debuffs = CreateFrame("Frame", nil, self)
	debuffs.PostCreateIcon = PostCreateIcon

	self.Buffs = buffs
	self.Debuffs = debuffs
	return buffs, debuffs
end

local function CreateCastbar(self,castbarHeight)
	local f = CreateFrame("Frame")
	local castbar = CreateFrame("StatusBar", nil, self)
	castbar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	local bg = castbar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	bg:SetVertexColor(0.1,0.1,0.1,0.7)
	local spark = castbar:CreateTexture(nil, "OVERLAY")
	spark:SetBlendMode("ADD")
	local time = castbar:CreateFontString(nil, "OVERLAY")
	time:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	local icon = castbar:CreateTexture(nil, "OVERLAY")
    local shieled = castbar:CreateTexture(nil, "OVERLAY")
	local text = castbar:CreateFontString(nil, "OVERLAY")
	text:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	local safezone = castbar:CreateTexture(nil, "OVERLAY")

	castbar.bg = bg
	castbar.Spark = spark
	castbar.Time = time
	castbar.Text = text
	castbar.Icon = icon
	castbar.Shieled = shieled
	castbar.SafeZone = safezone
	local function PostCastStart(self, unit)
		if self.notInterruptible then self:SetStatusBarColor(0.6,0.3,0.3) else self:SetStatusBarColor(0.3,0.3,0.3) end
	end
	castbar.PostCastStart = PostCastStart
	self.Castbar = castbar
	return f, castbar, spark, time, icon, shieled, text
end

local function CreatePlayerStyle(self)
	self.style = "player"
	self:SetSize(200,30)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText, healthPredict
	local healthWidth, healthHeight = 200, 26
	local health, healthText, healthPredict, otherHealthPredict, absorb, healAbsorb, overAbsorb = CreateHealth(self)
	health:SetHeight(healthHeight)
	healthText:SetPoint("BOTTOMLEFT",health,"BOTTOMLEFT", 2, 2)
	healthPredict:SetSize(healthWidth, healthHeight)
	otherHealthPredict:SetSize(healthWidth, healthHeight)
	absorb:SetSize(healthWidth, healthHeight)
	healAbsorb:SetSize(healthWidth, healthHeight)
	overAbsorb:SetSize(10,healthHeight)

	local power, powerText = CreatePower(self)
	power:SetHeight(4)
	powerText:SetPoint("BOTTOMRIGHT",health,"BOTTOMRIGHT", -2, 2)

	-- many icons
	local mark = upperFrame:CreateTexture(nil, "OVERLAY")
	mark:SetPoint("CENTER",self,"TOP")
	mark:SetSize(12,12)
	self.RaidTargetIndicator = mark
	local leader = upperFrame:CreateTexture(nil, "OVERLAY")
	leader:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,-3)
	leader:SetSize(12, 12)
	self.LeaderIndicator = leader
	local assistant = upperFrame:CreateTexture(nil, "OVERLAY")
	assistant:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,-3)
	assistant:SetSize(12, 12)
	self.AssistantIndicator = assistant
	local combat = upperFrame:CreateTexture(nil, "OVERLAY")
	combat:SetPoint("CENTER", self, "CENTER")
	combat:SetSize(22, 22)
	self.CombatIndicator = combat
	local rest = self:CreateTexture(nil, "OVERLAY")
	rest:SetPoint("TOPRIGHT", self, "TOPLEFT", 4, 0)
	rest:SetSize(18, 18)
	self.RestingIndicator = rest

	-- auras
	local buffs, debuffs = CreateAuras(self)
	buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	buffs.initialAnchor = "BOTTOMLEFT"
	buffs["growth-x"] = "RIGHT"
	buffs["growth-y"] = "UP"
	buffs.num = 16
	buffs.iconsPerRow = 8
	local width = self:GetWidth()
	buffs.size = 24
	buffs:SetWidth(self:GetWidth())
	buffs:SetHeight(buffs.size * floor(buffs.num/buffs.iconsPerRow + .5))
	debuffs.initialAnchor = "BOTTOMLEFT"
	debuffs["growth-x"] = "RIGHT"
	debuffs["growth-y"] = "UP"
	debuffs.num = 16
	debuffs.iconsPerRow = 8
	debuffs.showDebuffType = true
	debuffs.size = 24
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	debuffs:SetWidth(self:GetWidth())
	debuffs:SetHeight(debuffs.size * floor(debuffs.num/debuffs.iconsPerRow + .5))
	-- PlayerBuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass player buffs
	-- 4. block noduration
	-- 5. pass others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, duration, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if C.auras.playerBuffs[spellId] then return true end
		if duration == 0 then return false end
		return true
	end
	-- PlayerDebuffs Rules
	-- 1. block blacklist
	-- 2. pass others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, duration, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		return true
	end

	-- Castbar
	local castbarHeight = 12
	local f, castbar, spark, time, icon, shieled, text = CreateCastbar(self,castbarHeight)
	f:SetSize(healthWidth,castbarHeight)
	B:SetupMover(f, "PlayerCastBar",L["PlayerCastbar"],true)
	castbar:SetSize(healthWidth, castbarHeight)
	castbar:SetPoint("TOPLEFT",f,"TOPLEFT",castbarHeight,0)
	spark:SetSize(4,castbarHeight)
	time:SetPoint("RIGHT", castbar)
	icon:SetSize(castbarHeight,castbarHeight)
	icon:SetPoint("TOPLEFT", castbar, "TOPLEFT")
    shieled:SetSize(castbarHeight, castbarHeight)
    shieled:SetPoint("CENTER", icon)
	text:SetPoint("LEFT", icon,"RIGHT")
end

local function CreatePlayerCastbar(self)
	self.style = "playercastbar"
	self:SetSize(200,12)
end

local function CreateTargetStyle(self)
	self.style = "target"
	self:SetSize(200,30)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText, healthPredict
	local healthWidth, healthHeight = 200, 26
	local health, healthText, healthPredict, otherHealthPredict, absorb, healAbsorb, overAbsorb = CreateHealth(self)
	health:SetHeight(healthHeight)
	healthText:SetPoint("BOTTOMLEFT",health,"BOTTOMLEFT", 2, 2)
	healthPredict:SetSize(healthWidth, healthHeight)
	otherHealthPredict:SetSize(healthWidth, healthHeight)
	absorb:SetSize(healthWidth, healthHeight)
	healAbsorb:SetSize(healthWidth, healthHeight)
	overAbsorb:SetSize(10,healthHeight)

	local power, powerText = CreatePower(self)
	power:SetHeight(4)
	powerText:SetPoint("BOTTOMRIGHT",health,"BOTTOMRIGHT", -2, 2)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("TOP",health,"TOP", 0, 0)
	self:Tag(name, "[colorlvl] [colorname]")
	self.nameText = name

	-- many icons
	local mark = upperFrame:CreateTexture(nil, "OVERLAY")
	mark:SetPoint("CENTER",self,"TOP")
	mark:SetSize(12,12)
	self.RaidTargetIndicator = mark
	local leader = upperFrame:CreateTexture(nil, "OVERLAY")
	leader:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,-3)
	leader:SetSize(12, 12)
	self.LeaderIndicator = leader
	local assistant = upperFrame:CreateTexture(nil, "OVERLAY")
	assistant:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,-3)
	assistant:SetSize(12, 12)
	self.AssistantIndicator = assistant
	local phase = upperFrame:CreateTexture(nil, "OVERLAY")
	phase:SetPoint("CENTER",self, "CENTER")
	phase:SetSize(22, 22)
	self.PhaseIndicator = phase
	local combat = upperFrame:CreateTexture(nil, "OVERLAY")
	combat:SetPoint("CENTER", self, "CENTER")
	combat:SetSize(22, 22)
	self.CombatIndicator = combat


	-- auras
	local buffs, debuffs = CreateAuras(self)
	buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	buffs.initialAnchor = "BOTTOMLEFT"
	buffs["growth-x"] = "RIGHT"
	buffs["growth-y"] = "UP"
	buffs.num = 16
	buffs.iconsPerRow = 8
	local width = self:GetWidth()
	buffs.size = 24
	buffs:SetWidth(self:GetWidth())
	buffs:SetHeight(buffs.size * floor(buffs.num/buffs.iconsPerRow + .5))
	-- TargetBuffs Rules
	-- 1. block blacklist
	-- 2. pass others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, duration, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		return true
	end
	debuffs.initialAnchor = "BOTTOMLEFT"
	debuffs["growth-x"] = "RIGHT"
	debuffs["growth-y"] = "UP"
	debuffs.num = 16
	debuffs.iconsPerRow = 8
	debuffs.showDebuffType = true
	debuffs.size = 24
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	debuffs:SetWidth(self:GetWidth())
	debuffs:SetHeight(debuffs.size * floor(debuffs.num/debuffs.iconsPerRow + .5))
	-- TargetDebuffs Rules
	-- 1. block blacklist
	-- 2. pass yours
	-- 3. pass raiddebuffs
	-- 4. pass pvpdebuffs
	-- 5. block other players ->2-> block players
	-- 6. pass others
	debuffs.CustomFilter = function(_, unit, _, _, _, _, _, duration, _, source, _, _, spellId, _, _, castByPlayer) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if source and UnitIsUnit(source, "player") then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		if castByPlayer then return false end
		return true
	end

	-- Castbar
	local castbarHeight = 12
	local f, castbar, spark, time, icon, shieled, text = CreateCastbar(self,castbarHeight)
	f:SetSize(healthWidth,castbarHeight)
	B:SetupMover(f, "TargetCastBar",L["TargetCastBar"],true)
	castbar:SetSize(healthWidth, castbarHeight)
	castbar:SetPoint("TOPLEFT",f,"TOPLEFT",castbarHeight,0)
	spark:SetSize(4,castbarHeight)
	time:SetPoint("RIGHT", castbar)
	icon:SetSize(castbarHeight,castbarHeight)
	icon:SetPoint("TOPLEFT", castbar, "TOPLEFT")
    shieled:SetSize(castbarHeight, castbarHeight)
    shieled:SetPoint("CENTER", icon)
	text:SetPoint("LEFT", icon,"RIGHT")
end

B:AddInitScript(function()
	-- Player
	oUF:RegisterStyle("player", CreatePlayerStyle)
	oUF:SetActiveStyle("player")
	local playerFrame = oUF:Spawn("player")
	B:SetupMover(playerFrame, "PlayerFrame",L["PlayerFrame"],true)
	playerFrame:RegisterForClicks("AnyUp")

	-- Target
	oUF:RegisterStyle("target", CreateTargetStyle)
	oUF:SetActiveStyle("target")
	local targetFrame = oUF:Spawn("target")
	B:SetupMover(targetFrame, "TargetFrame",L["TargetFrame"],true)
	targetFrame:RegisterForClicks("AnyUp")
end)
