-- 分组聊天实现
-- Author: RedPig
-- Date: 2020/3/14

local CHAT_QUEUE_SIZE = 7
local CHAT_EXPIRE_TIME = 10.0
local CHAT_FADE_TIME = 2.0
local UserCommands = require("usercommands")
local input_chat_screen = require("screens/chatinputscreen")
local chat_queue = require("widgets/chatqueue")
local whisperTag = "[pkc_w]"

--重新聊天输入框
local oldDoInit = input_chat_screen.DoInit
function input_chat_screen:DoInit()
    oldDoInit(self)
    if self.chat_type then
        if self.whisper then
            self.chat_type:SetString("对所有人说")
        else
            self.chat_type:SetString("对队伍内说")
        end
    end
end

function input_chat_screen:Run()
    local chat_string = self.chat_edit:GetString()
    chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""
    if chat_string == "" then
        return
    elseif string.sub(chat_string, 1, 1) == "/" then
        --Process slash commands:
        UserCommands.RunTextUserCommand(string.sub(chat_string, 2), ThePlayer, false)
    elseif chat_string:utf8len() <= MAX_CHAT_INPUT_LENGTH then
        --Default to sending regular chat
        local prefix_tag = self.whisper and whisperTag or ""
        TheNet:Say(prefix_tag..chat_string, false)
    end
end

function calcChatAlpha(current_time, expire_time)
    local time_past_expiring = current_time - expire_time
    if time_past_expiring > 0.0 then
        if time_past_expiring < CHAT_FADE_TIME then
            local alpha_fade = ( CHAT_FADE_TIME - time_past_expiring ) / CHAT_FADE_TIME
            return alpha_fade
        end
        return 0.0
    end
    return 1.0
end

--重写聊天消息接收逻辑
function chat_queue:OnMessageReceivedForPKC(userid, name, prefab, message, colour, whisper, profileflair)
    if startWith(message, whisperTag) then
        whisper = true
        message = string.sub(message, whisperTag:len() + 1)
    end
    --Make sure that we use the default profile flair is the user hasn't set one.
    if profileflair == nil then
        profileflair = "default"
    end
    colour = {}
    colour[1], colour[2], colour[3] = HexToPercentColor(getColorByGroupId(PKC_PLAYER_INFOS[userid].GROUP_ID))
    --调换了下原始设定，改为按Y发起队伍内，按U发起所有人
    whisper = not whisper
    if whisper then
        --如果是发起的队伍内会话，则只往聊天消息队列中添加同一队伍的消息
        if PKC_PLAYER_INFOS[userid] and PKC_PLAYER_INFOS[ThePlayer.userid]
                and PKC_PLAYER_INFOS[userid].GROUP_ID == PKC_PLAYER_INFOS[ThePlayer.userid].GROUP_ID then
            self:PushMessageForPKC(self:GetDisplayName(name, prefab), message, colour, whisper, false, profileflair)
        end
    else
        -- Process Chat username
        self:PushMessageForPKC(self:GetDisplayName(name, prefab), message, colour, whisper, false, profileflair)
    end
end

--copy原始代码
function chat_queue:PushMessageForPKC(username, message, colour, whisper, nolabel, profileflair)
    -- Shuffle upwards
    for i = 1, CHAT_QUEUE_SIZE - 1 do
        self.chat_queue_data[i] = shallowcopy( self.chat_queue_data[i+1] )
    end

    --Set this new message into the chat queue data
    self.chat_queue_data[CHAT_QUEUE_SIZE].expire_time = GetTime() + CHAT_EXPIRE_TIME
    self.chat_queue_data[CHAT_QUEUE_SIZE].username = username
    self.chat_queue_data[CHAT_QUEUE_SIZE].message = message
    self.chat_queue_data[CHAT_QUEUE_SIZE].colour = colour
    self.chat_queue_data[CHAT_QUEUE_SIZE].whisper = whisper
    self.chat_queue_data[CHAT_QUEUE_SIZE].nolabel = nolabel
    self.chat_queue_data[CHAT_QUEUE_SIZE].profileflair = profileflair

    self:RefreshWidgetsForPKC()
end

function chat_queue:RefreshWidgetsForPKC()
    local current_time = GetTime()

    --apply the chat data to the widgets
    for i = 1, CHAT_QUEUE_SIZE do
        local row_data = self.chat_queue_data[i]

        local y = -400 - i * (self.chat_size + 2)
        local alpha_fade = calcChatAlpha(current_time, row_data.expire_time)

        if alpha_fade > 0 then
            local c = { row_data.colour[1], row_data.colour[2], row_data.colour[3], alpha_fade }

            local msg = self.widget_rows[i].message
            msg:Show()
            msg:SetTruncatedString(row_data.message, self.message_width, self.message_max_chars, true)
            local msg_width = msg:GetRegionSize()
            msg:SetPosition(msg_width * 0.5 - 290, y)
            if row_data.nolabel then
                msg:SetColour(c)
            else
                if row_data.whisper then
                    local r,g,b = unpack(WHISPER_COLOR)
                    msg:SetColour(r,g,b, alpha_fade)
                else
                    local r,g,b = unpack(SAY_COLOR)
                    msg:SetColour(r,g,b, alpha_fade)
                end
            end

            local user = self.widget_rows[i].user
            local user_width
            if row_data.nolabel then
                user:Hide()
            else
                user:Show()
                --添加消息头部标识
                if row_data.whisper then
                    local title = isNullOrEmpty(row_data.username) and "" or "[队伍内] "..row_data.username
                    user:SetTruncatedString(title, self.user_width, self.user_max_chars, true)
                else
                    local title = isNullOrEmpty(row_data.username) and "" or "[所有人] "..row_data.username
                    user:SetTruncatedString(title, self.user_width, self.user_max_chars, true)
                end
                user_width = user:GetRegionSize()
                user:SetPosition(user_width * -.5 - 330, y)
                user:SetColour(c)
            end

            local flair = self.widget_rows[i].flair
            if row_data.nolabel then
                flair:Hide()
            else
                flair:Show()
                flair:SetFlair(row_data.profileflair)
                flair:SetAlpha(alpha_fade)
            end
        else
            self.widget_rows[i].user:Hide()
            self.widget_rows[i].message:Hide()
            self.widget_rows[i].flair:Hide()
        end
    end
end

function chat_queue:OnUpdate()
    local current_time = GetTime()
    -- If the chat input screen is open, reset the timer to fade out soon
    local is_chat_open = ThePlayer ~= nil and ThePlayer.HUD ~= nil and ThePlayer.HUD:IsChatInputScreenOpen()

    for i = 1, CHAT_QUEUE_SIZE do
        local row_data = self.chat_queue_data[i]

        if is_chat_open then
            if row_data.expire_time < current_time then
                row_data.expire_time = current_time
            end
        end

        if row_data.expire_time > 0 then
            local time_past_expiring = current_time - row_data.expire_time
            if time_past_expiring > CHAT_FADE_TIME then
                row_data.expire_time = 0
            end
        end
    end

    self:RefreshWidgetsForPKC()
end