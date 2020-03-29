--
-- 保存所有位置信息的组件（只在服务端执行）
-- Author: RedPig
-- Date: 2020/3/4
--

local GlobalPositions = Class(function(self, inst)
    self.inst = inst
    self.positions = {}
    if not TheWorld.ismastersim
            or not TheNet:IsDedicated() then return end
    self.map_loaded = false
end)

function GlobalPositions:OnSave()
    if not TheNet:IsDedicated() then return end
    local data = {}
    if TheWorld.worldmapexplorer and TheWorld.worldmapexplorer.MapExplorer then
        data.worldmap = TheWorld.worldmapexplorer.MapExplorer:RecordMap()
    end
    return data
end

function GlobalPositions:OnLoad(data)
    if TheNet:IsDedicated() and data and data.worldmap then
        if TheWorld.worldmapexplorer.MapExplorer then
            local function TryLoadingWorldMap()
                if TheWorld.worldmapexplorer.MapExplorer:LearnRecordedMap(data.worldmap) then
                    self.map_loaded = true
                else
                    self.inst:DoTaskInTime(0, TryLoadingWorldMap)
                end
            end
            TryLoadingWorldMap()
        end
    end
end

function GlobalPositions:AddServerEntity(inst)
    local classified = SpawnPrefab("pkc_globalposition_classified")
    self.positions[inst.GUID] = classified
    classified.parentprefab:set(inst.prefab or "")
    classified.parententity:set(inst)
    classified.userid:set(inst.userid or "nil")
    local player
    for _,v in pairs(TheNet:GetClientTable()) do
        if v.userid == classified.userid:value() then
            player = v
        end
    end
    classified.playercolour = player and player.colour or classified.playercolour
    classified.name = player and (inst.name .. "\n(" .. player.name ..")") or (player and player.name or inst.name)
    if player then
        classified.parentname:set(player.name)
    end
    return classified
end

function GlobalPositions:AddClientEntity(inst)
    self.positions[inst.GUID] = inst
    local player
    for k,v in pairs(TheNet:GetClientTable()) do
        if v.userid == inst.userid:value() then
            player = v
        end
    end
    local prefabname = inst.parentprefab:value()
    inst.playercolour = player and player.colour or inst.playercolour
    inst.name = player and player.name or STRINGS.NAMES[prefabname:upper()] or inst.parentprefab:value()
    inst.OnRemoveEntity = function()
        self.positions[inst.GUID] = nil
    end
end

function GlobalPositions:RemoveServerEntity(inst)
    self.positions[inst.GUID]:Remove()
    self.positions[inst.GUID] = nil
end

return GlobalPositions