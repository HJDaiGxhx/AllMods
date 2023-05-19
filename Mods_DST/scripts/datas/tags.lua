local tags = {
    frozen = {
        { cal = 2.34375, weight = 2.34375, tag = 1, name = "ice",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_8_inv",},
        { name = "frozen",},
    },
    veggie = {
        { cal = 12.5, weight = 12.5, tag = 1, name = "rock_avocado_fruit_ripe",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "rock_avocado_fruit_ripe_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "garlic",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "onion",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "pepper_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "onion_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "garlic_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "pepper",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "potato_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "tomato",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "oceanfish_small_5_inv",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "cactus_meat",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "asparagus_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "carrot",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "tomato_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "carrot_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "potato",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "cactus_meat_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "asparagus",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "cutlichen_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "cutlichen",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "kelp",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "kelp_cooked",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "kelp_dried",},
        { cal = 25, weight = 25.0, tag = 1, name = "eggplant",},
        { cal = 25, weight = 25.0, tag = 1, name = "corn",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "red_cap",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "green_cap_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "green_cap",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "blue_cap",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "cactus_flower",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "moon_cap_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "blue_cap_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "corn_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "moon_cap",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_5_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "red_cap_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "eggplant_cooked",},
        { cal = 37.5, weight = 37.5, tag = 1, name = "pumpkin",},
        { cal = 37.5, weight = 37.5, tag = 1, name = "pumpkin_cooked",},
        { cal = 75, weight = 75.0, tag = 1, name = "mandrake",},
        { cal = 150, weight = 150.0, tag = 1, name = "cookedmandrake",},
        { name = "veggie",},
    },
    fat = {
        { cal = 25, weight = 25.0, tag = 1, name = "butter",},
        { name = "fat",},
    },
    dairy = {
        { cal = 12.5, weight = 12.5, tag = 1, name = "milkywhites",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "goatmilk",},
        { cal = 25, weight = 25.0, tag = 1, name = "butter",},
        { name = "dairy",},
    },
    fish = {
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "fishmeat_small",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "pondfish",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "fishmeat_small_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "pondeel",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "eel_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "eel",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "pondeel_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "fish_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "fish",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_1_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_3_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_8_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_4_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "fishmeat_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_7_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "fishmeat",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_1_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_9_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_6_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_2_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_6_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_7_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_2_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_8_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_9_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_4_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_3_inv",},
        { cal = 12.5, weight = 50.0, tag = 0.25, name = "barnacle_cooked",},
        { cal = 12.5, weight = 50.0, tag = 0.25, name = "barnacle",},
        { name = "fish",},
        { tag = 1, name = "wobster_sheller_land",},
    },
    monster = {
        { cal = 18.75, weight = 18.75, tag = 1, name = "cookedmonstermeat",},
        { cal = 18.75, weight = 18.75, tag = 1, name = "monstermeat_dried",},
        { cal = 18.75, weight = 18.75, tag = 1, name = "monstermeat",},
        { cal = 25, weight = 25.0, tag = 1, name = "durian_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "durian",},
        { name = "monster",},
    },
    egg = {
        { cal = 9.375, weight = 9.375, tag = 1, name = "bird_egg_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "bird_egg",},
        { cal = 25, weight = 6.25, tag = 4, name = "tallbirdegg",},
        { cal = 25, weight = 6.25, tag = 4, name = "tallbirdegg_cooked",},
        { name = "egg",},
    },
    fruit = {
        { cal = 12.5, weight = 12.5, tag = 1, name = "cave_banana_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "cave_banana",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "berries_cooked",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "berries",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "berries_juicy",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "berries_juicy_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "pomegranate_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "dragonfruit_cooked",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "pomegranate",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "dragonfruit",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "watermelon",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "watermelon_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "wormlight_lesser",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "fig",},
        { cal = 25, weight = 25.0, tag = 1, name = "wormlight",},
        { cal = 25, weight = 25.0, tag = 1, name = "durian",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "fig_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "durian_cooked",},
        { name = "fruit",},
    },
    magic = {
        { tag = 1, name = "nightmarefuel",},
        { cal = 75, weight = 75.0, tag = 1, name = "mandrake",},
        { cal = 150, weight = 150.0, tag = 1, name = "cookedmandrake",},
        { name = "magic",},
    },
    seed = {
        { cal = 9.375, weight = 9.375, tag = 1, name = "acorn",},
        { cal = 9.375, weight = 9.375, tag = 1, name = "acorn_cooked",},
        { name = "seed",},
    },
    decoration = {
        { cal = 0, weight = 0.0, tag = 1, name = "forgetmelots",},
        { cal = 1, weight = 0.5, tag = 2, name = "refined_dust",},
        { cal = 9.375, weight = 4.6875, tag = 2, name = "butterflywings",},
        { cal = 9.375, weight = 4.6875, tag = 2, name = "moonbutterflywings",},
        { name = "decoration",},
    },
    sweetener = {
        { cal = 9.375, weight = 9.375, tag = 1, name = "honey",},
        { cal = 12.5, weight = 4.1666666666667, tag = 3, name = "royal_jelly",},
        { tag = 1, name = "honeycomb",},
        { name = "sweetener",},
    },
    inedible = {
        { cal = 9.375, weight = 9.375, tag = 1, name = "twigs",},
        { tag = 1, name = "boneshard",},
        { tag = 1, name = "nightmarefuel",},
        { tag = 1, name = "lightninggoathorn",},
        { name = "inedible",},
    },
    meats = {
        { cal = 18.75, weight = 18.75, tag = 1, name = "monstermeat",},
        { cal = 18.75, weight = 18.75, tag = 1, name = "monstermeat_dried",},
        { cal = 18.75, weight = 18.75, tag = 1, name = "cookedmonstermeat",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "drumstick",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "froglegs",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "smallmeat_dried",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "froglegs_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "smallmeat",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "drumstick_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "cookedmeat",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "fishmeat_small_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "meat_dried",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "fishmeat_small",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "pondfish",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "cookedsmallmeat",},
        { cal = 25, weight = 25.0, tag = 1, name = "meat",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "fish_cooked",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "fish",},
        { cal = 12.5, weight = 12.5, tag = 1, name = "plantmeat",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "pondeel_cooked",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "eel_cooked",},
        { cal = 18.75, weight = 18.75, tag = 1, name = "plantmeat_cooked",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "pondeel",},
        { cal = 9.375, weight = 18.75, tag = 0.5, name = "eel",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_3_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_2_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "fishmeat_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_7_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "batwing_cooked",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "batnose_cooked",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_3_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_1_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "fishmeat",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_4_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_6_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_1_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_8_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_4_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_9_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_8_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "batnose",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_7_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "batwing",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "oceanfish_small_9_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_2_inv",},
        { cal = 25, weight = 25.0, tag = 1, name = "oceanfish_medium_6_inv",},
        { cal = 12.5, weight = 25.0, tag = 0.5, name = "batnose_dried",},
        { cal = 37.5, weight = 37.5, tag = 1, name = "trunk_summer",},
        { cal = 37.5, weight = 37.5, tag = 1, name = "trunk_winter",},
        { cal = 12.5, weight = 50.0, tag = 0.25, name = "barnacle",},
        { cal = 12.5, weight = 50.0, tag = 0.25, name = "barnacle_cooked",},
        { cal = 75, weight = 75.0, tag = 1, name = "trunk_cooked",},
        { tag = 1, name = "wobster_sheller_land",},
        { tag = 0.5, name = "mole",},
        { name = "meats",},
    },
}
return tags