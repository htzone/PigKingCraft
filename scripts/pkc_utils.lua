--
-- 常用工具类
-- Author: RedPig
-- Date: 2016/10/20
--

----[[常用的工具函数]]----

--get请求
function pkc_httpget(url, onResultFn)
    TheSim:QueryServer(url, onResultFn, "GET")
end

--post请求
function pkc_httppost(url, onResultFn, params)
    TheSim:QueryServer(url, onResultFn, "POST", params)
end

--震动
function pkc_shakeAllCameras(mode, duration, speed, scale, source, maxDist)
    --ShakeAllCameras(mode, duration, speed, scale, source, maxDist)
    if mode == nil then
        ShakeAllCameras(CAMERASHAKE.FULL, .4, .06, 1.3, nil, 50)
    else
        ShakeAllCameras(mode, duration, speed, scale, source, maxDist)
    end
end

--安置特效
function pkc_spawnFx(fxName, inst, scale)
    local fx = SpawnPrefab(fxName)
    local fxScale = 1
    if scale ~= nil then
        fxScale = scale
    end
    if fx and fx.Transform and inst and inst.Transform then
        fx.Transform:SetScale(fxScale, fxScale, fxScale)
        fx.Transform:SetPosition(Vector3(inst.Transform:GetWorldPosition()):Get())
    end
end

--数字转字符串
function pkc_numToString(num)
    if num ~= nil then
        return "" .. num
    end
    return ""
end

--让我玩家说话
function pkc_talk(player, content)
    player:DoTaskInTime(0, function()
        if player and player.components.talker then
            player.components.talker:Say(content)
        end
    end)
end

--传送物体
function pkc_teleportToPoint(inst, pos)
    if inst and pos then
        if inst.Physics ~= nil then
            inst.Physics:Teleport(pos:Get())
        else
            inst.Transform:SetPosition(pos:Get())
        end
    end
end

--将所有玩家传送到指定点
function pkc_teleportAllPlayerToInst(inst)
    for _,player in pairs(AllPlayers) do
        if player then
            pkc_teleport(player, inst, 2)
        end
    end
end

--传送物体
function pkc_teleport(inst, destination, offset)
    local mOffset = offset or 0
    if inst and destination and destination.Transform then
        local x, _, z = destination.Transform:GetWorldPosition()
        if inst.Physics ~= nil then
            inst.Physics:Teleport(x + mOffset, 0, z)
        else
            inst.Transform:SetPosition(x + mOffset, 0, z)
        end
        inst:DoTaskInTime(.2, function()
            if inst then
                pkc_spawnFx("lucy_ground_transform_fx", inst, 1.4)
            end
        end)
    end
end

--计算table大小
function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

--去掉首尾的空格
function trim(str)
    return str and (str:gsub("^%s*(.-)%s*$", "%1")) or str
end

--根据groupId来获取对应的name
--@param groupId 阵营Id
function getNamebyGroupId(groupId)
    for _, v in pairs(PKC_GROUP_INFOS) do
        if groupId == v.id then
            return v.name
        end
    end
    return ""
end

--根据groupId来获取对应的color
function getGroupColorByGroupId(groupId)
    for _, v in pairs(PKC_GROUP_INFOS) do
        if groupId == v.id then
            return v.head_color
        end
    end
    return "#B0B0B0"
end

--根据groupId来获取对应的shortname
function getGroupShortNameByGroupId(groupId)
    for _, v in pairs(PKC_GROUP_INFOS) do
        if groupId == v.id then
            return v.short_name
        end
    end
    return "Unknown"
end

function getGroupIdByUserId(userId)
    return PKC_PLAYER_INFOS[userId] and PKC_PLAYER_INFOS[userId].GROUP_ID or 0
end

function getGroupPlayerNumByGroupId(groupId)
    local groupPlayerNum = 0
    for _, player in pairs(AllPlayers) do
        if player and player.components.pkc_group
                and player.components.pkc_group:getChooseGroup() == groupId then
            groupPlayerNum = groupPlayerNum + 1
        end
    end
    return groupPlayerNum
end

