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
    return GLOBAL.PKC_PLAYER_INFOS[curUserid] and GLOBAL.PKC_PLAYER_INFOS[userid]
            and GLOBAL.PKC_PLAYER_INFOS[curUserid].GROUP_ID == GLOBAL.PKC_PLAYER_INFOS[userid].GROUP_ID
end

local function mapPosToWidgetPos(mappos)
    return Vector3(
        mappos.x * RESOLUTION_X/2,
        mappos.y * RESOLUTION_Y/2,
        0
    )
end

local DEFAULT_PLAYER_COLOUR = { 1, 1, 1, 1 }
local function showMapIcon(self, userid, x, y, z)
    local iconPos = Vector3(self:WorldPosToMapScreenPos(x, y, z))
    if not self.mapIcons[userid] then
        self.mapIcons[userid] = require("widgets/pkc_mapicon")()
    end
    self.mapIcons[userid]:SetString("Test")
    self.mapIcons[userid]:SetColour(DEFAULT_PLAYER_COLOUR)
    self.mapIcons[userid].text:SetPosition(iconPos:Get())
end


AddClassPostConstruct("widgets/mapwidget", function(MapWidget)
    MapWidget.offset = GLOBAL.Vector3(0, 0, 0)
    MapWidget.nametext = require("widgets/pkc_maphoverer")()
    MapWidget.mapIcons = {}

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
            if v then
                local userid = v.userid:value()
                local x, y, z = v.Transform:GetWorldPosition()
                if isSameGroup(ThePlayer and ThePlayer.userid or nil, userid) then
                    showMapIcon(self, userid, x, y, z)
                end
                local dq = GLOBAL.distsq(p.x, p.z, x, z)
                if dq < mindistsq then
                    mindistsq = dq
                    gpc = v
                end
            end
        end

        if gpc and isSameGroup(ThePlayer and ThePlayer.userid or nil, gpc.userid:value())
                and math.sqrt(mindistsq) < self.minimap:GetZoom() * 10 then
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

    -- 世界位置转地图位置
    function MapWidget:WorldPosToMapScreenPos(x, y, z)
        local px, _, pz = GLOBAL.ThePlayer:GetPosition():Get()
        local dx = x - px
        local dy = z - pz
        local md = math.sqrt(dx * dx + dy * dy) * 4.5 / self.minimap:GetZoom()
        local angle = GLOBAL.TheCamera:GetHeadingTarget() * math.pi / 180
        local wa = math.atan2(dx, dy) + angle
        local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
        local cx = screenwidth * .5 + self.offset.x * 4.5
        local cy = screenheight * .5 + self.offset.y * 4.5
        local mx = cx - md * math.cos(wa) * -1
        local my = cy + md * math.sin(wa) * -1
        return mx, my, 0
    end

    -- 地图位置转世界位置
    function MapWidget:MapScreenPosToWorldPos(x, y)
        local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
        local cx = screenwidth * .5 + self.offset.x * 4.5
        local cy = screenheight * .5 + self.offset.y * 4.5
        local ox = x - cx
        local oy = y - cy
        local angle = GLOBAL.TheCamera:GetHeadingTarget() * math.pi / 180
        local wd = math.sqrt(ox * ox + oy * oy) * self.minimap:GetZoom() / 4.5
        local wa = math.atan2(ox, oy) - angle
        local px, _, pz = GLOBAL.ThePlayer:GetPosition():Get()
        local wx = px - wd * math.cos(wa)
        local wz = pz + wd * math.sin(wa)
        return wx, 0, wz
    end

    -- 获取地图上鼠标所在的世界位置
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

--AddModRPCHandler("pkc_group_position", "iconshow", function(player)
--    for _, gpc in pairs(GLOBAL.TheWorld.net.components.pkc_globalpositions.positions) do
--        if not isSameGroup(player and player.userid or nil, gpc.userid:value()) then
--            hideIcon(gpc)
--        else
--            showIcon(gpc)
--        end
--    end
--end)

AddClassPostConstruct("screens/mapscreen", function(MapScreen)
    local OldOnBecomeActive = MapScreen.OnBecomeActive
    function MapScreen:OnBecomeActive(...)
--        for _, gpc in pairs(GLOBAL.TheWorld.net.components.pkc_globalpositions.positions) do
--            if not isSameGroup(ThePlayer and ThePlayer.userid or nil, gpc.userid:value()) then
--                hideIcon(gpc)
--            else
--                showIcon(gpc)
--            end
--        end
--        local Namespace="pkc_group_position"
--        local Action="iconshow"
--        SendModRPCToServer(MOD_RPC[Namespace][Action])
        OldOnBecomeActive(self, ...)
    end

    local OldOnBecomeInactive = MapScreen.OnBecomeInactive
    function MapScreen:OnBecomeInactive(...)
        --当地图关闭时名字消失
        self.minimap.nametext:SetString("")
        for _, v in pairs(self.minimap.mapIcons) do
            if v then
                v:SetString("")
            end
        end
        OldOnBecomeInactive(self, ...)
    end
end)

