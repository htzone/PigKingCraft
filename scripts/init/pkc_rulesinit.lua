--@name pkc_rulesinit
--@description 约束初始化
--@auther 大猪猪，redpig
--@date 2016-11-05

local function removeBurnable(inst)
	if GLOBAL.TheWorld.ismastersim then
		if inst 
		and inst:HasTag("structure")
		and inst.components.burnable
		then
			inst:RemoveTag("canlight")
			inst:AddTag("nolight")
			inst:AddTag("fireimmune")
		end
	end
end
--设置所有建筑不可烧
for k,recipes in pairs(GLOBAL.AllRecipes) do
	AddPrefabPostInit(recipes.name, removeBurnable)
end

--设置火焰蔓延半径为一半半径
local CurrentMakeSmallPropagator = GLOBAL.MakeSmallPropagator
GLOBAL.MakeSmallPropagator = function(inst)
	CurrentMakeSmallPropagator(inst)
	if inst.components.propagator then
		inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
	end
end
local CurrentMakeMediumPropagator = GLOBAL.MakeMediumPropagator
GLOBAL.MakeMediumPropagator = function(inst)
	CurrentMakeMediumPropagator(inst)
	if inst.components.propagator then
		inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
	end
end
local MakeLargePropagator = GLOBAL.MakeLargePropagator
GLOBAL.MakeLargePropagator = function(inst)
	MakeLargePropagator(inst)
	if inst.components.propagator then
		inst.components.propagator.propagaterange = inst.components.propagator.propagaterange/2.0
	end
end

--下线掉落身上所有物品(客机或服务器才有效)
if GetModConfigData("levae_drop_everything") then
	AddComponentPostInit("playerspawner", function(PlayerSpawner, inst)
		inst:ListenForEvent("ms_playerdespawn", function (inst, player)
			if player and player.components.inventory then
				player.components.inventory:DropEverything(false, false)
			end
		end)
	end)
end



