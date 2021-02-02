--
-- 生物变大组件
-- Author: 大猪猪, Redpig
-- Date: 2016/12/20
--

local PKC_TOBIG = Class(function(self, inst)
	self.inst = inst 
	self.scale = 1
end)

function PKC_TOBIG:growTo(scale)
	self.scale = scale + 1
	local currentscale = self.inst.Transform:GetScale()
	local canbebig = (currentscale < 1.25)
	if canbebig then
		self.inst.Transform:SetScale(currentscale * self.scale, currentscale * self.scale, currentscale * self.scale)
		if self.inst.components.health then
			if self.inst.prefab == "spider" then
				self.inst.components.health.maxhealth = math.min(self.inst.components.health.maxhealth * self.scale * 1.2,180)
				if self.inst.components.combat then --蜘蛛的伤害
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.5)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.5)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.5)
				end
			elseif self.inst.prefab == "spider_warrior" then
				self.inst.components.health.maxhealth = math.min(self.inst.components.health.maxhealth * self.scale * 1.2,650)
				if self.inst.components.combat then --蜘蛛战士的伤害
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.5)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.5)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.5)
				end				
			elseif self.inst.prefab == "merm" then
				self.inst.components.health.maxhealth = math.min(self.inst.components.health.maxhealth * self.scale * 1.2,600)			
				if self.inst.components.combat then --鱼人
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.2)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.2)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.2)
				end			
			elseif self.inst.prefab == "mermguard" then
				self.inst.components.health.maxhealth = math.min(self.inst.components.health.maxhealth * self.scale * 1.2,700)			
				if self.inst.components.combat then --鱼人战士伤害
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.2)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.2)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.2)
				end		
			elseif self.inst.prefab == "spider_moon" then
				self.inst.components.health.maxhealth = math.min(self.inst.components.health.maxhealth * self.scale * 1.2,750)			
				if self.inst.components.combat then --月岛蜘蛛的伤害
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.5)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.5)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.5)
				end
			elseif self.inst.prefab == "pkc_pigguard" then
				self.inst.components.health.maxhealth = math.min(self.inst.components.health.maxhealth * self.scale * 1.2, 1000)
				if self.inst.components.combat then
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.5)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.5)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.5)
				end
			else
				self.inst.components.health.maxhealth = self.inst.components.health.maxhealth * self.scale * 1.2
				if self.inst.components.combat then
					self.inst.components.combat.defaultdamage = self.inst.components.combat.defaultdamage * (0.8 + self.scale * 0.5)
					self.inst.components.combat.attackrange = self.inst.components.combat.attackrange * (0.5 + self.scale * 0.5)
					self.inst.components.combat.hitrange = self.inst.components.combat.hitrange * (0.5 + self.scale * 0.5)
				end
			end
			self.inst.components.health:DoDelta(self.inst.components.health.maxhealth * self.scale)
		end

		self.inst:ListenForEvent("death", function()
			if self.inst then
				local randomval = math.random()
				if randomval < (self.scale - 1) then
					self.inst.components.lootdropper:DropLoot(Vector3(self.inst.Transform:GetWorldPosition()))
				end
			end
		end)
		self.pkc_tobig = true
	end
end

function PKC_TOBIG:OnSave()
	return
	{
		pkc_tobig = self.pkc_tobig,
		scale = self.scale,
	}
end

function PKC_TOBIG:OnLoad(data)
	if data ~= nil then
		if data.pkc_tobig ~= nil and data.scale ~= nil then
			self.scale = data.scale
			self.pkc_tobig = data.pkc_tobig
			if self.pkc_tobig then
				self.inst:DoTaskInTime(.1, function()
					if self.scale - 1 >= 0 then
						self:growTo(self.scale - 1)
					end
				end)
			end
		end
	end
end

return PKC_TOBIG