--
-- 玩家计分显示屏幕
-- Author: RedPig
-- Date: 2016/11/23
--

local require = GLOBAL.require
local Text = require "widgets/text"
local UserCommands = require "usercommands"
local PlayerStatusScreen = require("screens/playerstatusscreen")
local REFRESH_INTERVAL = .5
local isDedicated = not TheNet:GetServerIsClientHosted()

local PERF_HOST_LEVELS =
{
    "host_indicator3.tex", --GOOD
    "host_indicator2.tex", --OK
    "host_indicator1.tex", --BAD
}

local PERF_CLIENT_UNKNOWN = "performance_indicator.tex"
local PERF_CLIENT_LEVELS =
{
    "performance_indicator3.tex", --GOOD
    "performance_indicator2.tex", --OK
    "performance_indicator1.tex", --BAD
}

--根据得分对玩家进行排序
local function sortClient(clientObjs)
    if not isDedicated then
        table.sort(clientObjs, function(a, b)
            local aScore = PKC_PLAYER_INFOS[a.userid].SCORE or 0
            local bScore = PKC_PLAYER_INFOS[b.userid].SCORE or 0
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
            local aScore = PKC_PLAYER_INFOS[a.userid].SCORE or 0
            local bScore = PKC_PLAYER_INFOS[b.userid].SCORE or 0
            return aScore > bScore
        end)
    end
end

--显示数字
local function showSortNum(playerListing, i)
    if isDedicated then
        playerListing.number:SetString(i-1)
        if i > 1 then
            playerListing.number:Show()
        else
            playerListing.number:Hide()
        end
    else
        playerListing.number:SetString(i)
        playerListing.number:Show()
    end
end

--高亮显示
local function showHighLight(playerListing)
    if playerListing.userid == ThePlayer.userid and playerListing.highlight then
        playerListing.highlight:Show()
    end
end

local OldDoInit = PlayerStatusScreen.DoInit
function PlayerStatusScreen:DoInit(ClientObjs, ...)
    if ClientObjs == nil then
        ClientObjs = TheNet:GetClientTable() or {}
    end
    --根据得分排序
    sortClient(ClientObjs)
    OldDoInit(self, ClientObjs, ...)
    if not self.scroll_list.old_updatefn then -- if we haven't already patched the widgets
        for i, playerListing in pairs(self.scroll_list.static_widgets) do
            showSortNum(playerListing, i)
            showHighLight(playerListing)
            playerListing.killNum = playerListing:AddChild(Text("bp50", 35, ""))
            playerListing.killNum:SetPosition(110, 3, 0)
            playerListing.killNum:SetHAlign(ANCHOR_MIDDLE)
            playerListing.score = playerListing:AddChild(Text("bp50", 35, ""))
            playerListing.score:SetPosition(190, 3, 0)
            playerListing.score:SetHAlign(ANCHOR_MIDDLE)
            playerListing.pkc_colour = { 1, 1, 1, 1 }
            if PKC_PLAYER_INFOS[playerListing.userid] ~= nil then
                --设置队伍名颜色
                playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
                = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(PKC_PLAYER_INFOS[playerListing.userid].GROUP_ID))
                --设置击杀数和颜色
                playerListing.killNum:Show()
                playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1
                        .. pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].KILLNUM or 0))
                playerListing.killNum:SetColour(playerListing.pkc_colour)
                --设置得分数和颜色
                playerListing.score:Show()
                playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2
                        .. pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].SCORE or 0))
                playerListing.score:SetColour(playerListing.pkc_colour)

                playerListing.characterBadge.headframe:SetTint(unpack(playerListing.pkc_colour))
            else
                playerListing.killNum:Hide()
                playerListing.score:Hide()
                playerListing.characterBadge.headframe:SetTint(unpack(DEFAULT_PLAYER_COLOUR))
            end
        end

        self.scroll_list.old_updatefn = self.scroll_list.updatefn
        self.scroll_list.updatefn = function(playerListing, client, ...)
            self.scroll_list.old_updatefn(playerListing, client, ...)
            showHighLight(playerListing)
            if PKC_PLAYER_INFOS[client.userid] ~= nil then
                --设置队伍名颜色
                playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
                = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(PKC_PLAYER_INFOS[client.userid].GROUP_ID))
                --设置击杀数和颜色
                playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1
                        .. pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].KILLNUM or 0))
                playerListing.killNum:SetColour(playerListing.pkc_colour)
                --设置得分数和颜色
                playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2
                        .. pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].SCORE or 0))
                playerListing.score:SetColour(playerListing.pkc_colour)

                playerListing.characterBadge.headframe:SetTint(unpack(playerListing.pkc_colour))
            end
        end
    end
