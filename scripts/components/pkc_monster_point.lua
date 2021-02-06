--
-- 怪物据点组件
-- Author: RedPig
-- Date: 2017/02/27
--

--local function spawnBearger()
--    TheWorld:DoTaskInTime(1, function()
--        local portal = pkc_findFirstPrefabByTag("portal")
--        if portal then
--            SpawnPrefab("lightning")
--            pkc_announce(PKC_SPEECH.MONSTER_POINT.SPEECH1)
--            pkc_shakeAllCameras()
--            pkc_trySpawnNear(portal, "bearger", 15, 35, 30, "lightning")
--        end
--    end)
--end
--
--local function produceBeagerBoss(world, day, random)
--    if TheWorld.state.cycles >= day then
--        if not world.pkc_pointbearger then
--            world.pkc_pointbearger = true
--            if math.random() < random then
--                spawnBearger()
--            end
--        end
--    end
--end

--GROUND.DIR

PREFAB_TO_TILE_TABLE = {
    pkc_rockyking = GROUND.ROCKY, --岩石
    pkc_mermking = GROUND.MARSH, --沼泽
    pigman = GROUND.DECIDUOUS, --桦树林
    pkc_bunnymanking = GROUND.SAVANNA, --稀树草原
    pigguard = GROUND.GRASS, --草原
    pkc_leifking = GROUND.FOREST, --森林
}

local HOSTILE_POINT_MIN_DIST = 40
local PKC_BOSS_MIN_DIST = 60
--return
--{
--    GROUND.FOREST = {point1, point2, ...},
--    GROUND.ROCKY = {point1, point2, ...},
--}
local function getTileToNodeData()
    local tile2NodePoints = {}
    for _, node in ipairs(TheWorld.topology.nodes) do
        if TheWorld.Map:IsPassableAtPoint(node.x, 0, node.y) then
            if node.tags ~= nil
                    and (table.contains(node.tags, "not_mainland")
                    or table.contains(node.tags, "lunacyarea")) then
            else
                local nodePoint = Point(node.x, 0, node.y)
                local tile = TheWorld.Map:GetTileAtPoint(nodePoint.x, 0, nodePoint.z)
                if tile2NodePoints[tile] then
                    table.insert(tile2NodePoints[tile], nodePoint)
                else
                    tile2NodePoints[tile] = {nodePoint}
                end
            end
        end
    end
    return tile2NodePoints
end

local function getAllNodePoints(tile2NodePoints)
    local allPoints = {}
    for i, nodePoints in pairs(tile2NodePoints) do
        for _, point in ipairs(nodePoints) do
            table.insert(allPoints, point)
        end
    end
    return allPoints
end

