local _, rui = ...
local B, L, C = unpack(rui)

local blackList = {
}

local whiteList = {
}

local raidBuffs = {
	[1022] = true,
	[6940] = true,
	[1044] = true,
	[77761] = true,
	[77764] = true,
	[31821] = true,
	[97463] = true,
	[64843] = true,
	[64901] = true,
	[81782] = true,
	[29166] = true,
	[47788] = true,
	[33206] = true,
	[53563] = true,
	[98007] = true,
	[223658] = true,
	[115310] = true,
	[116849] = true,
	[204018] = true,
	[102342] = true,
	[156910] = true,
	[192082] = true,
	[201633] = true,
	[207498] = true,
	[238698] = true,
	[209426] = true,
}

local raidDebuffs = {
	-- Shadowlands Dungeon
	-- Sanguine Depths
	[326827] = true,
	[326836] = true,
	[322554] = true,
	[321038] = true,
	[328593] = true,
	[325254] = true,
	[344993] = true,
	[331415] = true,
	[327814] = true,
	[323845] = true,
	[322429] = true,
	[328494] = true,
	[323573] = true,
	[325885] = true,
	[334653] = true,
	[335306] = true,
	-- Spires of Ascension
	[338729] = true,
	[327481] = true,
	[322818] = true,
	[322817] = true,
	[324154] = true,
	[335805] = true,
	[317661] = true,
	[328331] = true,
	[323195] = true,
	[27638]  = true,
	[338731] = true,
	[330683] = true,
	[331251] = true,
	[327648] = true,
	[331997] = true,
	[317963] = true,
	[317626] = true,
	[323792] = true,
	[341215] = true,
	-- The Necrotic Wake
	[321821] = true,
	[323365] = true,
	[338353] = true,
	[333485] = true,
	[338357] = true,
	[328181] = true,
	[320170] = true,
	[323464] = true,
	[323198] = true,
	[327401] = true,
	[327397] = true,
	[322681] = true,
	[320200] = true,
	[320717] = true,
	[333492] = true,
	[321807] = true,
	[323347] = true,
	[327396] = true,
	[320788] = true,
	[320839] = true,
	[334610] = true,
	[334748] = true,
	[320596] = true,
	[328212] = true,
	[343556] = true,
	[338606] = true,
	[320573] = true,
	[320366] = true,
	[343504] = true,
	[320646] = true,
	-- Halls of Atonement
	[335338] = true,
	[326891] = true,
	[329321] = true,
	[319603] = true,
	[319611] = true,
	[325876] = true,
	[326632] = true,
	[323650] = true,
	[326874] = true,
	[339237] = true,
	[340446] = true,
	[323001] = true,
	[323437] = true,
	[325701] = true,
	[326638] = true,
	[325700] = true,
	[344874] = true,
	-- Plaguefall
	[336258] = true,
	[331818] = true,
	[329110] = true,
	[325552] = true,
	[336301] = true,
	[330069] = true,
	[320512] = true,
	[333406] = true,
	[328365] = true,
	[324652] = true,
	[320072] = true,
	[334926] = true,
	[331399] = true,
	[319070] = true,
	[322358] = true,
	[333353] = true,
	[328180] = true,
	[322410] = true,
	[319120] = true,
	[335090] = true,
	[320542] = true,
	[332397] = true,
	[328501] = true,
	[340355] = true,
	[336306] = true,
	[330135] = true,
	[327882] = true,
	-- Mists of Tirna Scithe
	[325027] = true,
	[323043] = true,
	[322557] = true,
	[331172] = true,
	[322563] = true,
	[341198] = true,
	[321891] = true,
	[325418] = true,
	[340288] = true,
	[326092] = true,
	[326017] = true,
	[325021] = true,
	[325224] = true,
	[322486] = true,
	[323250] = true,
	[323137] = true,
	[328756] = true,
	[322939] = true,
	[321828] = true,
	[322487] = true,
	-- De Other Side
	[320786] = true,
	[334913] = true,
	[325725] = true,
	[328987] = true,
	[334496] = true,
	[339978] = true,
	[323692] = true,
	[333250] = true,
	[322746] = true,
	[323687] = true,
	[334535] = true,
	[334493] = true,
	[327649] = true,
	[332678] = true,
	[320147] = true,
	[333711] = true,
	[331379] = true,
	[323118] = true,
	[321948] = true,
	[320144] = true,
	[323877] = true,
	[332332] = true,
	[320142] = true,
	[324010] = true,
	[331847] = true,
	[331381] = true,
	-- Theater of Pain
	[333299] = true,
	[319539] = true,
	[326892] = true,
	[321768] = true,
	[323825] = true,
	[333231] = true,
	[330532] = true,
	[341949] = true,
	[330700] = true,
	[333708] = true,
	[319567] = true,
	[324449] = true,
	[319626] = true,
	[330725] = true,
	[330810] = true,
	[319521] = true,
	[332836] = true,
	[342675] = true,
	[333861] = true,
	[333540] = true,
	[320248] = true,
	[320679] = true,
	[323750] = true,
	[320180] = true,
	[333301] = true,

	-- Shadowlands Raid
	-- Castle Nathria
}

