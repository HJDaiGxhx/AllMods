local SpawnPrefab = GLOBAL.SpawnPrefab
local Vector3 = GLOBAL.Vector3
local TheInput = GLOBAL.TheInput
-- local ThePlayer = GLOBAL.ThePlayer
-- local ThePlayer
local TheSim = GLOBAL.TheSim

local widgetprops = {
	"numslots",
	"acceptsstacks",
	"usespecificslotsforitems",
	"issidewidget",
	"type",
	"widget",
	"itemtestfn",
	"priorityfn",
	"openlimit"
}
local containers = require("containers")

AddComponentPostInit("container", function(self)
	self.WidgetSetup = function(self, prefab, data)
		for i, v in ipairs(widgetprops) do
			GLOBAL.removesetter(self, v)
		end

		containers.widgetsetup(self, prefab, data)
		self.inst.replica.container:WidgetSetup(prefab, data)

		if prefab ~= "cookpot" then
			for i, v in ipairs(widgetprops) do
				GLOBAL.makereadonly(self, v) -- 是你？？？
			end
		end
	end
end)

local pots = { "cookpot" }
for k, pot in pairs(pots) do
	AddPrefabPostInit(pot, function(inst)
		inst.components.container.acceptsstacks = true
		inst.replica.container.acceptsstacks = true
	end)
end

-- stack = remain in inst num, else will goto ThePlayer's inventory.
local function dropFood(inst, stack)
	for _, v in pairs(inst.components.container.slots) do
		if v.components.stackable then
			local v_stack = v.components.stackable:StackSize()
			if v_stack > stack then
				local food = SpawnPrefab(v.prefab)
				food.components.stackable:SetStackSize(v_stack - stack)
				if food.components.perishable then
					food.components.perishable:SetPercent(v.components.perishable:GetPercent())
				end
				GLOBAL.ThePlayer.components.inventory:GiveItem(food, nil,
					Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))

				v.components.stackable:SetStackSize(stack)
			end
		end
	end
end

local function acceptsstacks(inst, TorF) -- inst == cookpot
	if inst.components.container then
		local newA = not inst.components.container.acceptsstacks
		if TorF then newA = TorF end

		local x, y, z = inst.Transform:GetWorldPosition()
		local pots = TheSim:FindEntities(x, y, z, 1640, { "stewer" })

		for k, pot in pairs(pots) do -- 其实我自己玩的时候完全就一两次有这种情况，我就觉得为什么我要为了某种安全性去这么写。
			if pot.components.container then
				pot.components.container.acceptsstacks = newA
				pot.replica.container.acceptsstacks = newA

				if newA == false then
					dropFood(pot, 1)
				end
			end
		end
	end
end

local TOGGLEPOT = AddAction("TOGGLEPOT", "toggle", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and not act.target:HasTag("burnt") and
		not act.target:HasTag("fire") then
		acceptsstacks(act.target)
		return true
	end
end)
TOGGLEPOT.priority = 8

AddComponentAction("SCENE", "stewer", function(inst, doer, actions, right)
	if right and not inst:HasTag("burnt") and not inst:HasTag("fire") and inst.components.container then
		table.insert(actions, GLOBAL.ACTIONS.TOGGLEPOT)
	end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(TOGGLEPOT, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(TOGGLEPOT, "give"))

AddComponentPostInit("stewer", function(self, inst)
	local old_StartCooking = self.StartCooking -- StartCooking, 我觉得也可以重新复制一遍，会有什么区别吗？
	self.StartCooking = function(self, doer)
		local accept = self.inst.components.container:AcceptsStacks()
		if accept then
			local stack = 9999

			for _, v in pairs(self.inst.components.container.slots) do
				if v.components.stackable then
					stack = math.min(v.components.stackable:StackSize(), stack) -- 仔细一想四个槽是都要放的。
				else
					stack = 1
					break
				end
			end
			-- 强制掉落多余的食材
			dropFood(inst, stack)

			self.foodstack = stack
			stack = nil
		end

		return old_StartCooking(self, doer) -- 时间还是一份的
	end

	local old = self.Harvest
	self.Harvest = function(self, harvester)
		-- local accept = self.inst.components.container:AcceptsStacks() -- 但这样就使得如果存档的时候正在做多个菜，读档之后默认调成单个的，就只能获得单个的了，但是我又觉得默认进游戏是单个比较好啊？
		-- p(accept)
		if self.foodstack then
			if not self.done then -- 未完成烹饪禁止收获
				return
			end
			local product, stack, spoilage = self.product, self.foodstack, self.product_spoilage
			self.foodstack = nil
			-- 在收获的时候，补上整组烹饪的数量
			if stack and stack > 1 then
				if product and harvester and harvester.components.inventory then
					local food = product ~= "spoiledfood" and SpawnPrefab(product) or SpawnPrefab("spoiled_food")
					if food.components.stackable then
						food.components.stackable:SetStackSize(stack - 1)
						-- 怪不得这里是-1，我说明明就是没有理解啊，原来是为了配合后面的old函数，它会生成一个，惊了。
					end
					if food.components.perishable then
						food.components.perishable:SetPercent(spoilage)
					end
					harvester.components.inventory:GiveItem(food, nil,
						Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())), true)
				end
			end
			product, stack, spoilage = nil, nil, nil
		end

		return old(self, harvester)
	end

	local old = self.OnSave
	self.OnSave = function(self)
		local data = old(self)
		if data and self.foodstack then
			data.foodstack = self.foodstack
		end
		return data
	end

	local old = self.OnLoad
	self.OnLoad = function(self, data)
		local old_return = old(self, data)
		if data.foodstack then
			self.foodstack = data.foodstack
		end
		return old_return
	end
end)