--检查table里是否包含指定key
--@param checkTable 检查table
--@param key 指定key
function containsKey(checkTable, key)
    for k, _ in pairs(checkTable) do
        if k == key then
            return true
        end
    end
    return false
end

--检查table是否包含某值
function containsValue(checkTable, value)
    for _, v in pairs(checkTable) do
        if v == value then
            return true
        end
    end
    return false
end

--系统公告
--@param content 公告内容
function pkc_announce(content, category)
    if category ~= nil then
        TheNet:Announce(content, nil, nil, category)
    else
        TheNet:Announce(content)
    end
end

--函数注入
--@param comp 组件名
--@param fn_name 组件函数名
--@param fn 要注入的函数实现
function pkc_inject(comp, fn_name, fn)
    comp["Old" .. fn_name] = comp[fn_name]
    comp[fn_name] = function(self, ...)
        return fn(self, ...)
    end
end

--函数注入
--@param comp 组件名
--@param fn_name 组件函数名
--@param fn 要注入的函数实现
--function pkc_inject(comp, fn_name, fn)
--	local old = comp[fn_name]
--	comp[fn_name] = function(self,...)
--		old(self,...)
--		fn(self,...)
--	end
--end

--属性注入
function pkc_propinject(comp, prop_name, prop)
    comp["Old" .. prop_name] = comp[prop_name]
    comp[prop_name] = prop
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
                fx.Transform:SetScale(currentscale * 1, currentscale * 1, currentscale * 1)
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
    local result_offset = FindValidPositionByFan(theta, radius, 36, function(offset)
        --这里其实就找是一个没有被其他物体占用的位置
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
function pkc_trySpawnNear(target, prefab_name, min_dist, max_dist, max_trying_times, fx_name)
    if min_dist == nil or max_dist == nil then
        min_dist = 15
        max_dist = 35
    end
    if max_trying_times == nil then
        max_trying_times = 40
    end
    if max_trying_times < 0 then
        --递归 尝试 max_trying_times 次，如果找不到有效地点则返回空
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
                b = pkc_trySpawnNear(target, prefab_name, min_dist, max_dist, max_trying_times - 1)
            end
        end
    end
    return b
end

--根据tag来找到最近的prefab
--@param tag Tag名
function pkc_findFirstPrefabByTag(tag)
    return TheSim:FindFirstEntityWithTag(tag)
end

--根据权值大小随机获取物品
--@param weight_table 传入的table 如：--设置掉落权值 local loot = {preab1 = 1, prefab2 = 2,}
--@return 返回随机获取后的物品字符串
function pkc_getRandomStrByWeight(weight_table)
    local function weighted_total(weight_table)
        local total = 0
        for choice, weight in pairs(weight_table) do
            total = total + weight
        end
        return total
    end
    local threshold = math.random() * weighted_total(weight_table)
    local last_choice
    for choice, weight in pairs(weight_table) do
        threshold = threshold - weight
        if threshold <= 0 then
            return choice
        end
        last_choice = choice
    end
    return last_choice
end

--定义网络变量
--@param inst 要添加网络变量的对象
--@param nettab 要添加网络变量的列表,例如{ GROUP_BIGPIG_POS_x = {"net_float", 0}, }
function pkc_setNetvar(inst, nettab)
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
    for k, v in pairs(nettab) do
        if type(v) == "table" then
            inst[k] = t[v[1]](inst.GUID, k, k .. "dirty")
            inst[k]:set(v[2])
        end
    end
end

--生成物体
--@param inst 生成新物体的参照物
--@param prefname 如果是string则是单一的新物体,如果是table，则为按照权重的单一物体,例如{bat=1,butterfly=2}那么蝙蝠概率1/3，蝴蝶概率2/3
--@param offset	新物体相对于参照物inst的位置比如{0,3,0}就是在上方3单位高度(看具体模式mode决定)
--@param mode 新物体相对于参照物的模式,如果mode为1,新物体则是inst的child,如果是sring类型,则这个是symbol,如果为空则是普通的位置关系
function pkc_spawnat(inst, prefname, offset, mode, fn)
    if not inst then
        return
    end
    local tar
    if type(prefname) == "string" then
        tar = SpawnPrefab(prefname)
    elseif type(prefname) == "table" then
        --获取权重
        local weight = 0
        for k, v in pairs(prefname) do
            weight = weight + v
        end
        --选取物体
        local t = 0
        local ran = math.random()
        for k, v in pairs(prefname) do
            t = t + v
            if ran <= t / weight then
                tar = SpawnPrefab(k)
                break
            end
        end
    else
        return
    end
    if not tar then
        return
    end

    --物体的parent位置关系
    if mode == 1 then
        tar.entity:SetParent(inst.entity)
        if type(offset) == "table" then
            tar.Transform:SetPosition(offset[1], offset[2], offset[3])
        else
            tar.Transform:SetPosition(0, 0, 0)
        end
        --Follow Symbol的关系
    elseif type(mode) == "string" then

        tar.entity:SetParent(inst.entity)
        tar.entity:AddFollower()
        if type(offset) == "table" then
            tar.Follower:FollowSymbol(inst.GUID, mode, offset[1], offset[2], offset[3])
        else
            tar.Follower:FollowSymbol(inst.GUID, mode, 0, 0, 0)
        end
        --普通生成模式
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = x, y, z
        if type(offset) == "table" then
            x1, y1, z1 = x + offset[1], y + offset[2], z + offset[3]
        end
        tar.Transform:SetPosition(x1, y1, z1)
    end

    if fn then
        fn(tar, inst)
    end
end

--清理猪王附近的东西
function clearNear(inst, radius, fn)
    if inst and inst.Transform then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, radius)
        for _, obj in ipairs(ents) do
            if obj and obj ~= inst and obj:IsValid()
                    and not obj:HasTag("burnt") and not obj:HasTag("FX")
                    and not obj:HasTag("structure") and not obj:HasTag("multiplayer_portal")
                    and not obj.components.inventoryitem
                    and (fn == nil or fn(obj)) then
                obj:Remove()
            end
        end
    end
