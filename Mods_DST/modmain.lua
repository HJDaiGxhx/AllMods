modimport("scripts/utils.lua")

local configs = GLOBAL.KnownModIndex:LoadModConfigurationOptions("AllMods", false)
for k, v in pairs(configs) do
	if v.type and v.type == "script" and GetModConfigData(v.name) == true then
		modimport("scripts/" .. (v.name) .. ".lua") -- assert(io.open(...))
	end
end

if GetModConfigData("debug") then
	YouAreGOD()
end
