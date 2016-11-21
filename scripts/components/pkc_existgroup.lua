--@name pkc_existgroup
--@description 玩家所属阵营组件
--@auther redpig
--@date 2016-10-23
--@大猪猪 10-31

json = require "json"

local function onExistGroupNumDirty(inst)
	local self = inst.components.pkc_existgroup
	GROUP_NUM = self._existGroupNum:value()
end

local PKC_EXISTGROUP = Class(function(self, inst)
	self.inst = inst
	self._existGroupNum = net_shortint(self.inst.GUID, "pkc_existgroup._existGroupNum", "_existGroupNumDirty")
	self.inst.existGroups = {BIGPIG = 1, REDPIG = 2, LONGPIG = 3, CUIPIG = 4}
	inst:ListenForEvent("_existGroupNumDirty", onExistGroupNumDirty)
end,
nil,
{
})

function PKC_EXISTGROUP:setExistGroupNum(num)
	GROUP_NUM = num
	self._existGroupNum:set(num)
end

function PKC_EXISTGROUP:OnSave()
	return
	{	
		existGroups = json.encode(self.inst.existGroups),
	}
end

function PKC_EXISTGROUP:OnLoad(data)
	if data ~= nil then
		if data.existGroups ~= nil then
			self.inst.existGroups = json.decode(data.existGroups)
		end
	end
end

return PKC_EXISTGROUP