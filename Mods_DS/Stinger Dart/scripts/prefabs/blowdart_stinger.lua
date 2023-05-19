local assets =
{
	Asset("ANIM", "anim/blow_dart.zip"),
	Asset("ANIM", "anim/swap_blowdart.zip"),
}

local prefabs = 
{
    "impact",
}

----------------------COMMON-------------------------

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart", "swap_blowdart")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx and attacker then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function common()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("blow_dart")
    anim:SetBuild("blow_dart")
    
    inst:AddTag("blowdart")
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    -------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true
    
    return inst
end

----------------------STINGER-------------------------

local function sleepthrown(inst)
    inst.AnimState:PlayAnimation("dart_purple")
end

local function stinger()
    local inst = common()

    inst.AnimState:PlayAnimation("idle_purple")
    inst.components.weapon:SetDamage(50)
    inst.components.projectile:SetOnThrownFn(sleepthrown) -- same as sleep dart

    inst.components.inventoryitem.imagename = "blowdart_sleep"
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

return Prefab("common/inventory/blowdart_stinger", stinger, assets, prefabs)