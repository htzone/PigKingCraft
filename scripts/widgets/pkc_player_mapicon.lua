-- 自定义地图图标
-- Author: RedPig
-- Date: 2020/3/23

local Widget = require "widgets/widget"
local PlayerBadge = require "widgets/playerbadge"

local PlayerMapIcon = Class(Widget, function(self, prefab, colour)
    Widget._ctor(self, "PlayerMapIcon")
    self.isFE = false
    self:SetClickable(false)
    self.prefabName = prefab or ""
    self.colour = colour or DEFAULT_PLAYER_COLOUR
    self.icon = self:AddChild(PlayerBadge(self.prefabName, self.colour, false, 0))
    self.icon:SetScale(.3)
end)

function PlayerMapIcon:Scale(scale)
    self.icon:SetScale(scale)
end

function PlayerMapIcon:ShowIcon()
    self.icon:Show()
    self.shown = true
end

function PlayerMapIcon:HideIcon()
    self.icon:Hide()
    self.shown = false
end

function PlayerMapIcon:Set(prefab, colour)
    self.prefabName = prefab or ""
    self.colour = colour or DEFAULT_PLAYER_COLOUR
    self.icon:Set(self.prefabName, self.colour, false, 0)
end

return PlayerMapIcon

