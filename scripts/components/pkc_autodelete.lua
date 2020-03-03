--@name pkc_autodelete
--@description 自动清理组件
--@author redpig
--@date 2016-11-26

local PKC_AUTO_DELETE = Class(function(self, inst)
	self.inst = inst
	self.perishtime = nil
	self.updatetask = nil
	self.perishremainingtime = nil
end)

----更新函数，功能的主体部分
local function Update(inst, dt)

    if inst.components.pkc_autodelete then
		local owner = nil 
			----判断物品的拥有者或占有方
		owner = inst.components.inventoryitem 
		and inst.components.inventoryitem.owner or nil
			
		if not owner and inst.components.occupier then
			owner = inst.components.occupier:GetOwner()
		end
			--拥有者或占有者为空的时候,开始动用定时删除
			if not owner then
			
				----对距离删除时间的计算
				if inst.components.pkc_autodelete.perishremainingtime then
						
						inst.components.pkc_autodelete.perishremainingtime = inst.components.pkc_autodelete.perishremainingtime - 1
						if inst.components.pkc_autodelete.perishremainingtime <= 0 then
							inst.components.pkc_autodelete:Perish()
						end
					
				end
			----拥有者或占有方存在的时候，剩余离删除时间清零，即重置为设定的perishtime
			else 
				inst.components.pkc_autodelete.perishremainingtime = inst.components.pkc_autodelete.perishtime
			end	
    end
end

----物体移除后
function PKC_AUTO_DELETE:OnRemoveEntity()
	self:StopPerishing()
end

----执行删除
function PKC_AUTO_DELETE:Perish()
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
	if self.inst and not self.inst:HasTag("burnt") then
		self.inst:Remove()
	end
end

----设置删除时间
function PKC_AUTO_DELETE:SetPerishTime(time)
	self.perishtime = time
	self.perishremainingtime = time
    if self.updatetask ~= nil then
        self:StartPerishing()
    end
end

----开始计算
function PKC_AUTO_DELETE:StartPerishing()
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
    self.updatetask = self.inst:DoPeriodicTask(1, Update)
end
----停止计算
function PKC_AUTO_DELETE:StopPerishing()
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
end

----存储与载入
function PKC_AUTO_DELETE:OnSave()
    return
    {
        paused = self.updatetask == nil or nil,
        time = self.perishremainingtime,
    }
end
function PKC_AUTO_DELETE:OnLoad(data)
    if data ~= nil and data.time ~= nil then
        self.perishremainingtime = data.time
        if not data.paused then
            self:StartPerishing()
        end
    end
end

return PKC_AUTO_DELETE