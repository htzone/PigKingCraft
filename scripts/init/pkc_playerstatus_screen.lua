-- not use this file at present
-- 玩家计分显示屏幕
-- Author: RedPig
-- Date: 2016/11/23
--

local require = GLOBAL.require
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local PlayerBadge = require "widgets/playerbadge"
local ScrollableList = require "widgets/scrollablelist"
local UserCommandPickerScreen = require "screens/redux/usercommandpickerscreen"
local UserCommands = require "usercommands"
local TEMPLATES = require("widgets/redux/templates")
local PlayerStatusScreen = require("screens/playerstatusscreen")
local isDedicated = not TheNet:GetServerIsClientHosted()
local BAN_ENABLED = true

local PERF_HOST_SCALE = { 1, 1, 1 }
local PERF_HOST_UNKNOWN = "host_indicator.tex"
local PERF_HOST_LEVELS =
{
    "host_indicator3.tex", --GOOD
    "host_indicator2.tex", --OK
    "host_indicator1.tex", --BAD
}

local PERF_CLIENT_SCALE = { .9, .9, .9 }
local PERF_CLIENT_UNKNOWN = "performance_indicator.tex"
local PERF_CLIENT_LEVELS =
{
    "performance_indicator3.tex", --GOOD
    "performance_indicator2.tex", --OK
    "performance_indicator1.tex", --BAD
}
local VOICE_MUTE_COLOUR = { 242 / 255, 99 / 255, 99 / 255, 255 / 255 }
local VOICE_ACTIVE_COLOUR = { 99 / 255, 242 / 255, 99 / 255, 255 / 255 }
local VOICE_IDLE_COLOUR = { 1, 1, 1, 1 }
local REFRESH_INTERVAL = .5

local function getPlayerKillNum(userid)
    return PKC_PLAYER_INFOS[userid] and PKC_PLAYER_INFOS[userid].PLAYER_KILLNUM or 0
end

local function getPlayerScore(userid)
    return PKC_PLAYER_INFOS[userid] and PKC_PLAYER_INFOS[userid].PLAYER_SCORE or 0
end

local function getGroupColor(userid)
    if PKC_PLAYER_INFOS[userid] then
        return HexToPercentColor(getGroupColorByGroupId(PKC_PLAYER_INFOS[userid].GROUP_ID))
    end
    return 1, 1, 1
end

--根据得分对玩家进行排序
local function sortClient(clientObjs)
    if not isDedicated then
        table.sort(clientObjs, function(a, b)
            local aScore = getPlayerScore(a.userid)
            local bScore = getPlayerScore(b.userid)
            return aScore > bScore
        end)
    else
        table.sort(clientObjs, function(a, b)
            if a.performance then --说明不是玩家，是服务器，始终排在第一个
                return true
            end
            if b.performance then
                return false
            end
            local aScore = getPlayerScore(a.userid)
            local bScore = getPlayerScore(b.userid)
            return aScore > bScore
        end)
    end
end

--显示数字
local function showSortNum(playerListing, i)
    if isDedicated then
        playerListing.number:SetPosition(-430,0,0)
        playerListing.number:SetString(string.format(PKC_SPEECH.SCORE_KILL_NUM.SPEECH3, i-1))
        if i > 1 then
            playerListing.number:Show()
        else
            playerListing.number:Hide()
        end
    else
        playerListing.number:SetPosition(-430,0,0)
        playerListing.number:SetString(string.format(PKC_SPEECH.SCORE_KILL_NUM.SPEECH3, i))
        playerListing.number:Show()
    end
end

--高亮显示
local function showHighLight(playerListing)
    if playerListing.userid == ThePlayer.userid and playerListing.highlight then
        playerListing.highlight:Show()
    end
end