-- Last update time 20.10.15
local playerBuffs = {
	[5384] = true,
	[18652] = true,
	[34477] = true,
	[109215] = true,
	[186257] = true,
	[199483] = true,
	[266921] = true,
	[281195] = true,
	[2825] = true,
	[2645] = true,
	[260881] = true,
	[8143] = true,
	[108271] = true,
	[546] = true,
	[6196] = true,
	[192106] = true,
	[114052] = true,
	[201633] = true,
	[974] = true,
	[52127] = true,
	[338334] = true,
	[328908] = true,
	[73920] = true,
	[320763] = true,
	[61295] = true,
	[53390] = true,
	[79206] = true,
	[325174] = true,
	[192082] = true,
	[328900] = true,
	[77762] = true,
	[216251] = true,
	[73685] = true,
	[207400] = true,
	[207498] = true,
	[280615] = true,
	[157507] = true,
	[288675] = true,
	[272737] = true,
	[342243] = true,
	[320125] = true,
	[118522] = true,
	[285514] = true,
	[260734] = true,
	[263806] = true,
	[108281] = true,
	[118337] = true,
	[210714] = true,
	[191634] = true,
	[58875] = true,
	[187878] = true,
	[187881] = true,
	[198300] = true,
	[333957] = true,
	[224126] = true,
	[224127] = true,
	[327942] = true,
	[201846] = true,
	[262652] = true,
	[215785] = true,
	[224125] = true,
	[210918] = true,
	[208963] = true,
	[204262] = true,
	[8178] = true,
	[204361] = true,
	[204366] = true,
	[236746] = true,
	[204293] = true,
	[236502] = true,
	[1459] = true,
	[45438] = true,
	[80353] = true,
	[130] = true,
	[32612] = true,
	[110909] = true,
	[116267] = true,
	[321358] = true,
	[116014] = true,
	[198065] = true,
	[11426] = true,
	[190446] = true,
	[44544] = true,
	[205473] = true,
	[12472] = true,
	[205766] = true,
	[108839] = true,
	[278310] = true,
	[206432] = true,
	[198144] = true,
	[327327] = true,
	[327330] = true,
	[235313] = true,
	[190319] = true,
	[48107] = true,
	[48108] = true,
	[157644] = true,
	[236060] = true,
	[269651] = true,
	[203277] = true,
	[203285] = true,
	[333314] = true,
	[333315] = true,
	[12051] = true,
	[12042] = true,
	[263725] = true,
	[110960] = true,
	[113862] = true,
	[235450] = true,
	[205025] = true,
	[210126] = true,
	[236298] = true,
	[321388] = true,
	[321390] = true,
	[264774] = true,
	[276743] = true,
	[198158] = true,
	[198111] = true,
	[332777] = true,
	[337299] = true,
	[337278] = true,
	[336832] = true,
	[182656] = true,
	[6673] = true,
	[262232] = true,
	[18499] = true,
	[190456] = true,
	[180844] = true,
	[23920] = true,
	[32216] = true,
	[336642] = true,
	[132404] = true,
	[97463] = true,
	[180847] = true,
	[235941] = true,
	[147833] = true,
	[330279] = true,
	[335198] = true,
	[1719] = true,
	[181712] = true,
	[184362] = true,
	[81099] = true,
	[184364] = true,
	[335082] = true,
	[280776] = true,
	[202225] = true,
	[202164] = true,
	[280746] = true,
	[85739] = true,
	[46924] = true,
	[199261] = true,
	[329038] = true,
	[213858] = true,
	[335234] = true,
	[184783] = true,
	[7384] = true,
	[29838] = true,
	[197690] = true,
	[334783] = true,
	[248622] = true,
	[107574] = true,
	[262228] = true,
	[198817] = true,
	[236321] = true,
	[871] = true,
	[12975] = true,
	[280001] = true,
	[181709] = true,
	[202602] = true,
	[213871] = true,
	[213915] = true,
	[180842] = true,
	[343672] = true,
	[325787] = true,
	[324867] = true,
	[310143] = true,
	[8936] = true,
	[783] = true,
	[22812] = true,
	[5215] = true,
	[5487] = true,
	[77761] = true,
	[77764] = true,
	[768] = true,
	[192081] = true,
	[276012] = true,
	[276029] = true,
	[1850] = true,
	[252216] = true,
	[319454] = true,
	[305497] = true,
	[209731] = true,
	[191034] = true,
	[24858] = true,
	[29166] = true,
	[194223] = true,
	[48518] = true,
	[48517] = true,
	[157228] = true,
	[202425] = true,
	[202345] = true,
	[102560] = true,
	[343648] = true,
	[209746] = true,
	[234084] = true,
	[106951] = true,
	[5217] = true,
	[69369] = true,
	[135700] = true,
	[61336] = true,
	[52610] = true,
	[102543] = true,
	[252071] = true,
	[145152] = true,
	[232059] = true,
	[202636] = true,
	[50334] = true,
	[22842] = true,
	[93622] = true,
	[155835] = true,
	[213708] = true,
	[102558] = true,
	[203975] = true,
	[213680] = true,
	[329042] = true,
	[258920] = true,
	[187827] = true,
	[263648] = true,
	[203819] = true,
	[209258] = true,
	[162264] = true,
	[343312] = true,
	[196555] = true,
	[198589] = true,
	[196718] = true,
	[208628] = true,
	[337313] = true,
	[208769] = true,
	[206803] = true,
	[227635] = true,
	[46585] = true,
	[48792] = true,
	[3714] = true,
	[47541] = true,
	[48707] = true,
	[51052] = true,
	[61999] = true,
	[49039] = true,
	[48265] = true,
	[327574] = true,
	[337430] = true,
	[51271] = true,
	[49143] = true,
	[47568] = true,
	[207230] = true,
	[521995] = true,
	[194913] = true,
	[152279] = true,
	[55233] = true,
	[49028] = true,
	[194679] = true,
	[195182] = true,
	[221699] = true,
	[212552] = true,
	[48743] = true,
	[194844] = true,
	[42650] = true,
	[275699] = true,
	[63569] = true,
	[207289] = true,
	[73325] = true,
	[586] = true,
	[17] = true,
	[21562] = true,
	[19236] = true,
	[10060] = true,
	[47788] = true,
	[64901] = true,
	[139] = true,
	[41635] = true,
	[64843] = true,
	[64844] = true,
	[77489] = true,
	[27827] = true,
	[45242] = true,
	[47536] = true,
	[33206] = true,
	[81782] = true,
	[194384] = true,
	[198069] = true,
	[15286] = true,
	[232698] = true,
	[47585] = true,
	[194249] = true,
	[341207] = true,
	[114255] = true,
	[321379] = true,
	[200183] = true,
	[121557] = true,
	[65081] = true,
	[265258] = true,
	[193065] = true,
	[280398] = true,
	[322105] = true,
	[109964] = true,
	[319952] = true,
	[321973] = true,
	[341282] = true,
	[123254] = true,
	[327661] = true,
	[327710] = true,
	[327694] = true,
	[321510] = true,
	[321527] = true,
	[342802] = true,
	[320009] = true,
	[342774] = true,
	[320235] = true,
	[320224] = true,
	[320130] = true,
	[319970] = true,
	[337749] = true,
	[337716] = true,
	[337661] = true,
	[111759] = true,
	[337948] = true,
	[343144] = true,
	[338333] = true,
	[213610] = true,
	[215769] = true,
	[289655] = true,
	[232707] = true,
	[213602] = true,
	[328530] = true,
	[329543] = true,
	[197548] = true,
	[197862] = true,
	[197871] = true,
	[290793] = true,
	[196440] = true,
	[247776] = true,
}

