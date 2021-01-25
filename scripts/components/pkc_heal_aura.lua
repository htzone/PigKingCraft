local function a(b)
    return b.components.health ~= nil and not b.components.health:IsDead()
end;
local function c(d)
    local e = GetTime() - d.components.combat.lastwasattackedtime;
    d:AddTag("_isinheals")
    if e > 3 and not (d.sg and d.sg:HasStateTag("hiding")) then
        d.components.sleeper:AddSleepiness(10, 3)
    end
end;
local f = Class(function(self, g)
    self.inst = g;
    self.range = 15;
    self.range = 4.1;
    self.duration = TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.DURATION;
    self.heal_rate = TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.HEAL_RATE;
    self.cache = {}
    local h = function()
        self:Stop()
    end;
    self.inst:DoTaskInTime(0, g.StartUpdatingComponent, self)
    self.inst:DoTaskInTime(self.duration, h)
end)
function f:OnUpdate(i)
    local j, k, l = self.inst.Transform:GetWorldPosition()
    local m = TheSim:FindEntities(j, 0, l, self.range, nil, { "fossilized" }) or {}
    for k, b in pairs(m) do
        if not self.cache[b] and a(b) then
            self.cache[b] = true;
            self:OnEntEnter(b)
        end
    end ;
    for b, k in pairs(self.cache) do
        local n = b:GetPosition()
        if not a(b) or distsq(n.x, n.z, j, l) > self.range * self.range then
            self:OnEntLeave(b)
        end
    end
end;
function f:OnEntEnter(b)
    if b.components.fossilizable and b.components.fossilizable:IsFossilized() then
        self.cache[b] = nil;
        return
    end ;
    if b.components.pkc_colourfader then
        b.components.pkc_colourfader:StartFade({ 0, 0.3, 0.1 }, .35)
    end ;
    if (b:HasTag("player") or b:HasTag("companion")) and b.components.debuffable ~= nil and b.components.debuffable:IsEnabled() and not (b.components.health ~= nil and b.components.health:IsDead()) and not b:HasTag("playerghost") then
        b.components.debuffable:AddDebuff("pkc_healingcircle_regenbuff", "pkc_healingcircle_regenbuff")
        b.components.debuffable.debuffs["pkc_healingcircle_regenbuff"].inst.heal_value = self.heal_rate * b.components.debuffable.debuffs["pkc_healingcircle_regenbuff"].inst.tick_rate;
        b.components.debuffable.debuffs["pkc_healingcircle_regenbuff"].inst.caster = self.caster;
        if b.components.debuffable:HasDebuff("scorpeon_dot") then
            b.components.debuffable:RemoveDebuff("scorpeon_dot")
        end
    elseif b.components.sleeper and not (b:HasTag("player") or b:HasTag("companion")) and not b.healingcircle_sleeptask then
        b.healingcircle_sleeptask = b:DoPeriodicTask(1 / 10, c)
        b.sleep_start = GetTime()
    end
end;
function f:OnEntLeave(b)
    if not self.cache[b] then
        return
    end ;
    if b:HasTag("_isinheals") then
        b:RemoveTag("_isinheals")
    end ;
    if b.components.pkc_colourfader then
        b.components.pkc_colourfader:StartFade({ 0, 0, 0 }, .35)
    end ;
    if b.components.debuffable ~= nil and b.components.debuffable:IsEnabled() and b.components.debuffable:HasDebuff("pkc_healingcircle_regenbuff") and not (b.components.health ~= nil and b.components.health:IsDead()) and not b:HasTag("playerghost") and b:HasTag("player") then
        b.components.debuffable:RemoveDebuff("pkc_healingcircle_regenbuff")
    elseif b.components.sleeper and not b:HasTag("player") and b.healingcircle_sleeptask then
        b.healingcircle_sleeptask:Cancel()
        b.healingcircle_sleeptask = nil
    end ;
    self.cache[b] = nil
end;
function f:Stop()
    self.inst:StopUpdatingComponent(self)
    for b, k in pairs(self.cache) do
        self:OnEntLeave(b)
    end
end;
f.OnRemoveEntity = f.Stop;
f.OnRemoveFromEntity = f.Stop;
return f