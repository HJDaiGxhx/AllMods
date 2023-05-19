---@diagnostic disable: deprecated, param-type-mismatch

local ingame = GLOBAL and true or false
if ingame then
    local env = GLOBAL.getfenv()

    for k, _ in pairs(GLOBAL) do
        if not env[k] then env[k] = GLOBAL.rawget(GLOBAL, k) end
    end

    setfenv(1, env)
end

function Player()
    return ThePlayer
end

function p(string) print(string) end

if ingame then
    p = function(string) print("[AllMods]: " .. string) end
end

local function p_log(string) io.write(string) end

function SendCommand(fnstr)
    -- local b, c, d = GLOBAL.TheSim:ProjectScreenPos(GLOBAL.TheSim:GetPosition())
    local localside = GLOBAL.TheNet:GetIsClient() and GLOBAL.TheNet:GetIsServerAdmin()
    if localside then
        GLOBAL.TheNet:SendRemoteExecute(fnstr)
    else
        GLOBAL.ExecuteConsoleCommand(fnstr)
    end
end

function YouAreGOD()
    local commands = {
        "ThePlayer.components.builder:GiveAllRecipes()",
        "ThePlayer.components.combat.damagemultiplier = 100",
        "c_godmode()", -- c_godmode(ThePlayer)
        -- "c_speedmult(40,\"me\")",
    }

    AddClassPostConstruct("widgets/statusdisplays", function() -- 和加载时间有关，越晚越好。
        for key, value in pairs(commands) do
            SendCommand(value)
        end
    end)
end

local comptypes = {
    -- SCENE		using an object in the world
    SCENE = --args: inst, doer, actions, right
    { inst = 1, doer = 2, actions = 3, right = 4 },
    -- USEITEM		using an inventory item on an object in the world
    USEITEM = --args: inst, doer, target, actions, right
    { inst = 1, doer = 2, target = 3, actions = 4, right = 5 },
    -- POINT		using an inventory item on a point in the world
    POINT = --args: inst, doer, pos, actions, right, target
    { inst = 1, doer = 2, pos = 3, actions = 4, right = 5, target = 6 },
    -- EQUIPPED		using an equiped item on yourself or a target object in the world
    EQUIPPED = --args: inst, doer, target, actions, right
    { inst = 1, doer = 2, target = 3, actions = 4, right = 5 },
    -- INVENTORY	using an inventory item
    INVENTORY = --args: inst, doer, actions, right
    { inst = 1, doer = 2, actions = 3, right = 4 },
    ISVALID = --args: inst, action, right
    { inst = 1, action = 2, right = 3 },
}
function NewAction(name, desc, comptype, compneed, statetype, compfn, actfn)
    local ACT = AddAction(name, desc, function(act)
        actfn(act)
        return true
    end)

    AddComponentAction(comptype, compneed, function(...)
        if compfn(...) then
            local params = { ... }
            local actions = params[comptypes[comptype].actions]
            table.insert(actions, ACT)
        end
    end)

    AddStategraphActionHandler("wilson", ActionHandler(ACT, statetype))
    AddStategraphActionHandler("wilson_client", ActionHandler(ACT, statetype))
end

function Same(item1, item2)
    if item1.prefab == item2.prefab and item1.skinname == item2.skinname then return true end
    return false
end

function Cancel(per, debug)
    if per then
        per:Cancel()
        if debug then print("per Cancel") end
        per = nil
    end
end

function Findk(table, name)
    for entryname, entry in pairs(table) do
        if entryname == name then
            return entry
        end
    end
    return nil
end

function Findv(table, name)
    for _, entry in pairs(table) do
        if entry.name == name then
            return entry
        end
    end
    return nil
end

function Copy(tbl)
    local block = {}

    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            block[k] = Copy(v)
        end
    else
        block = tbl
    end

    return block
end