-- Last update time 20.10.15
local defenseBuffs = {
	[18652] = true,
	[281195] = true,
	[260881] = true,
	[108271] = true,
	[201633] = true,
	[207400] = true,
	[207498] = true,
	[118337] = true,
	[210918] = true,
	[204293] = true,
	[45438] = true,
	[198065] = true,
	[11426] = true,
	[198144] = true,
	[235313] = true,
	[203285] = true,
	[113862] = true,
	[235450] = true,
	[198111] = true,
	[337299] = true,
	[190456] = true,
	[180844] = true,
	[23920] = true,
	[32216] = true,
	[336642] = true,
	[132404] = true,
	[97463] = true,
	[180847] = true,
	[235941] = true,
	[147833] = true,
	[330279] = true,
	[335198] = true,
	[184364] = true,
	[202225] = true,
	[184362] = true,
	[213858] = true,
	[29838] = true,
	[197690] = true,
	[1160] = true,
	[871] = true,
	[12975] = true,
	[280001] = true,
	[275335] = true,
	[213871] = true,
	[198912] = true,
	[213915] = true,
	[180842] = true,
	[317491] = true,
	[343672] = true,
	[324867] = true,
	[177278] = true,
	[22812] = true,
	[5487] = true,
	[192081] = true,
	[305497] = true,
	[234084] = true,
	[61336] = true,
	[203975] = true,
	[80313] = true,
	[201664] = true,
	[187827] = true,
	[268178] = true,
	[263648] = true,
	[247454] = true,
	[203819] = true,
	[204021] = true,
	[209258] = true,
	[162264] = true,
	[196555] = true,
	[198589] = true,
	[196718] = true,
	[317009] = true,
	[206803] = true,
	[227635] = true,
	[48792] = true,
	[49039] = true,
	[55233] = true,
	[49028] = true,
	[194679] = true,
	[195182] = true,
	[206940] = true,
	[48743] = true,
	[194844] = true,
	[19236] = true,
	[47788] = true,
	[64844] = true,
	[45242] = true,
	[33206] = true,
	[81782] = true,
	[47585] = true,
	[193065] = true,
	[327694] = true,
	[320224] = true,
	[337661] = true,
	[213610] = true,
	[213602] = true,
	[197548] = true,
}

