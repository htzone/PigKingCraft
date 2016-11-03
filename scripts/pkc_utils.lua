----[[常用的工具函数]]----

--系统公告
--@param content 公告内容
function pkc_announce(content)
	TheNet:Announce(content)
end

--函数注入
--@param comp 组件名
--@param fn_name 组件函数名
--@param fn 要注入的函数实现
function pkc_inject(comp, fn_name, fn)
	local old = comp[fn_name]
	comp[fn_name] = function(self,...)
		old(self,...)
		fn(self.inst)
	end
end

--强制触发网络变量更新函数
--@param netvar 网络变量名称
--@param val 网络变量的值
function pkc_setDirty(netvar, val)
    netvar:set_local(val)
    netvar:set(val)
end

--放置prefab 
--@param prefab_name 要放置的prefab名称
--@param pos_pt 要放置的位置（可以不写）
--@param fx_name 放置特效（可以不写）
function pkc_spawnPrefab(prefab_name, pos_pt, fx_name)
	local prefab = nil 
	prefab = SpawnPrefab(prefab_name)
	if prefab and pos_pt ~= nil then
		prefab.Transform:SetPosition(pos_pt:Get())
		if fx_name ~= nil then
			local currentscale = prefab.Transform:GetScale()
			local fx = SpawnPrefab(fx_name)
			if fx then
				fx.Transform:SetPosition(pos_pt:Get())
				fx.Transform:SetScale(currentscale*1,currentscale*1,currentscale*1)
			end
		end
	end
	return prefab
end

--获取要放置的位置
--@param target 放置目标
--@param min_dist 离目标最小的距离（可以不写）
--@param max_dist 离目标最大的距离（可以不写）
function pkc_getSpawnPoint(target, min_dist, max_dist)
	if min_dist == nil or max_dist == nil then
		min_dist = 15
		max_dist = 35
	end
	local pt = Vector3(target.Transform:GetWorldPosition())
	local theta = math.random() * 2 * PI
    local radius = math.random(min_dist, max_dist)
	local result_offset = FindValidPositionByFan(theta, radius, 36, function(offset) --这里其实就找是一个没有被其他物体占用的位置
		local pos = pt + offset
		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
		return next(ents) == nil
    end)
	if result_offset ~= nil then
        local pos = pt + result_offset
		return pos
	end
end

--尝试在目标附近放置prefab
--@param target 放置目标
--@param prefab_name 放置在目标周围的prefab名称
--@param min_dist 离目标最小的距离（可以不写）
--@param max_dist 离目标最大的距离（可以不写）
--@param max_trying_times 最大放置尝试次数（可以不写）
--@param fx_name 放置特效（可以不写）
function pkc_trySpawn(target, prefab_name, min_dist, max_dist, max_trying_times, fx_name)
	if min_dist == nil or max_dist == nil then
		min_dist = 15
		max_dist = 35
	end
	if max_trying_times == nil then
		max_trying_times = 40
	end
	if max_trying_times < 0 then --递归 尝试 max_trying_times 次，如果找不到有效地点则返回空
		return nil
	end
	local b = nil
	if target then
		local player_pt = Vector3(target.Transform:GetWorldPosition())
		local pt = pkc_getSpawnPoint(target, min_dist, max_dist)
		if pt ~= nil then
			local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
			local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255 --找到一个有效的位置才放置物体
			if canspawn then
				b = pkc_spawnPrefab(prefab_name, pt, fx_name)
				if b and player_pt then 
					b:FacePoint(player_pt)
				end
				return b
			else
				b = pkc_trySpawn(target, prefab_name, min_dist, max_dist, max_trying_times - 1)
			end
		end
	end
	return b
end

--定义网络变量
--@大猪猪 10-31
--@param inst 要添加网络变量的对象
--@param nettab 要添加网络变量的列表,例如{ GROUP_BIGPIG_POS_x = {"net_float", 0}, }
function pkc_setNetvar(inst,nettab)
	local t = {
		net_shortint = net_shortint,
		net_tinybyte = net_tinybyte,
		net_smallbyte = net_smallbyte,
		net_byte = net_byte,
		net_shortint = net_shortint,
		net_ushortint = net_ushortint,
		net_int = net_int,
		net_uint = net_uint,
		net_float = net_float,
		net_hash = net_hash,
		net_string = net_string,
		net_entity = net_entity,
		net_bytearray = net_bytearray,
		net_smallbytearray = net_smallbytearray,
	}
	for k,v in pairs(nettab) do
		if type(v) == "table" then
			inst[k] = t[v[1]](inst.GUID, k, k.."dirty")
			inst[k]:set(v[2])
		end
	end
end
	












