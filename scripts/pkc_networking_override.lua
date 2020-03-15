-- 重写系统网络函数
-- Author: RedPig
-- Date: 2020/3/13

function Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if message ~= nil and message:utf8len() > MAX_CHAT_INPUT_LENGTH then
        return
    end
    local entity = Ents[guid]
    if not isemote and entity ~= nil and entity.components.talker ~= nil then
        entity.components.talker:Say(not entity:HasTag("mime") and message or "", nil, nil, nil, true, colour)
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
                hud.controls.networkchatqueue:OnMessageReceivedForPKC(
                    userid, name, prefab, message, colour, whisper, profileflair)
            end
        end
    end
end
