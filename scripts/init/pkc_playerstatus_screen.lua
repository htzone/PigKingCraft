--@name pkc_playerstatus_screen
--@description 个人积分显示
--@auther redpig
--@date 2016-11-23

local require = GLOBAL.require
local SpawnPrefab = GLOBAL.SpawnPrefab
local Text = require "widgets/text"
local PlayerStatusScreen = require("screens/playerstatusscreen")
local OldDoInit = PlayerStatusScreen.DoInit
local DEFAULT_COLOR = "#B0B0B0"

local function getGroupNameByGroupId(groupId, language)
	if language == "chinese" then
		local groupName = "未知"
		if groupId == 1 then
			groupName = "大"
		elseif groupId == 2 then
			groupName = "红"
		elseif groupId == 3 then
			groupName = "龙"
		elseif groupId == 4 then
			groupName = "崔"
		end
		return groupName
	elseif language == "english" then
		local groupName = "unknown"
		if groupId == 1 then
			groupName = "BLU"
		elseif groupId == 2 then
			groupName = "RED"
		elseif groupId == 3 then
			groupName = "PUR"
		elseif groupId == 4 then
			groupName = "GRE"
		end
		return groupName
	end
	return ""

end

function PlayerStatusScreen:DoInit(ClientObjs, ...)
	OldDoInit(self, ClientObjs, ...)
	if not self.scroll_list.old_updatefn then -- if we haven't already patched the widgets
		for i, playerListing in pairs(self.scroll_list.static_widgets) do

			--playerListing.groupName = playerListing:AddChild(Text("bp50", 35, ""))
			--playerListing.groupName:SetPosition(playerListing.viewprofile:GetPosition():Get())
			--playerListing.groupName:SetPosition(playerListing.viewprofile:GetPosition():Get())
			--playerListing.groupName:SetHAlign(0)

			playerListing.killNum = playerListing:AddChild(Text("bp50", 35, ""))
			playerListing.killNum:SetPosition(111,3,0)
			playerListing.killNum:SetHAlign(0)

			playerListing.score = playerListing:AddChild(Text("bp50", 35, ""))
			playerListing.score:SetPosition(200,3,0)
			playerListing.score:SetHAlign(0)

			if PKC_PLAYER_INFOS[playerListing.userid] ~= nil then
				--设置队伍名
				--playerListing.groupName:SetString(""..getGroupNameByGroupId(PKC_PLAYER_INFOS[playerListing.userid].GROUP_ID, GLOBAL.GAME_LANGUAGE))
				--设置队伍名颜色
				playerListing.pkc_colour = {0,0,0, 1}
				playerListing.pkc_colour[1],playerListing.pkc_colour[2],playerListing.pkc_colour[3] = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(PKC_PLAYER_INFOS[playerListing.userid].GROUP_ID))
				--playerListing.groupName:SetColour(playerListing.pkc_colour)
				--设置击杀数和颜色
				playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1..pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].KILLNUM or 0))
				playerListing.killNum:SetColour(playerListing.pkc_colour)
				--设置得分数和颜色
				playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2..pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].SCORE or 0))
				playerListing.score:SetColour(playerListing.pkc_colour)
			else
				--设置队伍名
				--playerListing.groupName:SetString(getGroupNameByGroupId(0, GLOBAL.GAME_LANGUAGE))
				--设置队伍名颜色
				playerListing.pkc_colour = {0,0,0, 1}
				playerListing.pkc_colour[1],playerListing.pkc_colour[2],playerListing.pkc_colour[3] = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(0))
				--playerListing.groupName:SetColour(playerListing.pkc_colour)
			end
			
			-- if playerListing.characterBadge:IsAFK() then
			
			--playerListing.shareloc1 = playerListing:AddChild(ImageButton("images/unsharelocation.xml",
			--"unsharelocation.tex", "unsharelocation.tex",
			--"unsharelocation.tex", "unsharelocation.tex",
			--nil, {1,1}, {0,0}))
			--playerListing.shareloc1:SetPosition(playerListing.ban:GetPosition():Get())
			
			--playerListing.shareloc1:Show()
			--[[
			playerListing.shareloc:SetPosition(playerListing.mute:GetPosition():Get())
			playerListing.shareloc.scale_on_focus = false
			playerListing.shareloc:SetHoverText((is_sharing and "Uns" or "S").."hare Location", { font = GLOBAL.NEWFONT_OUTLINE, size = 24, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
			tint = is_sharing and {1,1,1,1} or {242/255, 99/255, 99/255, 255/255}
			playerListing.shareloc.image:SetTint(GLOBAL.unpack(tint))
			local gainfocusfn = playerListing.shareloc.OnGainFocus
			playerListing.shareloc.OnGainFocus = function()
				gainfocusfn(playerListing.shareloc)
				GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
				playerListing.shareloc.image:SetScale(1.1)
			end
			local losefocusfn = playerListing.shareloc.OnLoseFocus
			playerListing.shareloc.OnLoseFocus = function()
				losefocusfn(playerListing.shareloc)
				playerListing.shareloc.image:SetScale(1)
			end
			playerListing.shareloc:SetOnClick(function()
				is_sharing = not is_sharing
				local un = is_sharing and "" or "un"
				playerListing.shareloc.image_focus = un.."shareLocation.tex"
				playerListing.shareloc.image:SetTexture("images/"..un.."sharelocation.xml", un.."sharelocation.tex")
				playerListing.shareloc:SetTextures("images/"..un.."sharelocation.xml", un.."shareLocation.tex")
				playerListing.shareloc:SetHoverText((is_sharing and "Uns" or "S").."hare Location")
				tint = is_sharing and {1,1,1,1} or {242/255, 99/255, 99/255, 255/255}
				playerListing.shareloc.image:SetTint(GLOBAL.unpack(tint))
				
				SendModRPCToServer(MOD_RPC[modname]["ShareLocation"], is_sharing)
			end)
			
			if playerListing.userid == self.owner.userid then
				playerListing.viewprofile:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, playerListing.shareloc)
				playerListing.shareloc:SetFocusChangeDir(GLOBAL.MOVE_LEFT, playerListing.viewprofile)
				
				--playerListing.shareloc:SetFocusChangeDir(GLOBAL.MOVE_LEFT, playerListing.shareloc1)
				--playerListing.shareloc1:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, playerListing.shareloc)
			else
				playerListing.shareloc:Hide()
			end
			]]--
		end
		
		self.scroll_list.old_updatefn = self.scroll_list.updatefn
		self.scroll_list.updatefn = function(playerListing, client, ...)
			self.scroll_list.old_updatefn(playerListing, client, ...)
			--[[
			if client.userid == self.owner.userid then
				playerListing.shareloc:SetPosition(playerListing.mute:GetPosition():Get())
				playerListing.viewprofile:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, playerListing.shareloc)
				playerListing.shareloc:SetFocusChangeDir(GLOBAL.MOVE_LEFT, playerListing.viewprofile)
				playerListing.shareloc:Show()
				
				playerListing.shareloc1:SetPosition(playerListing.ban:GetPosition():Get())
				playerListing.shareloc:SetFocusChangeDir(GLOBAL.MOVE_LEFT, playerListing.shareloc1)
				playerListing.shareloc1:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, playerListing.shareloc)
				playerListing.shareloc1:Show()
				
			else
				playerListing.shareloc:Hide()
			end
			]]--
