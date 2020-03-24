-- 自定义地图图标
-- Author: RedPig
-- Date: 2020/3/23

require("constants")
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local MapIcon = Class(Widget, function(self)
    Widget._ctor(self, "MapIcon")
    self.isFE = false
    self:SetClickable(false)
    self.text = self:AddChild(Text(UIFONT, 30))
    --    self.default_text_pos = Vector3(0, 40, 0)
--    self.text:SetPosition(self.default_text_pos)
--    self:SetPosition(scr_w / 2, scr_h / 2)
end)

function MapIcon:GetString(...)
    return self.text:GetString(...)
end

function MapIcon:SetString(...)
    return self.text:SetString(...)
end

function MapIcon:SetColour(...)
    return self.text:SetColour(...)
end

return MapIcon