end

--环绕安置
--@RedPig 12-15
--@param target 作为中心点的物体
--@param prefab_name prefab名称
--@param radius	半径
--@param mode 需要安置的数量
function pkc_roundSpawnForWriteable(target, prefab_name, radius, num, text, clear)
    local mobs = {}
    if num == 0 or num == nil then
        return mobs
    end
    local pos = Vector3(target.Transform:GetWorldPosition())
    local attempt_angle = (2 * PI) / num
    local tmp_angles = {}
    for i = 0, num - 1 do
        local a = i * attempt_angle
        if a > PI then
            a = a - (2 * PI)
        end
        table.insert(tmp_angles, a)
    end
    local theta = math.random() * 2 * PI
    for _, attempt in ipairs(tmp_angles) do
        local check_angle = theta + attempt
        if check_angle > 2 * PI then
            check_angle = check_angle - 2 * PI
        end
        local offset = Vector3(radius * math.cos(check_angle), 0, -radius * math.sin(check_angle))
        local tmp_pos = pos + offset
        local valid_tile = TheWorld.Map:IsAboveGroundAtPoint(tmp_pos.x, tmp_pos.y, tmp_pos.z, false)
        if valid_tile then
            local mob = SpawnPrefab(prefab_name)
            if mob then
                if mob.components.writeable then
                    mob.components.writeable:SetText(text)
                end
                mob.Transform:SetPosition(tmp_pos:Get())
                if clear then
                    clearNear(mob, 2, function(item) return item and not item:HasTag("pkc_defences") end)
                end
                if mob:HasTag("pkc_defences") then
                    mob.ownername = "RedPig"
                    mob.ownerid = "Fuckyou"
                end
                table.insert(mobs, mob)
            end
        end
    end
    return mobs
end

