--@name pkc_prefabs
--@description 模拟prefab行为组件
--@auther redpig
--@date 2016-11-20

local PKC_PREFABS = Class(function(self, inst)
	self.inst = inst
	self.tags ={}
	self.attrs = {}
end,
nil,
{
})

--制造国王墓碑
local function makePigkingGrave(inst, name, desc)

	if name ~= nil then
		if not inst.components.named then
			inst:AddComponent("named")
		end
		inst.components.named:SetName(name)
	end
	
	if desc ~= nil then
		if not inst.components.inspectable then
			inst:AddComponent("inspectable")
		end
		inst.components.inspectable:SetDescription(desc)
	end
	
	inst.mound = nil
	local currentscale = inst.Transform:GetScale()
	inst.Transform:SetScale(currentscale*2.5,currentscale*2.5,currentscale*2.5)
	if inst.Transform then
		local x, y, z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 4)
		for _,obj in pairs(ents) do
			if obj and obj.prefab == "mound" then
				obj:Remove()
				break
			end
		end
	end
end

--生成物体
function PKC_PREFABS:make(name, desc)
	self.pkc_prefab = true
	self.name = name
	self.desc = desc
	--国王墓碑
	if self.inst.prefab == "gravestone" and self.inst:HasTag("kinggrave") then
		table.insert(self.tags, "king")
		table.insert(self.tags, "kinggrave")
		table.insert(self.tags, "pkc_group"..self.inst.pkc_group_id)
		self.attrs[1] = {}
		self.attrs[1].name = "pkc_group_id"
		self.attrs[1].value = self.inst.pkc_group_id
		makePigkingGrave(self.inst, name, desc)
	end
end

function PKC_PREFABS:OnSave()
	return
	{	
		pkc_prefab = self.pkc_prefab,
		name = self.name,
		desc = self.desc,
		tags = self.tags,
		attrs = self.attrs,
	}
end

function PKC_PREFABS:OnLoad(data)
	if data ~= nil then
		if data.tags and next(data.tags) ~= nil then
			for _, tag in pairs(data.tags) do
				self.inst:AddTag(tag)
			end
		end
		if data.attrs and next(data.attrs) ~= nil then
			for _, attr in ipairs(data.attrs) do
				self.inst[attr.name] = attr.value
			end
		end
		if data.pkc_prefab and data.name and data.desc then
			self:make(data.name, data.desc)
		end
	end
end

return PKC_PREFABS