local a = Class(function(self, b)
    self.inst = b;
    self.data = {}
    self.buffs = {}
end)
function a:AddBuff(c, d)
    if self.buffs[c] ~= nil then
        self:RemoveBuff(c)
    end ;
    self.buffs[c] = {}
    for e, f in pairs(d) do
        if not self.data[e] then
            self.data[e] = {}
        end ;
        self.data[e][c] = f;
        table.insert(self.buffs[c], e)
    end
end;
function a:GetBuffData(e)
    local f = 0;
    if self:HasBuffData(e) then
        for g, h in pairs(self.data[e]) do
            f = f + h
        end
    end ;
    return f
end;
function a:HasBuff(c)
    return self.buffs[c] ~= nil
end;
function a:HasBuffData(c)
    return self.data[c] ~= nil
end;
function a:RemoveBuff(c)
    for i, e in pairs(self.buffs[c]) do
        self.data[e][c] = nil;
        if GetTableSize(self.data[e]) < 1 then
            self.data[e] = nil
        end
    end ;
    self.buffs[c] = nil
end;
return a