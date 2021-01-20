--
-- pkc_surrender
-- Author: RedPig
-- Date: 2021/1/20
--

pkc_surrender_list = {}
--{
--    groupId1 = {userid1, userid2},
--    groupId2 = {userid1, userid2},
--    ...
--}
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

local OldNetworking_Say = GLOBAL.Networking_Say
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if message and startWith(message, "#") then
        --命令模式
        if message == PKC_SPEECH.SURRENDER_SPEECH.SPEECH1
                or message == "#touxiang"
                or message == "#surrender"
                or message == "#sur" then
            local groupId = getGroupIdByUserId(userid)
            local group_surrender_list = pkc_surrender_list[groupId] --每个队伍的投降名单
            if group_surrender_list and next(group_surrender_list) ~= nil then
                if containsValue(group_surrender_list, userid) then
                    --无效投票
                    message = PKC_SPEECH.SURRENDER_SPEECH.SPEECH2
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
                else
                    --有效投票
                    table.insert(group_surrender_list, userid)
                end
            else
                pkc_surrender_list[groupId] = {userid} --没有则初始化一个
            end

            --检查是否投票成功
            local totalGroupPlayerNum = getGroupPlayerNumByGroupId(groupId)
            local needValidSurrenderNum = getNeedValidSurrenderNum(totalGroupPlayerNum)
            local hasSurrenderNum = #(pkc_surrender_list[groupId])
            if hasSurrenderNum >= needValidSurrenderNum then
                --投票成功
                message = string.format(PKC_SPEECH.SURRENDER_SPEECH.SPEECH3, hasSurrenderNum, totalGroupPlayerNum)
                GLOBAL.TheWorld:PushEvent("pkc_surrender", {group_id = groupId, user_id = userid})
            else
                --仍需投票
                local remainSurrenderNum = needValidSurrenderNum - hasSurrenderNum
                message = string.format(PKC_SPEECH.SURRENDER_SPEECH.SPEECH4, hasSurrenderNum, totalGroupPlayerNum, remainSurrenderNum)
            end
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



