---@diagnostic disable: lowercase-global, undefined-global

AddPrefabPostInit("tentacle", function(inst)
    if GetModConfigData("tentacle") then

        if not GLOBAL.TheWorld.ismastersim then
            print("cancel AddPrefabPostInit tentacle")
            return
        end

        GLOBAL.SetSharedLootTable('tentacle_local',
            {
                -- { 'monstermeat', 1.0 },
                -- { 'monstermeat', 1.0 },
                { 'monstermeat', 0.5 },
                { 'tentaclespots', 0.2 },
                { 'tentaclespike', 0.01 },
            }
        )
        inst.components.lootdropper:SetChanceLootTable('tentacle_local')
    end
end)

local function pondfish()
    AddIngredientValues({ "pondfish" }, { meat = 1, fish = .5 }, false)
    AddPrefabPostInit("pondfish", function(inst)
        inst:AddComponent("stackable")
    end)
end

local function lootfn(inst, doer)
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        local rnd = math.random(2)
        if rnd == 1 then
            item = "blueprint"
        else
            item = GLOBAL.GetRandomLightWinterOrnament()
        end

        return { item }
    else
        return nil
    end
end

local function OnUnwrapped(inst, pos, doer)
    if inst.burnt then
        SpawnPrefab("ash").Transform:SetPosition(pos:Get())
    else
        local loottable = lootfn(inst, doer) or nil
        if loottable ~= nil then
            local moisture = inst.components.inventoryitem:GetMoisture()
            local iswet = inst.components.inventoryitem:IsWet()
            for i, v in ipairs(loottable) do
                local item = SpawnPrefab(v)
                if item ~= nil then
                    if item.Physics ~= nil then
                        item.Physics:Teleport(pos:Get())
                    else
                        item.Transform:SetPosition(pos:Get())
                    end
                    if item.components.inventoryitem ~= nil then
                        item.components.inventoryitem:InheritMoisture(moisture, iswet)
                        if tossloot then
                            item.components.inventoryitem:OnDropped(true, .5)
                        end
                    end
                end
            end
        end
        SpawnPrefab("wetpouch_unwrap").Transform:SetPosition(pos:Get())
    end
    if doer ~= nil and doer.SoundEmitter ~= nil then
        doer.SoundEmitter:PlaySound(inst.skin_wrap_sound or "dontstarve/common/together/packaged")
    end
    inst:Remove()
end

AddPrefabPostInit("wetpouch", function(inst)
    inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)
end)

local pick_dist = TUNING and TUNING.ORANGEAMULET_RANGE or 4
if GetModConfigData("orangeamulet") then pick_dist = 11 end
local function pickup(inst, owner)
    local item = GLOBAL.FindPickupableItem(owner, pick_dist, false)
    if item == nil then
        return
    end

    local didpickup = false
    if item.components.trap ~= nil then
        item.components.trap:Harvest(owner)
        didpickup = true
    end

    if owner.components.minigame_participator ~= nil then
        local minigame = owner.components.minigame_participator:GetMinigame()
        if minigame ~= nil then
            minigame:PushEvent("pickupcheat", { cheater = owner, item = item })
        end
    end

    --Amulet will only ever pick up items one at a time. Even from stacks.
    GLOBAL.SpawnPrefab("sand_puff").Transform:SetPosition(item.Transform:GetWorldPosition())

    inst.components.finiteuses:Use(1)

    if not didpickup then
        local item_pos = item:GetPosition()
        if item.components.stackable ~= nil then
            item = item.components.stackable:Get()
        end

        owner.components.inventory:GiveItem(item, nil, item_pos)
    end
end

local function onequip_orange(inst, owner)
    inst.owner = owner
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")

    if inst.components.finiteuses.current > 0 then
        inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, pickup, nil, owner)
    end
end