--			if PKC_PLAYER_INFOS[playerListing.userid] ~= nil then
--			end
--			playerListing.groupName:SetString(""..getGroupNameByGroupId(PKC_PLAYER_INFOS[client.userid].GROUP_ID, GLOBAL.GAME_LANGUAGE))
--			playerListing.pkc_colour[1],playerListing.pkc_colour[2],playerListing.pkc_colour[3] = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(PKC_PLAYER_INFOS[client.userid].GROUP_ID))
--			playerListing.groupName:SetColour(playerListing.pkc_colour)
--			playerListing.groupName:SetPosition(playerListing.mute:GetPosition():Get())
			--playerListing.killnumber:Show()

			if PKC_PLAYER_INFOS[client.userid] ~= nil then
				--设置队伍名
				--playerListing.groupName:SetString(""..getGroupNameByGroupId(PKC_PLAYER_INFOS[client.userid].GROUP_ID, GLOBAL.GAME_LANGUAGE))
				--设置队伍名颜色
				playerListing.pkc_colour[1],playerListing.pkc_colour[2],playerListing.pkc_colour[3] = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(PKC_PLAYER_INFOS[client.userid].GROUP_ID))
				--playerListing.groupName:SetColour(playerListing.pkc_colour)
				--playerListing.groupName:SetPosition(playerListing.mute:GetPosition():Get())
				--设置击杀数和颜色
				playerListing.killNum:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH1..pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].KILLNUM or 0))
				playerListing.killNum:SetColour(playerListing.pkc_colour)
				--设置得分数和颜色
				playerListing.score:SetString(PKC_SPEECH.SCORE_KILL_NUM.SPEECH2..pkc_numToString(PKC_PLAYER_INFOS[playerListing.userid].SCORE or 0))
				playerListing.score:SetColour(playerListing.pkc_colour)
			else
				--设置队伍名
				--playerListing.groupName:SetString(""..getGroupNameByGroupId(0, GLOBAL.GAME_LANGUAGE))
				--设置队伍名颜色
				playerListing.pkc_colour[1],playerListing.pkc_colour[2],playerListing.pkc_colour[3] = GLOBAL.HexToPercentColor(GLOBAL.getColorByGroupId(0))
				--playerListing.groupName:SetColour(playerListing.pkc_colour)
				--playerListing.groupName:SetPosition(playerListing.mute:GetPosition():Get())
			end
		end
	end
end