--环绕安置多个不同物品
--@RedPig 12-15
--@param target 作为中心点的物体
--@param prefab_name prefab名称
--@param radius	半径
--@param mode 需要安置的数量
function pkc_roundSpawnForMulti(target, prefabNames, radius, text, clear)
    if prefabNames and next(prefabNames) ~= nil then
        local pos = Vector3(target.Transform:GetWorldPosition())
        local num = #prefabNames
        local attempt_angle = (2 * PI) / num
        local tmp_angles = {}
        for i = 0, num - 1 do
            local a = i * attempt_angle
            if a > PI then
                a = a - (2 * PI)
            end
            table.insert(tmp_angles, a)
        end
        local theta = math.random() * 2 * PI
        for i, attempt in ipairs(tmp_angles) do
            local check_angle = theta + attempt
            if check_angle > 2 * PI then
                check_angle = check_angle - 2 * PI
            end
            local offset = Vector3(radius * math.cos(check_angle), 0, -radius * math.sin(check_angle))
            local tmp_pos = pos + offset
            local valid_tile = TheWorld.Map:IsAboveGroundAtPoint(tmp_pos.x, tmp_pos.y, tmp_pos.z, false)
            if valid_tile then
                local mob = SpawnPrefab(prefabNames[i])
                if mob then
                    if mob.components.writeable then
                        mob.components.writeable:SetText(text)
                    end
                    mob.Transform:SetPosition(tmp_pos:Get())
                    if clear then
                        clearNear(mob, 2, function(item) return item and not item:HasTag("pkc_defences") end)
                    end
                    if mob:HasTag("pkc_defences") then
                        mob.ownername = "RedPig"
                        mob.ownerid = "Fuckyou"
                    end
                end
            end
        end
    end
end

function pkc_roundSpawn(target, prefab_name, radius, num, clear)
    return pkc_roundSpawnForWriteable(target, prefab_name, radius, num, "", clear)
end

--根据地皮类型来放置Prefab
function pkc_spawnPrefabByTileTable(prefabName, tileTable, tryMaxTimes, checkFn, clear)
    local validTile = tileTable[prefabName]
    if not validTile then
        return nil
    end
    local b = nil
    local size_x, size_y = TheWorld.Map:GetSize()
    local tryTimes = 0
    while tryTimes < tryMaxTimes do
        local pt = Vector3(math.random(-size_x, size_x), 0, math.random(-size_y, size_y))
        local isAboveGround = TheWorld.Map:IsAboveGroundAtPoint(pt.x, pt.y, pt.z, false)
        if isAboveGround then
            local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
            local canSpawn = (tile == validTile)
            if canSpawn and not checkFn or checkFn(pt) then
                b = SpawnPrefab(prefabName)
                if b and b:IsValid() and b.Transform then
                    b.Transform:SetPosition(pt:Get())
                    if clear then
                        clearNear(b, 2)
                    end
                end
                break
            end
        end
        tryTimes = tryTimes + 1
    end
    return b
end

--根据地皮类型来放置Prefab
function pkc_spawnPrefabByTile(prefabName, validTile, tryMaxTimes, checkFn, clear)
    if not validTile then
        return nil
    end
    local b = nil
    local size_x, size_y = TheWorld.Map:GetSize()
    local tryTimes = 0
    while tryTimes < tryMaxTimes do
        local pt = Vector3(math.random(-size_x, size_x), 0, math.random(-size_y, size_y))
        local isAboveGround = TheWorld.Map:IsAboveGroundAtPoint(pt.x, pt.y, pt.z, false)
        if isAboveGround then
            local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
            local canSpawn = (tile == validTile)
            if canSpawn and not checkFn or checkFn(pt) then
                b = SpawnPrefab(prefabName)
                if b and b:IsValid() and b.Transform then
                    b.Transform:SetPosition(pt:Get())
                    if clear then
                        clearNear(b, 2)
                    end
                end
                break
            end
        end
        tryTimes = tryTimes + 1
    end
    return b
end

--判断在一定范围内有没有海
function pkc_isValidRange(center_pos, radius)
    local theta = math.random() * 2 * PI
    local result_offset = FindValidPositionByFan(theta, radius, 36, function(offset)
        local pos = center_pos + offset
        local tile = TheWorld.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
        local isValid = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255
        if isValid then
            return false
        end
        return true
    end)
    if result_offset == nil then
        return true
    end
    return false
end

