--
-- 玩家地图分组显示
-- author: RedPig
-- Date: 2017/1/06
--

-- 从其他mod中获取地图的小图标
GLOBAL.PKC_POSITIONS_MAP_ICONS = {}
for _, atlases in ipairs(ModManager:GetPostInitData("MinimapAtlases")) do
    for _, path in ipairs(atlases) do
        local file = io.open(resolvefilepath(path), "r")
        if file then
            local xml = file:read("*a")
            if xml then
                for element in string.gmatch(xml, "<Element[^>]*name=\"([^\"]*)\"") do
                    if element then
                        local elementName = string.match(element, "^(.*)[.]")
                        if elementName then
                            GLOBAL.PKC_POSITIONS_MAP_ICONS[elementName] = element
                        end
                    end
                end
            end
            file:close()
        end
    end
end
for _, prefab in pairs(DST_CHARACTERLIST) do
    GLOBAL.PKC_POSITIONS_MAP_ICONS[prefab] = prefab .. ".png"
end

--为世界添加位置组件（用于保存所有玩家位置）
AddPrefabPostInit("forest_network", function(inst) inst:AddComponent("pkc_globalpositions") end)
AddPrefabPostInit("cave_network", function(inst) inst:AddComponent("pkc_globalpositions") end)

local isDedicated = TheNet:IsDedicated()
local function playerPostInit(TheWorld, player)
    player:ListenForEvent("setowner", function()
        player:AddComponent("pkc_globalposition")
        if isDedicated then
            local function TryLoadingWorldMap()
                if not TheWorld.net.components.pkc_globalpositions.map_loaded
                        or not player.player_classified.MapExplorer:LearnRecordedMap(
                    TheWorld.worldmapexplorer.MapExplorer:RecordMap()) then
                    player:DoTaskInTime(0, TryLoadingWorldMap)
                end
            end
            TryLoadingWorldMap()
        elseif player ~= GLOBAL.AllPlayers[1] then --The host always has the master map
            local function TryLoadingHostMap()
                if not player.player_classified.MapExplorer:LearnRecordedMap(
                    GLOBAL.AllPlayers[1].player_classified.MapExplorer:RecordMap()) then
                    player:DoTaskInTime(0, TryLoadingHostMap)
                end
            end
            TryLoadingHostMap()
        end
    end)
end

AddPrefabPostInit("world", function(inst)
    inst:DoTaskInTime(30, function()
        if isDedicated then
            --给世界添加一个地图探索器用于记录已探索地图
            inst.worldmapexplorer = SpawnPrefab("pkc_worldmapexplorer")
        end
    end)
    inst:ListenForEvent("ms_playerspawn", playerPostInit)
end)

if isDedicated then
    MapRevealer = require("components/maprevealer")
    MapRevealer_ctor = MapRevealer._ctor
    MapRevealer._ctor = function(self, inst)
        self.counter = 1
        MapRevealer_ctor(self, inst)
    end
    MapRevealer_RevealMapToPlayer = MapRevealer.RevealMapToPlayer
    MapRevealer.RevealMapToPlayer = function(self, player)
        MapRevealer_RevealMapToPlayer(self, player)
        self.counter = self.counter + 1
        if self.counter > #GLOBAL.AllPlayers then
            GLOBAL.TheWorld.worldmapexplorer.MapExplorer:RevealArea(self.inst.Transform:GetWorldPosition())
            self.counter = 1
        end
    end
end

