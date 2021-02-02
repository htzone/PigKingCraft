--
-- 玩家地图分组显示
-- Author: RedPig
-- Date: 2020/03/20
--

local function onPlayerSpawn(TheWorld, player)
    player:ListenForEvent("setowner", function()
        -- 添加玩家位置组件
        player:AddComponent("pkc_globalposition")
    end)
end

-- 为世界添加位置组件（用于保存所有玩家位置）
AddPrefabPostInit("forest_network", function(inst) inst:AddComponent("pkc_globalpositions") end)
AddPrefabPostInit("cave_network", function(inst) inst:AddComponent("pkc_globalpositions") end)
-- 为玩家添加位置组件（在玩家部署的时候）
AddPrefabPostInit("world", function(inst)
    inst:ListenForEvent("ms_playerspawn", onPlayerSpawn)
end)

---- 暂时废弃，有bug，会把敌对的玩家头像共享出来
---- 同组玩家探索区域共享
MapRevealer = require("components/maprevealer")
MapRevealer.RevealMapToPlayer = function(self, player)
    if player and player.player_classified
            and player.components.pkc_group and self.inst.components.pkc_group
            and player.components.pkc_group:getChooseGroup() == self.inst.components.pkc_group:getChooseGroup() then
        player.player_classified.MapExplorer:RevealArea(self.inst.Transform:GetWorldPosition())
    end
end
---------------------------

local function isSameGroup(curUserid, userid)
    return GLOBAL.PKC_PLAYER_INFOS[curUserid] and GLOBAL.PKC_PLAYER_INFOS[userid]
            and GLOBAL.PKC_PLAYER_INFOS[curUserid].GROUP_ID == GLOBAL.PKC_PLAYER_INFOS[userid].GROUP_ID
end

local function getPlayerPrefab(userid)
    return PKC_PLAYER_INFOS[userid] and PKC_PLAYER_INFOS[userid].PLAYER_PREFAB or ""
end

local function getPlayerName(userid)
    return PKC_PLAYER_INFOS[userid] and PKC_PLAYER_INFOS[userid].PLAYER_NAME or ""
end

local function getPlayerColor(userid)
    if PKC_PLAYER_INFOS[userid] then
        return PKC_PLAYER_INFOS[userid].PLAYER_COLOR or {1, 1, 1, 1}
    end
    return {1, 1, 1, 1}
end

local function getPlayerGroupColor(userid)
    local color = {1, 1, 1, 1}
    if PKC_PLAYER_INFOS[userid] then
        color[1], color[2], color[3] = HexToPercentColor(PKC_PLAYER_INFOS[userid].GROUP_COLOR)
        return color[1] and color or {1, 1, 1, 1}
    end
    return color
end

local function scaleMapIcon(self, zoom)
    --print("zoom:"..tostring(zoom))
    for _, v in pairs(self.mapIcons) do
        if v and v.shown then
            local scale = ((20 - (zoom or 0)) / 20) * 0.4 + 0.5
            v:Scale(scale)
        end
    end
end

local playerMapIcon = require("widgets/pkc_player_mapicon")
local function showMapIcon(self, userid, x, y, z)
    local iconPos = Vector3(self:WorldPosToMapScreenPos(x, y, z))
    if not self.mapIcons[userid] then
        self.mapIcons[userid] = playerMapIcon()
    end
    self.mapIcons[userid]:SetIcon(getPlayerPrefab(userid), getPlayerGroupColor(userid))
    self.mapIcons[userid]:SetName(getPlayerName(userid), getPlayerColor(userid))
    self.mapIcons[userid]:SetPosition(iconPos:Get())
    self.mapIcons[userid]:ShowIcon()
    local zoom = self.minimap:GetZoom()
    scaleMapIcon(self, zoom)
end

