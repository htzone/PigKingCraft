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
    if not (_PKC_POSITIONS_MAP_ICONS[inst.prefab] or inst.MiniMapEntity) then return end
    classified.icon = SpawnPrefab("globalmapicon_noproxy")
    classified.icon.MiniMapEntity:SetPriority(10)
    classified.icon.MiniMapEntity:SetRestriction("player")
    classified.icon2 = SpawnPrefab("globalmapicon")
    classified.icon2.MiniMapEntity:SetPriority(10)
    classified.icon2.MiniMapEntity:SetRestriction("player")
    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetEnabled(false)
        classified.icon.MiniMapEntity:CopyIcon(inst.MiniMapEntity)
        classified.icon2.MiniMapEntity:CopyIcon(inst.MiniMapEntity)
    else
        classified.icon.MiniMapEntity:SetIcon(_GLOBALPOSITIONS_MAP_ICONS[inst.prefab])
        classified.icon2.MiniMapEntity:SetIcon(_GLOBALPOSITIONS_MAP_ICONS[inst.prefab])
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
            self:PushPortraitDirty()
        end
        self.becameghostfn = function()
            self:SetMapSharing(false)
            self:PushPortraitDirty()
        end
        self.inst:ListenForEvent("ms_respawnedfromghost", self.respawnedfromghostfn)
        self.inst:ListenForEvent("ms_becameghost", self.becameghostfn)
    end

    self.inittask = self.inst:DoTaskInTime(0, function()
        self.inittask = nil
        self.globalpositions = TheWorld.net.components.globalpositions
        self.classified = self.globalpositions:AddServerEntity(self.inst)
        if isplayer then
            AddGlobalIcon(inst, self.classified)
        end
        self.inst:StartUpdatingComponent(self)
    end)
end,
nil,
{
})

return GlobalPosition