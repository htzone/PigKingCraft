local function a(self)
    for b, c in ipairs({ "task", "timeout_task" }) do
        if self[c] then
            self[c]:Cancel()
            self[c] = nil
        end
    end
end;
local function d(e, f)
    local self = e.components.pkc_reticule_spawner;
    a(self)
    self.task = self.ping:DoTaskInTime(self.time or 2, function()
        self:KillRet()
        self.task = nil
    end)
end;
local g = Class(function(self, e)
    self.inst = e;
    self.time = 2;
    self.type = "aoe"
    self.ping = nil;
    self.task = nil
end)
function g:Setup(h, i)
    self.type = h or "aoe"
    self.time = i or 2
end;
function g:Spawn(j)
    if self.task then
        self.task:Cancel()
        self.task = nil;
        self:KillRet()
    end ;
    self.ping = SpawnAt("reticule" .. self.type, j)
    self.inst:ListenForEvent("aoe_casted", d)
    self.timeout_task = self.inst:DoTaskInTime(4, function()
        print("ReticuleSpawner: Timeouted!")
        self:Interrupt()
    end)
end;
function g:KillRet()
    if self.ping then
        self.ping:KillFX()
        self.ping = nil
    end ;
    self.inst:RemoveEventCallback("aoe_casted", d)
end;
function g:Interrupt()
    a(self)
    self:KillRet()
end;
return g