--@name pkc_prefabinit
--@description prefab初始化
--@auther redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--通过组件模拟prefab
local ComponentPrefabs = {
	"gravestone",
}

local function addComponent(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:AddComponent("pkc_prefabs")
	end
end

for _,v in pairs(ComponentPrefabs) do
	AddPrefabPostInit(v, addComponent) --组件实现的prefab,减少定义prefab的麻烦
end

--变大
local toBigTable = {
	{name = "deerclops", size = 1.5},
	{name = "moose", size = 1.5},
	{name = "bearger", size = 1.5},
}

local function toBig(inst, size)
	local mobSize = size or 1.5
	if inst and inst.Transform then
		local currentscale = inst.Transform:GetScale()
		if currentscale < 1.5 then
			inst.Transform:SetScale(currentscale * mobSize, currentscale * mobSize, currentscale * mobSize)
		end
	end	
end

for _, v in pairs(toBigTable) do
	AddPrefabPostInit(v.name, function(inst) toBig(inst, v.size) end)
end
