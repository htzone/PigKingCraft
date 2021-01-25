local a = Class(function(self, b)
    self.inst = b;
    self.onparrystart = nil;
    self.duration = 2;
    b:AddTag("parryweapon")
end)
function a:SetOnParryStartFn(c)
    self.onparrystart = c
end;
function a:OnPreParry(d)
    if d.sg then
        d.sg:PushEvent("start_parry")
    end ;
    if self.onparrystart then
        self.onparrystart(self.inst, d)
    end
end;
--inst, attacker, damage, weapon, stimuli
function a:TryParry(inst, attacker, damage, weapon, stimuli)
    if inst.sg then
        inst.sg:PushEvent("try_parry")
    end ;
    if self.ontryparry then
        return self.ontryparry(inst, attacker, damage, weapon, stimuli)
    end ;
    local i = attacker or weapon;
    local j = inst.Transform:GetRotation() - inst:GetAngleToPoint(i.Transform:GetWorldPosition())
    if not (math.abs(j) <= 70) then
        return false
    end ;
    local k = i.components.weapon and i.components.weapon.damagetype or i.components.combat and i.components.combat.damagetype or nil;
    if not (k == DAMAGETYPES.PHYSICAL) then
        return false
    end ;
    return true
end;
return a