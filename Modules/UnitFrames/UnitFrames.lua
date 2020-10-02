local _, rui = ...
local B, L, C = unpack(rui)

C.UF = {}
local oUF = rui.oUF

oUF.colors.power.MANA = {0, 0.2, 1}

local function CreateHealth(self, hasText)
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

	local healthText
	if hasText ~= false then
		healthText = upperFrame:CreateFontString()
		healthText:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
		self:Tag(healthText, "[hpcolor][hpperc]")
		self.healthValue = healthText
	end

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
		maxOverflow = 1,
	}

	return health, healthText, healthPredict, otherHealthPredict, absorb, healAbsorb, overAbsorb
end

local function CreatePower(self, hasText)
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

	local powerText
	if hasText ~= false then
		powerText = upperFrame:CreateFontString()
		powerText:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
		self:Tag(powerText, "[powercolor][power]")
		self.PowerValue = powerText
	end

	return powerText
end

local function PostCreateIcon(_, icon)
	local cooldown = _G[icon:GetName().."Cooldown"]
	B:SetupCooldown(cooldown,13)
	cooldown:SetReverse(true)
	local count = icon.count
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", 0, 0)
	count:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	local stealable = icon.stealable
	stealable:ClearAllPoints()
	stealable:SetPoint("TOPLEFT", -2, 2)
	stealable:SetPoint("BOTTOMRIGHT", 2, -2)
	icon.cooldown = cooldown
end

local function PostUpdateBuff(self)
	self:SetHeight(self.visibleBuffs == 0 and 0.00001 or self.size * ceil(self.visibleBuffs / self.iconsPerRow))
end

local function CreateAuras(self)
	local buffs = CreateFrame("Frame", nil, self)
	buffs.initialAnchor = "BOTTOMLEFT"
	buffs.showStealableBuffs = true
	buffs["growth-x"] = "RIGHT"
	buffs["growth-y"] = "UP"
	buffs.PostCreateIcon = PostCreateIcon
	buffs.PostUpdate = PostUpdateBuff
	local debuffs = CreateFrame("Frame", nil, self)
	debuffs.initialAnchor = "BOTTOMLEFT"
	debuffs["growth-x"] = "RIGHT"
	debuffs["growth-y"] = "UP"
	debuffs.showDebuffType = true
	debuffs.PostCreateIcon = PostCreateIcon

	self.Buffs = buffs
	self.Debuffs = debuffs
	return buffs, debuffs
end

local function CastTimeText(self,duration)
	return self.Time:SetFormattedText("%.2f/%.2f", duration, self.max)
end
local function CastColor(self)
	if self.notInterruptible then self:SetStatusBarColor(0.6,0.3,0.3) else self:SetStatusBarColor(0.3,0.3,0.3) end
end

local function CreateCastbar(self)
	local f = CreateFrame("Frame")
	local castbar = CreateFrame("StatusBar", nil, self)
	castbar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	local bg = castbar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	bg:SetVertexColor(0.1,0.1,0.1,0.7)
	local spark = castbar:CreateTexture(nil, "OVERLAY")
	spark:SetTexCoord(0.25, 0.75, 0.25, 0.75)
	spark:SetBlendMode("ADD")
	local time = castbar:CreateFontString(nil, "OVERLAY")
	time:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	local icon = castbar:CreateTexture(nil, "OVERLAY")
    local shieled = castbar:CreateTexture(nil, "OVERLAY")
	local text = castbar:CreateFontString(nil, "OVERLAY")
	text:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")

	castbar.bg = bg
	castbar.Spark = spark
	castbar.Time = time
	castbar.Text = text
	castbar.Icon = icon
	castbar.Shieled = shieled
	castbar.CustomTimeText = CastTimeText

	if self.style == "player" then
		local safezone = castbar:CreateTexture(nil, "OVERLAY")
		castbar.SafeZone = safezone
	end
	castbar.PostCastStart = CastColor
	castbar.PostChannelStart = CastColor
	self.Castbar = castbar
	castbar.f = f
	return f
end

local function UpdateThreat(self, _, unit)
	local role = UnitGroupRolesAssigned(unit)
	local status = UnitThreatSituation(unit)
	if role ~= "TANK" and status and status > 0 then
		self.ThreatIndicator:SetBackdropBorderColor(GetThreatStatusColor(status))
		self.ThreatIndicator:Show()
	else
		self.ThreatIndicator:Hide()
	end
