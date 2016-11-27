--@name pkc_introduction_screen
--@description 玩法介绍弹框
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
	
	--对话框显示
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(280, 300, 1, 1, 300 -80)) --后置背景宽高
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
	self.bg.fill:SetPosition(8, 12)
	self.bg.fill:SetSize(705, 380) --前置背景宽和高

    --title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(0, 170, 0)
    self.title:SetString(STRINGS.UI.INTRO.TITLE)
    self.title:SetColour(0,0,0,1)

    --subtitle
    self.subtitle = self.proot:AddChild(Text(NEWFONT_SMALL, 30))
    self.subtitle:SetPosition(0, 135, 0)
    self.subtitle:SetString(STRINGS.UI.INTRO.SUBTITLE)
    self.subtitle:SetColour(0,0,0,1)
	
	--description
	self.subtitle = self.proot:AddChild(Text(NEWFONT_SMALL, 25))
    self.subtitle:SetPosition(-43, 0, 0)
    self.subtitle:SetString(STRINGS.UI.INTRO.DESC)
    self.subtitle:SetColour(0,0,0,1)

    --create the menu itself
    local player = ThePlayer
    local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
    local button_w = 160
    local button_h = 45

	--添加按钮
    local buttons = {}
    table.insert(buttons, {text=STRINGS.UI.INTRO.NEXT, cb=function() self:nextStep() end }) 
    self.menu = self.proot:AddChild(Menu(buttons, -button_h, false))
    self.menu:SetPosition(0, -140, 0)
    for i,v in pairs(self.menu.items) do
        v:SetScale(.8)
    end

    if JapaneseOnPS4() then
        self.menu:SetTextSize(30)
        --self.afk_menu:SetTextSize(30)
    end

    TheInputProxy:SetCursorVisible(true)
    self.default_focus = self.menu
end)

--下一步（开始游戏）
function PauseScreen:nextStep()
    TheFrontEnd:PopScreen()
	local pkc_choosegroup_screen = require "screens/pkc_choosegroup_screen"
	TheFrontEnd:PushScreen(pkc_choosegroup_screen())
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
