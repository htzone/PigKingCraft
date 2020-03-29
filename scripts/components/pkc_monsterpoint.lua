--
-- 怪物据点组件
-- Author: RedPig
-- Date: 2017/02/27
--

local function spawnBearger()
    TheWorld:DoTaskInTime(1, function()
        local portal = pkc_findFirstPrefabByTag("portal")
        if portal then
            SpawnPrefab("lightning")
            pkc_announce(PKC_SPEECH.MONSTER_POINT.SPEECH1)
            pkc_shakeAllCameras()
            pkc_trySpawn(portal, "bearger", 15, 35, 30, "lightning")
        end
    end)
end

local function produceBeagerBoss(world, day, random)
    if TheWorld.state.cycles >= day then
        if not world.pkc_pointbearger then
            world.pkc_pointbearger = true
            if math.random() < random then
                spawnBearger()
            end
        end
    end
end

local function updateWorld(world)
    --安置巨熊BOSS
    produceBeagerBoss(world, 10, 1)
end

local PKC_Monster_Point = Class(function(self, inst)
    self.inst = inst
    self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
end)

function PKC_Monster_Point:OnSave()
    return
    {
        pkc_pointbearger = self.inst.pkc_pointbearger,
    }
end

function PKC_Monster_Point:OnLoad(data)
    if data ~= nil then
        if data.pkc_pointbearger ~= nil then
            self.inst.pkc_pointbearger = data.pkc_pointbearger
        end
    end
end

return PKC_Monster_Point

