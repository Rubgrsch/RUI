local _, rui = ...
local B, L, C = unpack(rui)

local oUF = rui.oUF

local function UpdateColor(element, unit)
	local r, g, b
	if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) or not UnitIsConnected(unit) then
		r, g, b = 0.7, 0.7, 0.7
	elseif UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
		end
	else
		r, g, b = UnitSelectionColor(unit, true)
		r, g, b = r * 0.8, g * 0.8, b * 0.8
	end

	if r then
		element:SetStatusBarColor(r, g, b)
	end
end

local function PostCreateIcon(_, icon)
	local cooldown = _G[icon:GetName().."Cooldown"]
	B:SetupCooldown(cooldown,8)
	cooldown:SetReverse(true)
	local count = icon.count
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT")
	count:SetFont(STANDARD_TEXT_FONT, 8, "OUTLINE")
	local stealable = icon.stealable
	stealable:ClearAllPoints()
	stealable:SetPoint("TOPLEFT", -2, 2)
	stealable:SetPoint("BOTTOMRIGHT", 2, -2)
	icon.cooldown = cooldown
end
local function CastTimeText(self,duration)
	return self.Time:SetFormattedText("%.2f", self.max - duration)
end
local function CastColor(self)
	if self.notInterruptible then self:SetStatusBarColor(0.6,0.3,0.3) else self:SetStatusBarColor(0.3,0.3,0.3) end
end

local function UpdateNP(self)
	local db = C.roleDB.nameplates
	
	local healthWidth, healthHeight = db.width,db.height
	local health, healthPredict, otherHealthPredict, absorb, healAbsorb, overAbsorb = self.Health, self.HealthPrediction.myBar, self.HealthPrediction.otherBar, self.HealthPrediction.absorbBar, self.HealthPrediction.healAbsorbBar, self.HealthPrediction.overAbsorb
	self:SetSize(healthWidth, healthHeight)
	healthPredict:SetSize(healthWidth, healthHeight)
	otherHealthPredict:SetSize(healthWidth, healthHeight)
	absorb:SetSize(healthWidth, healthHeight)
	healAbsorb:SetSize(healthWidth, healthHeight)
	overAbsorb:SetSize(10,healthHeight)

	local buffs, debuffs, aurasPerRow = self.Buffs, self.Debuffs, db.aurasPerRow
	buffs.size = floor(healthWidth / aurasPerRow)
	debuffs.size = floor(healthWidth / aurasPerRow)
	buffs.num = aurasPerRow
	buffs:SetSize(buffs.size * aurasPerRow, buffs.size)
	debuffs.num = aurasPerRow
	debuffs:SetSize(buffs.size * aurasPerRow, buffs.size)
	-- HACK: Force reset auras points after db loading/ config change.
	-- Sometimes widget size is not prepared and setpoint offset is -nan, which makes auras not showing if they exist at reloading but newly get auras are fine.
	buffs.anchoredIcons = 0
	debuffs.anchoredIcons = 0
	-- end of hack

	local castbar = self.Castbar
	local castbarWidth, castbarHeight = healthWidth, db.castbarHeight
	local f, spark, time, icon, shieled, text = castbar.f, castbar.Spark, castbar.Time, castbar.Icon, castbar.Shieled, castbar.Text
	castbar:SetSize(healthWidth-castbarHeight, castbarHeight)
	castbar:SetPoint("TOPLEFT",f,"TOPLEFT",castbarHeight,0)
	spark:SetSize(castbarHeight/3,castbarHeight)
	time:SetPoint("RIGHT", castbar)
	icon:SetSize(castbarHeight,castbarHeight)
	icon:SetPoint("TOPLEFT", f, "TOPLEFT")
	shieled:SetSize(castbarHeight, castbarHeight)
	shieled:SetPoint("CENTER", icon)
	text:SetPoint("LEFT", icon,"RIGHT")
	f:SetSize(healthWidth,castbarHeight)
	f:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
end

function C:NPUpdate()
	for _, f in pairs(oUF.objects) do
		if f.style == "nameplates" then
			UpdateNP(f)
		end
	end
end

