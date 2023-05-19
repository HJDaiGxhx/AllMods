---@diagnostic disable
name = "All Mods"
description = "None."
--[[ 
    1. fast_travel
    2. merm_kingdom
    3. multi_cook
    4. lazy_set
    5. winter_gift

    6. 因为每次拆家具只有一半材料使得我对于装修这件事产生了潜意识的恐惧与畏缩心理，所以希望能修改别人的那个mod，使得装了东西的盒子能放在物品栏，甚至同类同皮肤叠加。

    7. 温蒂的专属合成感觉工厂化过于弱了，我希望她那个骨灰坛可以设计为放四个花瓣在里面，一段时间后自己掉落哀悼荣耀，对阿比盖尔进行更多的加强；而另一方面骨灰坛环绕着花朵，风格也是温蒂的那种，所以可以设计为定期在周围产生花朵，甚至用它和蜂箱搭配，虽然没什么必要，使得花朵能够更方便的农场。

    8. 
]]

author = "local"
version = "1.1.0"

forumthread = ""

api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dst_compatible = true

client_only_mod = false
all_clients_require_mod = true
-- server_filter_tags = { "fast travel" }

priority = 0

configuration_options =
{
    {
        name = "fast_travel",
        label = "Fast Travel [Mod]",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = true,
        type = "script"
    },
    {
        name = "Travel_Cost",
        label = "Travel Cost",
        options =
        {
            { description = "Very low", data = 128 },
            { description = "Low", data = 64 },
            { description = "Normal", data = 32 },
            { description = "High", data = 22.6 }
        },
        default = 32,
    },
    {
        name = "Ownership",
        label = "Ownership Restriction?",
        options =
        {
            { description = "Enable", data = true },
            { description = "Disable", data = false }
        },
        default = false,
    },
    {
        name = "merm_kingdom",
        label = "Merm Kingdom [Mod]",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = true,
        type = "script"
    },
    {
        name = "multi_cook",
        label = "Multi Cook [Mod]",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = true,
        type = "script"
    },
    {
        name = "lazy_set",
        label = "Lazy Set [Mod]",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = true,
        type = "script"
    },
    {
        name = "tentacle", -- 感觉这种细小的改动如果能做到那个Forest界面上的话就很好。
        label = "tentacle",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = true,
    },
    {
        name = "orangeamulet",
        label = "orangeamulet",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = false,
    },
    {
        name = "winter_gift",
        label = "Winter Gift [Mod]",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = true,
        type = "script"
    },
    {
        name = "bonusgift_day",
        label = "How Long Can Get BigGift?",
        options =
        {
            { description = "4(Vallina)", data = 4 },
            { description = "8", data = 8 },
            { description = "16", data = 16 },
            { description = "24", data = 16 },
        },
        default = 16,
    },
    {
        name = "notation",
        label = "BigGift Notation",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = true,
    },
    {
        name = "food_helper",
        label = "food_helper",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = false,
        type = "script",
    },
    {
        name = "debug",
        label = "Debug",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = false,
    },
    {
        name = "easy_package",
        label = "easy_package",
        options =
        {
            { description = "Open", data = true },
            { description = "Close", data = false },
        },
        default = true,
        type = "script",
    },
}
