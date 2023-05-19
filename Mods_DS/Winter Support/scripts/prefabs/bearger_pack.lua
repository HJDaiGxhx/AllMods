local BEARGER_PACK_PERISHTIME = 480
local BEEFALOWOOL_FUEL_AMOUNT = 0.2 * BEARGER_PACK_PERISHTIME
local task = nil

local assets =
{
    Asset("ANIM", "anim/swap_icepack.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("MINIMAP_IMAGE", "icepack"),
}

local function heatup(inst)
	local owner = inst.components.inventoryitem.owner
	local temperature = owner.components.temperature
	
	if temperature:GetCurrent() <= 30 then
		temperature:DoDelta(5)
		-- print(temperature:GetCurrent())
	end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then	
		if inst.components.fueled then
			inst.components.fueled:StartConsuming()
		end

		-- notice bloodover !! It will not turn off after pack raises temperature
		-- requires change below (e.x. what.owner.bloodover:TurnOff())
		
		if task == nil then
			task = inst:DoPeriodicTask(1, function() heatup(inst) end)
		end
    end
end

local function turnoff(inst)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
		
    if task then
        task:Cancel()
		task = nil
	end
end


local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_icepack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_icepack", "swap_body")
    owner.components.inventory:SetOverflow(inst)
    inst.components.container:Open(owner)

	turnon(inst)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.components.inventory:SetOverflow(nil)
    inst.components.container:Close(owner)
	
	turnoff(inst)
end


local function nofuel(inst)
    turnoff(inst)
end

local function takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        turnon(inst)
    end
end


local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")	
	local container = inst.components.container
	
	for i = 1, container:GetNumSlots() do
		local item = container:GetItemInSlot(i)
		
		if item then
			if item:HasTag("furfuel") then
				local currentfuel = inst.components.fueled.currentfuel
				local need = math.floor((BEARGER_PACK_PERISHTIME - currentfuel) / BEEFALOWOOL_FUEL_AMOUNT)
				local have = item.components.stackable:StackSize()
				
				local n = math.min(need, have)
								
				if n >= 1 then
					inst.components.fueled:DoDelta(n * BEEFALOWOOL_FUEL_AMOUNT)
					takefuel(inst)
					
					for i = 1, n do                
						container:RemoveItem(item, false):Remove()
					end
					
					inst.SoundEmitter:PlaySound("dontstarve/HUD/repair_clothing")
				end
			end
		end
	end
end


local slotpos = {}

for y = 0, 3 do
	table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
end

local function common()
    local inst = CreateEntity()    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()	
    minimap:SetIcon("icepack.png")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "anim", "anim")  
    
    inst.AnimState:SetBank("icepack")
    inst.AnimState:SetBuild("swap_icepack")
    inst.AnimState:PlayAnimation("anim")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

    inst:AddTag("backpack")
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_backpack_2x4"
    inst.components.container.widgetanimbuild = "ui_backpack_2x4"
    inst.components.container.widgetpos = Vector3(-5,-70,0)
    inst.components.container.side_widget = true
    inst.components.container.type = "pack"
   
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(function()
        if inst.inventoryitemdata then inst.inventoryitemdata = nil end

        if inst.components.container then
            inst.components.container:DropEverything()
            inst.components.container:Close()
            inst:RemoveComponent("container")
        end
        
        local ash = SpawnPrefab("ash")
        ash.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst:Remove()
    end)

	return inst
end

local function fn()
    local inst = common()

    inst.components.inventoryitem.imagename = "icepack"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(BEARGER_PACK_PERISHTIME)
	inst.components.fueled:SetDepletedFn(nofuel)
	
	return inst
end

return Prefab("common/inventory/bearger_pack", fn, assets)