--local OldDoInit = PlayerStatusScreen.DoInit
--function PlayerStatusScreen:DoInit(ClientObjs, ...)
--    if ClientObjs == nil then
--        ClientObjs = TheNet:GetClientTable() or {}
--    end
--    --根据得分排序
--    sortClient(ClientObjs)
--    OldDoInit(self, ClientObjs, ...)
--    if not self.scroll_list.old_updatefn then -- if we haven't already patched the widgets
--        for i, playerListing in pairs(self.scroll_list.static_widgets) do
--            --showSortNum(playerListing, i)
--            showHighLight(playerListing)
--            playerListing.killNum = playerListing:AddChild(Text("bp50", 35, ""))
--            playerListing.killNum:SetPosition(110, 3, 0)
--            playerListing.killNum:SetHAlign(ANCHOR_MIDDLE)
--            playerListing.score = playerListing:AddChild(Text("bp50", 35, ""))
--            playerListing.score:SetPosition(190, 3, 0)
--            playerListing.score:SetHAlign(ANCHOR_MIDDLE)
--            playerListing.pkc_colour = { 1, 1, 1, 1 }
--            if isDedicated and not playerListing.ishost and PKC_PLAYER_INFOS[playerListing.userid] ~= nil
--                    or (not isDedicated and PKC_PLAYER_INFOS[playerListing.userid] ~= nil) then
--                --设置队伍名颜色
--                playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
--                = getGroupColor(playerListing.userid)
--                --设置击杀数和颜色
--                playerListing.killNum:Show()
--                playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1
--                        .. tostring(getPlayerKillNum(playerListing.userid)))
--                playerListing.killNum:SetColour(playerListing.pkc_colour)
--                --设置得分数和颜色
--                playerListing.score:Show()
--                playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2
--                        .. tostring(getPlayerScore(playerListing.userid)))
--                playerListing.score:SetColour(playerListing.pkc_colour)
--
--                playerListing.characterBadge.headframe:SetTint(unpack(playerListing.pkc_colour))
--            else
--                playerListing.killNum:Hide()
--                playerListing.score:Hide()
--                playerListing.characterBadge.headframe:SetTint(unpack(DEFAULT_PLAYER_COLOUR))
--            end
--        end
--
--        self.scroll_list.old_updatefn = self.scroll_list.updatefn
--        self.scroll_list.updatefn = function(playerListing, client, i, ...)
--            self.scroll_list.old_updatefn(playerListing, client, i, ...)
--            showSortNum(playerListing, i)
--            showHighLight(playerListing)
--            if (isDedicated and not client.performance ~= nil and PKC_PLAYER_INFOS[client.userid] ~= nil)
--                    or (not isDedicated and PKC_PLAYER_INFOS[client.userid] ~= nil) then
--                --设置队伍名颜色
--                playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
--                = getGroupColor(client.userid)
--                --设置击杀数和颜色
--                playerListing.killNum:Show()
--                playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1
--                        .. tostring(getPlayerKillNum(client.userid)))
--                playerListing.killNum:SetColour(playerListing.pkc_colour)
--                --设置得分数和颜色
--                playerListing.score:Show()
--                playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2
--                        .. tostring(getPlayerScore(client.userid)))
--                playerListing.score:SetColour(playerListing.pkc_colour)
--
--                playerListing.characterBadge.headframe:SetTint(unpack(playerListing.pkc_colour))
--            else
--                playerListing.killNum:Hide()
--                playerListing.score:Hide()
--                playerListing.characterBadge.headframe:SetTint(unpack(DEFAULT_PLAYER_COLOUR))
--            end
--        end
--    end
--end

