local a = Class(function(self, b)
    self.inst = b;
    self.spell_type = nil;
    self.aoe_cast = nil
end)
function a:SetAOESpell(c)
    self.aoe_cast = c
end;
function a:CanCast(d, e)
    local f, g, h = e:Get()
    return self.inst.components.aoetargeting ~= nil and self.inst.components.aoetargeting.alwaysvalid or TheWorld.Map:IsPassableAtPoint(f, g, h) and not TheWorld.Map:IsGroundTargetBlocked(e)
end;
function a:CastSpell(d, e)
    if self.inst.components.pkc_reticule_spawner and (self.inst.components.pkc_rechargeable and self.inst.components.pkc_rechargeable.isready) then
        self.inst.components.pkc_reticule_spawner:Spawn(e)
    end ;
    if self.aoe_cast ~= nil then
        self.aoe_cast(self.inst, d, e)
    end ;
    self.inst:PushEvent("aoe_casted", { caster = d, pos = e })
end;
function a:SetSpellType(i)
    self.spell_type = i
end;
function a:OnSpellCast(d, j)
    d:PushEvent("spell_complete", { spell_type = self.spell_type })
end;
return a