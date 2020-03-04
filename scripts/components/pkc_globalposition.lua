-- 位置组件
-- Author: RedPig
-- Date: 2020/3/4

local function AddGlobalIcon(inst, isplayer, classified)
    if not (_GLOBALPOSITIONS_MAP_ICONS[inst.prefab] or inst.MiniMapEntity) then return end
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

local function AddMapRevealer(inst)
    if not inst.components.maprevealer then
        inst:AddComponent("maprevealer")
    end
    inst.components.maprevealer.revealperiod = 0.5
    inst.components.maprevealer:Stop()
    if _GLOBALPOSITIONS_SHAREMINIMAPPROGRESS then
        inst.components.maprevealer:Start()
    end
end

local GlobalPosition = Class(function(self, inst)
    self.inst = inst
    self.classified = nil

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
        if ((isplayer and _GLOBALPOSITIONS_SHOWPLAYERICONS)
                or (not isplayer and (self.inst.prefab:find("ping_") or _GLOBALPOSITIONS_SHOWFIREICONS))) then
            AddGlobalIcon(inst, isplayer, self.classified)
        end
        self.inst:StartUpdatingComponent(self)
    end)
end,
nil,
{
})