-- 位置组件
-- Author: RedPig
-- Date: 2020/3/4

local function AddMapRevealer(inst)
    if not inst.components.maprevealer then
        inst:AddComponent("maprevealer")
    end
    inst.components.maprevealer.revealperiod = 0.5
    inst.components.maprevealer:Stop()
    inst.components.maprevealer:Start()
end

local function AddGlobalIcon(inst, classified)
    if not (PKC_POSITIONS_MAP_ICONS[inst.prefab] or inst.MiniMapEntity) then return end
    classified.icon = SpawnPrefab("pkc_globalmapicon_noproxy")
    classified.icon.MiniMapEntity:SetPriority(10)
    classified.icon.MiniMapEntity:SetRestriction("player")
    classified.icon.MiniMapEntity:SetDrawOverFogOfWar(true)
    classified.icon2 = SpawnPrefab("globalmapicon")
    classified.icon2.MiniMapEntity:SetPriority(10)
    classified.icon2.MiniMapEntity:SetRestriction("player")
    classified.icon2.MiniMapEntity:SetDrawOverFogOfWar(true)
    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetEnabled(false)
        classified.icon.MiniMapEntity:CopyIcon(inst.MiniMapEntity)
        classified.icon2.MiniMapEntity:CopyIcon(inst.MiniMapEntity)
    else
        classified.icon.MiniMapEntity:SetIcon(PKC_POSITIONS_MAP_ICONS[inst.prefab])
        classified.icon2.MiniMapEntity:SetIcon(PKC_POSITIONS_MAP_ICONS[inst.prefab])
    end
    classified:AddChild(classified.icon)
    classified:AddChild(classified.icon2)
end

local GlobalPosition = Class(function(self, inst)
    self.inst = inst
    self.globalpositions = nil
    self.classified = nil
    self.inittask = nil

    local isplayer = inst:HasTag("player")
    if isplayer then
        AddMapRevealer(inst)
        self.respawnedfromghostfn = function()
            self:SetMapSharing(true)
        end
        self.becameghostfn = function()
            self:SetMapSharing(false)
        end
        self.inst:ListenForEvent("ms_respawnedfromghost", self.respawnedfromghostfn)
        self.inst:ListenForEvent("ms_becameghost", self.becameghostfn)
    end
    self.globalpositions = TheWorld.net.components.pkc_globalpositions
    self.classified = self.globalpositions:AddServerEntity(self.inst)
    if isplayer then
        AddGlobalIcon(inst, self.classified)
    end

    self.inittask = self.inst:DoTaskInTime(0, function()
        self.inittask = nil
--        self.globalpositions = TheWorld.net.components.pkc_globalpositions
--        self.classified = self.globalpositions:AddServerEntity(self.inst)
--        if isplayer then
--            AddGlobalIcon(inst, self.classified)
--        end
        self.inst:StartUpdatingComponent(self)
    end)
end,
nil,
{
})

function GlobalPosition:OnUpdate(dt)
    local pos = self.inst:GetPosition()
    if self._x ~= pos.x or self._z ~= pos.z then
        self._x = pos.x
        self._z = pos.z
        self.classified.Transform:SetPosition(pos:Get())
    end
end

function GlobalPosition:OnRemoveEntity()
    if self.inst.MiniMapEntity then
        self.inst.MiniMapEntity:SetEnabled(true)
    end

    if self.inst.components.maprevealer then
        self:SetMapSharing(false)
    end

    if self.respawnedfromghostfn then
        self.inst:RemoveEventCallback("ms_respawnedfromghost", self.respawnedfromghostfn)
    end
    if self.becameghostfn then
        self.inst:RemoveEventCallback("ms_becameghost", self.becameghostfn)
    end

    if self.inittask then self.inittask:Cancel() end

    if self.globalpositions then
        self.globalpositions:RemoveServerEntity(self.inst)
    end
end

GlobalPosition.OnRemoveFromEntity = GlobalPosition.OnRemoveEntity

function GlobalPosition:SetMapSharing(enabled)
    if enabled then
        self.inst.components.maprevealer:Start()
    else
        self.inst.components.maprevealer:Stop()
    end
end

return GlobalPosition