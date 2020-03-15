--@name pkc_headshow
--@description 玩家头部显示名字组件
--@author redpig
--@date 2016-11-08

local PKC_HEADSHOW = Class(function(self, inst)
    self.inst = inst

    self._headText = net_string(self.inst.GUID, "pkc_headshow._headText", "_headTextDirty")
    self._headGroupTag = net_string(self.inst.GUID, "pkc_headshow._headGroupTag", "_headGroupTagDirty")
    self._headColor = net_string(self.inst.GUID, "pkc_headshow._headColor", "_headColorDirty")
    self._eventAddHeader = net_event(self.inst.GUID, "_eventAddHeaderDirty", "_eventAddHeaderDirty")

    self._titleText = net_string(self.inst.GUID, "pkc_headshow._titleText", "_titleTextDirty")
    self._titleColor = net_string(self.inst.GUID, "pkc_headshow._titleColor", "_titleColorDirty")
    self._eventAddTitle = net_event(self.inst.GUID, "_eventAddTitleDirty", "_eventAddTitleDirty")

    self.inst:ListenForEvent("_eventAddHeaderDirty", function() self:addHeadView() end)
    self.inst:ListenForEvent("_eventAddTitleDirty", function() self:addTitle() end)
end,
nil,
{})

--设置文字
function PKC_HEADSHOW:setHeadText(text)
    self._headText:set(text)
end

--设置头部标志
function PKC_HEADSHOW:setHeadGroupTag(text)
    self._headGroupTag:set(text)
end

--设置颜色
function PKC_HEADSHOW:setHeadColor(color)
    self._headColor:set(color)
end

-------

--设置title文字
function PKC_HEADSHOW:setTitleText(text)
    self._titleText:set(text)
end

--设置title颜色
function PKC_HEADSHOW:setTitleColor(color)
    self._titleColor:set(color)
end

--------

--获取文字
function PKC_HEADSHOW:getHeadText()
    return self._headText:value()
end

--获取头部标志
function PKC_HEADSHOW:getHeadGroupTag()
    return self._headGroupTag:value()
end

--获取颜色
function PKC_HEADSHOW:getHeadColor()
    local colour = { 0, 0, 0 }
    colour[1], colour[2], colour[3] = HexToPercentColor(self._headColor:value())
    return colour
end

-------

--获取Title文字
function PKC_HEADSHOW:getTitleText()
    return self._titleText:value()
end

--获取Title颜色
function PKC_HEADSHOW:getTitleColor()
    local colour = { 0, 0, 0 }
    if self._titleColor:value() ~= nil and self._titleColor:value() ~= "" then
        colour[1], colour[2], colour[3] = HexToPercentColor(self._titleColor:value())
        return colour
    else
        return nil
    end
end

function PKC_HEADSHOW:addHeadView()
    self.inst:DoTaskInTime(0.8, function()
        if self.inst then
            self.inst.pkc_title = SpawnPrefab("pkc_title")
            self.inst.pkc_title.entity:SetParent(self.inst.entity)
            self.inst.pkc_title.Transform:SetPosition(0, 3, 0)
            if next(self:getHeadColor()) ~= nil then
                self.inst.pkc_title.Label:SetColour(unpack(self:getHeadColor()))
            end
            local tag = self:getHeadGroupTag() or "★"
            local headText = self:getHeadText() or "Unknow"
            headText = trim(headText)
            self.inst.pkc_title.Label:SetText(tag .. (string.len(headText) <= 20
                        and headText or string.sub(headText, 1, 22)) .. tag) --截取前面字符，避免名字太长
        end
    end)
end

function PKC_HEADSHOW:addTitle()
    self.inst:DoTaskInTime(0.8, function()
        if self.inst then
            --称号
            self.inst.pkc_title2 = SpawnPrefab("pkc_title")
            self.inst.pkc_title2.entity:SetParent(self.inst.entity)
            self.inst.pkc_title2.Transform:SetPosition(0, 3, 0)
            self.inst.pkc_title2.Label:SetText("")
            self.inst.pkc_title2.Label:SetFontSize(22)
            self.inst.pkc_title2.Label:SetWorldOffset(0, 3.6, 0)

            if self:getTitleColor() and next(self:getTitleColor()) ~= nil then
                self.inst.pkc_title2.Label:SetColour(unpack(self:getTitleColor()))
            end
            if self:getTitleText() ~= nil then
                local headtext = trim(self:getTitleText())
                self.inst.pkc_title2.Label:SetText(headtext)
            end
        end
    end)
end

function PKC_HEADSHOW:OnSave()
    return
    {
        headText = self._headText:value(),
        headColor = self._headColor:value(),
    }
end

function PKC_HEADSHOW:OnLoad(data)
    if data ~= nil then
        if data.headText ~= nil then
            self._headText:set(data.headText)
        end
        if data.headColor ~= nil then
            self._headColor:set(data.headColor)
        end
    end
end

return PKC_HEADSHOW