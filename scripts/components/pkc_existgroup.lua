--@name pkc_existgroup
--@description 设置当前存在队伍组件
--@author redpig
--@date 2016-10-23

json = require "json"

local function onExistGroupsDirty(inst)
	local self = inst.components.pkc_existgroup
	CURRENT_EXIST_GROUPS = json.decode(self._existGroups:value())
	self.existGroups = CURRENT_EXIST_GROUPS
end

local PKC_EXISTGROUP = Class(function(self, inst)
	self.inst = inst
	self.existGroups = {}
	self._existGroups = net_string(self.inst.GUID, "pkc_existgroup._existGroups", "_existGroupsDirty")
	inst:ListenForEvent("_existGroupsDirty", onExistGroupsDirty)
end,
nil,
{
})

function PKC_EXISTGROUP:init()
	--第一次初始化
	if next(self.existGroups) == nil then
		for i=1, GROUP_NUM do
			CURRENT_EXIST_GROUPS[GROUP_ORDER[i]] = GROUP_INFOS[GROUP_ORDER[i]].id
		end
		self.existGroups = CURRENT_EXIST_GROUPS
		self._existGroups:set(json.encode(CURRENT_EXIST_GROUPS))
	else
		CURRENT_EXIST_GROUPS = self.existGroups
		self._existGroups:set(json.encode(CURRENT_EXIST_GROUPS))
	end
end

function PKC_EXISTGROUP:removeGroup(groupId)

	for k, v in pairs(CURRENT_EXIST_GROUPS) do
	if v == groupId then
		CURRENT_EXIST_GROUPS[k] = nil
		break
	end
	end
	self.existGroups = CURRENT_EXIST_GROUPS
	self._existGroups:set(json.encode(CURRENT_EXIST_GROUPS))

end

function PKC_EXISTGROUP:OnSave()
	return
	{	
		existGroups = json.encode(self.existGroups),
	}
end

function PKC_EXISTGROUP:OnLoad(data)
	if data ~= nil then
		if data.existGroups ~= nil then
			self.existGroups = json.decode(data.existGroups)
		end
	end
end

return PKC_EXISTGROUP