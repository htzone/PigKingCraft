local function a(self, b, c)
    if c == true and b == true then
        self.inst:AddTag("helmsplitter")
    elseif c == true and b == false then
        self.inst:RemoveTag("helmsplitter")
    end
end;
local d = Class(function(self, e)
    self.inst = e;
    self.ready = true;
    self.damage = 10;
    self.onhelmsplit = nil
end, nil, { ready = a })
function d:SetOnHelmSplitFn(f)
    self.onhelmsplit = f
end;
function d:StartHelmSplitting(g)
    if g.sg then
        g.sg:PushEvent("start_helmsplit")
        return true
    end ;
    return false
end;
function d:DoHelmSplit(g, h)
    if g.sg then
        g.sg:PushEvent("do_helmsplit")
    end ;
    local i = g.components.combat.damagemultiplier;
    g.components.combat:DoSpecialAttack(self.damage, h, "strong", i)
    if self.onhelmsplit then
        self.onhelmsplit(self.inst, g, h)
    end
end;
function d:StopHelmSplitting(g)
    if g.sg then
        g.sg:PushEvent("stop_helmsplit")
    end ;
    self.ready = false
end;
return d