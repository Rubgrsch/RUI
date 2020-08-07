local _, rui = ...
rui[1] = {} -- Base
rui[2] = {} -- Locales
rui[3] = {} -- Config
local B, L, C = unpack(rui)
RUI = rui
setmetatable(L, {__index=function(_, key) return key end})