end

local threatBackdrop = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
}

local function CreateThreat(self)
	local threat = CreateFrame("Frame", nil, self)
	threat:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	threat:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
	threat:SetBackdrop(threatBackdrop)
	threat:SetFrameLevel(1)
	threat:Hide()
	self.ThreatIndicator = threat
	self.ThreatIndicator.Override = UpdateThreat
end

local function CreateBuffIndicators(self)
	local buffs = {}
	for i=1, 4 do
		local button = CreateFrame("Button", nil, self)
		buffs[i] = button
		local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		cd:SetAllPoints()
		cd:SetHideCountdownNumbers(true)
		cd:SetReverse(true)
		--B:SetupCooldown(cd,12) -- enable cd text
		button.cd = cd
		local icon = button:CreateTexture(nil, "OVERLAY")
		icon:SetAllPoints()
		button.icon = icon
		local countFrame = CreateFrame("Frame", nil, button)
		countFrame:SetAllPoints(button)
		countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)
		local count = countFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		count:SetPoint("BOTTOMRIGHT", countFrame, "BOTTOMRIGHT", -1, 0)
		button.count = count
	end
	buffs[1]:SetPoint("TOPLEFT",self.Health)
	buffs[2]:SetPoint("TOPRIGHT",self.Health)
	buffs[3]:SetPoint("BOTTOMLEFT",self.Health)
	buffs[4]:SetPoint("BOTTOMRIGHT",self.Health)
	self.BuffIndicators = buffs
end

function C:UFUpdate(unit, frame)
	local self = frame or C.UF[unit]
	local unitType = unit:match("%D+")
	local db = C.roleDB.unitFrames[unitType]
	self:SetSize(db.width,db.height)
	if C.mover[self] then
		local x, y
		if unitType == "boss" then
			x, y = db.width, (db.height + db.castbarHeight + floor(db.width / db.aurasPerRow) * 2) * MAX_BOSS_FRAMES
		else
			x, y = db.width, db.height
		end
		B:ResizeMover(self,x,y)
	end
	if C.UF.ResetPoint[unitType] then C.UF.ResetPoint[unitType](self,unit) end
	if db.powerHeight >= db.height then db.powerHeight = db.height - 1 end
	local healthWidth, healthHeight = db.width,db.height - db.powerHeight
	local health, healthPredict, otherHealthPredict, absorb, healAbsorb, overAbsorb = self.Health, self.HealthPrediction.myBar, self.HealthPrediction.otherBar, self.HealthPrediction.absorbBar, self.HealthPrediction.healAbsorbBar, self.HealthPrediction.overAbsorb
	health:SetHeight(healthHeight)
	healthPredict:SetSize(healthWidth, healthHeight)
	otherHealthPredict:SetSize(healthWidth, healthHeight)
	absorb:SetSize(healthWidth, healthHeight)
	healAbsorb:SetSize(healthWidth, healthHeight)
	overAbsorb:SetSize(10,healthHeight)

	local power = self.Power
	power:SetHeight(db.powerHeight)

	local buffs, debuffs, aurasPerRow, rows, auraVert = self.Buffs, self.Debuffs, db.aurasPerRow, self.auraRows or 2, self.auraVert
	if buffs then
		if self.style == "raid" then
			buffs.size = db.auraSize
			debuffs.size = db.auraSize
		else
			buffs.size = auraVert and db.height/2 or floor(healthWidth / aurasPerRow)
			debuffs.size = auraVert and db.height/2 or floor(healthWidth / aurasPerRow)
		end
		buffs.num = aurasPerRow * rows
		buffs.iconsPerRow = aurasPerRow
		buffs:SetSize(buffs.size * aurasPerRow, buffs.size * rows)
		debuffs.num = aurasPerRow * rows
		debuffs.iconsPerRow = aurasPerRow
		debuffs:SetSize(buffs.size * aurasPerRow, buffs.size * rows)
		-- HACK: Force reset auras points after db loading/ config change.
		-- Sometimes widget size is not prepared and setpoint offset is -nan, which makes auras not showing if they exist at reloading but newly get auras are fine.
		buffs.anchoredIcons = 0
		debuffs.anchoredIcons = 0
		-- end of hack
	end

	local castbar = self.Castbar
	if castbar then
		local castbarWidth, castbarHeight = db.castbarWidth or healthWidth, db.castbarHeight
		local f, spark, time, icon, shieled, text = castbar.f, castbar.Spark, castbar.Time, castbar.Icon, castbar.Shieled, castbar.Text
		f:SetSize(castbarWidth,castbarHeight)
		if C.mover[f] then B:ResizeMover(f) end
		castbar:SetSize(castbarWidth-castbarHeight, castbarHeight)
		castbar:ClearAllPoints()
		castbar:SetPoint("TOPLEFT",f,"TOPLEFT",castbarHeight,0)
		spark:SetSize(castbarHeight/3,castbarHeight)
		time:ClearAllPoints()
		time:SetPoint("RIGHT", castbar)
		icon:SetSize(castbarHeight,castbarHeight)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", f, "TOPLEFT")
		shieled:SetSize(castbarHeight, castbarHeight)
		shieled:ClearAllPoints()
		shieled:SetPoint("CENTER", icon)
		text:ClearAllPoints()
		text:SetPoint("LEFT", icon,"RIGHT")
	end

	local buffIndicators = self.BuffIndicators
	if buffIndicators then
		for i=1, 4 do buffIndicators[i]:SetSize(db.buffIndicatorsSize, db.buffIndicatorsSize) end
	end