--判断在一定范围内有没有海
function pkc_isNoOceanRange(center_pos, radius)
    local num = 6
    local attempt_angle = (2 * PI) / num
    local tmp_angles = {}
    for i = 0, num - 1 do
        local a = i * attempt_angle
        if a > PI then
            a = a - (2 * PI)
        end
        table.insert(tmp_angles, a)
    end
    local theta = math.random() * 2 * PI
    local isNearOcean = false
    for i, attempt in ipairs(tmp_angles) do
        local check_angle = theta + attempt
        if check_angle > 2 * PI then
            check_angle = check_angle - 2 * PI
        end
        local offset = Vector3(radius * math.cos(check_angle), 0, -radius * math.sin(check_angle))
        local tmp_pos = center_pos + offset
        local valid_tile = TheWorld.Map:IsAboveGroundAtPoint(tmp_pos.x, tmp_pos.y, tmp_pos.z, false)
        if not valid_tile then
            isNearOcean = true
            break
        end
    end
    if isNearOcean then
        return false
    end
    return true
end

--让所有的玩家说同一句话
function pkc_makeAllPlayersSpeak(speech_str)
    for _, player in pairs(AllPlayers) do
        if player and player.components.talker then
            player.components.talker:Say(speech_str)
        end
    end
end

--根据权值获取物品,需传入一个table
function pkc_weightedChoose(choices)
    local function weighted_total(choices)
        local total = 0
        for _, weight in pairs(choices) do
            total = total + weight
        end
        return total
    end
    local threshold = math.random() * weighted_total(choices)
    local last_choice
    for choice, weight in pairs(choices) do
        threshold = threshold - weight
        if threshold <= 0 then
            return choice
        end
        last_choice = choice
    end
    return last_choice
end

--发送数据到服务端RPC
function sendToServer(key, data)
    local PKC_NAME_SPACE = "pkc_name_space"
    SendModRPCToServer(MOD_RPC[PKC_NAME_SPACE][key], data)
end

--接收数据从客户端RPC_HANDLER
function getFromClient(key, handleFn)
    local PKC_NAME_SPACE = "pkc_name_space"
    AddModRPCHandler(PKC_NAME_SPACE, key, function(player, data)
        handleFn(player, data)
    end)
end

function sendToClient(key, data)

end

function getFromServer(key, handleFn)

end

function table_maxn(t)
    local mn;
    for _, v in pairs(t) do
        if (mn == nil) then
            mn = v
        end
        if mn < v then
            mn = v
        end
    end
    return mn
end

--table深拷贝
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function isNullOrEmpty(str)
    if type(str) == "string" then
        return not str or string.len(str) == 0
    end
    return false
end

function startWith(str, start)
    if type(str) == "string" and type(start) == "string" then
        return start == string.sub(str, 1, start:len())
    end
    return false
end

function getPlayerColorByUserId(userid)
    local clientObjs = GetPlayerClientTable()
    for _, v in pairs(clientObjs) do
        if v and v.userid == userid then
            return v.colour
        end
    end
    return DEFAULT_PLAYER_COLOUR
end

function getPlayerByUserId(userid)
    for _, player in pairs(AllPlayers) do
        if player and player.userid == userid then
            return player
        end
    end
end

function isSameGroup(inst1, inst2)
    return inst1 and inst2
            and inst1.components.pkc_group and inst2.inst.components.pkc_group
            and inst1.components.pkc_group:getChooseGroup() == inst2.inst.components.pkc_group:getChooseGroup()
end

--根据值删除table中的元素
function pkc_removeByValue(list, value, removeAll)
    local deleteNum, i, max = 0, 1, #list
    while i <= max do
        if list[i] == value then
            table.remove(list, i)
            deleteNum = deleteNum + 1
            i = i - 1
            max = max - 1
            if not removeAll then
                break
            end
        end
        i = i + 1
    end
    return deleteNum
end

function pkc_removeByKey(list, key)
    list[key] = nil
end

function pkc_printArray(array)
    local str = ""
    for i = 1, #array do
        if i == 1 then
            str = tostring(array[i])
        else
            str = str.." "..tostring(array[i])
        end
    end
    print(str)