AddPrefabPostInit("orangeamulet", function(inst)
    inst.components.equippable:SetOnEquip(onequip_orange)
    inst.components.finiteuses:SetOnFinished(function()
        Cancel(inst.task, false)
    end)

    local old = inst.components.finiteuses.Repair
    inst.components.finiteuses.Repair = function(self, ...)
        old(self, ...)

        print("new Repair")
        if inst.components.equippable.isequipped and inst.task == nil then
            inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, pickup, nil, inst.owner)
        end
    end
end)

-- 其实优化无非就是局部性、积极策略懒惰策略，所以最优肯定是生成一条就更新一下，但考虑到虽然我自己从来只在绿洲钓过鱼，但综合肯定是在哪钓鱼显示哪里的内容，这肯定是不行的，所以我觉得先不想再优化什么了。
local ACTIONS = GLOBAL.ACTIONS
local REEL = GLOBAL.STRINGS.ACTIONS.REEL
local oldCANCEL = GLOBAL.STRINGS.ACTIONS.REEL.CANCEL -- Stop Fishing

local function textUpdate(pondmanager, nibbletime)
    REEL.CANCEL = oldCANCEL .. "\n" ..
        pondmanager.fishleft .. "/" .. pondmanager.maxfish .. ", " .. nibbletime .. "s"
end

local per = nil
ACTIONS.FISH.fn = function(act) -- 不知道为什么钓上鱼的情况下出现连续两次per cancel，但我真的不想管了。
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod then
        Cancel(per)

        local pondmanager = act.target.components.fishable
        local nibbletime = math.ceil(fishingrod.minwaittime +
            (1.0 - pondmanager:GetFishPercent()) * (fishingrod.maxwaittime - fishingrod.minwaittime))

        textUpdate(pondmanager, nibbletime)

        per = act.doer:DoPeriodicTask(1, function()
            -- print("DoPeriodicTask ", nibbletime)
            nibbletime = nibbletime - 1
            if nibbletime >= 0 then
                textUpdate(pondmanager, nibbletime)
            else
                REEL.CANCEL = "" -- 为什么Hook之后会显示CANCEL出来啊？
                Cancel(per)
            end
        end)

        fishingrod:StartFishing(act.target, act.doer)
    end
    return true
end

-- GET_ONE_ITEM
local _G = GLOBAL
local invslot = _G.require("widgets/invslot")
-- local TheFocalPoint = _G.TheFocalPoint

-- 惊了，真的我才发现这个功能比想象中更加重要，很多场景是真的用得到的啊。

local success = true
local failure = false
local function PlaySound(param)
    if param == true then _G.TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
    else _G.TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative") end
end

local function OnFailure(oneitem, source, stack)
    -- if stack then stack:SetStackSize(stack.stacksize + 1)
    -- else source.container_ori:GiveItem(oneitem, source.slot.num) end
    print("OnFailure")

    source.container_ori:GiveItem(oneitem, source.slot.num)
    PlaySound(failure)
end

local function GetOpenContainers(inv)
    local containers = {}
    local inv = inv.replica

    if inv.inst.HUD ~= nil and inv.inst.HUD.controls ~= nil then
        for k, v in pairs(inv.inst.HUD.controls.containers) do
            if v ~= nil and v.inst.entity:IsVisible() and k:IsValid() then
                containers[k] = true
            end
        end
        --TheInput:ControllerAttached() or Profile:GetIntegratedBackpack()
        local overflow = inv:GetOverflowContainer()
        if overflow and overflow.inst then
            containers[overflow.inst] = true
        end
    end

    for k, v in pairs(containers) do print(k, v) end
    return containers
end