--根据地皮类型来放置Prefab
local function trySpawn(prefabName, points, tryMaxTimes, clear, checkFn)
    local b = nil
    local tryTimes = 0
    while tryTimes < tryMaxTimes do
        local point = points[math.random(#points)]
        local isAboveGround = TheWorld.Map:IsAboveGroundAtPoint(point.x, point.y, point.z, false)
        if isAboveGround and not checkFn or checkFn(point) then
            b = SpawnPrefab(prefabName)
            if b and b:IsValid() and b.Transform then
                b.Transform:SetPosition(point:Get())
                if clear then
                    clearNear(b, 2)
                end
            end
            break
        end
        tryTimes = tryTimes + 1
    end
    return b
end

--安置据点
local function spawnPrefabByPoints(prefabName, points, num, tryMaxTimes, clear, perAction, checkFn)
    if points == nil or next(points) == nil then
        return nil
    end
    local mobs = {}
    num = num or 1
    tryMaxTimes = tryMaxTimes or 20
    clear = clear ~= nil and clear or true
    for i = 1, num do
        local mob = trySpawn(prefabName, points, tryMaxTimes, clear, checkFn)
        if mob then
            if perAction then
                perAction(mob)
            end
            table.insert(mobs, mob)
        end
    end
    print(string.format("pkc %s points size: %d", prefabName, #mobs))
    if next(mobs) ~= nil then
        return table.remove(mobs)
    else
        return nil
    end
end

local function canSpawnPigGuardTorch(pt)
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, HOSTILE_POINT_MIN_DIST)
    if ents and next(ents) ~= nil then
        for _, v in ipairs(ents) do
            if v and (v:HasTag("pkc_hostile") or v:HasTag("king") or v:HasTag("dragonfly") or v:HasTag("player")) then
                return false
            end
        end
    end
    return true
end

local function mobAction(mob)
    mob:AddComponent("pkc_spawner")
    mob.components.pkc_spawner:startSpawn("pkc_pigtorch")
end

--获取怪物数量
local function getMobNum(tags)
    local king = pkc_findFirstPrefabByTag("king")
    if king and king.Transform then
        local x, y, z = king.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 800, tags)
        if ents and next(ents) ~= nil then
            return #ents
        end
    end
    return 0
end

--安置猪人守卫据点
local function spawnPigGuardPoints(tile2NodePoints)
    local mobNum = getMobNum({ "pigtorch", "pkc_hostile" })
    print("pkc find pigguard num:"..tostring(mobNum))
    if mobNum < PIG_GUARD_MAX_POINT_NUM and tile2NodePoints and next(tile2NodePoints) ~= nil then
        local allMainLandPoints = getAllNodePoints(tile2NodePoints)
        spawnPrefabByPoints("pkc_pigtorch", allMainLandPoints, PIG_GUARD_PER_POINT_NUM,
                20, true, mobAction, canSpawnPigGuardTorch)
    end
end

local function teleportPlayerTo(inst, mob)
    inst:DoTaskInTime(5, function()
        local boss = pkc_findFirstPrefabByTag("pkc_hostile_boss")
        pkc_teleportAllPlayerToInst(boss)
    end)
end

local bossNameTable = {
    --"deerclops",
    "bearger",
}

--安置大门boss
local function spawnBossAtPortal(world)
    world:DoTaskInTime(2, function()
        local portal = pkc_findFirstPrefabByTag("multiplayer_portal")
        if portal then
            local pt = portal:GetPosition()
            local offset = Vector3(-3, 0, -3)
            local bossName = bossNameTable[math.random(#bossNameTable)]
            local mob = pkc_spawnPrefab(bossName, pt + offset, "lightning")
            if mob then
                pkc_announce(string.format(PKC_SPEECH.MONSTER_POINT.SPEECH2,
                        BOSS_NAME[bossName] and BOSS_NAME[bossName].NAME or "Unknown"), 15)
                print(string.format("pkc spawn %s success.", bossName))
            end
        end
    end)
end

local function canSpawnPKCBoss(pt)
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, PKC_BOSS_MIN_DIST, {"_combat"})
    if ents and next(ents) ~= nil then
        for _, v in ipairs(ents) do
            if v and (v:HasTag("pkc_hostile") or v:HasTag("king") or v:HasTag("player")) then
                return false
            end
        end
    end
    return true
end

local function spawnPKCBossByPrefabName(bossPrefabName, tile2NodePoints)
    local hasBoss = pkc_findFirstPrefabByTag(bossPrefabName)
    if not hasBoss then
        local tile = PREFAB_TO_TILE_TABLE[bossPrefabName]
        if tile and tile2NodePoints[tile] then
            local points = tile2NodePoints[tile]
            local boss = spawnPrefabByPoints(bossPrefabName, points, 1,
                    20, true, nil, canSpawnPKCBoss)
            return boss
        end
    end
    return nil
end

local function spawnPKCBoss(tile2NodePoints)
    --树精长老
    local leifking = spawnPKCBossByPrefabName("pkc_leifking", tile2NodePoints)

    --兔人国王
    local bunnymanking = spawnPKCBossByPrefabName("pkc_bunnymanking", tile2NodePoints)
    if bunnymanking then
        bunnymanking:AddComponent("pkc_spawner")
        bunnymanking.components.pkc_spawner:startSpawn("bunnyman", 3, 4, false, function(mobs)
            for _, v in ipairs(mobs) do
                if v then
                    v:AddComponent("pkc_hostile")
                    v.components.pkc_hostile:SetLeader(bunnymanking)
                    v.components.pkc_hostile:SetMaxHealth(300)
                    v.components.pkc_hostile:SetLoot({ "thulecite_pieces", "thulecite_pieces", "carrot" })
                    --睡不睡觉
                    if v.components.sleeper then
                        v.components.sleeper:SetSleepTest(function(inst) return false  end)
                        v.components.sleeper:SetWakeTest(function(inst) return true  end)
                    end
                end
            end
        end)
    end

    --鱼人国王
    local mermking = spawnPKCBossByPrefabName("pkc_mermking", tile2NodePoints)
    if mermking then
        mermking:AddComponent("pkc_spawner")
        mermking.components.pkc_spawner:startSpawn("mermguard", 3, 4, false, function(mobs)
            for _, v in ipairs(mobs) do
                if v then
                    v:AddComponent("pkc_hostile")
                    v.components.pkc_hostile:SetLeader(mermking)
                    v.components.pkc_hostile:SetMaxHealth(500)
                    v.components.pkc_hostile:SetLoot({ "thulecite_pieces", "thulecite_pieces", "pondfish", "froglegs"})
                    --睡不睡觉
                    if v.components.sleeper then
                        v.components.sleeper:SetSleepTest(function(inst) return false  end)
                        v.components.sleeper:SetWakeTest(function(inst) return true  end)
                    end
                end
            end
        end)
    end

    --石虾国王
    local rockyking = spawnPKCBossByPrefabName("pkc_rockyking", tile2NodePoints)
    if rockyking then
        rockyking:AddComponent("pkc_spawner")
        rockyking.components.pkc_spawner:startSpawn("pkc_rocky", 3, 4, false, function(mobs)
            for _, v in ipairs(mobs) do
                if v then
                    v:AddComponent("pkc_hostile")
                    v.components.pkc_hostile:SetLeader(rockyking)
                    v.components.pkc_hostile:SetMaxHealth(1000)
                    v.components.pkc_hostile:SetLoot({ "thulecite_pieces", "thulecite_pieces", "thulecite_pieces", "rocks", "rocks", "rocks"})
                    if v.components.sleeper then
                        v.components.sleeper:SetSleepTest(function(inst) return false  end)
                        v.components.sleeper:SetWakeTest(function(inst) return true  end)
                    end
                end
            end
        end)
    end
end

local function updateWorld(world)
    if not TheWorld.ismastersim then
        return
    end
    local showDay = TheWorld.state.cycles + 2
    if showDay ~= 0 and showDay % 5 == 0 then
        world.needPointPigGuard = true
    end

    --安置大门boss
    if PKC_PORTAL_SPAWN_BOSS and not world.needPointPortalBoss and showDay == 12 then
        spawnBossAtPortal(world)
        world.needPointPortalBoss = true
    end

    --安置怪物boss
    if not world.needPointPKCBoss and showDay >= 2 then
        local tile2NodePoints = getTileToNodeData()
        world:DoTaskInTime(.1, function()
            spawnPKCBoss(tile2NodePoints)
        end)
        world.needPointPKCBoss = true
    end

    if showDay >=2 then
        teleportPlayerTo(world)
    end

    --安置怪物据点
    if world.needPointPigGuard then
        world:DoTaskInTime(.1, function()
            if world.pointFirstTrigger then
                pkc_announce(PKC_SPEECH.MONSTER_POINT.SPEECH3)
            end
            if not world.pointFirstTrigger then --首次触发运行
                pkc_announce(PKC_SPEECH.MONSTER_POINT.SPEECH1)
                world.pointFirstTrigger = true
            end
            local tile2NodePoints = getTileToNodeData()
            spawnPKCBoss(tile2NodePoints)
            spawnPigGuardPoints(tile2NodePoints)
        end)
        world.needPointPigGuard = false
    end
end

local PKC_Monster_Point = Class(function(self, inst)
    self.inst = inst
    self.inst.pointFirstTrigger = false
    self.inst.needPointPigGuard = false
    self.inst.needPointPortalBoss= false
    self.inst.needPointPKCBoss= false
    self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
end)

function PKC_Monster_Point:OnSave()
    return
    {
        needPointPigGuard = self.inst.needPointPigGuard,
        pointFirstTrigger = self.inst.pointFirstTrigger,
        needPointPortalBoss = self.inst.needPointPortalBoss,
        needPointPKCBoss = self.inst.needPointPKCBoss,
    }
end

function PKC_Monster_Point:OnLoad(data)
    if data ~= nil then
        if data.needPointPigGuard ~= nil then
            self.inst.needPointPigGuard = data.needPointPigGuard
        end
        if data.pointFirstTrigger ~= nil then
            self.inst.pointFirstTrigger = data.pointFirstTrigger
        end
        if data.needPointPortalBoss ~= nil then
            self.inst.needPointPortalBoss = data.needPointPortalBoss
        end
        if data.needPointPKCBoss ~= nil then
            self.inst.needPointPKCBoss = data.needPointPKCBoss
        end
    end
end

return PKC_Monster_Point

