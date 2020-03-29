--
-- 记录基地位置的信息
-- Author: 大猪猪
-- Date: 2016/10/31
--

local PKC_BASEINFO = Class(function(self, inst)
	self.inst = inst
	self.GROUP_BIGPIG_POS_x=0
	self.GROUP_BIGPIG_POS_z=0
	self.GROUP_REDPIG_POS_x=0
	self.GROUP_REDPIG_POS_z=0
	self.GROUP_LONGPIG_POS_x=0
	self.GROUP_LONGPIG_POS_z=0
	self.GROUP_CUIPIG_POS_x=0
	self.GROUP_CUIPIG_POS_z=0
end)	

--保存基地的坐标
--@大猪猪 10-31
--@param name 阵营的猪猪名字 比如BIG是大猪猪,RED是红猪猪
--@param pos 传入的坐标
function PKC_BASEINFO:SetBasePos(name, pos)
	self["GROUP_"..name.."PIG_POS_x"] = pos.x
	self["GROUP_"..name.."PIG_POS_z"] = pos.z
	print(pos.x, pos.z)
end

function PKC_BASEINFO:OnSave()
	return
	{
		GROUP_BIGPIG_POS_x = self.GROUP_BIGPIG_POS_x,
		GROUP_BIGPIG_POS_z = self.GROUP_BIGPIG_POS_z,
		
		GROUP_REDPIG_POS_x = self.GROUP_REDPIG_POS_x,
		GROUP_REDPIG_POS_z = self.GROUP_REDPIG_POS_z,
		
		GROUP_LONGPIG_POS_x = self.GROUP_LONGPIG_POS_x,
		GROUP_LONGPIG_POS_z = self.GROUP_LONGPIG_POS_z,

		GROUP_CUIPIG_POS_x = self.GROUP_CUIPIG_POS_x,
		GROUP_CUIPIG_POS_z = self.GROUP_CUIPIG_POS_z,
	}
end

function PKC_BASEINFO:OnLoad(data)
	if data ~= nil then
		if data.GROUP_BIGPIG_POS_x ~= nil then
			self.GROUP_BIGPIG_POS_x = data.GROUP_BIGPIG_POS_x
		end
		if data.GROUP_BIGPIG_POS_z ~= nil then
			self.GROUP_BIGPIG_POS_z = data.GROUP_BIGPIG_POS_z
		end
		
		if data.GROUP_REDPIG_POS_x ~= nil then
			self.GROUP_REDPIG_POS_x = data.GROUP_REDPIG_POS_x
		end
		if data.GROUP_REDPIG_POS_z ~= nil then
			self.GROUP_REDPIG_POS_z = data.GROUP_REDPIG_POS_z
		end
		
		if data.GROUP_LONGPIG_POS_x ~= nil then
			self.GROUP_LONGPIG_POS_x = data.GROUP_LONGPIG_POS_x
		end
		if data.GROUP_LONGPIG_POS_z ~= nil then
			self.GROUP_LONGPIG_POS_z = data.GROUP_LONGPIG_POS_z
		end
		
		if data.GROUP_CUIPIG_POS_x ~= nil then
			self.GROUP_CUIPIG_POS_x = data.GROUP_CUIPIG_POS_x
		end
		if data.GROUP_CUIPIG_POS_z ~= nil then
			self.GROUP_CUIPIG_POS_z = data.GROUP_CUIPIG_POS_z
		end
	end
end

return PKC_BASEINFO