end

function C:UFGroupUpdate(unit)
	for _, f in pairs(oUF.objects) do
		if f.style == unit then C:UFUpdate(unit, f) end
	end
	local db = C.roleDB.unitFrames[unit]
	local x, y
	if unit == "party" then
		x, y = db.width, (db.castbarHeight + db.height) * 5 + 2
	elseif unit == "raid" then
		x, y = db.width * 8, db.height * 5
	end
	B:ResizeMover(C.UF[unit],x,y)
	if unit == "raid" then
		for i=1, 8 do C.UF:UpdateRaidHeaders(i) end
	end
end

-- Create Style
local function CreatePlayerStyle(self)
	self.style = "player"
	self:SetSize(C.roleDB.unitFrames.player.width,C.roleDB.unitFrames.player.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText
	local health, healthText = CreateHealth(self)
	healthText:SetPoint("BOTTOMLEFT",health,"BOTTOMLEFT", 1, 2)

	local powerText = CreatePower(self)
	powerText:SetPoint("BOTTOMRIGHT",self.Health,"BOTTOMRIGHT", -1, 2)

	-- icons
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
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	-- Player Buffs Rules
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
	-- Player Debuffs Rules
	-- 1. block blacklist
	-- 2. pass others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		return true
	end

	-- Castbar
	local castbarWidth, castbarHeight = C.roleDB.unitFrames.player.castbarWidth, C.roleDB.unitFrames.player.castbarHeight
	local f = CreateCastbar(self)
	f:SetSize(castbarWidth,castbarHeight)
	B:SetupMover(f, "PlayerCastBar",L["PlayerCastbar"],true)

	-- Threat - Player
	CreateThreat(self)
	local threatText = self.upperFrame:CreateFontString()
	threatText:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	threatText:SetPoint("TOPRIGHT",self.Health,"TOPRIGHT", 0, 0)
	self:Tag(threatText, "[threatcolor][threatPerc:Player]")
end

local function CreateTargetStyle(self)
	self.style = "target"
	self:SetSize(C.roleDB.unitFrames.target.width,C.roleDB.unitFrames.target.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText
	local health, healthText = CreateHealth(self)
	healthText:SetPoint("BOTTOMLEFT",health,"BOTTOMLEFT", 1, 2)

	local powerText = CreatePower(self)
	powerText:SetPoint("BOTTOMRIGHT",self.Health,"BOTTOMRIGHT", -1, 2)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("TOP",health,"TOP", 0, 0)
	self:Tag(name, "[colorlvl] [colorname]")
	self.nameText = name

	-- icons
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
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	-- Target Buffs Rules
	-- 1. block blacklist
	-- 2. pass others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		return true
	end
	-- Target Debuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass yours
	-- 4. pass raiddebuffs
	-- 5. pass pvpdebuffs
	-- 6. block other players ->(3)-> block players
	-- 7. pass others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, source, _, _, spellId, _, _, castByPlayer) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if source and UnitIsUnit(source, "player") then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		if castByPlayer then return false end
		return true
	end

	-- Castbar
	local castbarWidth, castbarHeight = C.roleDB.unitFrames.target.castbarWidth, C.roleDB.unitFrames.target.castbarHeight
	local f = CreateCastbar(self)
	f:SetSize(castbarWidth,castbarHeight)
	B:SetupMover(f, "TargetCastBar",L["TargetCastBar"],true)
end

local function CreateTargetTargetStyle(self)
	self.style = "targettarget"
	self:SetSize(C.roleDB.unitFrames.targettarget.width,C.roleDB.unitFrames.targettarget.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health
	local health = CreateHealth(self, false)

	CreatePower(self, false)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("CENTER",health)
	self:Tag(name, "[colorname]")
	self.nameText = name

	-- icons
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

	-- auras
	local buffs, debuffs = CreateAuras(self)
	buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	-- TargetTarget Buffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. block others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		return false
	end
	-- TargetTarget Debuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass yours
	-- 4. pass raiddebuffs
	-- 5. pass pvpdebuffs
	-- 6. block other players ->(3)-> block players
	-- 7. pass others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, source, _, _, spellId, _, _, castByPlayer) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if source and UnitIsUnit(source, "player") then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		if castByPlayer then return false end
		return true
	end
end

local function CreatePetStyle(self)
	self.style = "pet"
	self:SetSize(C.roleDB.unitFrames.pet.width,C.roleDB.unitFrames.pet.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText
	local healthWidth = C.roleDB.unitFrames.pet.width
	local health, healthText = CreateHealth(self)
	healthText:SetPoint("BOTTOMLEFT",health,"BOTTOMLEFT", 1, 2)

	local powerText = CreatePower(self)
	powerText:SetPoint("BOTTOMRIGHT",self.Health,"BOTTOMRIGHT", -1, 2)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("TOP",health,"TOP", 0, 0)
	self:Tag(name, "[colorname]")
	self.nameText = name

	-- icons
	local mark = upperFrame:CreateTexture(nil, "OVERLAY")
	mark:SetPoint("CENTER",self,"TOP")
	mark:SetSize(12,12)
	self.RaidTargetIndicator = mark

	-- auras
	local buffs, debuffs = CreateAuras(self)
	buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	-- Pet Buffs Rules
	-- 1. block blacklist
	-- 2. pass others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		return true
	end
	-- Pet Debuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass yours
	-- 4. pass raiddebuffs
	-- 5. pass pvpdebuffs
	-- 6. block other players ->(3)-> block players
	-- 7. pass others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, source, _, _, spellId, _, _, castByPlayer) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if source and UnitIsUnit(source, "player") then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		if castByPlayer then return false end
		return true
	end

	-- Castbar
	local castbarHeight = C.roleDB.unitFrames.pet.castbarHeight
	local f = CreateCastbar(self)
	f:SetSize(healthWidth,castbarHeight)
	f:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
end

local function CreateBossStyle(self)
	self.style = "boss"
	self:SetSize(C.roleDB.unitFrames.boss.width,C.roleDB.unitFrames.boss.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText
	local healthWidth = C.roleDB.unitFrames.boss.width
	local health, healthText = CreateHealth(self)
	healthText:SetPoint("BOTTOMLEFT",health,"BOTTOMLEFT", 1, 2)

	local powerText = CreatePower(self)
	powerText:SetPoint("BOTTOMRIGHT",self.Health,"BOTTOMRIGHT", -1, 2)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("TOP",health,"TOP", 0, 0)
	self:Tag(name, "[colorlvl] [colorname]")
	self.nameText = name

	-- icons
	local mark = upperFrame:CreateTexture(nil, "OVERLAY")
	mark:SetPoint("CENTER",self,"TOP")
	mark:SetSize(12,12)
	self.RaidTargetIndicator = mark

	-- auras
	local buffs, debuffs = CreateAuras(self)
	self.auraRows = 1
	buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 0)
	-- Boss Buffs Rules
	-- 1. block blacklist
	-- 2. pass others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		return true
	end
	-- Boss Debuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass yours
	-- 4. pass raiddebuffs
	-- 5. pass pvpdebuffs
	-- 6. block other players ->(3)-> block players
	-- 7. pass others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, source, _, _, spellId, _, _, castByPlayer) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if source and UnitIsUnit(source, "player") then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		if castByPlayer then return false end
		return true
	end

	-- Castbar
	local castbarHeight = C.roleDB.unitFrames.boss.castbarHeight
	local f = CreateCastbar(self)
	f:SetSize(healthWidth,castbarHeight)
	f:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
