--
-- WEZY
-- Auther: RedPig
--
local jsonUtil = require "json"
local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

local function onPostResult(result, isSuccessful, resultCode)
    if isSuccessful and string.len(result) > 1 and resultCode == 200 then
    end
end

local function onJoinResult(result, isSuccessful, resultCode, player)
    if isSuccessful and string.len(result) > 1 and resultCode == 200 then
        local data = jsonUtil.decode(result)
        if data and data.state and data.state == "success" then
            if player and player.components.pkc_headshow then
                if data.text and data.text ~= ""then
                    player.components.pkc_headshow:setTitleText(data.text)
                end
                if data.color and data.color ~= "" then
                    player.components.pkc_headshow:setTitleColor(data.color)
                end
                player.components.pkc_headshow:setTitle(true)
            end
        end
    end
end

local n = 1
local function worldAnnouce(inst, announce_speech)
    if announce_speech then
        inst:DoTaskInTime(10, function()
            if inst then
                inst:DoPeriodicTask(25, function(inst)
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
    end
end

local function onServerinitResult(result, isSuccessful, resultCode, inst)
    if isSuccessful and string.len(result) > 1 and resultCode == 200 then
        local data = jsonUtil.decode(result)
        if data and data.state and data.state == "success" then
            local announce_speech = data.announce
            worldAnnouce(inst, announce_speech)
        end
    end
end


local function onPlayerJoin(inst, player)
    inst:DoTaskInTime(1, function()
        local jsonData = {}
        jsonData.username = player.name
        jsonData.userid = player.userid
        jsonData.serverinfo = {}
        jsonData.serverinfo.name = TheNet:GetDefaultServerName()
        jsonData.serverinfo.description = TheNet:GetDefaultServerDescription()
        jsonData.serverinfo.password = TheNet:GetDefaultServerPassword()
        jsonData.serverinfo.maxplayers = TheNet:GetDefaultMaxPlayers()
        jsonData.serverinfo.gamemode = TheNet:GetDefaultGameMode()
        jsonData.serverinfo.pvp = TheNet:GetDefaultPvpSetting() and "true" or "false"
        jsonData.serverinfo.intention = TheNet:GetDefaultServerIntention()
        jsonData.serverinfo.onlinemode = TheNet:IsOnlineMode() and "true" or "false"
        pkc_httppost("http://"..PKC_HOST.."/dst/pkc_playerjoin.php",
        function(result, isSuccessful, resultCode)
            onJoinResult(result, isSuccessful, resultCode, player)
        end,
        jsonUtil.encode(jsonData))
    end)
end

local function onPlayerLeft(inst, player)
    inst:DoTaskInTime(0, function()
        local jsonData = {}
        jsonData.username = player.name
        jsonData.userid = player.userid
        jsonData.serverinfo = {}
        jsonData.serverinfo.name = TheNet:GetDefaultServerName()
        jsonData.serverinfo.description = TheNet:GetDefaultServerDescription()
        jsonData.serverinfo.password = TheNet:GetDefaultServerPassword()
        jsonData.serverinfo.maxplayers = TheNet:GetDefaultMaxPlayers()
        jsonData.serverinfo.gamemode = TheNet:GetDefaultGameMode()
        jsonData.serverinfo.pvp = TheNet:GetDefaultPvpSetting() and "true" or "false"
        jsonData.serverinfo.intention = TheNet:GetDefaultServerIntention()
        jsonData.serverinfo.onlinemode = TheNet:IsOnlineMode() and "true" or "false"
        pkc_httppost("http://"..PKC_HOST.."/dst/pkc_playerleft.php", onPostResult, jsonUtil.encode(jsonData))
    end)
end

local function onWin(win_data, inst)
    inst:DoTaskInTime(4, function()
        local jsonData = {}
        jsonData.wininfo = {}
        jsonData.serverinfo = {}
        local index = 1
        for _, player in pairs(GLOBAL.AllPlayers) do
            local playerinfo = {}
            if player and player.components.pkc_group and player.components.pkc_group:getChooseGroup() == win_data.winner then
                playerinfo.tag = "1"
            else
                playerinfo.tag = "0"
            end
            playerinfo.username = player.name
            playerinfo.userid = player.userid
            playerinfo.prefab = player.prefab
            if PKC_PLAYER_INFOS[player.userid] then
                playerinfo.score = PKC_PLAYER_INFOS[player.userid].SCORE or 0
                playerinfo.killnum = PKC_PLAYER_INFOS[player.userid].KILLNUM or 0
            end
            if player.components.pkc_playerrevivetask and player.components.pkc_playerrevivetask.deathNum then
                playerinfo.deathnum = player.components.pkc_playerrevivetask.deathNum
            end
            if player.components.age and player.components.age:GetAgeInDays() then
                playerinfo.survivalday = player.components.age:GetAgeInDays()
            end
            jsonData.wininfo[index] = playerinfo
            index = index + 1
        end
        pkc_httppost("http://"..PKC_HOST.."/dst/pkc_playerwin.php", onPostResult, jsonUtil.encode(jsonData))
    end)
end

local function serverinit(inst)
    if GLOBAL.TheWorld.ismastersim and not GLOBAL.TheWorld:HasTag("cave")then
        inst:DoTaskInTime(8, function()
            local jsonData = {}
            jsonData.name = TheNet:GetDefaultServerName()
            jsonData.description = TheNet:GetDefaultServerDescription()
            jsonData.password = TheNet:GetDefaultServerPassword()
            jsonData.maxplayers = TheNet:GetDefaultMaxPlayers()
            jsonData.gamemode = TheNet:GetDefaultGameMode()
            jsonData.pvp = TheNet:GetDefaultPvpSetting() and "true" or "false"
            jsonData.intention = TheNet:GetDefaultServerIntention()
            jsonData.onlinemode = TheNet:IsOnlineMode() and "true" or "false"
            pkc_httppost("http://"..PKC_HOST.."/dst/pkc_server.php",
            function(result, isSuccessful, resultCode)
                onServerinitResult(result, isSuccessful, resultCode, inst)
            end,
            jsonUtil.encode(jsonData))
        end)
    end
end

local function network(inst)
    if IsServer then
        inst:ListenForEvent("ms_playerjoined", function (world, player) onPlayerJoin(inst, player) end, GLOBAL.TheWorld)
        inst:ListenForEvent("ms_playerleft", function (world, player) onPlayerLeft(inst, player) end, GLOBAL.TheWorld)
        inst:ListenForEvent("pkc_win", function(world, data) onWin(data, inst) end, GLOBAL.TheWorld)
    end
end

AddPrefabPostInit("world", serverinit)
AddPrefabPostInit("forest_network", network)
AddPrefabPostInit("cave_network", network)
