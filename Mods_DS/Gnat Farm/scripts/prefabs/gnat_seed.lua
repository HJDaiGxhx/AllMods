local assets = 
{
    Asset("ANIM", "anim/gnat_seed.zip"),
    Asset("IMAGE", "images/inventoryimages/gnat_seed.tex"),
    Asset("ATLAS", "images/inventoryimages/gnat_seed.xml"), 
}

local function ondeploy(inst, pt)
    local home = SpawnPrefab("gnatmound")

    home.Transform:SetPosition(pt.x, pt.y, pt.z)
    home.components.workable.workleft = 1
    home.rebuildfn(home)

    inst.components.stackable:Get():Remove()
end

---------------FN TO RETURN-----------------

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gnat_seed")    
    inst.AnimState:SetBuild("gnat_seed")   
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gnat_seed.xml"

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy    

    return inst
end

return Prefab("common/inventory/gnat_seed", fn, assets),
       MakePlacer("common/gnat_seed_placer", "gnat_seed", "gnat_seed", "placer")