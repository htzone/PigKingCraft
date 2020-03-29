--
-- 保存所有玩家基本信息的组件（服务端客户端均可访问）
-- 只保存不易改变的信息，存放在全局变量PKC_PLAYER_INFOS中，避免频繁在进程间通信
-- Author: RedPig
-- Date: 2016/11/20
--
--Example：
--PKC_PLAYER_INFOS = {
--    KU_2312323s1 = {
--        GROUP_ID = 1,
--        GROUP_COLOR = "",
--        PLAYER_NAME = "redpig",
--        PLAYER_PREFAB = "wilson",
--        PLAYER_COLOR = "7C6AD208",
--    },
--    KU_2312323s2 = {
--        GROUP_ID = 2,
--        GROUP_COLOR = "",
--        PLAYER_NAME = "dazhuzhu",
--        PLAYER_PREFAB = "wilson",
--        PLAYER_COLOR = "7C6AD207",
--    },
--    ...
--}

local json = require "json"

local function getPlayerColor(userid)
    local clientObjs = GetPlayerClientTable()
    for _, v in pairs(clientObjs) do
        if v and v.userid == userid then
            return v.colour
        end
    end
    return DEFAULT_PLAYER_COLOUR
end

--队伍选择
local function onCompletedChooseGroup(self, data)
    self:SetPlayerInfo(data.chooser)
end

local function onPlayerInfoDirty(inst)
    local self = inst.components.pkc_playerinfos
    PKC_PLAYER_INFOS = json.decode(self._playerinfos:value())
end

local PKC_PLAYERINFOS = Class(function(self, inst)
    self.inst = inst
    self._playerinfos = net_string(self.inst.GUID, "pkc_playerinfo._playerinfos", "_playerinfoDirty")
    if TheNet:GetIsServer() then
        --监听队伍选择完成
        self.inst:ListenForEvent("pkc_completedChooseGroup", function(world, data)
            onCompletedChooseGroup(self, data) end,
            TheWorld)
    else
        --客户端监听事件
        self.inst:ListenForEvent("_playerinfoDirty", onPlayerInfoDirty)
    end
end, nil, {})

--设置队伍选择信息
function PKC_PLAYERINFOS:SetPlayerInfo(player)
    local playerInfo = {}
    if player then
        if player.components.pkc_group then
            playerInfo.GROUP_ID = player.pkc_groupid
            playerInfo.GROUP_COLOR = getGroupColorByGroupId(playerInfo.GROUP_ID)
        end
        playerInfo.PLAYER_NAME = player.name
        playerInfo.PLAYER_PREFAB = player.prefab
        playerInfo.PLAYER_COLOR = getPlayerColor(player.userid)
        print("[pkc]--groupId:"..tostring(playerInfo.GROUP_ID))
        print("[pkc]--groupColor:"..tostring(playerInfo.GROUP_COLOR))
        print("[pkc]--playerName:"..tostring(playerInfo.PLAYER_NAME))
        print("[pkc]--playerPrefab:"..tostring(playerInfo.PLAYER_PREFAB))
        print("[pkc]--playerColor:"..tostring(playerInfo.PLAYER_COLOR))
        PKC_PLAYER_INFOS[player.userid] = playerInfo
        self._playerinfos:set(json.encode(PKC_PLAYER_INFOS))
    end

end

--增加玩家分数
function PKC_PLAYERINFOS:addPlayerScore(player, score)
    if player and PKC_PLAYER_INFOS[player.userid] then
        if PKC_PLAYER_INFOS[player.userid].SCORE == nil then
            PKC_PLAYER_INFOS[player.userid].SCORE = 0
        end
        PKC_PLAYER_INFOS[player.userid].SCORE = PKC_PLAYER_INFOS[player.userid].SCORE + score
        self._playerinfos:set(json.encode(PKC_PLAYER_INFOS))
    end
end

--增加玩家击杀个数(具体指击杀玩家的个数)
function PKC_PLAYERINFOS:addPlayerKillNum(player, num)
    if player and PKC_PLAYER_INFOS[player.userid] then
        if PKC_PLAYER_INFOS[player.userid].KILLNUM == nil then
            PKC_PLAYER_INFOS[player.userid].KILLNUM = 0
        end
        if num == nil then
            PKC_PLAYER_INFOS[player.userid].KILLNUM = PKC_PLAYER_INFOS[player.userid].KILLNUM + 1
        else
            PKC_PLAYER_INFOS[player.userid].KILLNUM = PKC_PLAYER_INFOS[player.userid].KILLNUM + num
        end
        self._playerinfos:set(json.encode(PKC_PLAYER_INFOS))
    end
end

function PKC_PLAYERINFOS:OnSave()
    return
    {
        playerInfos = json.encode(PKC_PLAYER_INFOS)
    }
end

function PKC_PLAYERINFOS:OnLoad(data)
    if data and data.playerInfos then
        PKC_PLAYER_INFOS = json.decode(data.playerInfos)
        if TheNet:GetIsServer() then
            self._playerinfos:set(data.playerInfos)
        end
    end
end

return PKC_PLAYERINFOS