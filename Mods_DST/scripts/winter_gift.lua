local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS
local bonusgift_day = GetModConfigData("bonusgift_day")
local notation = GetModConfigData("notation")

local statedata =
{
    { -- empty
        name        = "empty",
        idleanim    = "idle",
        loot        = function(inst) return { inst.seedprefab, "boards", "poop" } end,
        burntloot   = function(inst) return { "boards", "poop" } end,
        burntanim   = "burnt",
        burnfxlevel = 3,
    },
    { -- sapling
        name        = "sapling",
        idleanim    = "idle_sapling",
        burntanim   = "burnt",
        workleft    = 1,
        workaction  = "HAMMER",
        growsound   = "dontstarve/wilson/plant_tree",
        loot        = function(inst) return { inst.seedprefab, "boards", "poop" } end,
        burntloot   = function(inst) return { "ash", "boards", "poop" } end,
        burnfxlevel = 3,
    },
    { -- short
        name           = "short",
        idleanim       = "idle_short",
        sway1anim      = "sway1_loop_short",
        sway2anim      = "sway2_loop_short",
        hitanim        = "chop_short",
        breakrightanim = "fallright_short",
        breakleftanim  = "fallleft_short",
        burntbreakanim = "chop_burnt_short",
        burntanim      = "burnt_short",
        growanim       = "grow_sapling_to_short",
        growsound      = "dontstarve/forest/treeGrow",
        workleft       = TUNING.WINTER_TREE_CHOP_SMALL,
        workaction     = "CHOP",
        loot           = function(inst) return { "log", "boards", "poop" } end,
        burntloot      = function(inst) return { "charcoal", "boards", "poop" } end,
        burnfxlevel    = 4,
        burntree       = true,
        shelter        = true,
    },
    { -- normal
        name           = "normal",
        idleanim       = "idle_normal",
        sway1anim      = "sway1_loop_normal",
        sway2anim      = "sway2_loop_normal",
        hitanim        = "chop_normal",
        breakrightanim = "fallright_normal",
        breakleftanim  = "fallleft_normal",
        burntbreakanim = "chop_burnt_normal",
        burntanim      = "burnt_normal",
        growanim       = "grow_short_to_normal",
        growsound      = "dontstarve/forest/treeGrow",
        workleft       = TUNING.WINTER_TREE_CHOP_NORMAL,
        workaction     = "CHOP",
        loot           = function(inst) return { "log", "log", inst.seedprefab, "boards", "poop" } end,
        burntloot      = function(inst) return { "charcoal", "boards", "poop" } end,
        burnfxlevel    = 4,
        burntree       = true,
        shelter        = true,
    },
    { -- tall
        name           = "tall",
        idleanim       = "idle_tall",
        sway1anim      = "sway1_loop_tall",
        sway2anim      = "sway2_loop_tall",
        hitanim        = "chop_tall",
        breakrightanim = "fallright_tall",
        breakleftanim  = "fallleft_tall",
        burntbreakanim = "chop_burnt_tall",
        burntanim      = "burnt_tall",
        growanim       = "grow_normal_to_tall",
        growsound      = "dontstarve/forest/treeGrow",
        workleft       = TUNING.WINTER_TREE_CHOP_TALL,
        workaction     = "CHOP",
        loot           = function(inst) return { "log", "log", "log", inst.seedprefab, inst.seedprefab, "boards", "poop" } end,
        burntloot      = function(inst) return { "charcoal", "charcoal", inst.seedprefab, "boards", "poop" } end,
        burnfxlevel    = 4,
        burntree       = true,
        shelter        = true,
    },
}

-------------------------------------------------------------------------------
local function PushSway(inst)
    if inst.statedata.sway1anim ~= nil then
        inst.AnimState:PushAnimation(math.random() > .5 and inst.statedata.sway1anim or inst.statedata.sway2anim, true)
    else
        inst.AnimState:PushAnimation(inst.statedata.idleanim, false)
    end
end

local function PlaySway(inst)
    if inst.OnPlayAnim ~= nil then
        inst:OnPlayAnim()
    end
    if inst.statedata.sway1anim ~= nil then
        inst.AnimState:PlayAnimation(math.random() > .5 and inst.statedata.sway1anim or inst.statedata.sway2anim, true)
    else
        inst.AnimState:PlayAnimation(inst.statedata.idleanim, false)
    end
end

local function PlayAnim(inst, anim)
    if inst.OnPlayAnim ~= nil then
        inst:OnPlayAnim()
    end
    inst.AnimState:PlayAnimation(anim)
end

local function SetGrowth(inst)
    if inst.components.burnable == nil then
        -- NOTES(JBK): This thing got burnt in the time between the thing growing and now so do nothing.
        return
    end
    local new_size = inst.components.growable.stage
    inst.statedata = statedata[new_size]
    PlaySway(inst)

    inst.components.workable:SetWorkAction(ACTIONS[inst.statedata.workaction])
    inst.components.workable:SetWorkLeft(inst.statedata.workleft)

    inst.components.burnable:SetFXLevel(inst.statedata.burnfxlevel)
    inst.components.burnable:SetBurnTime(inst.statedata.burntree and TUNING.TREE_BURN_TIME or 20)

    if inst.canshelter and inst.statedata.shelter then
        inst:AddTag("shelter")
    end

    if new_size >= #statedata then
        inst.components.container.canbeopened = true
        inst.components.growable:StopGrowing()

        local gift_trees = GLOBAL.TheWorld.components.giftmanager.gift_trees
        if gift_trees then
            table.insert(gift_trees, inst)
        else
            print("no gift_trees in SetGrowth")
        end
    end
end

local function DoGrow(inst)
    if inst.statedata.growanim ~= nil then
        PlayAnim(inst, inst.statedata.growanim)
    end
    if inst.statedata.growsound ~= nil then
        inst.SoundEmitter:PlaySound(inst.statedata.growsound)
    end

    PushSway(inst)
end

local GetRandomWithVariance = GLOBAL.GetRandomWithVariance
local GROWTH_STAGES =
{
    {
        time = function(inst) return 0 end,
        fn = SetGrowth,
        growfn = function() end,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[2].base,
                TUNING.WINTER_TREE_GROW_TIME[2].random)
        end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[3].base,
                TUNING.WINTER_TREE_GROW_TIME[3].random)
        end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[4].base,
                TUNING.WINTER_TREE_GROW_TIME[4].random)
        end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[5].base,
                TUNING.WINTER_TREE_GROW_TIME[5].random)
        end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
}

local tree_types = { "winter_tree", "winter_twiggytree", "winter_deciduoustree" }
for key, value in pairs(tree_types) do
    AddPrefabPostInit(value, function(inst)
        inst.components.growable.stages = GROWTH_STAGES
    end)
end

AddPrefabPostInit("world", function(inst)
    inst:AddComponent("giftmanager")
    inst.components.giftmanager.DAY = bonusgift_day
    inst.components.giftmanager.notation = notation
    if not notation then
        inst.components.giftmanager.notationfn = function() end
    end
end)
