-- 重写系统网络函数
-- Author: RedPig
-- Date: 2020/3/13
local whisperTag = "[pkc_w]"
function Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if message ~= nil and message:utf8len() > MAX_CHAT_INPUT_LENGTH then
        return
    end
    local entity = Ents[guid]
    if not isemote and entity ~= nil and entity.components.talker ~= nil then
        --截取tag
        local actualMsg = startWith(message, whisperTag) and string.sub(message, whisperTag:len() + 1) or message
        entity.components.talker:Say(not entity:HasTag("mime") and actualMsg or "", nil, nil, nil, true, colour)
    end
    if message ~= nil then
        if not (whisper or isemote) then
            local screen = TheFrontEnd:GetActiveScreen()
            if screen ~= nil and screen.ReceiveChatMessage then
                screen:ReceiveChatMessage(name, prefab, message, colour, whisper)
            end
        end
        local hud = ThePlayer ~= nil and ThePlayer.HUD or nil
        if hud ~= nil
                and (not whisper
                or (entity ~= nil
                and (hud:HasTargetIndicator(entity) or
                entity.entity:FrustumCheck()))) then
            if isemote then
                hud.controls.networkchatqueue:DisplayEmoteMessage(name, prefab, message, colour, whisper)
            else
                local profileflair = GetRemotePlayerVanityItem(user_vanity or {}, "profileflair")
                --使用自定义消息接收方法
                hud.controls.networkchatqueue:OnMessageReceivedForPKC(
                    userid, name, prefab, message, colour, whisper, profileflair)
            end
        end
    end
end
