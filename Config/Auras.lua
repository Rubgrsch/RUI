local _, rui = ...
local B, L, C = unpack(rui)

local blackList = {
}

local whiteList = {
}

local raidBuffs = {
}

local raidDebuffs = {
	-- Shadowlands Dungeon
	-- Sanguine Depths
	-- Spires of Ascension
	-- The Necrotic Wake
	-- Halls of Atonement
	-- Plaguefall
	-- Mists of Tirna Scithe
	-- De Other Side
	-- Theater of Pain

	-- Shadowlands Raid
	-- Castle Nathria
}

local playerBuffs = {
}

local defenseBuffs = {
}

local pvpDebuffs = {
}

-- Default buff indicator (corners of party/raid)
-- [specID] = {[buffids] = CornerID}
local buffIndicators = {
	--[263] = {[269279] = 1}, -- test: enhancement
}

-- Default auras data
local auras = {
	["blackList"] = blackList,
	["whiteList"] = whiteList,
	["raidBuffs"] = raidBuffs,
	["raidDebuffs"] = raidDebuffs,
	["playerBuffs"] = playerBuffs,
	["defenseBuffs"] = defenseBuffs,
	["pvpDebuffs"] = pvpDebuffs,
}

B:AddInitScript(function()
	local specID = GetSpecializationInfo(GetSpecialization())
	-- Buff indicators
	C.buffIndicators = buffIndicators[specID] or {}
	-- copy auras to config
	C.auras = {}
	for k,v in pairs(auras) do
		for kk,vv in pairs(C.db.auras[k]) do v[kk] = vv end
		C.auras[k] = v
	end
end)