end

function PlayerStatusScreen:OnUpdate(dt)
    if TheFrontEnd:GetFadeLevel() > 0 then
        self:Close()
    elseif self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
    else
        self.time_to_refresh = REFRESH_INTERVAL

        local ClientObjs = TheNet:GetClientTable() or {}

        sortClient(ClientObjs)

        --rebuild if player count changed
        local needs_rebuild = #ClientObjs ~= self.numPlayers

        --rebuild if players changed even though count didn't change
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

        if needs_rebuild then
            -- We've either added or removed a player
            -- Kill everything and re-init
            self:DoInit(ClientObjs)
        else
            if TheNet:GetServerGameMode() == "lavaarena" then
                self.serverstate:SetString(subfmt(STRINGS.UI.PLAYERSTATUSSCREEN.LAVAARENA_SERVER_MODE,
                    {mode=GetGameModeString(TheNet:GetServerGameMode()),
                        num = TheWorld.net.components.lavaarenaeventstate:GetCurrentRound()}))
            elseif self.serverstate and self.serverage and self.serverage ~= TheWorld.state.cycles + 1 then
                self.serverage = TheWorld.state.cycles + 1
                local modeStr = GetGameModeString(TheNet:GetServerGameMode()) ~= nil
                        and GetGameModeString(TheNet:GetServerGameMode()).." - " or ""
                self.serverstate:SetString(modeStr.." "..STRINGS.UI.PLAYERSTATUSSCREEN.AGE_PREFIX..self.serverage)
            end

            if self.scroll_list ~= nil then
                for i, playerListing in ipairs(self.player_widgets) do
                    showHighLight(playerListing)
                    showSortNum(playerListing, i)
                    for _,client in ipairs(ClientObjs) do
                        if playerListing.userid == client.userid
                                and playerListing.ishost == (client.performance ~= nil) then
                            playerListing.name:SetTruncatedString(
                                self:GetDisplayName(client),
                                playerListing.name._align.maxwidth,
                                playerListing.name._align.maxchars, true)
                            local w, h = playerListing.name:GetRegionSize()
                            playerListing.name:SetPosition(playerListing.name._align.x + w * .5, 0, 0)

                            playerListing.pkc_colour = playerListing.pkc_colour or { 1, 1, 1, 1 }
                            playerListing.pkc_colour[1], playerListing.pkc_colour[2], playerListing.pkc_colour[3]
                            = HexToPercentColor(getColorByGroupId(PKC_PLAYER_INFOS[client.userid].GROUP_ID))
                            playerListing.characterBadge:Set(
                                client.prefab or "",
                                playerListing.pkc_colour,
                                playerListing.ishost, client.userflags or 0)

                            if playerListing.characterBadge:IsAFK() then
                                playerListing.age:SetString(STRINGS.UI.PLAYERSTATUSSCREEN.AFK)
                            else
                                playerListing.age:SetString(
                                    client.playerage ~= nil and client.playerage > 0 and (tostring(client.playerage)
                                            ..(client.playerage == 1 and STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAY
                                            or STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAYS)) or "")
                            end

                            if client.performance ~= nil then
                                playerListing.perf:SetTexture("images/scoreboard.xml",
                                    PERF_HOST_LEVELS[math.min(client.performance + 1, #PERF_HOST_LEVELS)])
                            elseif client.netscore ~= nil then
                                playerListing.perf:SetTexture("images/scoreboard.xml",
                                    PERF_CLIENT_LEVELS[math.min(client.netscore + 1, #PERF_CLIENT_LEVELS)])
                            else
                                playerListing.perf:SetTexture("images/scoreboard.xml",
                                    PERF_CLIENT_UNKNOWN)
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
                        end
                    end
                end
            end
        end
    end
end
