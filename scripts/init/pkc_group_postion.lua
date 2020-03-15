--
-- 玩家地图分组显示
-- author: RedPig
-- Date: 2017/1/06
--

-- 从其他mod中获取地图的小图标
GLOBAL._PKC_POSITIONS_MAP_ICONS = {}
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
                            GLOBAL._PKC_POSITIONS_MAP_ICONS[elementName] = element
                        end
                    end
                end
            end
            file:close()
        end
    end
end
for _, prefab in pairs(DST_CHARACTERLIST) do
    GLOBAL._PKC_POSITIONS_MAP_ICONS[prefab] = prefab .. ".png"
end

--为世界添加位置组件（保存所有玩家位置）
AddPrefabPostInit("forest_network", function(inst) inst:AddComponent("pkc_globalpositions") end)
AddPrefabPostInit("cave_network", function(inst) inst:AddComponent("pkc_globalpositions") end)
local isDedicated = TheNet:IsDedicated()
AddPrefabPostInit("world", function(inst)
    inst:DoTaskInTime(30, function()
        if isDedicated then
            inst.worldmapexplorer = SpawnPrefab("pkc_worldmapexplorer")
            local isExist = inst.worldmapexplorer ~= nil
            print("test:"..isExist)
        end
    end)

--    inst:ListenForEvent("ms_playerspawn", PlayerPostInit)
end)

