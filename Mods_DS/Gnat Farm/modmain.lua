local SpawnPrefab = GLOBAL.SpawnPrefab

---------------ADD DESCRIPTION---------------

PrefabFiles = 
{
    "gnat_seed",
}

Assets = 
{
    Asset("ATLAS", "images/inventoryimages/gnat_seed.xml"),
}

STRINGS = GLOBAL.STRINGS
STRINGS.NAMES.GNAT_SEED = "Gnat Seed"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GNAT_SEED = "Plant it!"

---------------ADD TO ROOT-----------------

local function AddLoot(inst)
    local prefabs = {"gnat_seed",}
    inst.components.lootdropper:SetLoot({"gnat_seed"})
end

AddPrefabPostInit("gnat", AddLoot)