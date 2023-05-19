local TUNING = GLOBAL.TUNING
local SpawnPrefab = GLOBAL.SpawnPrefab

---------------ADD DESCRIPTION---------------

PrefabFiles = 
{
    "blowdart_stinger",
}

Assets = 
{
    -- Asset("ATLAS", "images/inventoryimages/blowdart_stinger.xml"),
}

local STRINGS = GLOBAL.STRINGS
STRINGS.NAMES.BLOWDART_STINGER = "Stinger Dart"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLOWDART_STINGER = "Blow it!"
STRINGS.RECIPE_DESC.BLOWDART_STINGER = "Craft it!"

---------------ADD TO RECIPE-------------------

local RECIPETABS 	= GLOBAL.RECIPETABS
local Recipe 		= GLOBAL.Recipe
local TECH		= GLOBAL.TECH
local Ingredient 	= GLOBAL.Ingredient

local blowdart_stinger = Recipe("blowdart_stinger", {Ingredient("cutreeds", 2), Ingredient("stinger", 1), Ingredient("beefalowool", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE)
blowdart_stinger.image = "blowdart_sleep.tex"
blowdart_stinger.sortkey = -1