end

--根据id获取各队伍的猪王保护半径
function getPigkingRange(pigkingId)
    local needLevelUpScore = WIN_SCORE / #(PIGKING_LEVEL_CONSTANT)
    local pigkigRange = 20
    if pigkingId ~= nil then
        if pigkingId == GROUP_BIGPIG_ID then
            local currentScore = GROUP_SCORE.GROUP1_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigkigRange = PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
            end
        elseif pigkingId == GROUP_REDPIG_ID then
            local currentScore = GROUP_SCORE.GROUP2_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigkigRange = PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
            end
        elseif pigkingId == GROUP_LONGPIG_ID then
            local currentScore = GROUP_SCORE.GROUP3_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigkigRange = PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
            end
        elseif pigkingId == GROUP_CUIPIG_ID then
            local currentScore = GROUP_SCORE.GROUP4_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigkigRange = PIGKING_LEVEL_CONSTANT[currentLevel].PIGKING_RANGE
            end
        end
    end
    return pigkigRange ~= nil and pigkigRange or 20
end

--获取猪王附近允许建造的猪房数量
function getPigHouseNum(pigkingId)
    local needLevelUpScore = WIN_SCORE / #(PIGKING_LEVEL_CONSTANT)
    local pigHouseNum = PKC_INIT_PIGHOUSE_NUM
    if pigkingId ~= nil then
        if pigkingId == GROUP_BIGPIG_ID then
            local currentScore = GROUP_SCORE.GROUP1_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigHouseNum = PIGKING_LEVEL_CONSTANT[currentLevel].PIGHOUSE_NUM
            end
        elseif pigkingId == GROUP_REDPIG_ID then
            local currentScore = GROUP_SCORE.GROUP2_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigHouseNum = PIGKING_LEVEL_CONSTANT[currentLevel].PIGHOUSE_NUM
            end
        elseif pigkingId == GROUP_LONGPIG_ID then
            local currentScore = GROUP_SCORE.GROUP3_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigHouseNum = PIGKING_LEVEL_CONSTANT[currentLevel].PIGHOUSE_NUM
            end
        elseif pigkingId == GROUP_CUIPIG_ID then
            local currentScore = GROUP_SCORE.GROUP4_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                pigHouseNum = PIGKING_LEVEL_CONSTANT[currentLevel].PIGHOUSE_NUM
            end
        end
    end
    return pigHouseNum ~= nil and pigHouseNum or PKC_INIT_PIGHOUSE_NUM
end

--获取传送木牌的限制数量
function getHomeSignNum(pigkingId)
    local needLevelUpScore = WIN_SCORE / #(PIGKING_LEVEL_CONSTANT)
    local homeSignNum = PKC_INIT_GROUPHOMESIGN_NUM
    if pigkingId ~= nil then
        if pigkingId == GROUP_BIGPIG_ID then
            local currentScore = GROUP_SCORE.GROUP1_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                homeSignNum = PIGKING_LEVEL_CONSTANT[currentLevel].HOMESING_NUM
            end
        elseif pigkingId == GROUP_REDPIG_ID then
            local currentScore = GROUP_SCORE.GROUP2_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                homeSignNum = PIGKING_LEVEL_CONSTANT[currentLevel].HOMESING_NUM
            end
        elseif pigkingId == GROUP_LONGPIG_ID then
            local currentScore = GROUP_SCORE.GROUP3_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                homeSignNum = PIGKING_LEVEL_CONSTANT[currentLevel].HOMESING_NUM
            end
        elseif pigkingId == GROUP_CUIPIG_ID then
            local currentScore = GROUP_SCORE.GROUP4_SCORE
            local currentLevel = math.floor(currentScore / needLevelUpScore) + 1
            if PIGKING_LEVEL_CONSTANT[currentLevel] then
                homeSignNum = PIGKING_LEVEL_CONSTANT[currentLevel].HOMESING_NUM
            end
        end
    end
    return homeSignNum ~= nil and homeSignNum or PKC_INIT_GROUPHOMESIGN_NUM
end