-- Last update time 20.10.15
local pvpDebuffs = {
	[1513] = true,
	[3355] = true,
	[5116] = true,
	[13295] = true,
	[135299] = true,
	[257284] = true,
	[196840] = true,
	[3600] = true,
	[51514] = true,
	[118905] = true,
	[64695] = true,
	[51490] = true,
	[342240] = true,
	[197214] = true,
	[305485] = true,
	[122] = true,
	[205708] = true,
	[118] = true,
	[82691] = true,
	[321329] = true,
	[212792] = true,
	[228354] = true,
	[289308] = true,
	[12486] = true,
	[33395] = true,
	[157997] = true,
	[205021] = true,
	[228600] = true,
	[198121] = true,
	[2120] = true,
	[31661] = true,
	[157981] = true,
	[31589] = true,
	[236299] = true,
	[1715] = true,
	[1161] = true,
	[5246] = true,
	[180943] = true,
	[105771] = true,
	[12323] = true,
	[182656] = true,
	[132169] = true,
	[236077] = true,
	[64382] = true,
	[236273] = true,
	[6343] = true,
	[203201] = true,
	[199042] = true,
	[132168] = true,
	[316593] = true,
	[199085] = true,
	[198912] = true,
	[206891] = true,
	[325886] = true,
	[326062] = true,
	[307871] = true,
	[84868] = true,
	[33786] = true,
	[339] = true,
	[5211] = true,
	[102359] = true,
	[305497] = true,
	[200947] = true,
	[81261] = true,
	[61391] = true,
	[209749] = true,
	[22570] = true,
	[99] = true,
	[217832] = true,
	[207684] = true,
	[202137] = true,
	[204021] = true,
	[202138] = true,
	[162264] = true,
	[198793] = true,
	[179057] = true,
	[211881] = true,
	[205630] = true,
	[45524] = true,
	[111673] = true,
	[43265] = true,
	[49576] = true,
	[56222] = true,
	[279302] = true,
	[196770] = true,
	[207167] = true,
	[206930] = true,
	[108199] = true,
	[8122] = true,
	[605] = true,
	[226943] = true,
	[15487] = true,
	[200200] = true,
	[204263] = true,
	[205364] = true,
	[64044] = true,
	[333526] = true,
	[320267] = true,
	[337956] = true,
	[322442] = true,
	[199845] = true,
}

-- Default buff indicator (corners of party/raid)
-- [specID] = {[buffids] = CornerID}
-- specID: /dump GetSpecializationInfo(GetSpecialization())
local buffIndicators = {
	[264] = {
		[61295] = 1,
		[974] = 2,
	},
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
