--
-- 屏幕计分组件
-- Author: 大猪猪
-- Date: 2016/10/03
--

local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"

local Pvp_Widget = Class(Widget, function(self)
    Widget._ctor(self, "Pvp_Widget")

	self.button = self:AddChild(ImageButton())

	self.button:SetScale(.7, .7, .7)
	self.button:SetText("hello world")
	self.button:SetClickable(false)
	self.button:Show()
end)

return Pvp_Widget