local static = require("datas/static")
function Init(name, needindex, updatefn)
    --[[     local tbl = {}

    if static[name] then
        if needindex then
            for _, entry in pairs(static[name]) do
                tbl[entry.name] = entry
            end
        else tbl = static[name] end
    else
        print("NO static[name]!!!!")
    end

    if updatefn then updatefn(tbl) end
    return tbl
 ]]
    local tbl = {}
    local static_tbl = require("datas/" .. name)
    if static_tbl ~= true then
        if needindex then
            for _, entry in pairs(static_tbl) do
                tbl[entry.name] = entry
            end
        else tbl = static_tbl end
    end

    if updatefn then
        updatefn(tbl)
        Write({ name = name, tbl = tbl })
    end
    return tbl
end

-- false是不交换，true是交换的意思？
function Comp(a, b, strings)
    if type(strings) == "table" then
        for _, string in pairs(strings) do
            if a then a = a[string]
            else print("no a..." .. string .. "!!!") end
            if b then b = b[string]
            else print("no b..." .. string .. "!!!") end
        end
    end

    if a and not b or a and b and a < b then
        return true
    end
    return false
end

function Sort(tbl, strings)
    table.sort(tbl, function(a, b)
        return Comp(a, b, strings)
    end)
end

function ToString(tabs, namefromparent, block_p, ...)
    if type(block_p) == "table" then

        if type(namefromparent) == "string" then
            namefromparent = namefromparent .. " = "
        else
            namefromparent = ""
        end

        local start = tabs .. namefromparent .. "{ "
        local finish = tabs .. "},"
        local tab = false

        if (#block_p <= 3) then
            local str = start

            for k, v in pairs(block_p) do
                if type(v) ~= "table" then
                    if type(v) == "string" then str = str .. k .. " = \"" .. v .. "\", "
                    else str = str .. k .. " = " .. v .. ", " end
                end
            end

            for k, v in pairs(block_p) do
                if type(v) == "table" then
                    if str ~= "" then
                        print(str)
                        tab = true
                        str = ""
                    end
                    ToString(tabs .. "    ", k, v)
                end
            end
            if tab then str = tabs end
            print(str .. "},")
        else
            print(start)
            for k, v in pairs(block_p) do ToString(tabs .. "    ", k, v) end
            print(finish)
        end

    elseif type(block_p) == "string" then
        print(tabs .. namefromparent .. " = \"" .. block_p .. "\", ")
    else
        print(tabs .. namefromparent .. " = " .. block_p .. ", ")
    end
end

function ToString_Log(tabs, elemname, elem, sad)
    if type(elemname) == "string" then elemname = elemname .. " = "
    else elemname = "" end

    if type(elem) == "table" then
        local start = tabs .. elemname .. "{"
        local finish = "},\n"
        if sad then finish = "}\n" end

        print(start)
        local size = 0
        for k, v in pairs(elem) do
            size = size + 1
            if type(v) ~= "table" then
                ToString_Log(" ", k, v)
                size = size - 1
            end
        end

        if size > 0 then
            print("\n")
            for k, v in pairs(elem) do
                if type(v) == "table" then
                    ToString_Log(tabs .. "    ", k, v)
                end
            end
            print(tabs)
        end
        print(finish)

    else
        if type(elem) == "string" then elem = "\"" .. elem .. "\"" end
        if elem == true then elem = "true" elseif elem == false then elem = "false" end
        print(tabs .. elemname .. elem .. ",")
    end
end

-- local homepath = "C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/mods/"
-- local objname = "AllMods"
function Log(filename, fn)
    if AddClassPostConstruct then
        fn()
        return
    end

    local path = "datas/" .. filename .. ".lua"
    local file = io.open(path, "w+")
    print = p_log
    ToString = ToString_Log

    io.output(path)
    fn()
    io.close(file)
end

function Write(tbls)
    if tbls.name then
        Log(tbls.name, function()
            ToString("", "local " .. tbls.name, tbls.tbl, true)
            print("return " .. tbls.name)
        end)
    else for tblname, tbl in pairs(tbls) do
            if type(tbl) == "table" then
                Log(tblname, function()
                    ToString("", "local " .. tblname, tbl, true)
                    print("return " .. tblname)
                end)
            else
                print("write failed!!!")
            end
        end
    end
end
