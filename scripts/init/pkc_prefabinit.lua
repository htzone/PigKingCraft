--@name pkc_prefabinit
--@description prefab初始化
--@auther redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--通过组件实现的prefab
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