local TUNING = GLOBAL.TUNING
local SpawnPrefab = GLOBAL.SpawnPrefab

-- others
local require = GLOBAL.require
local EventHandler = GLOBAL.EventHandler
local Action = GLOBAL.Action
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler
local Lerp = GLOBAL.Lerp
local FindWalkableOffset = GLOBAL.FindWalkableOffset
local PI = GLOBAL.PI
local Vector3 = GLOBAL.Vector3
local debug = GLOBAL.debug
local GetPlayer = GLOBAL.GetPlayer
local IsHUDPaused = GLOBAL.IsPaused
local TheInput = GLOBAL.TheInput
local TheFrontEnd = GLOBAL.TheFrontEnd
local TheSim = GLOBAL.TheSim

---------------OVERLOAD CROP:HARVEST---------------

local H_INSTALLED = GLOBAL.IsDLCInstalled(GLOBAL.PORKLAND_DLC)
local H_ENABLED = GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC)

if H_INSTALLED and H_ENABLED then

	local Crop = require "components/crop"
	local ProfileStatsAdd = GLOBAL.ProfileStatsAdd

	function Crop:Harvest(harvester)
		
		if self.matured or self.withered then
		
			local product = nil
			if self.grower and self.grower:HasTag("fire") or self.inst:HasTag("fire") then
			
				local temp = SpawnPrefab(self.product_prefab)
				if temp.components.cookable and temp.components.cookable.product then
					product = SpawnPrefab(temp.components.cookable.product)
				else
					product = SpawnPrefab("seeds_cooked")
				end
				temp:Remove()
			else
				product = SpawnPrefab(self.product_prefab)
			end	

			if product then
				self.inst:ApplyInheritedMoisture(product)
			end
			
			harvester.components.inventory:GiveItem(product, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
			ProfileStatsAdd("grown_"..product.prefab) 
			
			self.matured = false
			self.withered = false
			self.inst:RemoveTag("withered")
			self.growthpercent = 0
			
			if harvester:HasTag("plantkin") then -- !! but farmplot will never be emptied wither. However crops can be dug up by a shover.
			
				self:DoGrow(0)
			
				local dt = 2
				self.task = self.inst:DoPeriodicTask(dt, function() self:DoGrow(dt) end)
			else
				self.product_prefab = nil

				if self.grower and self.grower.components.grower then
					self.grower.components.grower:RemoveCrop(self.inst)
					self.grower = nil
				else
					self.inst:Remove()
				end
			end
			
			return true
		end
	end
end

---------------ADD COM TO PLANT_NORMAL---------------

local function ondug(inst, worker)
	
	local crop = inst.components.crop
	
	if crop.matured then
		inst.components.lootdropper:SpawnLootPrefab(crop.product_prefab)		
	end
	
	if crop.grower and crop.grower.components.grower then
		crop.grower.components.grower:RemoveCrop(inst)
		crop.grower = nil
	else
		inst:Remove()
	end
end

local function AddCom(inst)
				
	if GetPlayer():HasTag("plantkin") then  -- plantkin only in DLC3
	
		inst:AddTag("plant")
		
		inst:AddComponent("lootdropper")			

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.DIG)
		inst.components.workable:SetWorkLeft(1)
		inst.components.workable:SetOnFinishCallback(ondug)
	end
end

AddPrefabPostInit("plant_normal", AddCom)




