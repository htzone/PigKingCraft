local function a(b, c)
    if c.components.health ~= nil and not c.components.health:IsDead() and not c:HasTag("playerghost") then
        local d = b.heal_value;
        local e = c.healmult and c.healmult or 1;
        if c.components.pkc_buffable then
            d = d * (c.components.pkc_buffable:GetBuffData("heal_recieved_mult") + 1)
        end ;
        c.components.health:DoDelta(d * e, true, "pkc_healingcircle", nil, b.caster)
    else
        b.components.debuff:Stop()
    end
end;
local function f(b, c)
    b.entity:SetParent(c.entity)
    b.task = b:DoPeriodicTask(b.tick_rate, a, nil, c)
    b:ListenForEvent("death", function()
        b.components.debuff:Stop()
    end, c)
end;
local function g(b, h)
    if h.name == "regenover" then
        b.components.debuff:Stop()
    end
end;
local function i(b, c)
    b.components.timer:StopTimer("regenover")
    b.components.timer:StartTimer("regenover", b.duration)
    b.task:Cancel()
    b.task = b:DoPeriodicTask(b.tick_rate, a, nil, c)
end;
local function j(b)
    local k = b.entity:GetParent()
    if k ~= nil then
        k:PushEvent("starthealthregen", b)
    else
        b:Remove()
    end
end;
local function l()
    local b = CreateEntity()
    b.entity:AddTransform()
    b.entity:AddNetwork()
    b:DoTaskInTime(0, j)
    if not TheWorld.ismastersim then
        return b
    end ;
    b.tick_rate = 1 / 30;
    b.heal_value = TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.HEAL_RATE * b.tick_rate;
    b.duration = TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.DURATION;
    b.caster = nil;
    b.entity:Hide()
    b.persists = false;
    b:AddTag("CLASSIFIED")
    b:AddComponent("debuff")
    b.components.debuff:SetAttachedFn(f)
    b.components.debuff:SetDetachedFn(b.Remove)
    b.components.debuff:SetExtendedFn(i)
    b.components.debuff.keepondespawn = true;
    b:AddComponent("timer")
    b.components.timer:StartTimer("regenover", b.duration)
    b:ListenForEvent("timerdone", g)
    return b
end;
return Prefab("pkc_healingcircle_regenbuff", l)