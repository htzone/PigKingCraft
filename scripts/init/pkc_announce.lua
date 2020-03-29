--
-- 自动公告
-- Author: RedPig
-- Date: 2017/03/04
--

local jsonUtil = require "json"

local announce_speech = {
    --"服务公告：本服为猪王争霸专用服，适合喜欢挑战的老玩家，新手可以先去玩生存！",
    --"服务公告：请认真玩，骂人和恶意捣乱的玩家将被永久封禁！！！",
    --"服务公告：投诉和建议反馈QQ群486149251，欢迎加入！",
    --"服务公告：客户端不建议开启小地图和智能锅MOD，可能会导致客户端卡顿和崩溃！",
}

local n = 1
local function addAnnouncement(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:DoTaskInTime(4, function()
            local jsonData = {}
            inst:DoTaskInTime(10, function()
                if inst then
                    inst:DoPeriodicTask(30, function(inst)
                        if #announce_speech > 0 then
                            local temp_n = n % (#announce_speech)
                            if temp_n == 0 then
                                if not GLOBAL.TheWorld:HasTag("cave") then
                                    GLOBAL.TheNet:Announce(announce_speech[(#announce_speech)])
                                end
                            else
                                if not GLOBAL.TheWorld:HasTag("cave") then
                                    GLOBAL.TheNet:Announce(announce_speech[n % (#announce_speech)])
                                end
                            end
                            n = n + 1
                        end
                    end)
                end
            end)
        end)
    end
end

--AddPrefabPostInit("world", addAnnouncement)
