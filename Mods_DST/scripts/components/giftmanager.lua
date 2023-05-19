local test = true
local function p(string)
end

local random_gift1 =
{
    moonrocknugget = 2,
    gears = 1,
    silk = .3,
    sewing_kit = .2,

    --gems
    redgem = .2,
    bluegem = .2,
    greengem = .1,
    orangegem = .1,
    yellowgem = .1,

    --hats
    -- beefalohat = .5,
    -- winterhat = .5,
    -- earmuffshat = .5,
    -- catcoonhat = .5,
    molehat = .5,
}

local random_gift2 =
{
    gears = .2,
    moonrocknugget = .2,

    --gems
    redgem = .1,
    bluegem = .1,
    greengem = .1,
    orangegem = .1,
    yellowgem = .1,

    --special
    -- walrushat = .2,
    -- cane = .2,
    -- panflute = .1,
}

local function UpdateLights(inst, light)
    local was_on = inst.Light:IsEnabled()

    local batteries = inst.forceoff ~= true and
        inst.components.container:FindItems(function(item) return item:HasTag("lightbattery") end) or {}

    local lightcolour = Vector3(0, 0, 0)
    local num_lights_on = 0
    for i, v in ipairs(batteries) do
        if v.ornamentlighton then
            lightcolour = lightcolour + Vector3(v.Light:GetColour())
            num_lights_on = num_lights_on + 1
        end
    end

    if light ~= nil then
        local slot = inst.components.container:GetItemSlot(light)
        if slot ~= nil then
            inst.AnimState:OverrideSymbol("plain" .. slot, light.winter_ornament_build or "winter_ornaments",
                light.winter_ornamentid .. (light.ornamentlighton and "_on" or "_off"))
        end
    end

    if num_lights_on == 0 then
        if was_on then
            inst.Light:Enable(false)
            inst.AnimState:ClearBloomEffectHandle()
            inst.AnimState:SetLightOverride(0)
        end
    else
        if not was_on then
            inst.Light:Enable(true)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.AnimState:SetLightOverride(0.2)
        end

        inst.Light:SetRadius(light_str[1].radius)
        inst.Light:SetFalloff(light_str[1].falloff)
        inst.Light:SetIntensity(light_str[1].intensity)

        lightcolour:Normalize()
        inst.Light:SetColour(lightcolour.x, lightcolour.y, lightcolour.z)
    end
end

local function NobodySeesPoint(pt)
    if TheWorld.Map:IsPointNearHole(pt) then
        return false
    end
    for i, v in ipairs(AllPlayers) do
        if CanEntitySeePoint(v, pt.x, pt.y, pt.z) then
            return false
        end
    end
    return true
end

local INLIMBO_TAGS = { "INLIMBO" }
local function NoOverlap(pt)
    return NobodySeesPoint(pt) and #TheSim:FindEntities(pt.x, 0, pt.z, .75, nil, INLIMBO_TAGS) <= 0
end

-- 或许可以一劳永逸的是，在trygift前调用保存世界的函数，那么闪退了也无所畏惧。
-- 感觉还是有一点鸡肋，因为好像保存要一点时间，在这期间出错了就没有保存下来。
local GiftManager = Class(function(self, inst)
    self.inst = inst
    self.gift_trees = {}
    -- self.player = nil

    self.giftgiving = false
    self.bonusgift = false

    self.per = {}
    self.previousgiftday = 0
    self.GIFTING_PLAYER_RADIUS_SQ = 25 * 25
    -- MOD
    self.DAY = 4
    self.notation = false

    -- 这个在晚上开始和晚上结束的时候都调用了，奇怪。
    self.inst:WatchWorldState("isnight", function()
        if TheWorld.state.isnight then
            p("isnightfirst")
            self:periodic_trygifting()
        else
            p("isnightlast")
            for k, v in pairs(self.per) do
                p(v)
                v:Cancel()
                p("isnight Cancel")
            end
            self.per = {}
        end
    end)
end)

function GiftManager:notationfn()
    if self:GetDaysSinceLastGift() == self.DAY - 1 then
        for k, player in pairs(AllPlayers) do
            if player.components.talker then
                player.components.talker:Say("Tomorrow, BIGgifts! Happy!")
            end
        end
    end
end

function GiftManager:GetDaysSinceLastGift()
    -- p(TheWorld.state.cycles)
    -- p(self.previousgiftday)
    return TheWorld.state.cycles - self.previousgiftday
end

function GiftManager:OnGiftGiven()
    self.previousgiftday = TheWorld.state.cycles
end

--[[ food*1-3 + charcoal

   food*1-3 + basic_ornament + random_gift1 + trinket

   food*4-6 + fancy/event_ornament + random_gift1 + random_gift2 ]]
function GiftManager:choosegift(inst, loot)
    p("choosegift")

    local fully_decorated = inst.components.container:IsFull()

    if self:GetDaysSinceLastGift() >= self.DAY then
        self.bonusgift = true
        p("GetDaysSinceLastGift() >= 4")

        table.insert(loot,
            { prefab = "winter_food" .. math.random(NUM_WINTERFOOD),
                stack = math.random(3) + (fully_decorated and 3 or 0) })
        table.insert(loot, { prefab = not fully_decorated and GetRandomBasicWinterOrnament()
            or math.random() < 0.5 and GetRandomFancyWinterOrnament()
            or GetRandomFestivalEventWinterOrnament() })
        table.insert(loot, { prefab = weighted_random_choice(random_gift1) }) -- threshold = 6.7

        if fully_decorated then
            table.insert(loot, { prefab = weighted_random_choice(random_gift2) }) -- threshold = 1.4
        else
            table.insert(loot, { prefab = PickRandomTrinket() })
        end
    else
        table.insert(loot, { prefab = "winter_food" .. math.random(NUM_WINTERFOOD), stack = math.random(3) })
        table.insert(loot, { prefab = "charcoal" })
    end

    return loot
