--
-- 玩家地图图标
-- Author: RedPig
-- Date: 2020/03/23
--

local Widget = require "widgets/widget"
local Image = require('widgets/image')
local Text = require('widgets/text')
local PlayerBadge = require "widgets/playerbadge"

local PlayerMapIcon = Class(Widget, function(self, prefab, colour)
    Widget._ctor(self, "PlayerMapIcon")
    self.isFE = false
    self:SetClickable(false)
    self.prefabName = prefab or ""
    self.colour = colour or DEFAULT_PLAYER_COLOUR
    self.icon = self:AddChild(PlayerBadge(self.prefabName, self.colour, false, 0))
    self.icon:SetScale(.84)
    self.title = self:AddChild(Image("images/pkc_status_bgs.xml", "pkc_status_bgs.tex"))
    self.title:SetScale( .75,.4,.75)
    self.title:SetPosition(-.5, -35, 0)
    self.text = self:AddChild(Text(NUMBERFONT, 20))
    self.text:SetFont(NUMBERFONT)
    self.text:SetSize(20)
    self.text:SetPosition(2, -35.5, 0)
    self.text:SetScale(1,1,1)
    self.text:MoveToFront()
    self:SetName("Unknown")
end)

function PlayerMapIcon:Scale(scale)
    self:SetScale(scale)
end

function PlayerMapIcon:SetName(text, color)
    text = text or ""
    color = color or DEFAULT_PLAYER_COLOUR
    local name = trim(text)
    local num = string.len(name)
    if num == 0 then
        self.text:SetString("Unknown")
    else
        self.text:SetString(num <= 12 and name or (tostring(string.sub(name, 1, 12))).."...")
        self.text:SetColour(color)
    end

    if num >= 12 then
        self.title:SetScale( .8,.4,.8)
    elseif num > 6 then
        self.title:SetScale( .6,.4,.6)
    else
        self.title:SetScale( .4,.4,.4)
    end
end

function PlayerMapIcon:ShowIcon()
    self:Show()
    self.shown = true
end

function PlayerMapIcon:HideIcon()
    self:Hide()
    self.shown = false
end

function PlayerMapIcon:SetIcon(prefab, colour)
    self.prefabName = prefab or ""
    self.colour = colour or DEFAULT_PLAYER_COLOUR
    self.icon:Set(self.prefabName, self.colour, false, 0)
end

return PlayerMapIcon

