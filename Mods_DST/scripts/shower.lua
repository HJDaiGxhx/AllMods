require("utils")

local function main()
    Init("shower", false, function(tbl)
        local date = os.date("*t")
        local string = date.year .. "/" .. date.month .. "/" .. date.day ..
            " " .. date.hour .. ":" .. date.min .. ":" .. date.sec
        table.insert(tbl, { string, date = date })
    end)
end

main()
