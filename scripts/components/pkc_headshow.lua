--@name pkc_headshow
--@description 玩家头部显示名字组件
--@auther redpig
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
	
local PKC_HEADSHOW = Class(function(self, inst)
	self.inst = inst
	--self.jsonData = json.decode(json.encode({1,0,0}))
	self._headText = net_string(self.inst.GUID, "pkc_headshow._headText", "_headTextDirty")
	self._headColor = net_string(self.inst.GUID, "pkc_headshow._headColor", "_headColorDirty")
	self._setChoose = net_bool(self.inst.GUID, "pkc_headshow._hasChoose", "_setChooseDirty")
	
	self.headText = ""
	self.headColor = ""
	
	self.inst:ListenForEvent("_setChooseDirty", function() onSetChoose(self) end)
	
end,
nil,
{
	headText=onheadText,
	headColor=onheadColor,
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

--添加头部显示
function PKC_HEADSHOW:addHeadView()
	self.inst:DoTaskInTime(0.8, function()
		if self.inst then
			self.inst.pkc_title = SpawnPrefab("pkc_title")
			self.inst.pkc_title.entity:SetParent(self.inst.entity)
			self.inst.pkc_title.Transform:SetPosition(0, 3, 0)
			if next(self:getHeadColor()) ~= nil then
				self.inst.pkc_title.Label:SetColour(unpack(self:getHeadColor()))
			end
			if self:getHeadText() ~= nil then
				self.inst.pkc_title.Label:SetText(string.len(self:getHeadText()) <= 20 and self:getHeadText() or string.sub(self:getHeadText(), 1, 20).."...") --只取前20个字符
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