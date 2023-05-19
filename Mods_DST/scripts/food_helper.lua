local require = require
if AddClassPostConstruct then require = GLOBAL.require end
local utils = require("utils")
local static = require("datas/static")

local slot
local amount
local best_recipe = { cal = 0, slots = { name = "", cal = 0 } }

local tags = {}
local ingredients = {}
local preparedfoods = {}

local function getCal(name)
    local cal = nil
    local exists = true

    if not ingredients[name] then
        if GLOBAL.Prefabs[name] then
            local inst = GLOBAL.Prefabs[name].fn() -- 这相当于SpawnPrefab吗？
            cal = inst.components and inst.components.edible and inst.components.edible.hungervalue or nil
            ingredients[name] = { tags = {}, cal = cal }
        end

        exists = false
    else
        cal = ingredients[name].cal
    end

    return cal, exists
end

local function insertBestIngre(pref, cal, minus)
    -- print("bestInsert")

    local tbl = best_recipe

    table.insert(tbl.slots, { name = pref, cal = cal })

    if cal ~= nil then
        if not tbl.cal then tbl.cal = 0 end
        tbl.cal = tbl.cal + cal
    end
    slot = slot - 1

    if minus then amount = amount - minus end
    -- TODO: 在这里列出所有饥饿度相似的多种食谱，或者我自己设置优先级覆盖食物，应该是做在sort里面，那就是很好的。如果只要最小值我确实只应该做min，但是sort后来可以有扩展性？
end

local function insertBestTag(recipe_needs, need, tag)
    -- local not_tags = recipe_needs.not_tags
    amount = need.atleast
    local slot_density = amount / slot

    for _, prefab in pairs(tag) do
        if prefab.tag then
            while slot > 0 and amount > 0 and prefab.tag >= slot_density do
                insertBestIngre(prefab.name, prefab.cal or getCal(prefab.name), prefab.tag)
                slot_density = amount / slot
            end

            if not (amount > 0 and slot > 0) then break end
        end
    end
end

local function init_ingre(names, tagname_table, cancook, candry)
    local cal
    local cal_cooked = nil
    local cal_dried = nil

    local name_cooked
    local name_dried

    local exists

    for _, name in pairs(names) do
        cal = getCal(name)

        name_cooked = name .. "_cooked"
        name_dried = name .. "_dried"

        if cancook then
            cal_cooked = getCal("cooked" .. name)
            if cal_cooked then name_cooked = "cooked" .. name

            else cal_cooked, exists = getCal(name .. "_cooked")
                if not exists then
                    cal_cooked = cal
                    ingredients[name_cooked] = { tags = {}, cal = cal_cooked }
                end
            end
        end

        if candry then
            cal_dried = getCal("dried" .. name)
            if cal_dried then name_dried = "dried" .. name

            else cal_dried, exists = getCal(name .. "_dried")
                if not exists then
                    cal_dried = cal
                    ingredients[name_dried] = { tags = {}, cal = cal_dried }
                end
            end
        end

        for tagname, tagval in pairs(tagname_table) do -- 可以这么写是为了以后tags可遍历。
            if not tags[tagname] then
                tags[tagname] = {}
            end

            local tbl = Findv(tags[tagname], name)
            tbl.tag = tagval
            -- ingredients[name].tags[tagname] = tagval -- 那这个tags完全和外界没有关系？

            if cancook then
                -- table.insert(tags[tagname].prefabs, { name = name_cooked, cal = cal_cooked })
                -- ingredients[name_cooked].tags[tagname] = tagval -- 那这个tags完全和外界没有关系？
                tbl = Findv(tags[tagname], name_cooked)
                tbl.tag = tagval
            end

            if candry then cal_cooked = getCal(name .. "_dried")
                -- table.insert(tags[tagname].prefabs, { name = name_dried, cal = cal_dried })
                -- ingredients[name_dried].tags[tagname] = tagval -- 那这个tags完全和外界没有关系？
                tbl = Findv(tags[tagname], name_dried)
                tbl.tag = tagval
            end
        end
    end
