local TUNING = GLOBAL.TUNING
local SpawnPrefab = GLOBAL.SpawnPrefab

-- others
local require = GLOBAL.require
local EventHandler = GLOBAL.EventHandler
local Action = GLOBAL.Action
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler
local Lerp = GLOBAL.Lerp
local FindWalkableOffset = GLOBAL.FindWalkableOffset
local PI = GLOBAL.PI
local Vector3 = GLOBAL.Vector3
local debug = GLOBAL.debug
local GetPlayer = GLOBAL.GetPlayer
local IsHUDPaused = GLOBAL.IsPaused
local TheInput = GLOBAL.TheInput
local TheFrontEnd = GLOBAL.TheFrontEnd
local TheSim = GLOBAL.TheSim

---------------ADD TAG---------------

local function addatag(inst)
	inst:AddTag("furfuel")
end

AddPrefabPostInit("beefalowool", addatag)

---------------ADD DESCRIPTION---------------

PrefabFiles = 
{
    "bearger_pack",
}

local STRINGS = GLOBAL.STRINGS
STRINGS.NAMES.BEARGER_PACK = "Hibearnation Pack"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEARGER_PACK = "Keeps you warm among long winter."
STRINGS.RECIPE_DESC.BEARGER_PACK = "Keeps you warm among long winter."

---------------ADD TO RECIPE-------------------

local RECIPETABS 	   = GLOBAL.RECIPETABS
local Recipe 		   = GLOBAL.Recipe
local TECH			   = GLOBAL.TECH
local Ingredient 	   = GLOBAL.Ingredient
-- local RECIPE_GAME_TYPE = GLOBAL.RECIPE_GAME_TYPE

local bearger_pack = Recipe("bearger_pack", {Ingredient("beargervest", 2), Ingredient("gears", 3), Ingredient("transistor", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, GLOBAL.RECIPE_GAME_TYPE.ROG)
bearger_pack.image = "icepack.tex"
bearger_pack.sortkey = -1