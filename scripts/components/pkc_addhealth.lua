--@name pkc_hashealth
--@description 让prefab具有生命且可被杀死组件
--@auther redpig
--@date 2016-11-02

local PKC_ADD_HEALTH = Class(function(self, inst)
	self.inst = inst 
	if not self.inst.components.health then
		self.inst:AddComponent("health")
	end
	if not self.inst.components.combat then
		self.inst:AddComponent("combat")
	end
	self.inst.components.combat.hiteffectsymbol = "body"
end)

--设置最大生命值
function PKC_ADD_HEALTH:setMaxHealth(maxHealth)
	if maxHealth > 0 then
		self.inst.components.health:SetMaxHealth(maxHealth)
	end
end

--设置被攻击的回调函数
function PKC_ADD_HEALTH:setOnAttackedFn(attacked_fn)
	self.inst:ListenForEvent("attacked", attacked_fn)
end

--设置血量改变的回调函数
function PKC_ADD_HEALTH:setOnHealthDelta(healthdelta_fn)
	self.inst:ListenForEvent("healthdelta", healthdelta_fn)
end

--设置掉落
function PKC_ADD_HEALTH:setDropLoot(loot_table)
	if next(loot_table) ~= nil then
		if not self.inst.components.lootdropper then
			self.inst:AddComponent("lootdropper")
		end
		self.inst.components.lootdropper:SetLoot(loot_table)
		self.inst:ListenForEvent("death", function(inst)
			inst.components.lootdropper:DropLoot()
		end)
	end
end

--设置死亡回调函数
function PKC_ADD_HEALTH:setDeathFn(death_fn)
	self.inst:ListenForEvent("death", death_fn)
end

function PKC_ADD_HEALTH:OnSave()
	return
	{	
	}
end

function PKC_ADD_HEALTH:OnLoad(data)
	if data ~= nil then
	end
end

return PKC_ADD_HEALTH