local function CreatePlates(self)
	local width, height = 100, 4
	self:SetSize(width, height)
	self:SetPoint("CENTER")
	local upperFrame = CreateFrame("Frame",nil,self)
	self.upperFrame = upperFrame

	local health = CreateFrame("StatusBar", nil, self)
	health:SetAllPoints()
	health:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	self.Health = health
	self.Health.UpdateColor = UpdateColor
	local healthbg = health:CreateTexture(nil, "BACKGROUND")
	healthbg:SetAllPoints()
	healthbg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	healthbg:SetVertexColor(0.1,0.1,0.1,0.7)

	local healthText = upperFrame:CreateFontString()
	healthText:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	--healthText:SetPoint("BOTTOMRIGHT",health,"TOPRIGHT",0,2)
	healthText:SetPoint("CENTER",health)
	self:Tag(healthText, "[hp]")
	self.healthValue = healthText

	-- healthpredict
	local healthPredict = CreateFrame("StatusBar", nil, health)
	healthPredict:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT")
	healthPredict:SetSize(width, height)
	healthPredict:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	healthPredict:SetStatusBarColor(0, 0.8, 0.5, 0.5)
	local otherHealthPredict = CreateFrame("StatusBar", nil, health)
	otherHealthPredict:SetPoint("TOPLEFT", healthPredict:GetStatusBarTexture(), "TOPRIGHT")
	otherHealthPredict:SetSize(width, height)
	otherHealthPredict:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	otherHealthPredict:SetStatusBarColor(0, 0.8, 0.5, 0.5)
	local absorb = CreateFrame("StatusBar", nil, health)
	absorb:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT")
	absorb:SetSize(width, height)
	absorb:SetAlpha(0.5)
	absorb:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	absorb:SetStatusBarColor(0.9, 1, 1, 0.5)
	local healAbsorb = CreateFrame("StatusBar", nil, health)
	healAbsorb:SetPoint("TOPRIGHT", healthPredict:GetStatusBarTexture())
	healAbsorb:SetSize(width, height)
	healAbsorb:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
	local overAbsorb = health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetPoint("TOPLEFT", health, "TOPRIGHT", -4, 0)
	overAbsorb:SetAlpha(0.8)
	overAbsorb:SetSize(10,height)
	self.HealthPrediction = {
		myBar = healthPredict,
		otherBar = otherHealthPredict,
		absorbBar = absorb,
		healAbsorbBar = healAbsorb,
		overAbsorb = overAbsorb,
		maxOverflow = 1,
	}

	-- name
	local name = self:CreateFontString()
	name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	name:SetPoint("BOTTOMLEFT",health,"TOPLEFT", 0, 2)
	self:Tag(name, "[colorlvl:high ][name]")
	self.nameText = name

	-- auras
	local buffs = CreateFrame("Frame", nil, self)
	buffs.initialAnchor = "BOTTOMLEFT"
	buffs.showStealableBuffs = true
	buffs["growth-x"] = "RIGHT"
	buffs["growth-y"] = "UP"
	buffs.PostCreateIcon = PostCreateIcon
	local debuffs = CreateFrame("Frame", nil, self)
	debuffs.initialAnchor = "BOTTOMRIGHT"
	debuffs["growth-x"] = "LEFT"
	debuffs["growth-y"] = "UP"
	debuffs.showDebuffType = true
	debuffs.PostCreateIcon = PostCreateIcon

	self.Buffs = buffs
	self.Debuffs = debuffs

	buffs:SetPoint("BOTTOMLEFT", health, "TOPLEFT", 0, 12)
	debuffs:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 0, 12)
	-- NP Buffs Rules
	-- 1. block blacklist
	-- 2. pass whiteList
	-- 3. pass raidBuffs
	-- 4. pass defenseBuffs
	-- 5. block others
	buffs.CustomFilter = function(_, _, _, _, _, _, _, _, _, _, _, _, spellId) -- self, unit, button, UnitAura()
		if C.auras.blackList[spellId] then return false end
		if C.auras.whiteList[spellId] then return true end
		if C.auras.raidBuffs[spellId] then return true end
		if C.auras.defenseBuffs[spellId] then return true end
		return false
	end
	-- NP Debuffs Rules
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
	time:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	local icon = castbar:CreateTexture(nil, "OVERLAY")
    local shieled = castbar:CreateTexture(nil, "OVERLAY")
	local text = castbar:CreateFontString(nil, "OVERLAY")
	text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")

	castbar.bg = bg
	castbar.Spark = spark
	castbar.Time = time
	castbar.Text = text
	castbar.Icon = icon
	castbar.Shieled = shieled
	castbar.CustomTimeText = CastTimeText
	castbar.PostCastStart = CastColor
	castbar.PostChannelStart = CastColor
	castbar.f = f
	self.Castbar = castbar

	-- target indicators
	local targetIndicators = CreateFrame("Frame",nil,self)
	targetIndicators:Hide()
	local arrowLeft = targetIndicators:CreateTexture(nil, "OVERLAY")
	arrowLeft:SetPoint("RIGHT",health,"LEFT")
	arrowLeft:SetSize(32,32)
	arrowLeft:SetTexture("Interface\\MINIMAP\\MiniMap-VignetteArrow")
	arrowLeft:SetRotation(math.pi * 1.5)
	arrowLeft:SetAlpha(0.8)
	local arrowRight = targetIndicators:CreateTexture(nil, "OVERLAY")
	arrowRight:SetPoint("LEFT",health,"RIGHT")
	arrowRight:SetSize(32,32)
	arrowRight:SetTexture("Interface\\MINIMAP\\MiniMap-VignetteArrow")
	arrowRight:SetRotation(math.pi * 0.5)
	arrowRight:SetAlpha(0.8)
	self.TargetIndicator = targetIndicators

	-- DeathTimer
	local deathTimer = CreateFrame("Frame", nil, self)
	deathTimer:SetPoint("BOTTOM",self,"TOP", 0, 6)
	deathTimer:SetSize(150,25)
	local dtText = deathTimer:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	dtText:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	dtText:SetAllPoints()
	self.DeathTimer = deathTimer
	self.DeathTimer.text = dtText
end

local function Callback(self, event, unit)
	if event == "NAME_PLATE_UNIT_ADDED" then
		if UnitIsUnit(unit, "target") then
			self.TargetIndicator:Show()
		else
			self.TargetIndicator:Hide()
		end
	end
end

B:AddInitScript(function()
	if C.roleDB.nameplates.enable then
		oUF:RegisterStyle("nameplates", CreatePlates)
		oUF:SetActiveStyle("nameplates")
		oUF:SpawnNamePlates("oUF_NPs", Callback)
		C:NPUpdate()
		oUF:RegisterInitCallback(function(self)
			local style = self.style
			if style == "nameplates" then
				C:NPUpdate()
			end
		end)
	end
end)
