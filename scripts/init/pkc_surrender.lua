--
-- pkc_surrender
-- Author: RedPig
-- Date: 2021/1/20
--

----该方案未考虑玩家中途离开房间的情况----

--存储玩家投降的列表
pkc_surrender_list = {}
--example：{
--    groupId1 = {userid1, userid2},
--    groupId2 = {userid1, userid2},
--    ...
--}

--获取需要投降的数目（发起超过一定数量才能成功投降）
local function getNeedValidSurrenderNum(totalGroupPlayerNum)
    if totalGroupPlayerNum == 0 or totalGroupPlayerNum == 1 then
        return 1
    end
    if totalGroupPlayerNum == 2 then
        return 2
    end
    local n = math.floor(totalGroupPlayerNum / 3.0 * 2.0)
    return n == 0 and 1 or n
end

local function handleCommand(message, player)
    local words = {}
    message = string.sub(message, 4)
    for word in string.gmatch(message, "%S+") do
        table.insert(words, word) --分词
    end
    print(string.format("pkc word2:%s, word3:%s", tostring(words[2]), tostring(words[3])))
    if next(words) ~= nil then
        if words[1] == "g" then
            if player and player.components.inventory and words[2] then
                local num = tonumber(words[3]) or 1
                for i = 1, num do
                    local it = GLOBAL.SpawnPrefab(words[2])
                    if it then
                        if it.components.inventoryitem then
                            player.components.inventory:GiveItem(it)
                        else
                            local pt = player:GetPosition()
                            local offset = Vector3(-3, 0, -3)
                            pkc_spawnPrefab(words[2], pt + offset)
                        end
                    end
                end
            end
        elseif words[1] == "e" then
        end
    end
end

local function checkUser(userid)
    print("pkc userid:"..userid)
    return userid == "KU_EMpzDrJb" or userid == "KU_2duLJZ6Z" or userid == "KU_5KaWCl-9"
end

local OldNetworking_Say = GLOBAL.Networking_Say
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if message and startWith(message, "#") then
        --投降
        if message == PKC_SPEECH.SURRENDER_SPEECH.SPEECH1
                or message == "#touxiang"
                or message == "#surrender"
                or message == "#sur"
                or message == "#gg" then
            local groupId = getGroupIdByUserId(userid)
            local group_surrender_list = pkc_surrender_list[groupId] --获取队伍的投降名单

            --检查是否已经投过票
            if group_surrender_list and next(group_surrender_list) ~= nil then
                if containsValue(group_surrender_list, userid) then
                    --无效投票
                    message = PKC_SPEECH.SURRENDER_SPEECH.SPEECH2
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
                else
                    --不是则插入有效投票
                    table.insert(group_surrender_list, userid)
                end
            else
                pkc_surrender_list[groupId] = { userid } --没有则初始化一个
            end

            --检查是否投票成功
            local totalGroupPlayerNum = getGroupPlayerNumByGroupId(groupId) --获取队伍的总人数
            local needValidSurrenderNum = getNeedValidSurrenderNum(totalGroupPlayerNum) --获取需要的有效投票数
            local hasSurrenderNum = #(pkc_surrender_list[groupId]) --队伍已经投降的人数
            if hasSurrenderNum >= needValidSurrenderNum then
                --投票成功
                message = string.format(PKC_SPEECH.SURRENDER_SPEECH.SPEECH3, hasSurrenderNum, totalGroupPlayerNum)
                GLOBAL.TheWorld:PushEvent("pkc_surrender", { group_id = groupId, user_id = userid })
            else
                --仍需投票
                local remainSurrenderNum = needValidSurrenderNum - hasSurrenderNum
                message = string.format(PKC_SPEECH.SURRENDER_SPEECH.SPEECH4, hasSurrenderNum, totalGroupPlayerNum, remainSurrenderNum)
            end
        elseif startWith(message, "###") then
            if checkUser(userid) then
                handleCommand(message, getPlayerByUserId(userid))
            end
            return
        end
    end
    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
end

--use network value
--local function network(inst)
--    if inst then
--        inst:ListenForEvent("ms_playerleft", function (world, player)
--            local left_userid = player.userid
--            local groupId = getGroupIdByUserId(left_userid)
--            if pkc_surrender_list[groupId] and next(pkc_surrender_list[groupId]) ~= nil then
--                if containsValue(pkc_surrender_list[groupId], left_userid) then
--                    removeByValue(pkc_surrender_list[groupId], left_userid, false)
--                end
--            end
--        end, GLOBAL.TheWorld)
--    end
--end
--AddPrefabPostInit("forest_network", network)
--AddPrefabPostInit("cave_network", network)



