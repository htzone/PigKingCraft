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

PREFAB_TO_TILE_TABLE = {
    rocky = GROUND.ROCKY, --岩石
    merm = GROUND.MARSH, --沼泽
    pigman = GROUND.DECIDUOUS, --桦树林
    bunnyman = GROUND.SAVANNA, --稀树草原
    pigguard = GROUND.GRASS, --草原
    leif_sparse = GROUND.FOREST, --森林
    pkc_pigtorch = GROUND.DECIDUOUS, --桦树林
    pkc_pigtorch = GROUND.SAVANNA, --稀树草原
    pkc_pigtorch = GROUND.GRASS, --草原
    pkc_pigtorch = GROUND.ROCKY, --岩石
    pkc_pigtorch = GROUND.FOREST, --森林
}

local HOSTILE_POINT_MIN_DIST = 40

local function canSpawn(pt)
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, HOSTILE_POINT_MIN_DIST, { "_combat"})
    if ents and next(ents) ~= nil then
        for _, v in ipairs(ents) do
            if v and (v:HasTag("pkc_hostile") or v:HasTag("king") or v:HasTag("spiderden") or v:HasTag("dragonfly")) then
                return false
            end
        end
    end
    return true
end

local function updateWorld(world)
    if world.needPoint and TheWorld.state.cycles >= 0 then
        world:DoTaskInTime(1, function()
            pkc_announce("世界异变开始了...")
            for i = 1, 100 do
                local mob = pkc_spawnPrefabByTileTable("pkc_pigtorch", PREFAB_TO_TILE_TABLE, 20, canSpawn, true)
                if mob then
                    mob:AddComponent("pkc_spawner")
                    mob.components.pkc_spawner:startSpawn("pkc_pigtorch")
                end
            end
            --world:DoTaskInTime(2, function()
            --    pkc_teleportAllPlayerToInst(mob)
            --end)
        end)
        world.needPoint = false
    end
end

local PKC_Monster_Point = Class(function(self, inst)
    self.inst = inst
    self.inst.needPoint = true
    self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
end)

function PKC_Monster_Point:OnSave()
    return
    {
    }
end

function PKC_Monster_Point:OnLoad(data)
    if data ~= nil then
    end
end

return PKC_Monster_Point