end

function GiftManager:spawngift(inst, player, loot)
    p("spawngift")

    local items = {}
    for i, v in ipairs(loot) do
        local item = SpawnPrefab(v.prefab)
        if item ~= nil then
            if item.components.stackable ~= nil then
                item.components.stackable.stacksize = math.max(1, v.stack or 1)
            end
            table.insert(items, item)
        end
    end

    if #items > 0 then
        local gift = SpawnPrefab("gift")
        gift.components.unwrappable:WrapItems(items)
        for i, v in ipairs(items) do
            v:Remove()
        end
        local pos = inst:GetPosition()
        local radius = inst:GetPhysicsRadius(0) + .7 + math.random() * .5
        local theta = inst:GetAngleToPoint(player.Transform:GetWorldPosition()) * DEGREES
        local offset =
        FindWalkableOffset(pos, theta, radius, 8, false, true, NoOverlap) or
            FindWalkableOffset(pos, theta, radius + .5, 8, false, true, NoOverlap) or
            FindWalkableOffset(pos, theta, radius, 8, false, true, NobodySeesPoint) or
            FindWalkableOffset(pos, theta, radius + .5, 8, false, true, NobodySeesPoint)
        if offset ~= nil then
            gift.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
        else
            inst.components.lootdropper:FlingItem(gift)
        end
    end
end

function GiftManager:dogifting(inst, player)
    p("dogifting")

    if not TheWorld.state.isnight then return end

    local loot = {}
    self:choosegift(inst, loot)
    self:spawngift(inst, player, loot)

    if inst.forceoff then
        inst:DoTaskInTime(1, function() inst.forceoff = false end, inst)
    end

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain")
    inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")

    return true
end

function GiftManager:treecheck(inst, player)
    if not inst or inst.components.container == nil or inst.components.container:IsEmpty()
    then return end -- 如果树被烧了或者砍了，对应后面两条筛选。

    local x, y, z = inst.Transform:GetWorldPosition()

    if player:GetDistanceSqToPoint(x, y, z) < self.GIFTING_PLAYER_RADIUS_SQ then
        -- p("distance ok")
        if CanEntitySeePoint(player, x, y, z) then
            p("CanEntitySeePoint")
            local batteries = inst.components.container:FindItems(function(item)
                return item:HasTag("lightbattery")
            end)

            if #batteries > 0 then
                p("maybe because of light")
                inst.forceoff = true
                UpdateLights(inst)
                -- 如果只挂了一个灯，.2秒后自己灭掉；不然.4秒左右后UpdateLights使它灭掉。
                self.inst:DoTaskInTime(.2, function()
                    if TheWorld.state.isnight and player:HasTag("sleeping") then
                        self:treecheck(inst, player)
                    end
                end)
            end
        else
            p("treecheck passed.")
            return true
        end
    else
        p("too far")
    end

    p("treecheck failed.")
    return false
end

function GiftManager:periodic_trygifting()
    self:notationfn()

    table.insert(self.per, self.inst:DoPeriodicTask(2, function()
        -- self.per = self.inst:DoPeriodicTask(2, function() -- 这里是真不知道到底怎么回事，返回的是表？
        -- 应该self.per是一个循环任务，不可能它每次都insert了啊？反正先这样写心理上觉得保险一些。
        p("DoPeriodicTask")

        if not IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then return end

        for key, player in pairs(AllPlayers) do -- AllPlayers or client and self.player???
            if player:HasTag("sleeping") then self:trygifting(player) end
        end
    end))
end

function GiftManager:trygifting(player)
    if self.giftgiving then return end
    if self:GetDaysSinceLastGift() <= 0 then
        p("self:GetDaysSinceLastGift() <= 0")
        return
    end -- OnLoad?

    self.giftgiving = true
    c_save()

    if not self.gift_trees or not next(self.gift_trees) then -- 极小概率事件，并且正常的话查找完也是nil。
        p("self.gift_trees nothing, try FindEntities")
        local x, y, z = player.Transform:GetPosition()
        self.gift_trees = TheSim:FindEntities(x, y, z, 1640, { "winter_tree" })
    end

    local giftgiven = false
    for key, inst in pairs(self.gift_trees) do
        if self:treecheck(inst, player) then
            self:dogifting(inst, player)
            giftgiven = true
        end
    end

    if giftgiven then
        for k, v in pairs(self.per) do
            p(v)
            v:Cancel()
            p("trygifting Cancel")
        end
        self.per = {}

        if self.bonusgift then
            self:OnGiftGiven()
            self.bonusgift = false
        end
    end

    self.giftgiving = false
end

function GiftManager:OnSave()
    return { previousgiftday = self.previousgiftday }
end

function GiftManager:OnLoad(data)
    self.previousgiftday = data.previousgiftday

    if TheWorld.state.isnight then
        p("OnLoad periodic_trygifting")
        self:periodic_trygifting()
    end
end

return GiftManager
