--
-- 自动公告
-- Author: RedPig
-- Date: 2017/03/04
--

local jsonUtil = require "json"

local PKC_ANNOUNCE_SPEECH = GLOBAL.PKC_SPEECH.ANNOUNCE_SPEECH

local n = 1
local function addAnnouncement(inst)
    if GLOBAL.TheWorld.ismastersim and not GLOBAL.TheWorld:HasTag("cave") then
        if inst then
            inst:DoTaskInTime(15, function()
                inst:DoPeriodicTask(30, function()
                    if #(PKC_ANNOUNCE_SPEECH) > 0 then
                        local temp_n = n % (#PKC_ANNOUNCE_SPEECH)
                        if temp_n == 0 then
                            GLOBAL.TheNet:Announce(PKC_ANNOUNCE_SPEECH[(#PKC_ANNOUNCE_SPEECH)])
                        else
                            GLOBAL.TheNet:Announce(PKC_ANNOUNCE_SPEECH[temp_n])
                        end
                        n = n + 1
                    end
                end)
            end)
        end
    end
end

AddPrefabPostInit("world", addAnnouncement)
