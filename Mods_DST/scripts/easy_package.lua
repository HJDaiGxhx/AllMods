local BANNED_TAGS =
{
    "campfire",
    "spiderden",
    "tent",
    "wall"
}

local BANNED_PREFABS =
{
    "pighouse",
    "rabbithouse",
    "slow_farmplot",
    "fast_farmplot"
}

local PACKABLE =
{
    { "beebox", true or false },
    { "birdcage", true or false },
    { "cartographydesk", true or false },
    { "cookpot", true or false },
    { "dragonflychest", true or false },
    { "dragonflyfurnace", true or false },
    { "endtable", true or false },
    { "firesuppressor", true or false },
    { "icebox", true or false },
    { "lightning_rod", true or false },
    { "meatrack", true or false },
    { "moondial", true or false },
    { "mushroom_farm", true or false },
    { "mushroom_light", true or false },
    { "nightlight", true or false },
    { "perdshrine", true or false },
    { "pottedfern", true or false },
    { "rainometer", true or false },
    { "researchlab", true or false },
    { "researchlab2", true or false },
    { "researchlab3", true or false },
    { "researchlab4", true or false },
    { "resurrectionstatue", true or false },
    { "saltlick", true or false },
    { "scarecrow", true or false },
    { "sculptingtable", true or false },
    { "succulent_potted", true or false },
    { "townportal", true or false },
    { "treasurechest", true or false },
    { "wardrobe", true or false },
    { "winterometer", true or false },
}

PrefabFiles = { "moving_box" }

GLOBAL.STRINGS.NAMES.MOVING_BOX = "Moving Box"
GLOBAL.STRINGS.NAMES.MOVING_BOX_FULL = "Moving Box (Full)"
GLOBAL.STRINGS.RECIPE_DESC.MOVING_BOX = "You can use it to move structures."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOVING_BOX = "It's a box I can move things with."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MOVING_BOX = "It's a big box for us to move things with."
GLOBAL.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.UNPACK =
{
    GENERIC = "I can't unpack that now!",
    NOROOM = "There is not enough room to unpack that here."
}

AddRecipe("moving_box",
    { GLOBAL.Ingredient("papyrus", 3), GLOBAL.Ingredient("silk", 1) },
    GLOBAL.RECIPETABS.TOOLS,
    GLOBAL.TECH.SCIENCE_ONE,
    nil, -- placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/box.xml", -- atlas
    "box.tex")

NewAction("PACK", "Pack", "USEITEM", "package", "doshortaction",
    function(inst, doer, target, actions)
        if target:HasTag("packable") and not inst.components.package.content then
            return true
        end
    end,
    function(act)
        local inst = act.invobject
        local data = {
            overridedeployplacername = act.target.prefab .. "_placer" or nil,
            skin_build_name = GetBuildForItem(act.target.skinname),
            content_guid = act.target.GUID,
        }
        inst:OnLoad(data)

        inst.components.package:Pack(act.target)

        act.doer.components.inventory:SetActiveItem(nil)
        act.doer.components.inventory:GiveItem(inst)
    end)
-- ACTIONS.DEPLOY.priority = 10
ACTIONS.PACK.priority = 10

AddPrefabPostInitAny(function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    if inst:HasTag("packable") then return end

    if inst:HasTag("structure") then inst:AddTag("packable") end
end)