end

local function CreatePartyStyle(self)
	self.style = "party"
	self:SetSize(C.roleDB.unitFrames.party.width,C.roleDB.unitFrames.party.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText
	local healthWidth = C.roleDB.unitFrames.party.width
	local health, healthText = CreateHealth(self)
	healthText:SetPoint("CENTER",health,"CENTER", 0,0)

	local powerText = CreatePower(self)
	powerText:SetPoint("CENTER",self.Health,"CENTER", 0, -10)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("CENTER",health,"CENTER", 0, 10)
	self:Tag(name, "[colorlvl:smart] [colorname]")
	self.nameText = name

	-- icons
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
	local role = upperFrame:CreateTexture(nil, "OVERLAY")
	role:SetPoint("LEFT", self, "LEFT", 0, 0)
	role:SetSize(12, 12)
	self.GroupRoleIndicator = role

	-- auras
	local buffs, debuffs = CreateAuras(self)
	buffs.PostUpdate = nil
	self.auraRows = 1
	self.auraVert = true
	buffs:SetPoint("TOPLEFT", health, "TOPRIGHT", 0, 0)
	debuffs:SetPoint("TOPLEFT", buffs, "BOTTOMLEFT", 0, 0)
	-- Party Buffs Rules
	-- 1. block blacklist
	-- 2. pass defensebuffs
	-- 3. block others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.defenseBuffs[spellId] then return true end
		return false
	end
	-- Party Debuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass raiddebuffs
	-- 4. pass pvpdebuffs
	-- 5. block others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		return false
	end
	--buffs.disableMouse = true
	--debuffs.disableMouse = true

	-- Castbar
	local castbarHeight = C.roleDB.unitFrames.party.castbarHeight
	local f = CreateCastbar(self)
	f:SetSize(healthWidth,castbarHeight)
	f:SetPoint("TOPLEFT", self, "BOTTOMLEFT")

	-- Range alpha
	self.Range = {
        insideAlpha = 1,
        outsideAlpha = 1/2,
	}

	-- Buff indicators
	CreateBuffIndicators(self)

	self:RegisterForClicks("AnyUp")
end

local function CreateRaidStyle(self)
	self.style = "raid"
	self:SetSize(C.roleDB.unitFrames.raid.width,C.roleDB.unitFrames.raid.height)
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	-- health, healthText
	local health, healthText = CreateHealth(self)
	healthText:SetPoint("CENTER",health,"CENTER", 0,0)

	local powerText = CreatePower(self)
	powerText:SetPoint("CENTER",self.Health,"CENTER", 0, -10)

	-- name
	local name = upperFrame:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	name:SetPoint("CENTER",health,"CENTER", 0, 10)
	self:Tag(name, "[colorlvl:smart] [colorname]")
	self.nameText = name

	-- icons
	local mark = upperFrame:CreateTexture(nil, "OVERLAY")
	mark:SetPoint("CENTER",self,"TOP")
	mark:SetSize(12,12)
	self.RaidTargetIndicator = mark
	local leader = upperFrame:CreateTexture(nil, "OVERLAY")
	leader:SetPoint("LEFT",self,"LEFT",12,0)
	leader:SetSize(12, 12)
	self.LeaderIndicator = leader
	local assistant = upperFrame:CreateTexture(nil, "OVERLAY")
	assistant:SetPoint("LEFT",self,"LEFT",12,0)
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
	local role = upperFrame:CreateTexture(nil, "OVERLAY")
	role:SetPoint("LEFT", self, "LEFT", 0, 0)
	role:SetSize(12, 12)
	self.GroupRoleIndicator = role

	-- auras
	local buffs, debuffs = CreateAuras(self)
	self.auraRows = 1
	buffs.PostUpdate = nil
	buffs["growth-x"] = "LEFT"
	debuffs:SetPoint("LEFT", health, "CENTER", 0, 0)
	buffs:SetPoint("RIGHT", debuffs, "RIGHT", 0, 0)
	-- Raid Buffs Rules
	-- 1. block blacklist
	-- 2. pass raidBuffs
	-- 3. block others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if C.auras.raidBuffs[spellId] then return true end
		return false
	end
	-- Raid Debuffs Rules
	-- 1. block blacklist
	-- 2. pass whitelist
	-- 3. pass raiddebuffs
	-- 4. pass pvpdebuffs
	-- 5. block others
	debuffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if C.auras.raidDebuffs[spellId] then return true end
		if C.auras.pvpDebuffs[spellId] then return true end
		return false
	end
	buffs.disableMouse = true
	debuffs.disableMouse = true

	-- Range alpha
	self.Range = {
        insideAlpha = 1,
        outsideAlpha = 1/2,
	}

	-- Buff indicators
	CreateBuffIndicators(self)

	self:RegisterForClicks("AnyUp")
end

-- Config
C.UF.ResetPoint = {}
function C.UF.ResetPoint.boss(self, unit)
	local yOffset = C.roleDB.unitFrames.boss.height + C.roleDB.unitFrames.boss.castbarHeight + floor(C.roleDB.unitFrames.boss.width / C.roleDB.unitFrames.boss.aurasPerRow) * 2
	local i = tonumber(unit:match("%d+"))
	if i ~= 1 then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT",C.UF["boss1"],"TOPLEFT",0,-yOffset*(i-1))
	end
end

function C.UF.ResetPoint.party(self)
	local idx = 0
	local health = self.Health
	if C.roleDB.unitFrames.party.healthText then idx = idx + 1 end
	if C.roleDB.unitFrames.party.powerText then idx = idx + 1 end
	idx = idx / 2

	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("CENTER",health,"CENTER", 0, idx*13)
	if C.roleDB.unitFrames.party.healthText then
		self.healthValue:ClearAllPoints()
		idx = idx - 1
		self.healthValue:SetPoint("CENTER",health,"CENTER", 0, idx*13)
		self.healthValue:Show()
	else
		self.healthValue:Hide()
	end
	if C.roleDB.unitFrames.party.powerText then
		self.PowerValue:ClearAllPoints()
		idx = idx - 1
		self.PowerValue:SetPoint("CENTER",health,"CENTER", 0, idx*13)
		self.PowerValue:Show()
	else
		self.PowerValue:Hide()
	end
end

function C.UF.ResetPoint.raid(self)
	local idx = 0
	local health = self.Health
	if C.roleDB.unitFrames.raid.healthText then idx = idx + 1 end
	if C.roleDB.unitFrames.raid.powerText then idx = idx + 1 end
	idx = idx / 2

	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("CENTER",health,"CENTER", 0, idx*13)
	if C.roleDB.unitFrames.raid.healthText then
		self.healthValue:ClearAllPoints()
		idx = idx - 1
		self.healthValue:SetPoint("CENTER",health,"CENTER", 0, idx*13)
		self.healthValue:Show()
	else
		self.healthValue:Hide()
	end
	if C.roleDB.unitFrames.raid.powerText then
		self.PowerValue:ClearAllPoints()
		idx = idx - 1
		self.PowerValue:SetPoint("CENTER",health,"CENTER", 0, idx*13)
		self.PowerValue:Show()
	else
		self.PowerValue:Hide()
	end
end

function C.UF:UpdateRaidHeaders(idx)
	local self = C.UF["raid"..idx]
	local xOffset = C.roleDB.unitFrames.raid.width
	if idx ~= 1 then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT",C.UF["raid1"],"TOPLEFT",xOffset*(idx-1),0)
	end
end

B:AddInitScript(function()
	-- Player
	oUF:RegisterStyle("player", CreatePlayerStyle)
	oUF:SetActiveStyle("player")
	local playerFrame = oUF:Spawn("player")
	B:SetupMover(playerFrame, "PlayerFrame",L["PlayerFrame"],true)
	playerFrame:RegisterForClicks("AnyUp")
	C.UF.player = playerFrame

	-- Target
	oUF:RegisterStyle("target", CreateTargetStyle)
	oUF:SetActiveStyle("target")
	local targetFrame = oUF:Spawn("target")
	B:SetupMover(targetFrame, "TargetFrame",L["TargetFrame"],true)
	targetFrame:RegisterForClicks("AnyUp")
	C.UF.target = targetFrame

	-- TargetTarget
	oUF:RegisterStyle("targettarget", CreateTargetTargetStyle)
	oUF:SetActiveStyle("targettarget")
	local targettargetFrame = oUF:Spawn("targettarget")
	B:SetupMover(targettargetFrame, "TargetTargetFrame",L["TargetTargetFrame"],true)
	targettargetFrame:RegisterForClicks("AnyUp")
	C.UF.targettarget = targettargetFrame

	-- Pet
	oUF:RegisterStyle("pet", CreatePetStyle)
	oUF:SetActiveStyle("pet")
	local petFrame = oUF:Spawn("pet")
	B:SetupMover(petFrame, "PetFrame",L["PetFrame"],true)
	petFrame:RegisterForClicks("AnyUp")
	C.UF.pet = petFrame

	-- Boss
	oUF:RegisterStyle("boss", CreateBossStyle)
	oUF:SetActiveStyle("boss")
	for i=1, MAX_BOSS_FRAMES do
		local bossFrame = oUF:Spawn("boss"..i)
		bossFrame:RegisterForClicks("AnyUp")
		if i == 1 then
			B:SetupMover(bossFrame, "BossFrame",L["BossFrame"],true)
		end
		C.UF["boss"..i] = bossFrame
	end

	-- Party
	oUF:RegisterStyle("party", CreatePartyStyle)
	oUF:SetActiveStyle("party")
	-- https://wow.gamepedia.com/SecureGroupHeaderTemplate
	local partyFrame = oUF:SpawnHeader("oUF_Party", nil, "solo,party",
		"showPlayer", true,
		"showSolo", false,
		"showParty", true,
		"showRaid", false,
		"groupBy", "ASSIGNEDROLE",
		"groupingOrder", "TANK,HEALER,DAMAGER,NONE",
		"point", "BOTTOM", -- BOTTOM for vert, LEFT for horz
		"columnAnchorPoint", "LEFT",
		"yOffset", C.roleDB.unitFrames.party.castbarHeight,
		"oUF-initialConfigFunction", format([[self:SetWidth(%d); self:SetHeight(%d)]], C.roleDB.unitFrames.party.width, C.roleDB.unitFrames.party.height)
	)
	B:SetupMover(partyFrame, "PartyFrame",L["PartyFrame"],true)
	C.UF["party"] = partyFrame

	-- Raid
	oUF:RegisterStyle("raid", CreateRaidStyle)
	oUF:SetActiveStyle("raid")
	for i=1, 8 do
		-- https://wow.gamepedia.com/SecureGroupHeaderTemplate
		local raidFrame = oUF:SpawnHeader("oUF_Raid"..i, nil, "solo,raid",
			"showPlayer", true,
			"showSolo", false,
			"showParty", true,
			"showRaid", true,
			"groupFilter", tostring(i),
			"groupBy", "ASSIGNEDROLE",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"point", "BOTTOM", -- BOTTOM for vert, LEFT for horz
			"columnAnchorPoint", "LEFT",
			"unitsPerColumn", 5,
			"oUF-initialConfigFunction", format([[self:SetWidth(%d); self:SetHeight(%d)]], C.roleDB.unitFrames.raid.width, C.roleDB.unitFrames.raid.height)
		)
		if i == 1 then
			B:SetupMover(raidFrame, "RaidFrame",L["RaidFrame"],true)
			C.UF["raid"] = raidFrame
		end
		C.UF["raid"..i] = raidFrame
		raidFrame.GroupNum = i
	end

	C:UFUpdate("player")
	C:UFUpdate("target")
	C:UFUpdate("targettarget")
	C:UFUpdate("pet")
	for i=1, MAX_BOSS_FRAMES do
		C:UFUpdate("boss"..i)
	end
	C:UFGroupUpdate("party")
	C:UFGroupUpdate("raid")
	oUF:RegisterInitCallback(function(self)
		local style = self.style
		if style == "raid" or style == "party" then
			C:UFUpdate(style, self)
			C.UF.ResetPoint[style](self, self.unit)
		end
	end)

	local f = CreateFrame("Frame")
	f:SetSize(256,64)
	B:SetupMover(f, "PlayerPowerBarAlt",L["PlayerPowerBarAlt"])
	hooksecurefunc(PlayerPowerBarAlt, "SetPoint", function(self, _, parent)
		if parent ~= f then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", f)
		end
	end)
	hooksecurefunc("UnitPowerBarAlt_SetUp", function(self)
		local statusFrame = self.statusFrame
		if statusFrame.enabled then
			statusFrame:Show()
			statusFrame.Hide = statusFrame.Show
		end
	end)

	-- hide blz raid
	if CompactRaidFrameManager_SetSetting then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
		CompactRaidFrameManager:UnregisterAllEvents()
		CompactRaidFrameManager:SetParent(B.hider)
	end
end)