function PlayerStatusScreen:DoInit(ClientObjs)

    TheInput:EnableDebugToggle(false)

    if not self.black then
        --darken everything behind the dialog
        --bleed outside the screen a bit, otherwise it may not cover
        --the edge of the screen perfectly when scaled to some sizes
        local bleeding = 4
        self.black = self:AddChild(Image("images/global.xml", "square.tex"))
        self.black:SetSize(RESOLUTION_X + bleeding, RESOLUTION_Y + bleeding)
        self.black:SetVRegPoint(ANCHOR_MIDDLE)
        self.black:SetHRegPoint(ANCHOR_MIDDLE)
        self.black:SetVAnchor(ANCHOR_MIDDLE)
        self.black:SetHAnchor(ANCHOR_MIDDLE)
        self.black:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
        self.black:SetTint(0,0,0,0) -- invisible, but clickable!
    end

    if not self.root then
        self.root = self:AddChild(Widget("ROOT"))
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetVAnchor(ANCHOR_MIDDLE)
    end

    if not self.bg then
        self.bg = self.root:AddChild(Image( "images/scoreboard.xml", "scoreboard_frame.tex" ))
        self.bg:SetScale(.96,.9)
    end

    if not self.servertitle then
        self.servertitle = self.root:AddChild(Text(UIFONT,45))
        self.servertitle:SetColour(1,1,1,1)
    end

    if not self.serverstate then
        self.serverstate = self.root:AddChild(Text(UIFONT,30))
        self.serverstate:SetColour(1,1,1,1)
    end

    if TheNet:GetServerGameMode() == "lavaarena" then
        self.serverstate:SetString(subfmt(STRINGS.UI.PLAYERSTATUSSCREEN.LAVAARENA_SERVER_MODE, {mode=GetGameModeString(TheNet:GetServerGameMode()), num = TheWorld.net.components.lavaarenaeventstate:GetCurrentRound()}))
    else
        self.serverage = TheWorld.state.cycles + 1
        local modeStr = GetGameModeString(TheNet:GetServerGameMode()) ~= nil and GetGameModeString(TheNet:GetServerGameMode()).." - " or ""
        self.serverstate:SetString(modeStr.." "..STRINGS.UI.PLAYERSTATUSSCREEN.AGE_PREFIX..self.serverage)
    end

    local servermenunumbtns = 0

    --服务器集群按钮
    self.server_group = TheNet:GetServerClanID()
    if self.server_group ~= "" and not TheInput:ControllerAttached() then
        if self.viewgroup_button == nil then
            self.viewgroup_button = self.root:AddChild(ImageButton("images/scoreboard.xml", "clan_normal.tex", "clan_hover.tex", "clan.tex", "clan.tex", nil, { .4, .4 }, { 0, 0 }))
            self.viewgroup_button:SetOnClick(function() TheNet:ViewNetProfile(self.server_group) end)
            self.viewgroup_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.VIEWGROUP, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 48, colour = WHITE})
        end
        servermenunumbtns = servermenunumbtns + 1
    elseif self.viewgroup_button ~= nil then
        self.viewgroup_button:Kill()
        self.viewgroup_button = nil
    end

    --更多动作按钮
    if not TheInput:ControllerAttached() and #UserCommands.GetServerActions(self.owner) > 0 then
        if self.serveractions_button == nil then
            self.serveractions_button = self.root:AddChild(ImageButton("images/scoreboard.xml", "more_actions_normal.tex", "more_actions_hover.tex", "more_actions.tex", "more_actions.tex", nil, { .4, .4 }, { 0, 0 }))
            self.serveractions_button:SetOnClick(function()
                TheFrontEnd:PopScreen()
                self:OpenUserCommandPickerScreen(nil)
            end)
            self.serveractions_button:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.SERVERACTIONS, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 48, colour = WHITE})
        end
        servermenunumbtns = servermenunumbtns + 1
    elseif self.serveractions_button ~= nil then
        self.serveractions_button:Kill()
        self.serveractions_button = nil
    end

    if ClientObjs == nil then
        ClientObjs = TheNet:GetClientTable() or {}
    end
    --pkc 根据得分排序
    sortClient(ClientObjs)

    self.numPlayers = #ClientObjs

    --服务器玩家人数
    if not self.players_number then
        self.players_number = self.root:AddChild(Text(UIFONT, 25))
        self.players_number:SetPosition(318,170)
        self.players_number:SetRegionSize(100,30)
        self.players_number:SetHAlign(ANCHOR_RIGHT)
        self.players_number:SetColour(1,1,1,1)
    end
    self.players_number:SetString(tostring(not TheNet:GetServerIsClientHosted() and self.numPlayers - 1 or self.numPlayers).."/"..(TheNet:GetServerMaxPlayers() or "?"))

    --服务器简介
    local serverDescStr = ServerPreferences:IsNameAndDescriptionHidden() and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_DESCRIPTION or TheNet:GetServerDescription()
    if not self.serverdesc then
        self.serverdesc = self.root:AddChild(Text(UIFONT,30))
        self.serverdesc:SetColour(1,1,1,1)
    end

    --分割线
    if not self.divider then
        self.divider = self.root:AddChild(Image("images/scoreboard.xml", "white_line.tex"))
    end

    --设置位置
    local servermenux = -329
    local servermenubtnoffs = 24
    if self.viewgroup_button ~= nil then
        self.viewgroup_button:SetPosition(servermenux - (servermenunumbtns > 1 and servermenubtnoffs or 0), 200)
    end
    if self.serveractions_button ~= nil then
        self.serveractions_button:SetPosition(servermenux + (servermenunumbtns > 1 and servermenubtnoffs or 0), 200)
    end

    if serverDescStr == "" then
        self.servertitle:SetPosition(0,215)
        self.serverdesc:SetPosition(0,175)
        self.serverstate:SetPosition(0,175)
        self.divider:SetPosition(0,155)
    else
        self.servertitle:SetPosition(0,223)
        self.servertitle:SetSize(40)
        self.serverdesc:SetPosition(0,188)
        self.serverdesc:SetSize(23)
        self.serverstate:SetPosition(0,163)
        self.serverstate:SetSize(23)
        self.players_number:SetPosition(318,160)
        self.players_number:SetSize(20)
        self.divider:SetPosition(0,149)
    end

    --获取服务器名字
    local serverNameStr = ServerPreferences:IsNameAndDescriptionHidden() and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or TheNet:GetServerName()
    if serverNameStr == "" then
        self.servertitle:SetString(serverNameStr)
    elseif servermenunumbtns > 1 then
        self.servertitle:SetTruncatedString(serverNameStr, 550, 100, true)
    elseif servermenunumbtns > 0 then
        self.servertitle:SetTruncatedString(serverNameStr, 600, 110, true)
    else
        self.servertitle:SetTruncatedString(serverNameStr, 800, 145, true)
    end

    if serverDescStr == "" then
        self.serverdesc:SetString(serverDescStr)
    elseif servermenunumbtns > 1 then
        self.serverdesc:SetTruncatedString(serverDescStr, 550, 175, true)
    elseif servermenunumbtns > 0 then
        self.serverdesc:SetTruncatedString(serverDescStr, 600, 190, true)
    else
        self.serverdesc:SetTruncatedString(serverDescStr, 800, 250, true)
    end

    if not self.servermods and TheNet:GetServerModsEnabled() then
        local modsStr = TheNet:GetServerModsDescription()
        self.servermods = self.root:AddChild(Text(UIFONT,25))
        self.servermods:SetPosition(20,-250,0)
        self.servermods:SetColour(1,1,1,1)
        self.servermods:SetTruncatedString(STRINGS.UI.PLAYERSTATUSSCREEN.MODSLISTPRE.." "..modsStr, 650, 146, true)

        self.bg:SetScale(.95,.95)
        self.bg:SetPosition(0,-10)
    end

    --定义按钮方法
    local function doButtonFocusHookups(playerListing)
        local buttons = {}
        if playerListing.viewprofile:IsVisible() then table.insert(buttons, playerListing.viewprofile) end
        if playerListing.mute:IsVisible() then table.insert(buttons, playerListing.mute) end
        if playerListing.kick:IsVisible() then table.insert(buttons, playerListing.kick) end
        if playerListing.ban:IsVisible() then table.insert(buttons, playerListing.ban) end
        if playerListing.useractions:IsVisible() then table.insert(buttons, playerListing.useractions) end

        local focusforwardset = false
        for i,button in ipairs(buttons) do
            if not focusforwardset then
                focusforwardset = true
                playerListing.focus_forward = button
            end
            if buttons[i-1] then
                button:SetFocusChangeDir(MOVE_LEFT, buttons[i-1])
            end
            if buttons[i+1] then
                button:SetFocusChangeDir(MOVE_RIGHT, buttons[i+1])
            end
        end
    end

    --列表初始化方法
    local function listingConstructor(i, parent)
        local playerListing =  parent:AddChild(Widget("playerListing"))

        playerListing.highlight = playerListing:AddChild(Image("images/scoreboard.xml", "row_goldoutline.tex"))
        playerListing.highlight:SetPosition(22, 5)
        playerListing.highlight:Hide()

        if self.show_player_badge then
            playerListing.profileFlair = playerListing:AddChild(TEMPLATES.RankBadge())
            playerListing.profileFlair:SetPosition(-388,-14,0)
            playerListing.profileFlair:SetScale(.6)
        end

        playerListing.characterBadge = nil
        playerListing.characterBadge = playerListing:AddChild(PlayerBadge("", DEFAULT_PLAYER_COLOUR, false, 0))
        playerListing.characterBadge:SetScale(.8)
        playerListing.characterBadge:SetPosition(-328,5,0)
        playerListing.characterBadge:Hide()

        playerListing.number = playerListing:AddChild(Text(UIFONT, 35))
        --playerListing.number:SetPosition(-422,0,0)
        playerListing.number:SetPosition(-426,3,0) --pkc_p
        playerListing.number:SetHAlign(ANCHOR_MIDDLE)
        playerListing.number:SetColour(1,1,1,1)
        playerListing.number:Hide()

        playerListing.adminBadge = playerListing:AddChild(ImageButton("images/avatars.xml", "avatar_admin.tex", "avatar_admin.tex", "avatar_admin.tex", nil, nil, {1,1}, {0,0}))
        playerListing.adminBadge:Disable()
        playerListing.adminBadge:SetPosition(-355,-13,0)
        playerListing.adminBadge.image:SetScale(.3)
        playerListing.adminBadge.scale_on_focus = false
        playerListing.adminBadge:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.ADMIN, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.adminBadge:Hide()

        playerListing.name = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.name._align = {
            maxwidth = 215,
            maxchars = 36,
            x = -286,
        }

        playerListing.age = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.age:SetPosition(-20,3,0)
        playerListing.age:SetHAlign(ANCHOR_MIDDLE)
        if TheNet:GetServerGameMode() == "lavaarena" then
            playerListing.age:Hide()
        end

        playerListing.viewprofile = playerListing:AddChild(ImageButton("images/scoreboard.xml", "addfriend.tex", "addfriend.tex", "addfriend.tex", "addfriend.tex", nil, {1,1}, {0,0}))
        playerListing.viewprofile:SetPosition(120,3,0)
        playerListing.viewprofile:SetNormalScale(0.39)
        playerListing.viewprofile:SetFocusScale(0.39*1.1)
        playerListing.viewprofile:SetFocusSound("dontstarve/HUD/click_mouseover")
        playerListing.viewprofile:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})

        playerListing.mute = playerListing:AddChild(ImageButton("images/scoreboard.xml", "chat.tex", "chat.tex", "chat.tex", "chat.tex", nil, {1,1}, {0,0}))
        playerListing.mute:SetPosition(170,3,0)
        playerListing.mute:SetNormalScale(0.39)
        playerListing.mute:SetFocusScale(0.39*1.1)
        playerListing.mute:SetFocusSound("dontstarve/HUD/click_mouseover")
        playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.MUTE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.mute.image.inst.OnUpdateVoice = function(inst)
            inst.widget:SetTint(unpack(playerListing.userid ~= nil and TheNet:IsVoiceActive(playerListing.userid) and VOICE_ACTIVE_COLOUR or VOICE_IDLE_COLOUR))
        end
        playerListing.mute.image.inst.SetMuted = function(inst, muted)
            if muted then
                inst.widget:SetTint(unpack(VOICE_MUTE_COLOUR))
                if inst._task ~= nil then
                    inst._task:Cancel()
                    inst._task = nil
                end
            else
                inst:OnUpdateVoice()
                if inst._task == nil then
                    inst._task = inst:DoPeriodicTask(1, inst.OnUpdateVoice)
                end
            end
        end
        playerListing.mute.image.inst.DisableMute = function(inst)
            inst.widget:SetTint(unpack(VOICE_IDLE_COLOUR))
            if inst._task ~= nil then
                inst._task:Cancel()
                inst._task = nil
            end
        end

        playerListing.mute:SetOnClick(
                function()
                    if playerListing.userid ~= nil then
                        playerListing.isMuted = not playerListing.isMuted
                        TheNet:SetPlayerMuted(playerListing.userid, playerListing.isMuted)
                        if playerListing.isMuted then
                            playerListing.mute.image_focus = "mute.tex"
                            playerListing.mute.image:SetTexture("images/scoreboard.xml", "mute.tex")
                            playerListing.mute:SetTextures("images/scoreboard.xml", "mute.tex")
                            playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.UNMUTE)
                        else
                            playerListing.mute.image_focus = "chat.tex"
                            playerListing.mute.image:SetTexture("images/scoreboard.xml", "chat.tex")
                            playerListing.mute:SetTextures("images/scoreboard.xml", "chat.tex")
                            playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.MUTE)
                        end
                        playerListing.mute.image.inst:SetMuted(playerListing.isMuted)
                    end
                end)

        playerListing.mute.image.inst:DisableMute()

        playerListing.kick = playerListing:AddChild(ImageButton("images/scoreboard.xml", "kickout.tex", "kickout.tex", "kickout_disabled.tex", "kickout.tex", nil, {1,1}, {0,0}))
        playerListing.kick:SetNormalScale(0.39)
        playerListing.kick:SetFocusScale(0.39*1.1)
        playerListing.kick:SetFocusSound("dontstarve/HUD/click_mouseover")
        playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.KICK, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        local gainfocusfn = playerListing.kick.OnGainFocus
        playerListing.kick.OnGainFocus = function()
            gainfocusfn(playerListing.kick)
            local commandresult = UserCommands.UserRunCommandResult("kick", self.owner, playerListing.userid)
            if commandresult == COMMAND_RESULT.ALLOW then
                playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.KICK)
            elseif commandresult == COMMAND_RESULT.VOTE then
                playerListing.kick:SetHoverText(string.format(STRINGS.UI.PLAYERSTATUSSCREEN.VOTEHOVERFMT, STRINGS.UI.PLAYERSTATUSSCREEN.KICK))
            elseif commandresult == COMMAND_RESULT.DISABLED then
                --we know canstart is false, but we want the reason
                local canstart, reason = UserCommands.CanUserStartCommand("kick", self.owner, playerListing.userid)
                playerListing.kick:SetHoverText(reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.COMMANDCANNOTSTART[reason] or "")
            elseif commandresult == COMMAND_RESULT.DENY then
                local worldvoter = TheWorld.net ~= nil and TheWorld.net.components.worldvoter or nil
                local playervoter = self.owner.components.playervoter
                if worldvoter == nil or playervoter == nil or not worldvoter:IsEnabled() then
                    --technically we should never get here (expected COMMAND_RESULT.INVALID)
                elseif worldvoter:IsVoteActive() then
                    playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VOTEACTIVEHOVER)
                elseif playervoter:IsSquelched() then
                    playerListing.kick:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VOTESQUELCHEDHOVER)
                else
                    --we know canstart is false, but we want the reason
                    local canstart, reason = UserCommands.CanUserStartVote("kick", self.owner, playerListing.userid)
                    playerListing.kick:SetHoverText(reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.VOTECANNOTSTART[reason] or "")
                end
            end -- INVALID hides the button.
        end
        playerListing.kick:SetOnClick( function()
            if playerListing.userid then
                TheFrontEnd:PopScreen()
                UserCommands.RunUserCommand("kick", {user=playerListing.userid}, self.owner)
            end
        end)

        playerListing.ban = playerListing:AddChild(ImageButton("images/scoreboard.xml", "banhammer.tex", "banhammer.tex", "banhammer.tex", "banhammer.tex", nil, {1,1}, {0,0}))
        playerListing.ban:SetPosition(220,3,0)
        playerListing.ban:SetNormalScale(0.39)
        playerListing.ban:SetFocusScale(0.39*1.1)
        playerListing.ban:SetFocusSound("dontstarve/HUD/click_mouseover")
        playerListing.ban:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.BAN, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.ban:SetOnClick( function()
            if playerListing.userid then
                TheFrontEnd:PopScreen()
                UserCommands.RunUserCommand("ban", {user=playerListing.userid}, self.owner)
            end
        end)

        playerListing.useractions = playerListing:AddChild(ImageButton("images/scoreboard.xml", "more_actions.tex", "more_actions.tex", "more_actions.tex", "more_actions.tex", nil, {1,1}, {0,0}))
        playerListing.useractions:SetPosition(220,3,0)
        playerListing.useractions:SetNormalScale(0.39)
        playerListing.useractions:SetFocusScale(0.39*1.1)
        playerListing.useractions:SetFocusSound("dontstarve/HUD/click_mouseover")
        playerListing.useractions:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.USERACTIONS, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.useractions:SetOnClick(function()
            TheFrontEnd:PopScreen()
            self:OpenUserCommandPickerScreen(playerListing.userid)
        end)

        playerListing.perf = playerListing:AddChild(Image("images/scoreboard.xml", PERF_CLIENT_UNKNOWN))
        playerListing.perf:SetPosition(295, 4, 0)
        playerListing.perf:SetScale(unpack(PERF_CLIENT_SCALE))

        playerListing.OnGainFocus = function()
            playerListing.highlight:Show()
        end
        playerListing.OnLoseFocus = function()
            playerListing.highlight:Hide()
        end

        --pkc 添加我们的得分信息
        playerListing.groupTag = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.groupTag:SetPosition(-60,3,0) --pkc_p
        playerListing.groupTag:SetHAlign(ANCHOR_MIDDLE)
        playerListing.killNum = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.killNum:SetPosition(110, 3, 0)
        playerListing.killNum:SetHAlign(ANCHOR_MIDDLE)
        playerListing.score = playerListing:AddChild(Text(UIFONT, 35, ""))
        playerListing.score:SetPosition(190, 3, 0)
        playerListing.score:SetHAlign(ANCHOR_MIDDLE)
        playerListing.pkc_colour = { 1, 1, 1, 1 }

        return playerListing
    end

    --更新玩家列表项
    local function UpdatePlayerListing(playerListing, client, i)

        if client == nil or GetTableSize(client) == 0 then
            playerListing:Hide()
            return
        end

        playerListing:Show()

        playerListing.displayName = self:GetDisplayName(client)

        playerListing.userid = client.userid

        if self.show_player_badge then
            if client.netid ~= nil then
                local _, _, _, profileflair, rank = GetSkinsDataFromClientTableData(client)
                playerListing.profileFlair:SetRank(profileflair, rank)
                playerListing.profileFlair:Show()
            else
                playerListing.profileFlair:Hide()
            end
        end

        playerListing.characterBadge:Set(client.prefab or "", client.colour or DEFAULT_PLAYER_COLOUR, client.performance ~= nil, client.userflags or 0)
        playerListing.characterBadge:Show()

        if client.admin then
            playerListing.adminBadge:Show()
        else
            playerListing.adminBadge:Hide()
        end

        local visible_index = i
        if not TheNet:GetServerIsClientHosted() then
            --playerListing.number:SetString(string.format(PKC_SPEECH.SCORE_KILL_NUM.SPEECH3, i-1)) --pkc
            playerListing.number:SetString(tostring(i-1))
            visible_index = i-1
            if i > 1 then
                playerListing.number:Show()
            else
                playerListing.number:Hide()
            end
        else
            --playerListing.number:SetString(string.format(PKC_SPEECH.SCORE_KILL_NUM.SPEECH3, i))
            playerListing.number:SetString(tostring(i))
            playerListing.number:Show() --pkc
        end

        playerListing.name:SetTruncatedString(playerListing.displayName, playerListing.name._align.maxwidth, playerListing.name._align.maxchars, true)
        local w, h = playerListing.name:GetRegionSize()
        playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)
        playerListing.name:SetColour(unpack(client.colour or DEFAULT_PLAYER_COLOUR))

        playerListing.age:SetString(client.playerage ~= nil and client.playerage > 0 and (tostring(client.playerage)..(client.playerage == 1 and STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAY or STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAYS)) or "")

        playerListing.ishost = client.performance ~= nil

        if client.performance ~= nil then
            local perf_id = math.min(client.performance + 1, #PERF_HOST_LEVELS)
            playerListing.perf:SetTexture("images/scoreboard.xml", PERF_HOST_LEVELS[perf_id])
            playerListing.perf:SetScale(unpack(PERF_HOST_SCALE))
            playerListing.perf:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.PERF_HOST_LEVELS[perf_id])
        else
            if client.netscore ~= nil then
                local perf_id = math.min(client.netscore + 1, #PERF_CLIENT_LEVELS)
                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_LEVELS[perf_id])
                playerListing.perf:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.PERF_CLIENT_LEVELS[perf_id])
            else
                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_UNKNOWN)
                playerListing.perf:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.PERF_CLIENT_LEVEL_UNKNOWN)
            end
            playerListing.perf:SetScale(unpack(PERF_CLIENT_SCALE))
        end

        local this_user_is_dedicated_server = client.performance ~= nil and not TheNet:GetServerIsClientHosted()

        playerListing.viewprofile:SetOnClick(
                function()
                    TheFrontEnd:PopScreen()
                    self.owner.HUD:TogglePlayerAvatarPopup(playerListing.displayName, client, true, true)
                end)

        local button_start = 50
        local button_x = button_start
        local button_x_offset = 42

        local can_kick = false
        local can_ban = false

        if not this_user_is_dedicated_server then
            playerListing.viewprofile:Show()
            playerListing.viewprofile:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset
            can_kick = UserCommands.CanUserAccessCommand("kick", self.owner, client.userid)
            can_ban = BAN_ENABLED and UserCommands.CanUserAccessCommand("ban", self.owner, client.userid)
        else
            playerListing.viewprofile:Hide()
        end

        playerListing.isMuted = client.muted == true
        if playerListing.isMuted then
            playerListing.mute.image_focus = "mute.tex"
            playerListing.mute.image:SetTexture("images/scoreboard.xml", "mute.tex")
            playerListing.mute:SetTextures("images/scoreboard.xml", "mute.tex")
            playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.UNMUTE)
        else
            playerListing.mute.image_focus = "chat.tex"
            playerListing.mute.image:SetTexture("images/scoreboard.xml", "chat.tex")
            playerListing.mute:SetTextures("images/scoreboard.xml", "chat.tex")
            playerListing.mute:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.MUTE)
        end

        if client.userid ~= self.owner.userid and not this_user_is_dedicated_server then
            playerListing.mute:Show()
            playerListing.mute:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset
            playerListing.mute.image.inst:SetMuted(playerListing.isMuted)
        else
            playerListing.mute:Hide()
            playerListing.mute.image.inst:DisableMute()
        end

        if can_kick then
            playerListing.kick:Show()
            playerListing.kick:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset

            local res = UserCommands.UserRunCommandResult("kick", self.owner, client.userid)
            if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                playerListing.kick:Select()
            else
                playerListing.kick:Unselect()
            end
        else
            playerListing.kick:Hide()
        end

        if can_ban then
            playerListing.ban:Show()
            playerListing.ban:SetPosition(button_x,3,0)
            button_x = button_x + button_x_offset

            local res = UserCommands.UserRunCommandResult("ban", self.owner, client.userid)
            if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                playerListing.ban:Select()
            else
                playerListing.ban:Unselect()
            end
        else
            playerListing.ban:Hide()
        end

        if this_user_is_dedicated_server then
            playerListing.useractions:Hide()
        else
            --Check if we have any user actions other than kick or ban (they have their own buttons)
            playerListing.useractions:Hide()
            for i, v in ipairs(UserCommands.GetUserActions(self.owner, playerListing.userid)) do
                if v.commandname ~= "kick" and v.commandname ~= "ban" then
                    playerListing.useractions:SetPosition(button_start + button_x_offset * 4, 3, 0)
                    playerListing.useractions:Show()
                    break
                end
            end
        end

        doButtonFocusHookups(playerListing)

        --pkc 更新得分信息
        if isDedicated and not playerListing.ishost and PKC_PLAYER_INFOS[playerListing.userid] ~= nil
                or (not isDedicated and PKC_PLAYER_INFOS[playerListing.userid] ~= nil) then
            --获取队伍颜色
            playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
            = getGroupColor(playerListing.userid)
            --设置队伍标识
            playerListing.groupTag:Show()
            playerListing.groupTag:SetString(getGroupShortNameByGroupId(PKC_PLAYER_INFOS[playerListing.userid].GROUP_ID))
            playerListing.groupTag:SetColour(playerListing.pkc_colour)
            --设置击杀数和颜色
            playerListing.killNum:Show()
            playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1
                    .. tostring(getPlayerKillNum(playerListing.userid)))
            playerListing.killNum:SetColour(playerListing.pkc_colour)
            --设置得分数和颜色
            playerListing.score:Show()
            playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2
                    .. tostring(getPlayerScore(playerListing.userid)))
            playerListing.score:SetColour(playerListing.pkc_colour)
            --设置玩家头像轮廓颜色
            playerListing.characterBadge.headframe:SetTint(unpack(playerListing.pkc_colour))
        else
            playerListing.groupTag:Hide()
            playerListing.killNum:Hide()
            playerListing.score:Hide()
            playerListing.characterBadge.headframe:SetTint(unpack(DEFAULT_PLAYER_COLOUR))
        end
    end

    if not self.scroll_list then
        self.list_root = self.root:AddChild(Widget("list_root"))
        self.list_root:SetPosition(210, -35)

        self.row_root = self.root:AddChild(Widget("row_root"))
        self.row_root:SetPosition(210, -35)

        --初始化六个进行填充
        self.player_widgets = {}
        for i=1,6 do
            table.insert(self.player_widgets, listingConstructor(i, self.row_root))
            UpdatePlayerListing(self.player_widgets[i], ClientObjs[i] or {}, i)
        end
        --构造玩家下拉列表
        self.scroll_list = self.list_root:AddChild(ScrollableList(ClientObjs, 380, 370, 60, 5, UpdatePlayerListing, self.player_widgets, nil, nil, nil, -15))
        self.scroll_list:LayOutStaticWidgets(-15)
        self.scroll_list:SetPosition(0,-10)

        self.focus_forward = self.scroll_list
        self.default_focus = self.scroll_list
    else
        self.scroll_list:SetList(ClientObjs)
    end

    if not self.bgs then
        self.bgs = {}
    end
    if #self.bgs > #ClientObjs then
        for i = #ClientObjs + 1, #self.bgs do
            table.remove(self.bgs):Kill()
        end
    else
        local maxbgs = math.min(self.scroll_list.widgets_per_view, #ClientObjs)
        if #self.bgs < maxbgs then
            for i = #self.bgs + 1, maxbgs do
                local bg = self.scroll_list:AddChild(Image("images/scoreboard.xml", "row.tex"))
                bg:SetTint(1, 1, 1, (i % 2) == 0 and .85 or .5)
                bg:SetPosition(-170, 165 - 65 * (i - 1))
                bg:MoveToBack()
                table.insert(self.bgs, bg)
            end
        end
    end
end

--玩家列表更新
function PlayerStatusScreen:OnUpdate(dt)
    if TheFrontEnd:GetFadeLevel() > 0 then
        self:Close()
    elseif self.time_to_refresh > dt then --判断是否需要更新
        self.time_to_refresh = self.time_to_refresh - dt
    else
        self.time_to_refresh = REFRESH_INTERVAL
        --获取玩家列表 判断是否需要重新构建
        local ClientObjs = TheNet:GetClientTable() or {}
        sortClient(ClientObjs) --pkc
        --rebuild if player count changed
        --如果玩家人数发生改变则重新构建
        local needs_rebuild = #ClientObjs ~= self.numPlayers

        --rebuild if players changed even though count didn't change
        --即使玩家人数没有发生改变也需要重新构建的情况
        if not needs_rebuild and self.scroll_list ~= nil then
            for i, client in ipairs(ClientObjs) do
                local listitem = self.scroll_list.items[i]
                if listitem == nil or
                        client.userid ~= listitem.userid or
                        (client.performance ~= nil) ~= (listitem.performance ~= nil) then
                    needs_rebuild = true
                    break
                end
            end
        end

        --如果需要重新构建则初始化列表
        if needs_rebuild then
            -- We've either added or removed a player
            -- Kill everything and re-init
            self:DoInit(ClientObjs)
        else
            --如果不需要则更新一下列表数据
            if TheNet:GetServerGameMode() == "lavaarena" then
                self.serverstate:SetString(subfmt(STRINGS.UI.PLAYERSTATUSSCREEN.LAVAARENA_SERVER_MODE, {mode=GetGameModeString(TheNet:GetServerGameMode()), num = TheWorld.net.components.lavaarenaeventstate:GetCurrentRound()}))
            elseif self.serverstate and self.serverage and self.serverage ~= TheWorld.state.cycles + 1 then
                self.serverage = TheWorld.state.cycles + 1
                local modeStr = GetGameModeString(TheNet:GetServerGameMode()) ~= nil and GetGameModeString(TheNet:GetServerGameMode()).." - " or ""
                self.serverstate:SetString(modeStr.." "..STRINGS.UI.PLAYERSTATUSSCREEN.AGE_PREFIX..self.serverage)
            end

            if self.scroll_list ~= nil then
                for _,playerListing in ipairs(self.player_widgets) do
                    for _,client in ipairs(ClientObjs) do
                        if playerListing.userid == client.userid and playerListing.ishost == (client.performance ~= nil) then
                            playerListing.name:SetTruncatedString(self:GetDisplayName(client), playerListing.name._align.maxwidth, playerListing.name._align.maxchars, true)
                            local w, h = playerListing.name:GetRegionSize()
                            playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)

                            playerListing.characterBadge:Set(client.prefab or "", client.colour or DEFAULT_PLAYER_COLOUR, playerListing.ishost, client.userflags or 0)

                            if playerListing.characterBadge:IsAFK() then
                                playerListing.age:SetString(STRINGS.UI.PLAYERSTATUSSCREEN.AFK)
                            else
                                playerListing.age:SetString(client.playerage ~= nil and client.playerage > 0 and (tostring(client.playerage)..(client.playerage == 1 and STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAY or STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAYS)) or "")
                            end

                            if client.performance ~= nil then
                                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_HOST_LEVELS[math.min(client.performance + 1, #PERF_HOST_LEVELS)])
                            elseif client.netscore ~= nil then
                                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_LEVELS[math.min(client.netscore + 1, #PERF_CLIENT_LEVELS)])
                            else
                                playerListing.perf:SetTexture("images/scoreboard.xml", PERF_CLIENT_UNKNOWN)
                            end

                            if playerListing.kick:IsVisible() then
                                local res = UserCommands.UserRunCommandResult("kick", self.owner, client.userid)
                                if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                                    playerListing.kick:Select()
                                else
                                    playerListing.kick:Unselect()
                                end
                            end

                            if playerListing.ban:IsVisible() then
                                local res = UserCommands.UserRunCommandResult("ban", self.owner, client.userid)
                                if res == COMMAND_RESULT.DENY or res == COMMAND_RESULT.DISABLED then
                                    playerListing.ban:Select()
                                else
                                    playerListing.ban:Unselect()
                                end
                            end

                            --pkc 更新得分信息
                            if isDedicated and not playerListing.ishost and playerListing.userid and PKC_PLAYER_INFOS[playerListing.userid] ~= nil
                                    or (not isDedicated and playerListing.userid and PKC_PLAYER_INFOS[playerListing.userid] ~= nil) then
                                --获取队伍颜色
                                playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
                                = getGroupColor(playerListing.userid)
                                --设置队伍标识
                                playerListing.groupTag:Show()
                                playerListing.groupTag:SetString(getGroupShortNameByGroupId(PKC_PLAYER_INFOS[playerListing.userid].GROUP_ID))
                                playerListing.groupTag:SetColour(playerListing.pkc_colour)
                                --设置击杀数和颜色
                                playerListing.killNum:Show()
                                playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1
                                        .. tostring(getPlayerKillNum(playerListing.userid)))
                                playerListing.killNum:SetColour(playerListing.pkc_colour)
                                --设置得分数和颜色
                                playerListing.score:Show()
                                playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2
                                        .. tostring(getPlayerScore(playerListing.userid)))
                                playerListing.score:SetColour(playerListing.pkc_colour)
                                --设置玩家头像轮廓颜色
                                playerListing.characterBadge.headframe:SetTint(unpack(playerListing.pkc_colour))
                            else
                                playerListing.groupTag:Hide()
                                playerListing.killNum:Hide()
                                playerListing.score:Hide()
                                playerListing.characterBadge.headframe:SetTint(unpack(DEFAULT_PLAYER_COLOUR))
                            end
                        end
                    end
                end
            end
        end
    end
end
