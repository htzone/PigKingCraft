local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"

local Pvp_Widget = Class(Widget, function(self)
    Widget._ctor(self, "Pvp_Widget")

	self.button = self:AddChild(ImageButton())

	self.button:SetScale(.7, .7, .7)
	self.button:SetText("Hello PVP")
	self.button:SetClickable(false)
	self.button:Show()
end)

return Pvp_Widget
