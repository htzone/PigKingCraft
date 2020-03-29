--
-- 阵营选择弹框
-- Author: RedPig
-- Date: 2016/10/23
--

local _G = _G or GLOBAL
require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"
local TEMPLATES = require "widgets/templates"

local function getExistGroups(groupNum)
	local exist_groups = {}
	for i = 1, groupNum do
		if EXIST_GROUPS[i] ~= nil and next(EXIST_GROUPS[i]) ~= nil then
			exist_groups[i] = EXIST_GROUPS[i]
		end
	end
	return exist_groups
end

local PauseScreen = Class(Screen, function(self)
    Screen._ctor(self, "PauseScreen")

    TheInput:ClearCachedController()

    self.active = true
    SetPause(true,"pause")

    --darken everything behind the dialog
    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0,0,0,0) -- invisible, but clickable!
    self.black:SetOnClick(function() 
	--TheFrontEnd:PopScreen() 
	end)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(-40, 236, 0.75, 0.75, 50, -31))
    self.bg:SetPosition(-5,0)
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetSize(295, 307)
    self.bg.fill:SetPosition(2, 10)
  
    --title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(0, 130, 0)
    self.title:SetString(STRINGS.UI.CHOOSEGROUP.TITLE)
    self.title:SetColour(0,0,0,1)

    --subtitle
    self.subtitle = self.proot:AddChild(Text(NEWFONT_SMALL, 16))
    self.subtitle:SetPosition(0, 90, 0)
    self.subtitle:SetString(STRINGS.UI.CHOOSEGROUP.SUBTITLE)
    self.subtitle:SetColour(0,0,0,1)

    --create the menu itself
    local player = ThePlayer
    local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
    local button_w = 160
   -- local button_h = 70 --竖排按钮间的距离 （两个）
    local button_h = 90

	--添加选择阵营按钮
    local buttons = {}
	
	--根据设置的阵营数和存在的阵营数来设置button
	local exist_groups = CURRENT_EXIST_GROUPS
	
	for k, v in pairs(exist_groups) do
		table.insert(buttons, {text=STRINGS.UI.CHOOSEGROUP.BUTTON_NAME[k], cb=function() self:chooseGroup(v) end })
	end
	
	if GROUP_NUM >= 3 then
		button_h = 70
	end
	
	if GROUP_NUM >= 4 then
		button_h = 50
	end
	
    self.menu = self.proot:AddChild(Menu(buttons, -button_h, false))
	if GROUP_NUM < 3 then
		self.menu:SetPosition(0, 20, 0)
	else
		self.menu:SetPosition(0, 50, 0)
	end
    
    for i,v in pairs(self.menu.items) do
        v:SetScale(.8)
    end

    if JapaneseOnPS4() then
        self.menu:SetTextSize(30)
    end

    TheInputProxy:SetCursorVisible(true)
    self.default_focus = self.menu
end)

--把请求发送给主机,这样就省去网络变量的定义了
--@param player 玩家
--@param group_id 玩家选择的营地ID
--@大猪猪 10-31
local function teleportToBase(player, group_id)
	local Namespace="pkc_teleport"
	local Action="TeleportToBase"
	if TheWorld.ismastersim then
		MOD_RPC_HANDLERS[Namespace][MOD_RPC[Namespace][Action].id](player, group_id)
	else
		SendModRPCToServer( MOD_RPC[Namespace][Action], group_id)
	end
end

--选择阵营势力
--选择后进入基地
--@大猪猪 10-31
function PauseScreen:chooseGroup(group_id)
	if ThePlayer then
		teleportToBase(ThePlayer, group_id)
		self:unpause()
	end
end

function PauseScreen:unpause()
    TheInput:CacheController()
    self.active = false
    TheFrontEnd:PopScreen(self)
    SetPause(false)
    TheWorld:PushEvent("continuefrompause")
end

function PauseScreen:OnControl(control, down)
    if PauseScreen._base.OnControl(self,control, down) then
        return true
    elseif not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then
        --self:unpause()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function PauseScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function PauseScreen:OnBecomeActive()
	PauseScreen._base.OnBecomeActive(self)
	-- Hide the topfade, it'll obscure the pause menu if paused during fade. Fade-out will re-enable it
	TheFrontEnd:HideTopFade()
end

return PauseScreen
