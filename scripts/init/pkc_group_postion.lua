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
                        or not player.player_classified.MapExplorer:LearnRecordedMap(TheWorld.worldmapexplorer.MapExplorer:RecordMap()) then
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

MapRevealer = require("components/maprevealer")
MapRevealer_ctor = MapRevealer._ctor
MapRevealer._ctor = function(self, inst)
    self.counter = 1
    MapRevealer_ctor(self, inst)
end
MapRevealer.RevealMapToPlayer = function(self, player)
    if player.player_classified ~= nil
            and player.components.pkc_group and self.inst.components.pkc_group
            and player.components.pkc_group:getChooseGroup() == self.inst.components.pkc_group:getChooseGroup() then
        player.player_classified.MapExplorer:RevealArea(self.inst.Transform:GetWorldPosition())
    end
    if isDedicated then
        self.counter = self.counter + 1
        if self.counter > #GLOBAL.AllPlayers then
            GLOBAL.TheWorld.worldmapexplorer.MapExplorer:RevealArea(self.inst.Transform:GetWorldPosition())
            self.counter = 1
        end
    end
end

local function isSameGroup(curUserid, userid)
    return GLOBAL.PKC_PLAYER_INFOS[curUserid].GROUP_ID == GLOBAL.PKC_PLAYER_INFOS[userid].GROUP_ID
end

local function hideIcon(gpc)
    if gpc and gpc.icon and gpc.icon2 then
        gpc.icon.MiniMapEntity:SetEnabled(false)
        gpc.icon2.MiniMapEntity:SetEnabled(false)
    end
end

local function showIcon(gpc)
    if gpc and gpc.icon and gpc.icon2 then
        gpc.icon.MiniMapEntity:SetEnabled(true)
        gpc.icon2.MiniMapEntity:SetEnabled(true)
    end
end


AddClassPostConstruct("widgets/mapwidget", function(MapWidget)
    MapWidget.offset = GLOBAL.Vector3(0, 0, 0)
    MapWidget.nametext = require("widgets/pkc_maphoverer")()
    function MapWidget:OnUpdate(dt)
        if not self.shown then
            return
        end

        -- copy start
        if GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_PRIMARY) then
            local pos = GLOBAL.TheInput:GetScreenPosition()
            if self.lastpos then
                local scale = 0.25
                local dx = scale * (pos.x - self.lastpos.x)
                local dy = scale * (pos.y - self.lastpos.y)
                self:Offset(dx, dy) --#rezecib changed this so we can capture offsets
            end

            self.lastpos = pos
        else
            self.lastpos = nil
        end
        -- copy end

        local p = self:GetWorldMousePosition()
        local mindistsq, gpc = math.huge, nil
        for _, v in pairs(GLOBAL.TheWorld.net.components.pkc_globalpositions.positions) do
            if not isSameGroup(ThePlayer and ThePlayer.userid or nil, v.userid:value()) then
                hideIcon(v)
            else
                showIcon(v)
            end
            local x, y, z = v.Transform:GetWorldPosition()
            local dq = GLOBAL.distsq(p.x, p.z, x, z)
            if dq < mindistsq then
                mindistsq = dq
                gpc = v
            end
        end
--        if isSameGroup(GLOBAL.ThePlayer and GLOBAL.ThePlayer.userid or nil, gpc.userid) and math.sqrt(mindistsq) < self.minimap:GetZoom() * 10 then
        if isSameGroup(ThePlayer and ThePlayer.userid or nil, gpc.userid:value()) and math.sqrt(mindistsq) < self.minimap:GetZoom() * 10 then
            if self.nametext:GetString() ~= gpc.name then
                self.nametext:SetString(gpc.name)
                self.nametext:SetColour(gpc.playercolour)
            end
        else
            self.nametext:SetString("")
        end
    end

    local OldOffset = MapWidget.Offset
    function MapWidget:Offset(dx, dy, ...)
        self.offset.x = self.offset.x + dx
        self.offset.y = self.offset.y + dy
        OldOffset(self, dx, dy, ...)
    end

    local OldOnShow = MapWidget.OnShow
    function MapWidget:OnShow(...)
        self.offset.x = 0
        self.offset.y = 0
        OldOnShow(self, ...)
    end

    local OldOnZoomIn = MapWidget.OnZoomIn
    function MapWidget:OnZoomIn(...)
        local zoom1 = self.minimap:GetZoom()
        OldOnZoomIn(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown then
            self.offset = self.offset * zoom1 / zoom2
        end
    end

    local OldOnZoomOut = MapWidget.OnZoomOut
    function MapWidget:OnZoomOut(...)
        local zoom1 = self.minimap:GetZoom()
        OldOnZoomOut(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown and zoom1 < 20 then
            self.offset = self.offset * zoom1 / zoom2
        end
    end

    function MapWidget:GetWorldMousePosition()
        local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
        local cx = screenwidth * .5 + self.offset.x * 4.5
        local cy = screenheight * .5 + self.offset.y * 4.5
        local mx, my = GLOBAL.TheInput:GetScreenPosition():Get()
        if GLOBAL.TheInput:ControllerAttached() then
            mx, my = screenwidth * .5, screenheight * .5
        end
        local ox = mx - cx
        local oy = my - cy
        local angle = GLOBAL.TheCamera:GetHeadingTarget() * math.pi / 180
        local wd = math.sqrt(ox * ox + oy * oy) * self.minimap:GetZoom() / 4.5
        local wa = math.atan2(ox, oy) - angle
        local px, _, pz = GLOBAL.ThePlayer:GetPosition():Get()
        local wx = px - wd * math.cos(wa)
        local wz = pz + wd * math.sin(wa)
        return GLOBAL.Vector3(wx, 0, wz)
    end
end)

AddClassPostConstruct("screens/mapscreen", function(MapScreen)
    local OldOnBecomeInactive = MapScreen.OnBecomeInactive
    function MapScreen:OnBecomeInactive(...)
        --当地图关闭时名字消失
        self.minimap.nametext:SetString("")
        OldOnBecomeInactive(self, ...)
    end
end)

