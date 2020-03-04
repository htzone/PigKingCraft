--
-- 玩家地图分组显示
-- author: RedPig
-- Date: 2017/1/06
--
GLOBAL._GLOBALPOSITIONS_MAP_ICONS = {}

-- 从其他mod中获取地图的小图标
for i,atlases in ipairs(GLOBAL.ModManager:GetPostInitData("MinimapAtlases")) do
    for i,path in ipairs(atlases) do
        local file = GLOBAL.io.open(GLOBAL.resolvefilepath(path), "r")
        if file then
            local xml = file:read("*a")
            if xml then
                for element in string.gmatch(xml, "<Element[^>]*name=\"([^\"]*)\"") do
                    if element then
                        local elementName = string.match(element, "^(.*)[.]")
                        if elementName then
                            GLOBAL._GLOBALPOSITIONS_MAP_ICONS[elementName] = element
                        end
                    end
                end
            end
            file:close()
        end
    end
end

for _,prefab in pairs(GLOBAL.DST_CHARACTERLIST) do
    GLOBAL._GLOBALPOSITIONS_MAP_ICONS[prefab] = prefab .. ".png"
end


local is_dedicated = TheNet:IsDedicated()

local function PlayerPostInit(TheWorld, player)
    player:ListenForEvent("setowner", function()
        player:AddComponent("globalposition")
        if SHAREMINIMAPPROGRESS then
            if is_dedicated then
                local function TryLoadingWorldMap()
                    if not TheWorld.net.components.globalpositions.map_loaded or not player.player_classified.MapExplorer:LearnRecordedMap(TheWorld.worldmapexplorer.MapExplorer:RecordMap()) then
                        player:DoTaskInTime(0, TryLoadingWorldMap)
                    end
                end
                TryLoadingWorldMap()
            elseif player ~= GLOBAL.AllPlayers[1] then --The host always has the master map
                local function TryLoadingHostMap()
                    if not player.player_classified.MapExplorer:LearnRecordedMap(GLOBAL.AllPlayers[1].player_classified.MapExplorer:RecordMap()) then
                        player:DoTaskInTime(0, TryLoadingHostMap)
                    end
                end
                TryLoadingHostMap()
            end
        end
    end)
end

AddPrefabPostInit("world", function(inst)
    if is_dedicated then
        inst.worldmapexplorer = GLOBAL.SpawnPrefab("worldmapexplorer")
    end
    inst:ListenForEvent("ms_playerspawn", PlayerPostInit)
end)

