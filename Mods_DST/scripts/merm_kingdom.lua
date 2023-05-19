local SpawnPrefab = GLOBAL.SpawnPrefab
local Vector3 = GLOBAL.Vector3
local TheFrontEnd = GLOBAL.TheFrontEnd

-- local function p(string)
-- 	print("[mermking]:")
-- 	print(string)
-- end

AddModRPCHandler("MermKing", "youareGODClient", function()
	print("youareGODClient")
	-- local ThePlayer = GLOBAL.ThePlayer
	GLOBAL.ThePlayer.components.builder:GiveAllRecipes()
	GLOBAL.ThePlayer.components.combat.damagemultiplier = 100
	GLOBAL.c_godmode(GLOBAL.ThePlayer)
end)

AddModRPCHandler("MermKing", "getManager", function()
	print(GLOBAL.TheWorld.components.mermkingmanager)
	return GLOBAL.TheWorld.components.mermkingmanager
end)

local function youareGOD()
	-- local ThePlayer = GLOBAL.ThePlayer
	-- if ThePlayer then -- you are god!!!!
	-- 	ThePlayer.replica.builder:GiveAllRecipes()
	-- 	ThePlayer.replica.combat.damagemultiplier = 100
	-- 	GLOBAL.c_godmode(ThePlayer)
	-- end
	-- SendModRPCToServer(MOD_RPC.MermKing.youareGODClient)
	print("youareGOD")
end

local function RGBA(r, g, b, a)
	return { r / 255, g / 255, b / 255, a or 1 }
end

local Badge = require("widgets/badge")
-- local HungerBadge = require("widgets/hungerbadge")
local GREEN = RGBA(21, 102, 117, 0.6)
local GREEN2 = RGBA(106, 181, 148)
local GREEN3 = RGBA(85, 145, 119)
local QING = RGBA(159, 252, 253)
local QING2 = RGBA(145, 179, 181)
local BLUE = RGBA(50, 130, 246, 0.5)

local CHECK_MODS = {
	["workshop-376333686"] = "COMBINED_STATUS",
	["CombinedStatus"] = "COMBINED_STATUS",
}
local has_mod = false
--If the mod is a]ready loaded at this point
for mod_name, key in pairs(CHECK_MODS) do
	-- HAS_MOD[key] = HAS_MOD[key] or (GLOBAL.KnownModIndex:IsModEnabled(mod_name) and mod_name)
	if (GLOBAL.KnownModIndex:IsModEnabled(mod_name) and mod_name) then
		has_mod = true
		break
	end
end
--If the mod hasn't loaded yet
if not has_mod then
	for k, v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
		if CHECK_MODS[v] then
			has_mod = true
			break
		end
	end
end

local POS = { -120, 20, 0 }
if has_mod then
	POS = { -125, 35, 0 }
end

-- now you can check mermking health---------------------------------------------------
-- by action
local CHECK_KING = AddAction("CHECK_KING", "Check", function(act)
	if act.doer ~= nil and act.doer:HasTag("player") and act.doer.components.talker then
		local mermking = GLOBAL.FindEntity(act.doer, 1640, nil, { "mermking" })
		-- local mermking = GLOBAL.TheWorld.components.mermkingmanager.king
		local talk = act.doer.components.talker

		if mermking then
			local string = "Hunger: " .. mermking.components.hunger.current ..
				"/" .. mermking.components.hunger.max .. "\nHealth: " .. mermking.components.health.currenthealth
			talk:Say(string)
		else
			talk:Say("Merm king is not present.")
		end

		return true
	end
end)
CHECK_KING.priority = 8

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
	if right then
		table.insert(actions, GLOBAL.ACTIONS.CHECK_KING) -- 啊我真的好讨厌试错，非常讨厌这种枚举法，这种变量控制法
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(CHECK_KING, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(CHECK_KING, "give"))

-- UPGRADE: by widget

local function badgeRefresh(inst)
	-- p(inst.mermking.components.hunger:GetPercent())
	-- p(inst.mermking.components.hunger.current)
	inst.mermking_stomach:SetPercent(inst.mermking.components.hunger:GetPercent(), 200)
end

--[[ badgeInit:
refind the mermking, if exist then show hidden badge, because periodic task is slow first refresh the badge, then go to periodic refresh.]]
local function badgeShow(inst, king)
	inst.mermking = king -- 惊了，这优化也……没有极限是吧。甚至不用再多一个变量，每次去manager那里取就行了。

	if inst.mermking then
		badgeRefresh(inst)
		inst.mermking_stomach:Show()

		inst.per = inst.inst:DoPeriodicTask(19, function() -- TUNING.total_day_time/25
			if inst.mermking then -- 我本来不想写多余的一行，但考虑到在我自己的档使用的时候，实在不想因为极致的优化而增加闪退风险。不对啊……不是因为这个。
				badgeRefresh(inst)
			end
		end)
	end
end

local function badgeHide(inst, manager)
	inst.mermking_stomach:Hide()
	if inst.per then inst.per:Cancel() end -- 这个函数是哪里冒出来的啊……

	manager.inst:RemoveEventCallback("death", badgeHide, manager.king)
end

local status = nil
AddClassPostConstruct("widgets/statusdisplays", function(inst)
	-- youareGOD()
	status = inst

	inst.mermking_stomach = inst:AddChild(Badge(nil, nil, GREEN3, "status_hunger", nil, nil, true))
	inst.mermking_stomach:SetPosition(POS[1], POS[2], POS[3])
	inst.mermking_stomach:Hide()

	local manager = GLOBAL.TheWorld.components.mermkingmanager
	if manager then
		-- [[when king spawn or dead, badge should be triggered by event.]]
		if manager.king then
			badgeShow(inst, manager.king)
			manager.inst:ListenForEvent("death", function() badgeHide(inst, manager) end, manager.king)
		end

		local old = manager.CreateMermKing
		manager.CreateMermKing = function(self, ...)
			old(self, ...)

			-- inst.mermking_stomach:PulseGreen() -- want boatmeter anim!
			badgeShow(inst, self.king)
			self.inst:ListenForEvent("death", function() badgeHide(inst, self) end, self.king)
		end
	end

	-- [[when player give king food, badge should be triggered by stategraph..?]]
end)

AddStategraphPostInit("mermking", function(self)
	for k, v in pairs(self.states) do

		if v.name == 'eat' then
			local old = v.onenter

			v.onenter = function(self, ...)
				status.mermking_stomach:PulseGreen()
				status.inst:DoTaskInTime(0.1, function() badgeRefresh(status) end)
				old(self, ...)
			end
		end
	end
end)

-- now player with a disguise can fake mermguard and hire them
local function LocalShouldAcceptItem(inst, item, giver)
	if inst:HasTag("mermguard") and inst.king ~= nil then
		return false
	end

	if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
		inst.components.sleeper:WakeUp()
	end

	return giver:HasTag("merm") and
		-- not (inst:HasTag("mermguard") and giver:HasTag("mermdisguise"))
		((item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD) or
			(item.components.edible and inst.components.eater:CanEat(item)) or
			(
			item:HasTag("fish") and
				not (TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:IsCandidate(inst))))
end

local merms = { "merm", "mermguard" }
for k, v in pairs(merms) do
	AddPrefabPostInit(v, function(inst)
		if inst.components and inst.components.trader then
			inst.components.trader:SetAcceptTest(LocalShouldAcceptItem)
		end
	end)
end
