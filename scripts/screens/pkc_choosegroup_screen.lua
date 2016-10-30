--@name pkc_choosegroup_screen
--@description 选择阵营弹框
--@auther redpig
--@date 2016-10-23

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
    self.title:SetPosition(0, 105, 0)
    self.title:SetString(STRINGS.UI.CHOOSEGROUP.TITLE)
    self.title:SetColour(0,0,0,1)

    --subtitle
    self.subtitle = self.proot:AddChild(Text(NEWFONT_SMALL, 16))
    self.subtitle:SetPosition(0, 75, 0)
    self.subtitle:SetString(STRINGS.UI.CHOOSEGROUP.SUBTITLE)
    self.subtitle:SetColour(0,0,0,1)

    --create the menu itself
    local player = ThePlayer
    local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
    local button_w = 160
    local button_h = 70 --竖排按钮间的距离

	--选择阵营按钮
    local buttons = {}
    table.insert(buttons, {text=STRINGS.UI.CHOOSEGROUP.BIGPIG, cb=function() self:chooseGroup(GROUP_BIGPIG_ID) end })
    table.insert(buttons, {text=STRINGS.UI.CHOOSEGROUP.REDPIG, cb=function() self:chooseGroup(GROUP_REDPIG_ID) end })

    self.menu = self.proot:AddChild(Menu(buttons, -button_h, false))
    self.menu:SetPosition(0, 20, 0)
    for i,v in pairs(self.menu.items) do
        v:SetScale(.8)
    end

    if JapaneseOnPS4() then
        self.menu:SetTextSize(30)
    end

    TheInputProxy:SetCursorVisible(true)
    self.default_focus = self.menu
end)

--取消无敌状态
local function cnancleInvincible(player, delay_time)
	player:DoTaskInTime(delay_time, function()
		if player then
			if player.components.health then
				player.components.health:SetInvincible(false)
			end
			if player._fx then
				player._fx:kill_fx()
				player._fx:Remove()
				player._fx = nil
			end
		end
	end)
end

--选择阵营势力
function PauseScreen:chooseGroup(group_id)
	if ThePlayer  then 
		if not ThePlayer.components.pkc_group then
			ThePlayer:AddComponent("pkc_group")
		end
		--标记已选择阵营
		ThePlayer.components.pkc_group:setChoosen(true)
		cnancleInvincible(ThePlayer, 5)
	end
	if GROUP_BIGPIG_ID == group_id then
		--TODO 选择阵营之后的操作，记录选择的阵营并传送至对应基地

		self:unpause()
	elseif GROUP_REDPIG_ID == group_id then
		--TODO 选择阵营之后的操作，记录选择的阵营并传送至对应基地
		
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
