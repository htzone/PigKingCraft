local a = Class(function(self, b)
    self.inst = b;
    self.hitdist = 1;
    self.range = 10;
    self.speed = 20;
    self.damage = nil;
    self.stimuli = nil;
    self.onthrown = nil;
    self.onhit = nil;
    self.onmiss = nil
end)
function a:SetHitDistance(c)
    self.hitdist = c
end;
function a:SetRange(d)
    self.range = d
end;
function a:SetSpeed(e)
    self.speed = e
end;
function a:SetDamage(f)
    self.damage = f
end;
function a:SetStimuli(g)
    self.stimuli = g
end;
function a:SetOnThrownFn(h)
    self.onthrown = h
end;
function a:SetOnHitFn(h)
    self.onhit = h
end;
function a:SetOnMissFn(h)
    self.onmiss = h
end;
function a:RotateToTarget(i)
    local j = (i - self.inst:GetPosition()):GetNormalized()
    local k = math.acos(j:Dot(Vector3(1, 0, 0))) / DEGREES;
    self.inst.Transform:SetRotation(k)
    self.inst:FacePoint(i)
end;
function a:Throw(l, m, n)
    self.owner = l;
    self.attacker = m;
    self.start = l:GetPosition()
    self.dest = n;
    if m ~= nil and self.launchoffset ~= nil then
        local o, p, q = self.inst.Transform:GetWorldPosition()
        local r = m.Transform:GetRotation() * DEGREES;
        self.inst.Transform:SetPosition(o + self.launchoffset.x * math.cos(r), p + self.launchoffset.y, q - self.launchoffset.x * math.sin(r))
    end ;
    self:RotateToTarget(self.dest)
    self.inst.Physics:SetMotorVel(self.speed, 0, 0)
    self.inst:StartUpdatingComponent(self)
    self.inst:PushEvent("onthrown", { thrower = m })
    if self.onthrown ~= nil then
        self.onthrown(self.inst, l, m, n)
    end
end;
function a:Stop()
    self.inst:StopUpdatingComponent(self)
    self.target = nil;
    self.attacker = nil;
    self.owner = nil
end;
function a:Miss()
    if self.onmiss ~= nil then
        self.onmiss(self.inst, self.owner, self.attacker)
    end ;
    self:Stop()
end;
function a:Hit(s)
    self.inst.Physics:Stop()
    if self.attacker and self.owner and self.owner.components.weapon then
        self.owner.components.weapon:DoAltAttack(self.attacker, s, nil, self.stimuli)
    end ;
    if self.onhit ~= nil then
        self.onhit(self.inst, self.owner, self.attacker, s)
    end ;
    self:Stop()
end;
function a:OnUpdate(t)
    local u = self.inst:GetPosition()
    if self.range ~= nil and distsq(self.start, u) > self.range * self.range then
        self:Miss()
    else
        local v = {}
        local s = nil;
        local o, p, q = u:Get()
        local w = TheSim:FindEntities(o, p, q, 3, nil, { "player", "companion" })
        for x, y in ipairs(w) do
            if y.entity:IsValid() and y.entity:IsVisible() and (y.components.health and not y.components.health:IsDead() or self.inst.prefab == 'riledlucy' and y:HasTag("tree") and not y:HasTag("stump") and y.components.workable and y.components.workable:CanBeWorked() and y.components.workable:GetWorkAction()) then
                local z = y:GetPhysicsRadius(0) + self.hitdist;
                local A = distsq(u, y:GetPosition())
                if z > A then
                    table.insert(v, { target = y, hitrange = z, currentrange = A })
                end
            end
        end ;
        for x, B in pairs(v) do
            if s == nil or B.currentrange - B.hitrange < s.range then
                s = { ent = B.target, range = B.currentrange - B.hitrange }
            end
        end ;
        if s ~= nil then
            self:Hit(s.ent)
        end
    end
end;
local function C(b, self)
    self.delaytask = nil;
    b:Show()
end;
function a:DelayVisibility(D)
    if self.delaytask ~= nil then
        self.delaytask:Cancel()
    end ;
    self.inst:Hide()
    self.delaytask = self.inst:DoTaskInTime(D, C, self)
end;
return a