-- TODO: 为什么冰箱比锅优先级高，但总之在这个只推一份特殊情况下，肯定是锅优先级高，所以最好能之后优化一下。
local function FindBestContainer(self, item, containers, exclude_containers)
    if item == nil or containers == nil then
        return
    end

    --Construction containers
    --NOTE: reusing containerwithsameitem variable
    local containerwithsameitem = self.owner ~= nil and self.owner.components.constructionbuilderuidata ~= nil and
        self.owner.components.constructionbuilderuidata:GetContainer() or nil
    if containerwithsameitem ~= nil then
        if containers[containerwithsameitem] ~= nil and
            (exclude_containers == nil or not exclude_containers[containerwithsameitem]) then
            local slot = self.owner.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
            if slot ~= nil then
                local container = containerwithsameitem.replica.container
                if container ~= nil and container:CanTakeItemInSlot(item, slot) then
                    local existingitem = container:GetItemInSlot(slot)
                    if existingitem == nil or
                        (
                        container:AcceptsStacks() and existingitem.replica.stackable ~= nil and
                            not existingitem.replica.stackable:IsFull()) then
                        return containerwithsameitem
                    end
                end
            end
        end
        containerwithsameitem = nil
    end

    --local containerwithsameitem = nil --reused with construction containers code above
    local containerwithemptyslot = nil
    local containerwithnonstackableslot = nil

    for k, v in pairs(containers) do
        if exclude_containers == nil or not exclude_containers[k] then
            local container = k.replica.container or k.replica.inventory
            if container ~= nil and container:CanTakeItemInSlot(item) then
                local isfull = container:IsFull()
                if container:AcceptsStacks() then
                    if not isfull and containerwithemptyslot == nil then
                        containerwithemptyslot = k
                    end
                    if item.replica.equippable ~= nil and container == k.replica.inventory then
                        local equip = container:GetEquippedItem(item.replica.equippable:EquipSlot())
                        if equip ~= nil and equip.prefab == item.prefab and equip.skinname == item.skinname then
                            if equip.replica.stackable ~= nil and not equip.replica.stackable:IsFull() then
                                return k
                            elseif not isfull and containerwithsameitem == nil then
                                containerwithsameitem = k
                            end
                        end
                    end
                    for k1, v1 in pairs(container:GetItems()) do
                        if v1.prefab == item.prefab and v1.skinname == item.skinname then
                            if v1.replica.stackable ~= nil and not v1.replica.stackable:IsFull() then
                                return k
                            elseif not isfull and containerwithsameitem == nil then
                                containerwithsameitem = k
                            end
                        end
                    end
                elseif not isfull and containerwithnonstackableslot == nil then
                    containerwithnonstackableslot = k
                end
            end
        end
    end

    return containerwithsameitem or containerwithemptyslot or containerwithnonstackableslot
end

local function FindBestContainer_BySource(inv, source)
    local character = GLOBAL.ThePlayer
    local bestprefab = nil

    local opencontainers = GetOpenContainers(inv) -- owner.replica.inventory:Get...
    if opencontainers == nil then return end -- TODO: next(opencontainers)

    local overflow = inv.replica:GetOverflowContainer()
    local backpack = nil
    if overflow ~= nil and overflow:IsOpenedBy(character) then
        backpack = overflow.inst
        overflow = backpack.replica.container
        if overflow == nil then
            backpack = nil
        end
    else overflow = nil end

    -- p("source.container == ")
    if source.container == inv.replica then
        -- print("inv.replica")
        local playercontainers = backpack ~= nil and { [backpack] = true } or nil
        bestprefab = FindBestContainer(source.slot, source.item, opencontainers, playercontainers)
            or FindBestContainer(source.slot, source.item, playercontainers)

    elseif source.container == overflow then
        -- print("overflow, backpack")
        bestprefab = FindBestContainer(source.slot, source.item, opencontainers, { [backpack] = true })
            or (inv.replica:IsOpenedBy(character) and character or backpack)
    else
        -- print("opencontainers")
        local exclude_containers = { [source.container.inst] = true }
        if backpack ~= nil then
            exclude_containers[backpack] = true
        end
        bestprefab = FindBestContainer(source.slot, source.item, opencontainers, exclude_containers)
            or (inv.replica:IsOpenedBy(character) and character or backpack) -- nil/exclude_containers
    end

    return bestprefab
end

