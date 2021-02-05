--
-- pkc_hostile
-- Author: RedPig
-- Date: 2021/2/5
--

local function NormalRetargetFn(inst)
    return not inst:IsInLimbo()
            and FindEntity(inst, 20, function(guy)
        if guy:HasTag("player") then
            return true
        end
        if guy.components.follower and guy.components.follower.leader
                and guy.components.follower.leader:HasTag("player") then
            return true
        end
        if guy:HasTag("monster") or guy:HasTag("pkc_hostile")
                or guy:HasTag("shadowboss") or guy:HasTag("playerghost") then
            return false
        end
        return guy:HasTag("pkc_defences")
    end)
            or nil
end

local function NormalKeepTargetFn(inst, target)
    return not (target.sg ~= nil and target.sg:HasStateTag("hiding")) and inst.components.combat:CanTarget(target)
end

local PKC_HOSTILE = Class(function(self, inst)
    self.inst = inst
    self.loot = nil
    self.maxHealth = nil
    self:AddAttr()
    self:SetAttackTarget()
end)

function PKC_HOSTILE:AddAttr()
    self.inst:AddTag("pkc_hostile")
    self.inst:AddTag("monster")
end

function PKC_HOSTILE:SetAttackTarget()
    if self.inst.components.combat then
        self.inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
        self.inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    end
end

function PKC_HOSTILE:SetMaxHealth(value)
    if self.inst.components.health then
        self.maxHealth = value
        self.inst.components.health:SetMaxHealth(value)
        self.inst.components.health:StartRegen(60, 30)
    end
end

function PKC_HOSTILE:SetLeader(leader)
    if self.inst.components.follower then
        if leader and not leader.components.leader then
            leader:AddComponent("leader")
        end
        self.inst.components.follower:SetLeader(leader)
    end
end

function PKC_HOSTILE:SetLoot(loot)
    if self.inst.components.lootdropper then
        self.loot = loot
        self.inst.components.lootdropper:SetLoot(loot)
    end
end

function PKC_HOSTILE:OnSave()
    return
    {
        loot = self.loot,
        maxHealth = self.maxHealth,
    }
end

function PKC_HOSTILE:OnLoad(data)
    if data ~= nil then
        if data.loot ~= nil then
            self.loot = data.loot
            self:SetLoot(self.loot)
        end
        if data.maxHealth ~= nil then
            self.maxHealth = data.maxHealth
            self:SetMaxHealth(self.maxHealth)
        end
        self:AddAttr()
        self:SetAttackTarget()
    end
end

return PKC_HOSTILE