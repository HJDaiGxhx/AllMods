local Ownership = GetModConfigData("Ownership")
local Travel_Cost = GetModConfigData("Travel_Cost")
local FTSignTag = 'fast_travel'

local FT_Points = {
	"homesign"
}

for k, v in pairs(FT_Points) do
	AddPrefabPostInit(v, function(inst)
		inst:AddComponent("talker")
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("fasttravel")
			inst.components.fasttravel.dist_cost = Travel_Cost
			inst.components.fasttravel.ownership = Ownership
		end
	end)
end

-- Actions ------------------------------

AddAction("DESTINATION", "Select Destination", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.fasttravel and
		not act.target:HasTag("burnt") and not act.target:HasTag("fire") then
		act.target.components.fasttravel:SelectDestination(act.doer)
		return true
	end
end)

local sign_edit = AddAction("SIGN_EDIT", "Edit", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.fasttravel and
		not act.target:HasTag("burnt") and not act.target:HasTag("fire") then
		if not act.target.components.writeable then
			act.target:AddComponent("writeable")
		end
		if act.target.components.writeable then -- 意想不到的是writeable写成了writable导致出错，感觉还是记录下来。
			act.target.components.writeable:BeginWriting(act.doer)
		end
		return true
	end
end)
sign_edit.priority = 9

-- 这里尝试用了SCENE，因为觉得两个应该按照逻辑的话就是可以正常绑定的，但是没有实现，不想做了。可能是同样的component导致了？
AddComponentAction("SCENE", "writeable", function(inst, doer, actions, right)
	if not right and inst:HasTag(FTSignTag) and not inst:HasTag("burnt") and not inst:HasTag("fire") then
		table.insert(actions, GLOBAL.ACTIONS.SIGN_EDIT)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SIGN_EDIT, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SIGN_EDIT, "give"))

local sign_repair = AddAction("SIGN_REPAIR", "Repair", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.fasttravel and
		act.target:HasTag("burnt") then
		local tar = act.target
		local prod = GLOBAL.SpawnPrefab("homesign") -- 你连自己怎么死的都不知道。

		if prod then
			local pt = tar:GetPosition()
			local text = tar.components.writable and tar.components.writable:GetText()
			-- print("[local]: text = %s.", text)
			tar:Remove()
			prod.Transform:SetPosition(pt:Get())
			print("[local]: tag ~= nil?", prod:HasTag(FTSignTag))
			print("[local]: fasttravel ~= nil?", prod.components.fasttravel)

			if prod.components.writeable then
				-- prod.components.writeable:BeginWriting(act.doer)
				prod.components.writeable:Write(act.doer, text)
				-- 这里没有作用啊，不知道是什么原因，难道是因为烧掉的没有text了？总之根据行为来看，一般烧掉的情况不多，比如我是用来尝试优化火烧方案的，所以先不做了，用到的不会很多导致很麻烦。
				print("[local]: writable ~= nil.")
			else
				print("[local]: writable == nil.")
			end
			return true
		end
	end
end)
sign_repair.priority = 8

AddComponentAction("EQUIPPED", "weapon", function(inst, doer, target, actions, right)
	if target:HasTag(FTSignTag) and target:HasTag("burnt") and doer then
		table.insert(actions, GLOBAL.ACTIONS.SIGN_REPAIR)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SIGN_REPAIR, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SIGN_REPAIR, "dolongaction"))

-- Component actions ---------------------

AddComponentAction("SCENE", "fasttravel", function(inst, doer, actions, right)
	if right then
		if inst:HasTag(FTSignTag) and not inst:HasTag("burnt") and not inst:HasTag("fire") then
			table.insert(actions, GLOBAL.ACTIONS.DESTINATION)
		end
	end
end)

-- Stategraph ----------------------------

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DESTINATION, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DESTINATION, "give"))