local function OneItem(source)
    local stack = source.item.components.stackable
    local oneitem

    if stack and stack:StackSize() > 1 then
        oneitem = stack:Get(1)
        print("stack:Get(1)", oneitem)
    else
        oneitem = source.container_ori:RemoveItemBySlot(source.slot.num)
        print("RemoveItemBySlot", oneitem)
    end

    return oneitem
end

local function Trade_OneItem(oneitem, inv, source)
    local inst = FindBestContainer_BySource(inv, source)

    if inst ~= nil then
        print(inst, "is the bestprefab.")

        local container = inst.components.inventory
        if not container then
            print("container not inventory")
            container = inst.components.container
        end

        if container and inst ~= source.container.inst and container ~= source.container and
            container ~= source.container_ori then
            print("oneitem", oneitem, container, container.inst)

            local item = source.item
            local builder = source.owner.components.constructionbuilderuidata
            local targetslot

            if builder ~= nil then
                print("builder")
                if builder:GetContainer() == container.inst then
                    print("GetContainer")
                    targetslot = builder:GetSlotForIngredient(item.prefab) or nil -- 这个是平常会用的吗？
                    print("targetslot =", targetslot)
                elseif builder:GetContainer() == inst then
                    print("GetContainer2")
                    targetslot = builder:GetSlotForIngredient(item.prefab) or nil
                    print("targetslot =", targetslot)
                end
            end

            oneitem = OneItem(source)
            local item = oneitem

            item.prevcontainer = nil
            item.prevslot = nil

            --Hacks for altering normal inventory:GiveItem() behaviour
            if container.ignoreoverflow ~= nil and container:GetOverflowContainer() == source.container then
                container.ignoreoverflow = true
            end
            if container.ignorefull ~= nil then
                container.ignorefull = true
            end

            if not container:GiveItem(item, targetslot, nil, false) then
                source.container_ori:GiveItem(item, nil, nil, true)
            else
                print("GiveItem passed")
                PlaySound(success)
                return
            end

            --Hacks for altering normal inventory:GiveItem() behaviour
            if container.ignoreoverflow then
                container.ignoreoverflow = false
            end
            if container.ignorefull then
                container.ignorefull = false
            end
        end
    end

    OnFailure(oneitem, source)
end

local function Cursor_OneItem(oneitem, inv, source)
    local active_item = inv.inventory:GetActiveItem()
    print("active_item =", active_item)
    oneitem = OneItem(source)

    if active_item == nil then
        oneitem.prevslot = source.slot.num
        oneitem.prevcontainer = source.container
        inv.inventory:GiveActiveItem(oneitem)
        PlaySound(success)

    elseif Same(active_item, source.item) and active_item.components.stackable then
        active_item.components.stackable:Put(oneitem)
        PlaySound(success)

    else
        OnFailure(oneitem, source)
    end
end

local function GetOneItem(invslot, trade)
    local source = {
        slot = invslot,
        item = invslot.tile.item,
        owner = invslot.owner,
        container = invslot.container,
        container_ori = invslot.container,
        targetslot = nil,
    } -- 只是我个人觉得invslot换个写法？
    local inv = {
        inventory = source.owner.components.inventory,
        replica = source.owner.replica.inventory,
    }

    local oneitem

    local inst = source.container.inst
    if inst then source.container_ori = inst.components.inventory or inst.components.container end

    if source.item then
        -- oneitem = OneItem(source)

        if not trade then Cursor_OneItem(oneitem, inv, source)
        else
            -- Trade_OneItem(oneitem, inv, source)
        end
    end

    return true
end

local function OnControlHook(self)
    local _oldOnControl = self.OnControl

    function self:OnControl(control, down, ...)
        if down and control == _G.CONTROL_ACCEPT and _G.TheInput:IsControlPressed(_G.CONTROL_FORCE_STACK) and
            self.tile then
            -- p("OnControl")
            return GetOneItem(self, _G.TheInput:IsControlPressed(_G.CONTROL_FORCE_TRADE) and true or false)
        else
            -- p("_oldOnControl")
            return _oldOnControl(self, control, down, ...)
        end
    end
end

OnControlHook(invslot)
pondfish()