AddClassPostConstruct("widgets/mapwidget", function(MapWidget)
    MapWidget.offset = GLOBAL.Vector3(0, 0, 0)
    --MapWidget.nametext = require("widgets/pkc_maphoverer")()
    MapWidget.mapIcons = {}

    function MapWidget:OnUpdate(dt)
        if not self.shown then
            return
        end

        --- copy start
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
        --- copy end

        --local p = self:GetWorldMousePosition()
        --local mindistsq, gpc = math.huge, nil
        --同组队友显示
        if GLOBAL.TheWorld.net then
            for _, v in pairs(GLOBAL.TheWorld.net.components.pkc_globalpositions.positions) do
                if v then
                    local userid = v.userid:value()
                    local x, y, z = v.Transform:GetWorldPosition()
                    if isSameGroup(ThePlayer and ThePlayer.userid or nil, userid) then
                        showMapIcon(self, userid, x, y, z)
                    end
                    --local dq = GLOBAL.distsq(p.x, p.z, x, z)
                    --if dq < mindistsq then
                    --    mindistsq = dq
                    --    gpc = v
                    --end
                end
            end
        end

        --if gpc and isSameGroup(ThePlayer and ThePlayer.userid or nil, gpc.userid:value())
        --        and math.sqrt(mindistsq) < self.minimap:GetZoom() * 10 then
        --    if self.nametext:GetString() ~= gpc.name then
        --        self.nametext:SetString(gpc.name)
        --        self.nametext:SetColour(gpc.playercolour)
        --    end
        --else
        --    self.nametext:SetString("")
        --end
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
        scaleMapIcon(self, zoom1)
        OldOnZoomIn(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown then
            self.offset = self.offset * zoom1 / zoom2
        end
    end

    local OldOnZoomOut = MapWidget.OnZoomOut
    function MapWidget:OnZoomOut(...)
        local zoom1 = self.minimap:GetZoom()
        scaleMapIcon(self, zoom1)
        OldOnZoomOut(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown and zoom1 < 20 then
            self.offset = self.offset * zoom1 / zoom2
        end
    end

    -- 世界位置转地图位置
    function MapWidget:WorldPosToMapScreenPos(x, y, z)
        --local px, _, pz = ThePlayer and ThePlayer:GetPosition():Get() or 0, 0, 0
        local px, _, pz = ThePlayer:GetPosition():Get()
        local dx = x - px
        local dy = z - pz
        local md = math.sqrt(dx * dx + dy * dy) * 4.5 / self.minimap:GetZoom()
        local angle = TheCamera:GetHeadingTarget() * math.pi / 180
        local wa = math.atan2(dx, dy) + angle
        local screenwidth, screenheight = TheSim:GetScreenSize()
        local cx = screenwidth * .5 + self.offset.x * 4.5
        local cy = screenheight * .5 + self.offset.y * 4.5
        local mx = cx - md * math.cos(wa) * -1
        local my = cy + md * math.sin(wa) * -1
        return mx, my, 0
    end

    -- 地图位置转世界位置
    function MapWidget:MapScreenPosToWorldPos(x, y)
        local screenwidth, screenheight = TheSim:GetScreenSize()
        local cx = screenwidth * .5 + self.offset.x * 4.5
        local cy = screenheight * .5 + self.offset.y * 4.5
        local ox = x - cx
        local oy = y - cy
        local angle = TheCamera:GetHeadingTarget() * math.pi / 180
        local wd = math.sqrt(ox * ox + oy * oy) * self.minimap:GetZoom() / 4.5
        local wa = math.atan2(ox, oy) - angle
        local px, _, pz = ThePlayer:GetPosition():Get()
        --local px, _, pz = ThePlayer and ThePlayer:GetPosition():Get() or 0, 0, 0
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
        local px, _, pz = GLOBAL.ThePlayer and GLOBAL.ThePlayer:GetPosition():Get() or 0, 0, 0
        --local px, _, pz = GLOBAL.ThePlayer:GetPosition():Get()
        local wx = px - wd * math.cos(wa)
        local wz = pz + wd * math.sin(wa)
        return GLOBAL.Vector3(wx, 0, wz)
    end
end)

AddClassPostConstruct("screens/mapscreen", function(MapScreen)
    local OldOnBecomeActive = MapScreen.OnBecomeActive
    function MapScreen:OnBecomeActive(...)
        OldOnBecomeActive(self, ...)
    end

    local OldOnBecomeInactive = MapScreen.OnBecomeInactive
    --function MapScreen:OnBecomeInactive(...)
    --    --当地图关闭时让图标消失
    --    self.minimap.nametext:SetString("")
    --    if self.minimap.mapIcons and next(self.minimap.mapIcons) ~= nil then
    --        for _, v in pairs(self.minimap.mapIcons) do
    --            if v then
    --                v:HideIcon()
    --            end
    --        end
    --    end
    --    OldOnBecomeInactive(self, ...)
    --end

    local OldDestroy = MapScreen.OnDestroy
    function MapScreen:OnDestroy(...)
        --当地图关闭时让图标消失
        --self.minimap.nametext:SetString("")
        if self.minimap.mapIcons and next(self.minimap.mapIcons) ~= nil then
            for _, v in pairs(self.minimap.mapIcons) do
                if v then
                    v:HideIcon()
                end
            end
        end
        OldDestroy(self, ...)
    end
end)

--local oldmaxrange = GLOBAL.TUNING.MAX_INDICATOR_RANGE
--local oldmaxrangesq = (oldmaxrange*1.5)*(oldmaxrange*1.5)
--local PlayerTargetIndicator = require("components/playertargetindicator")
--local function ShouldRemove(x, z, v)
--    local vx, vy, vz = v.Transform:GetWorldPosition()
--    return GLOBAL.distsq(x, z, vx, vz) > oldmaxrangesq
--end
--
--local OldOnUpdate = PlayerTargetIndicator.OnUpdate
--function PlayerTargetIndicator:OnUpdate(...)
--    local oldUpdate = OldOnUpdate(self, ...)
--    local x, _, z = self.inst.Transform:GetWorldPosition()
--    for i,v in ipairs(self.offScreenPlayers) do
--        while ShouldRemove(x, z, v) do
--            self.inst.HUD:RemoveTargetIndicator(v)
--            GLOBAL.table.remove(self.offScreenPlayers, i)
--            v = self.offScreenPlayers[i]
--            if v == nil then break end
--        end
--    end
--    return oldUpdate
--end
--

--屏幕边缘附近玩家的指示图标颜色修改为队伍颜色
local function StartIndicator(target, self)
    self.inst.startindicatortask = nil
    self.inst.OnRemoveEntity = nil
    if target.userid and PKC_PLAYER_INFOS[target.userid] then
        local color = {1, 1, 1, 1}
        color[1], color[2], color[3] = HexToPercentColor(PKC_PLAYER_INFOS[target.userid].GROUP_COLOR)
        self.colour = color[1] and color or {1, 1, 1, 1}
    else
        self.colour = target.playercolour or PORTAL_TEXT_COLOUR
    end
    self:StartUpdating()
    self:OnUpdate()
    self:Show()
end

local function CancelIndicator(inst)
    inst.startindicatortask:Cancel()
    inst.startindicatortask = nil
    inst.OnRemoveEntity = nil
end

local TargetIndicator = require("widgets/targetindicator")
local OldTargetIndicator_ctor = TargetIndicator._ctor
TargetIndicator._ctor = function(self, owner, target, ...)
    OldTargetIndicator_ctor(self, owner, target, ...)
    if self.inst and target then
        self.inst.startindicatortask:Cancel()
        self.inst.startindicatortask = target:DoTaskInTime(0, StartIndicator, self)
        self.inst.OnRemoveEntity = CancelIndicator
    end
end