end

local function getMustSlots(recipe)
    local must_needs = recipe.must_needs

    for _, need in pairs(must_needs) do
        amount = need.atleast

        if ingredients[need.name] then
            while slot > 0 and amount > 0 do
                insertBestIngre(need.name, getCal(need.name), 1)
            end
        elseif tags[need.name] then
            insertBestTag(recipe, need, tags[need.name])
        end
    end
end

local function getOrSlots(recipe)
    local or_needs = recipe.or_needs
    local choice

    for _, need in pairs(or_needs) do
        if type(need) == "table" then

            for _, ingre in pairs(need) do
                if ingredients[ingre.name] then

                    ingre.cal = ingre.cal or getCal(ingre.name)
                    if ingre.atleast and ingre.atleast > 1 then
                        ingre.cal = ingre.cal and ingre.cal * ingre.atleast or nil
                    end

                elseif tags[ingre.name] then -- not tags
                    print("tags[ingre.name] error")
                    return
                end
            end

            Sort(need, { "cal" })

            choice = need[1]
            amount = choice.atleast
            while slot > 0 and amount > 0 do
                insertBestIngre(choice.name, choice.cal, 1)
            end
        else
            print("type(need) == table error")
        end
    end
end

local function getRemainSlots(recipe)
    local not_tags = recipe.not_tags

    for _, ingre in pairs(static.ingredients) do -- 而且考虑到not_tags和比较的大小，可能都可以做静态的表然后怎么样。
        if not Findv(not_tags, ingre.name) then
            local flag = true
            for tagname, _ in pairs(ingre.tags) do
                for _, not_tag in pairs(not_tags) do
                    if tagname == not_tag.name then
                        flag = false
                        break
                    end
                end
                if flag == false then break end
            end

            if flag then
                while slot > 0 do
                    insertBestIngre(ingre.name, ingre.cal)
                end
                break
            end
        end
    end
end

local function getBestRecipes(tbl)
    for _, recipe in pairs(tbl) do
        slot = 4
        best_recipe = { cal = 0, slots = {} }

        getMustSlots(recipe.needs)
        if (slot > 0) then
            getOrSlots(recipe.needs)
            if (slot > 0) then
                getRemainSlots(recipe.needs)
            end
        end

        recipe.best_recipe = best_recipe
        recipe.priority.cal = recipe.cal - recipe.best_recipe.cal
        -- ToString_Log("", recipe.name, recipe)
    end
end

local function main()
    ingredients = Init("ingredients", true, function(tbl)
        -- table.sort(static.ingredients, function(a, b)
        --     print(a.name, b.name)
        --     if static.farmok[a.name] and not static.farmok[b.name] then return true end
        --     if not static.farmok[a.name] and static.farmok[b.name] then return false end
        --     return Comp(a.cal, b.cal)
        -- end)
    end)
    tags = Init("tags", false, function(tbl)
        -- for k, tag in pairs(tbl) do
        --     table.sort(tag, function(a, b)
        --         if static.farmok[a.name] and not static.farmok[b.name] then return true end
        --         if not static.farmok[a.name] and static.farmok[b.name] then return false end

        --         if static.farmok[a.name] and static.farmok[b.name] then return Comp(a, b, { "weight" }) end
        --         if not static.farmok[a.name] and not static.farmok[b.name] then return Comp(a, b, { "weight" }) end

        --         return false
        --     end)
        --     -- Sort(tag, "weight")
        -- end
        -- Write({ tags = tbl, })
    end)
    preparedfoods = Init("preparedfoods", false, function(tbl)
        getBestRecipes(tbl)
        Sort(tbl, { "priority", "cal" })
        Write({ preparedfoods = tbl, })
    end)
end

if AddClassPostConstruct then
    AddClassPostConstruct("widgets/statusdisplays", function() -- 和加载时间有关，越晚越好。
        main()
    end)
else
    main()
    print("done.")
end
