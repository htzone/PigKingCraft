-- 玩家信息保存
-- Created by IntelliJ IDEA.
-- User: RedPig
-- Date: 2017/2/19
-- Time: 20:08
-- To change this template use File | Settings | File Templates.
--

--PKC_PLAYER_INFOS格式：
--PKC_PLAYER_INFOS = {
--    KU_2312323s1 = {
--        GROUP_ID = 2,
--        PLAYER_NAME = "redpig",
--        PLAYER_SCORE = 121,
--    },
--    ...
--}

json = require "json"

--队伍选择
local function onCompleteChooseGroup(data, inst)
    print("--choosername:"..data.chooser.name)
    print("--chooserid:"..data.chooser.userid)
    print("--groupId:"..data.groupId)
    inst.components.pkc_playerinfos:SetGroup(data.chooser, data.groupId)
end

----击杀得分
--local function onEntityDied(data, inst)
--    if data and data.inst and data.afflicter then
--        if data.inst:HasTag("player") and data.afflicter:HasTag("player")
--        and data.inst.components.pkc_group and data.afflicter.components.pkc_group then
--            inst.components.pkc_playerinfos:addPlayerKillNum(data.afflicter)
--        end
--    end
--end
--
----贡献得分
--local function onGiveScoreItem(data, inst)
--    if data then
--        if data.giver and data.getter and data.addScore and data.giver.components.pkc_group and data.getter.components.pkc_group then
--            inst.components.pkc_playerinfos:addPlayerScore(data.giver, data.addScore)
--        end
--    end
--end

local function OnPlayerInfoDirty(inst)
    local self = inst.components.pkc_playerinfos
    PKC_PLAYER_INFOS = json.decode(self._playerinfo:value())
end

local PKC_PLAYERINFOS = Class(function(self, inst)
    self.inst = inst
    self._playerinfo = net_string(self.inst.GUID, "pkc_playerinfo._playerinfo", "_playerinfoDirty")
    if TheNet:GetIsServer() then
        --监听队伍选择完成
        self.inst:ListenForEvent("pkc_completeChooseGroup", function(world, data) onCompleteChooseGroup(data, inst) end, TheWorld)
        --监听贡献得分
        --self.inst:ListenForEvent("pkc_giveScoreItem", function(world, data) onGiveScoreItem(data, inst) end, TheWorld)
        --监听击杀得分
        --self.inst:ListenForEvent("entity_death", function(world, data) onEntityDied(data, inst) end, TheWorld)
    else
        --客户端监听事件
        self.inst:ListenForEvent("_playerinfoDirty", OnPlayerInfoDirty)
    end
end, nil, {})

--设置队伍选择信息
function PKC_PLAYERINFOS:SetGroup(player, groupId)
    local playerInfos = {}
    playerInfos.GROUP_ID = groupId
    playerInfos.PLAYER_NAME = player.name
    PKC_PLAYER_INFOS[player.userid] = playerInfos
    self._playerinfo:set(json.encode(PKC_PLAYER_INFOS))
end

--增加玩家分数
function PKC_PLAYERINFOS:addPlayerScore(player, score)
    if player and PKC_PLAYER_INFOS[player.userid] then
        if PKC_PLAYER_INFOS[player.userid].SCORE == nil then
            PKC_PLAYER_INFOS[player.userid].SCORE = 0
        end
        PKC_PLAYER_INFOS[player.userid].SCORE = PKC_PLAYER_INFOS[player.userid].SCORE + score
        self._playerinfo:set(json.encode(PKC_PLAYER_INFOS))
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
        self._playerinfo:set(json.encode(PKC_PLAYER_INFOS))
    end
end

function PKC_PLAYERINFOS:OnSave()
    return
    {
        playerInfos = json.encode(PKC_PLAYER_INFOS)
    }
end

function PKC_PLAYERINFOS:OnLoad(data)
    if data ~= nil then
        PKC_PLAYER_INFOS = json.decode(data.playerInfos)
        if TheNet:GetIsServer() then
            self._playerinfo:set(data.playerInfos)
        end
    end
end

return PKC_PLAYERINFOS