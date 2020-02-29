--
-- Created by IntelliJ IDEA.
-- User: hetao
-- Date: 2017/2/18
-- Time: 23:00
-- To change this template use File | Settings | File Templates.
--

--local Ownership = GetModConfigData("Ownership")
--local Travel_Cost = GetModConfigData("Travel_Cost")
local FTSignTag = 'fast_travel'

local FT_Points = {
    "homesign",
    "pkc_homesign_big",
    "pkc_homesign_red",
    "pkc_homesign_long",
    "pkc_homesign_cui",
}

for _, v in pairs(FT_Points) do
    AddPrefabPostInit(v,function(inst)
        inst:AddComponent("talker")
        if GLOBAL.TheWorld.ismastersim then
            inst:AddComponent("pkc_grouptravel")
            inst.components.pkc_grouptravel.dist_cost = 32
            inst.components.pkc_grouptravel.ownership = false
        end
    end)
end

local language = GetModConfigData("language")
local ACTION_STR = ""
if language == "chinese" then
    ACTION_STR = "选择目的地"
elseif language == "english" then
    ACTION_STR = "Select destination"
end

-- Actions ------------------------------
AddAction("DESTINATION", ACTION_STR, function(act)
    if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.pkc_grouptravel and not act.target:HasTag("burnt") and not act.target:HasTag("fire") then
        act.target.components.pkc_grouptravel:SelectDestination(act.doer)
        return true
    end
end)

-- Component actions ---------------------
AddComponentAction("SCENE", "pkc_grouptravel", function(inst, doer, actions, right)
    if right then
        if inst:HasTag(FTSignTag) and not inst:HasTag("burnt") and not inst:HasTag("fire") then
            table.insert(actions, GLOBAL.ACTIONS.DESTINATION)
        end
    end
end)

-- Stategraph ----------------------------
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DESTINATION, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DESTINATION, "give"))

