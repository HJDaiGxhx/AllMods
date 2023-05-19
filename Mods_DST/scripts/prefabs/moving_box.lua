---@diagnostic disable: lowercase-global, deprecated, param-type-mismatch, undefined-global
local PHYSICS_RADIUS = .15

local assets =
{
	Asset("ANIM", "anim/box.zip"),
	Asset("ANIM", "anim/box_full.zip"),
	Asset("ANIM", "anim/swap_box_full.zip"),
	Asset("ATLAS", "images/inventoryimages/box.xml"),
	Asset("IMAGE", "images/inventoryimages/box.tex"),
	Asset("ATLAS", "images/inventoryimages/box_full.xml"),
	Asset("IMAGE", "images/inventoryimages/box_full.tex"),
}

----------------------------------

local function OnUnequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "swap_box_full", "swap_body")
end

local function OnBurnt(inst)
	if inst.components.package ~= nil then
		inst.components.package:Empty()
	end

	SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())

	inst:Remove()
end

local function OnDrop(inst)
	inst.Physics:SetVel(0, 0, 0)
end

local function ondeploy(inst, pt, deployer)
	local package = inst.components.package
	print("ondeploy", "package", package, "package.content", package.content)
	if package then
		-- package.content.Transform:SetPosition(pt:Get()) -- teleport entity back
		-- SpawnPrefab("die_fx").Transform:SetPosition(pt:Get())
		local unpacked = package:UnPack(pt)

		if unpacked then
			deployer.components.inventory:GiveItem(SpawnPrefab("moving_box"), nil, pt)
			inst:Remove()
		else
			deployer.components.inventory:GiveItem(inst, nil, pt)
		end
	end
end

local function onsave(inst, data)
	data.overridedeployplacername = inst.overridedeployplacername
	data.skin_build_name = inst.skin_build_name
	data.content_guid = inst.components.package.content and inst.components.package.content.GUID or nil
	return { inst.components.package }
end

local function onload(inst, data)
	print("onload")
	if data then
		inst.overridedeployplacername = data.overridedeployplacername
		inst.skin_build_name = data.skin_build_name
		inst.content_guid = data.content_guid
		print(inst.overridedeployplacername, inst.skin_build_name, inst.content_guid)

		if inst.overridedeployplacername then
			inst:AddComponent("deployable")
			inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)
			inst.components.deployable.ondeploy = ondeploy
		end
	end
end

local function onloadpostpass(inst, newents, savedata)
	print("onloadpostpass")
	if savedata then
		local content = newents[savedata.content_guid]
		if content then
			inst.components.package.content = content.entity
			print("package.content", inst.components.package.content)
		end
	end
end

local function common()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("box")
	inst.AnimState:SetBuild("box")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("nonpotatable")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim or not TheNet:GetIsServer() then
		return inst
	end

	--------

	inst:AddComponent("inspectable")

	inst:AddComponent("package")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.cangoincontainer = true
	inst.components.inventoryitem.imagename = "box"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/box.xml"

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)
	inst.components.burnable:SetOnBurntFn(OnBurnt)

	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnLoadPostPass = onloadpostpass

	return inst
end

local function full()
	local inst = common()

	MakeSmallHeavyObstaclePhysics(inst, PHYSICS_RADIUS)

	inst.AnimState:SetBank("box_full")
	inst.AnimState:SetBuild("swap_box_full")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("full")
	inst:AddTag("heavy")
	inst:AddTag("irreplaceable")

	if not TheWorld.ismastersim or not TheNet:GetIsServer() then
		return inst
	end

	--------

	inst.components.inventoryitem.cangoincontainer = false
	inst.components.inventoryitem.imagename = "box_full"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/box_full.xml"
	inst.components.inventoryitem:SetOnDroppedFn(OnDrop)

	inst:AddComponent("heavyobstaclephysics")
	inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)
	inst.components.heavyobstaclephysics:MakeSmallObstacle()

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.walkspeedmult = 0.25

	return inst
end

return Prefab("moving_box", common, assets),
	Prefab("moving_box_full", full, assets)
-- -- name, bank, build, anim, onground, snap, metersnap, scale, fixedcameraoffset, facing, postinit_fn, offset, onfailedplacement
-- MakePlacer("moving_box_placer", "box_full", "swap_box_full", "idle")
