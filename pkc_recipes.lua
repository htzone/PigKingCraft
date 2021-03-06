--
-- recipes
-- Author: RedPig
-- Date: 2021/1/10
--

local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH

local armor_bramble =  GLOBAL.AllRecipes["armor_bramble"]
if armor_bramble  then
    armor_bramble.ingredients = {Ingredient("livinglog", 6), Ingredient("boneshard", 6)}
end

local homesign = GLOBAL.AllRecipes["homesign"]
homesign.sortkey = -20
local treasurechest = GLOBAL.AllRecipes["treasurechest"]
treasurechest.sortkey = -19

local recipe_ewecushat = AddRecipe("pkc_ewecushat",
        { Ingredient("goldnugget", 25), Ingredient("hammer", 4), Ingredient("feather_crow", 2) },
        RECIPETABS.WAR,
        TECH.SCIENCE_TWO,
        nil,
        nil,
        nil,
        nil,
        "pkc_group1",
        "images/inventoryimages/pkc_ewecushat.xml",
        "pkc_ewecushat.tex")
recipe_ewecushat.sortkey = -20

local recipe_spartahelmut = AddRecipe("pkc_spartahelmut",
        { Ingredient("goldnugget", 25), Ingredient("goldenpickaxe", 2), Ingredient("feather_robin", 2) },
        RECIPETABS.WAR,
        TECH.SCIENCE_TWO,
        nil,
        nil,
        nil,
        nil,
        "pkc_group2",
        "images/inventoryimages/pkc_spartahelmut1.xml",
        "pkc_spartahelmut.tex")
recipe_spartahelmut.sortkey = -20

local recipe_birchnuthat = AddRecipe("pkc_birchnuthat",
        { Ingredient("goldnugget", 25), Ingredient("acorn", 8), Ingredient("rope", 2) },
        RECIPETABS.WAR,
        TECH.SCIENCE_TWO,
        nil,
        nil,
        nil,
        nil,
        "pkc_group3",
        "images/inventoryimages/pkc_birchnuthat.xml",
        "pkc_birchnuthat.tex")
recipe_birchnuthat.sortkey = -20

local recipe_summerbandana = AddRecipe("pkc_summerbandana",
        { Ingredient("goldnugget", 25), Ingredient("goldenaxe", 2), Ingredient("papyrus", 2) },
        RECIPETABS.WAR,
        TECH.SCIENCE_TWO,
        nil,
        nil,
        nil,
        nil,
        "pkc_group4",
        "images/inventoryimages/pkc_summerbandana.xml",
        "pkc_summerbandana.tex")
recipe_summerbandana.sortkey = -20

