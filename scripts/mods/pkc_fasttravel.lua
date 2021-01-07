--
-- 分组传送
-- Author: RedPig
-- Date: 2016/10/23
--
local require = GLOBAL.require
local TravelScreen = require "screens/pkc_travelscreen"

local FT_Points = {
    "homesign",
    "pkc_homesign_big",
    "pkc_homesign_red",
    "pkc_homesign_long",
    "pkc_homesign_cui",
}

AddReplicableComponent("pkc_travelable")
for _, v in pairs(FT_Points) do
    AddPrefabPostInit(
        v,
        function(inst)
            inst:AddComponent("talker")
            inst:AddTag("_travelable")
            if GLOBAL.TheWorld.ismastersim then
                inst:RemoveTag("_travelable")
                inst:AddComponent("pkc_travelable")
                inst.components.pkc_travelable.dist_cost = 32
                inst.components.pkc_travelable.ownership = false
            end
        end
    )
end

-- Mod RPC ------------------------------
AddModRPCHandler(
    "FastTravel",
    "Travel",
    function(player, inst, index)
        local pkc_travelable = inst.components.pkc_travelable
        if pkc_travelable ~= nil then
            pkc_travelable:Travel(player, index)
        end
    end
)

-- PlayerHud UI -------------------------

AddClassPostConstruct(
    "screens/playerhud",
    function(self, anim, owner)
        self.ShowTravelScreen = function(_, attach)
            if attach == nil then
                return
            else
                self.travelscreen = TravelScreen(self.owner, attach)
                self:OpenScreenUnderPause(self.travelscreen)
                return self.travelscreen
            end
        end

        self.CloseTravelScreen = function(_)
            if self.travelscreen then
                self.travelscreen:Close()
                self.travelscreen = nil
            end
        end
    end
)

-- Actions ------------------------------

AddAction(
    "DESTINATION_UI",
    "选择目的地",
    function(act)
        if act.doer and act.target
                and act.doer:HasTag("player")
                and act.target.components.pkc_travelable and not act.target:HasTag("burnt")
                and not act.target:HasTag("fire") then
            act.target.components.pkc_travelable:BeginTravel(act.doer)
            return true
        end
    end
)
GLOBAL.ACTIONS.DESTINATION_UI.priority = 1

-- Component actions ---------------------

AddComponentAction(
    "SCENE",
    "pkc_travelable",
    function(inst, doer, actions, right)
        if right then
            if not inst:HasTag("burnt") and not inst:HasTag("fire") then
                table.insert(actions, GLOBAL.ACTIONS.DESTINATION_UI)
            end
        end
    end
)

-- Stategraph ----------------------------

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DESTINATION_UI, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DESTINATION_UI, "give"))


