--@name pkc_headshow
--@description 玩家头部显示名字组件
--@author redpig
--@date 2016-11-08

--local json = require "json"

local function onheadText(self,v)
	self._headText:set(v)
end

local function onheadColor(self, v)
	self._headColor:set(v)
end

--当选择完阵营后在客机调用
local function onSetChoose(self)
	if self._setChoose:value() then
		self:addHeadView()
	end
end

local function ontitleText(self, v)
	self._titleText:set(v)
end

local function ontitleColor(self, v)
	self._titleColor:set(v)
end

local function onSetTitle(self)
	if self._setTitle:value() then
		self:addTitle()
	end
end

local PKC_HEADSHOW = Class(function(self, inst)
	self.inst = inst
	--self.jsonData = json.decode(json.encode({1,0,0}))
	self._headText = net_string(self.inst.GUID, "pkc_headshow._headText", "_headTextDirty")
	self._headColor = net_string(self.inst.GUID, "pkc_headshow._headColor", "_headColorDirty")
	self._setChoose = net_bool(self.inst.GUID, "pkc_headshow._hasChoose", "_setChooseDirty")
	self._titleText = net_string(self.inst.GUID, "pkc_headshow._titleText", "_titleTextDirty")
	self._titleColor = net_string(self.inst.GUID, "pkc_headshow._titleColor", "_titleColorDirty")
	self._setTitle = net_bool(self.inst.GUID, "pkc_headshow._settitle", "_settitleDirty")

	self.headText = ""
	self.headColor = ""
	self.titleText = ""
	self.titleColor = ""
	
	self.inst:ListenForEvent("_setChooseDirty", function() onSetChoose(self) end)
	self.inst:ListenForEvent("_settitleDirty", function() onSetTitle(self) end)
end,
nil,
{
	headText=onheadText,
	headColor=onheadColor,
	titleText=ontitleText,
	titleColor=ontitleColor;
})

--设置文字
function PKC_HEADSHOW:setHeadText(text)
	self.headText = text
end

--设置颜色
function PKC_HEADSHOW:setHeadColor(color)
	self.headColor = color
end

--选择完阵营后触发客机回调
function PKC_HEADSHOW:setChoose(isChoose)
	self._setChoose:set(true)
end
-------

--设置title文字
function PKC_HEADSHOW:setTitleText(text)
	self.titleText = text
end

--设置title颜色
function PKC_HEADSHOW:setTitleColor(color)
	self.titleColor = color
end

--触发客机title调用
function PKC_HEADSHOW:setTitle(isSet)
	self._setTitle:set(true)
end
--------

--获取文字
function PKC_HEADSHOW:getHeadText()
	return self._headText:value()
end

--获取颜色
function PKC_HEADSHOW:getHeadColor()
	local colour = {0,0,0}
	colour[1],colour[2],colour[3] = HexToPercentColor(self._headColor:value())
	return colour
end

-------

--获取Title文字
function PKC_HEADSHOW:getTitleText()
	return self._titleText:value()
end

--获取Title颜色
function PKC_HEADSHOW:getTitleColor()
	local colour = {0,0,0 }
	if self._titleColor:value() ~= nil and self._titleColor:value() ~= "" then
		colour[1],colour[2],colour[3] = HexToPercentColor(self._titleColor:value())
		return colour
	else
		return nil
	end
end

local titles = {
	"万恶的小红猪Lv.1",
--	"萌新Lv.2",
--	"新司机Lv.4",
--	"老司机Lv.7",
--	"大佬Lv.9",
--	"神Lv.10",
}
--添加头部显示
function PKC_HEADSHOW:addHeadView()
	self.inst:DoTaskInTime(0.8, function()
		if self.inst then
			self.inst.pkc_title = SpawnPrefab("pkc_title")
			self.inst.pkc_title.entity:SetParent(self.inst.entity)
			self.inst.pkc_title.Transform:SetPosition(0, 3, 0)

			--称号
--			self.inst.pkc_title2 = SpawnPrefab("pkc_title")
--			self.inst.pkc_title2.entity:SetParent(self.inst.entity)
--			self.inst.pkc_title2.Transform:SetPosition(0, 3, 0)
--			self.inst.pkc_title2.Label:SetText("[坑逼Lv.1]")
--			self.inst.pkc_title2.Label:SetFontSize(22)
--			self.inst.pkc_title2.Label:SetWorldOffset(0, 3.6, 0)

			if next(self:getHeadColor()) ~= nil then
				self.inst.pkc_title.Label:SetColour(unpack(self:getHeadColor()))
			end
			if self:getHeadText() ~= nil then
				local headtext = trim(self:getHeadText())
				if headtext == "" or string.len(headtext) < 2 then
					if GAME_LANGUAGE == "chinese" then
						self.inst.pkc_title.Label:SetText("["..headtext.."我是傻逼]")
					else
						self.inst.pkc_title.Label:SetText("["..headtext.."ImSB]")
					end
				else
					self.inst.pkc_title.Label:SetText("["..(string.len(self:getHeadText()) <= 20 and self:getHeadText() or string.sub(self:getHeadText(), 1, 22)).."]") --只取前20个字符
				end
			end
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
		headText = self.headText,
		headColor = self.headColor,

	}
end

function PKC_HEADSHOW:OnLoad(data)
	if data ~= nil then
		if data.headText ~= nil then
			self.headText = data.headText
		end
		if data.headColor ~= nil then
			self.headColor = data.headColor
		end
	end
end

return PKC_HEADSHOW