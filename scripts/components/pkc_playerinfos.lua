--
-- 保存所有玩家基本信息的组件（服务端客户端均可访问）
-- Author: RedPig
-- Date: 2016/11/20
--
--Example：
--PKC_PLAYER_INFOS = {
--    KU_2312323s1 = {
--        USERID = KU_2312323s1,
--        GROUP_ID = 1,
--        GROUP_COLOR = "",
--        PLAYER_NAME = "redpig",
--        PLAYER_PREFAB = "wilson",
--        PLAYER_COLOR = "7C6AD207",
--        PLAYER_SCORE = 100,
--        PLAYER_KILLNUM = 2,
--        PLAYER_CONTRIBUTION = 100,
--    },
--    KU_2312323s2 = {
--        USERID = KU_2312323s2,
--        GROUP_ID = 2,
--        GROUP_COLOR = "",
--        PLAYER_NAME = "dazhuzhu",
--        PLAYER_PREFAB = "wilson",
--        PLAYER_COLOR = "7C6AD207",
--        PLAYER_SCORE = 100,
--        PLAYER_KILLNUM = 2,
--        PLAYER_CONTRIBUTION = 100,
--    },
--    ...
--}

local json = require "json"

local function getPlayerColorByUserId(userid)
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

local function onPlayerInfosDirty(inst)
    local self = inst.components.pkc_playerinfos
    PKC_PLAYER_INFOS = json.decode(self._playerinfos:value())
end

local function onPlayerInfoDirty(inst)
    local self = inst.components.pkc_playerinfos
    local playerinfo = json.decode(self._playerinfo:value())
    PKC_PLAYER_INFOS[playerinfo.USERID] = playerinfo
end

local function onScoreInfoDirty(inst)
    local self = inst.components.pkc_playerinfos
    local info = json.decode(self._scoreinfo:value())
    if PKC_PLAYER_INFOS[info.USERID] then
        PKC_PLAYER_INFOS[info.USERID].PLAYER_SCORE = info.PLAYER_SCORE
    end
end

local function onKillNumInfoDirty(inst)
    local self = inst.components.pkc_playerinfos
    local info = json.decode(self._killnuminfo:value())
    if PKC_PLAYER_INFOS[info.USERID] then
        PKC_PLAYER_INFOS[info.USERID].PLAYER_KILLNUM = info.PLAYER_KILLNUM
    end
end

local function onAssistsNumInfoDirty(inst)
    local self = inst.components.pkc_playerinfos
    local info = json.decode(self._assistsnuminfo:value())
    if PKC_PLAYER_INFOS[info.USERID] then
        PKC_PLAYER_INFOS[info.USERID].PLAYER_ASSISTS_NUM = info.PLAYER_ASSISTS_NUM
    end
end

local PKC_PLAYERINFOS = Class(function(self, inst)
    self.inst = inst
    self._playerinfos = net_string(self.inst.GUID, "pkc_playerinfo._playerinfos", "_playerinfosDirty")
    self._playerinfo = net_string(self.inst.GUID, "pkc_playerinfo._playerinfo", "_playerinfoDirty")
    self._scoreinfo = net_string(self.inst.GUID, "pkc_playerinfo._scoreinfo", "_scoreinfoDirty")
    self._killnuminfo = net_string(self.inst.GUID, "pkc_playerinfo._killnuminfo", "_killnuminfoDirty")
    self._assistsnuminfo = net_string(self.inst.GUID, "pkc_playerinfo._assistsnuminfo", "_assistsnuminfoDirty")

    if TheNet:GetIsServer() then
        --监听队伍选择完成
        self.inst:ListenForEvent("pkc_completedChooseGroup", function(world, data)
            onCompletedChooseGroup(self, data) end,
            TheWorld)
    end

    self.inst:ListenForEvent("_playerinfosDirty", onPlayerInfosDirty)
    self.inst:ListenForEvent("_playerinfoDirty", onPlayerInfoDirty)
    self.inst:ListenForEvent("_scoreinfoDirty", onScoreInfoDirty)
    self.inst:ListenForEvent("_killnuminfoDirty", onKillNumInfoDirty)
    self.inst:ListenForEvent("_assistsnuminfoDirty", onAssistsNumInfoDirty)
end, nil, {})

-- 设置玩家信息
function PKC_PLAYERINFOS:SetPlayerInfo(player)
    local playerInfo = {}
    if player then
        playerInfo.USERID = player.userid
        if player.components.pkc_group then
            playerInfo.GROUP_ID = player.pkc_groupid
            playerInfo.GROUP_COLOR = getGroupColorByGroupId(player.pkc_groupid)
        end
        playerInfo.PLAYER_NAME = player.name
        playerInfo.PLAYER_PREFAB = player.prefab
        playerInfo.PLAYER_COLOR = getPlayerColorByUserId(player.userid)
        print("[pkc]--groupId:"..tostring(playerInfo.GROUP_ID))
        print("[pkc]--groupColor:"..tostring(playerInfo.GROUP_COLOR))
        print("[pkc]--playerName:"..tostring(playerInfo.PLAYER_NAME))
        print("[pkc]--playerPrefab:"..tostring(playerInfo.PLAYER_PREFAB))
        print("[pkc]--playerColor:"..tostring(playerInfo.PLAYER_COLOR))
        self._playerinfo:set(json.encode(playerInfo))
    end
end

-- 增加玩家分数
function PKC_PLAYERINFOS:addPlayerScore(player, score)
    if player and PKC_PLAYER_INFOS[player.userid] then
        local newScore = (PKC_PLAYER_INFOS[player.userid].PLAYER_SCORE or 0) + (score or 1)
        local scoreinfo = {}
        scoreinfo.USERID = player.userid
        scoreinfo.PLAYER_SCORE = newScore
        self._scoreinfo:set(json.encode(scoreinfo))
    end
end

-- 增加玩家分数
function PKC_PLAYERINFOS:addPlayerScoreByUserId(userid, score)
    if player and PKC_PLAYER_INFOS[userid] then
        local newScore = (PKC_PLAYER_INFOS[userid].PLAYER_SCORE or 0) + (score or 1)
        local scoreinfo = {}
        scoreinfo.USERID = userid
        scoreinfo.PLAYER_SCORE = newScore
        self._scoreinfo:set(json.encode(scoreinfo))
    end
end

-- 增加玩家击杀个数
function PKC_PLAYERINFOS:addPlayerKillNum(player, num)
    if player and PKC_PLAYER_INFOS[player.userid] then
        local newKillNum = (PKC_PLAYER_INFOS[player.userid].PLAYER_KILLNUM or 0) + (num or 1)
        local info = {}
        info.USERID = player.userid
        info.PLAYER_KILLNUM = newKillNum
        self._killnuminfo:set(json.encode(info))
    end
end

--增加玩家助攻击杀个数
function PKC_PLAYERINFOS:addPlayerAssistsNum(userid, num)
    if userid then
        local newAssistNum = (PKC_PLAYER_INFOS[userid].PLAYER_ASSISTS_NUM or 0) + (num or 1)
        local info = {}
        info.USERID = userid
        info.PLAYER_ASSISTS_NUM = newAssistNum
        self._assistsnuminfo:set(json.encode(info))
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