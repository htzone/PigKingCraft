--
-- pkc_assists 助攻组件
-- Author: RedPig
-- Date: 2021/2/6
--

--{
--    ku_xxx = {groupId = 1, time = 123441},
--    ...
--}
local json = require "json"
local ASSIST_MAX_TIME = 20

local PKC_ASSISTS = Class(function(self, inst)
    self.inst = inst
    self.allAssistsPlayers = {}
    self.deleteAssistsTask = self.inst:DoPeriodicTask(ASSIST_MAX_TIME, function()
        local needDeleteUids = {}
        for uid, v in pairs(self.allAssistsPlayers) do
            if os.time() - v.time > ASSIST_MAX_TIME then
                table.insert(needDeleteUids, uid)
            end
        end
        for _, v in ipairs(needDeleteUids) do
            pkc_removeByKey(self.allAssistsPlayers, v)
        end
    end)
end)

function PKC_ASSISTS:getAssistsPlayers(killer)
    local assistsPlayers = {}
    local groupId = nil
    if killer.components.pkc_group then
        groupId = killer.components.pkc_group:getChooseGroup()
    end
    if groupId and killer.userid then
        for uid, v in pairs(self.allAssistsPlayers) do
            if killer.userid ~= uid then
                if v.groupId == groupId then
                    assistsPlayers[uid] = v
                end
            end
        end
    end
    return assistsPlayers
end

function PKC_ASSISTS:addAssistsPlayer(uid, groupId)
    if uid and groupId then
        self.allAssistsPlayers[uid] = {groupId = groupId, time = os.time()}
    end
end

function PKC_ASSISTS:OnSave()
    return
    {
        allAssistsPlayers = json.encode(self.allAssistsPlayers)
    }
end

function PKC_ASSISTS:OnLoad(data)
    if data ~= nil then
        if data.allAssistsPlayers ~= nil then
            self.allAssistsPlayers = json.decode(data.allAssistsPlayers)
        end
    end
end

return PKC_ASSISTS