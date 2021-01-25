local a = 1 / 1000;
local function b()
    local c = CreateEntity()
    c.entity:AddTransform()
    c:AddTag("CLASSIFIED")
    c.blooms = {}
    c.caster = nil;
    c:AddComponent("pkc_heal_aura")
    c:DoTaskInTime(TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.DURATION, function(c)
        for d, e in pairs(c.blooms) do
            if e.Kill ~= nil then
                e:Kill(true)
            end
        end ;
        c:Remove()
    end)
    function c:SpawnBlooms()
        local f = "pkc_healingcircle_bloom"
        for g = 1, 15 do
            local h = c:GetPosition()
            if g == 1 then
                c:DoTaskInTime(math.random(), function()
                    local i = SpawnPrefab(f)
                    i.Transform:SetPosition(h:Get())
                    i.buffed = c.buffed;
                    table.insert(c.blooms, i)
                end)
            elseif g >= 2 and g < 7 then
                local j = (g - 1) / 5 * 2 * PI;
                local k = c.components.pkc_heal_aura.range / 2;
                local l = FindWalkableOffset(h, j, k, 2, true, true)
                if l ~= nil then
                    l.x = l.x + h.x;
                    l.z = l.z + h.z;
                    c:DoTaskInTime(math.random(), function()
                        local i = SpawnPrefab(f)
                        i.Transform:SetPosition(l.x, 0, l.z)
                        i.buffed = c.buffed;
                        table.insert(c.blooms, i)
                    end)
                end
            elseif g >= 7 then
                local j = (g - 5) / 9 * 2 * PI;
                local k = c.components.pkc_heal_aura.range;
                local l = FindWalkableOffset(h, j, k, 2, true, true)
                if l ~= nil then
                    l.x = l.x + h.x;
                    l.z = l.z + h.z;
                    c:DoTaskInTime(math.random(), function()
                        local i = SpawnPrefab(f)
                        i.Transform:SetPosition(l.x, 0, l.z)
                        i.buffed = c.buffed;
                        table.insert(c.blooms, i)
                    end)
                end
            end
        end
    end;
    function c:SpawnCenter()
        local h = c:GetPosition()
        local m = SpawnPrefab("pkc_healingcircle_center")
        m.Transform:SetPosition(h.x, 0, h.z)
        m:DoTaskInTime(TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.COOLDOWN / 2, c.Remove)
    end;
    c:DoTaskInTime(0, c.SpawnCenter)
    c:DoTaskInTime(0, c.SpawnBlooms)
    c.OnLoad = c.Remove;
    return c
end;
local function n()
    local c = CreateEntity()
    c.entity:AddTransform()
    c.entity:AddAnimState()
    c.entity:AddSoundEmitter()
    c.entity:AddNetwork()
    c.AnimState:SetBuild("lavaarena_heal_flowers_fx")
    c.AnimState:SetBank("lavaarena_heal_flowers")
    if not TheWorld.ismastersim then
        return c
    end ;
    c.variation = tostring(math.random(1, 6))
    c:AddComponent("pkc_colourfader")
    local function o()
        c.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds", "flower_sound")
        c.SoundEmitter:SetVolume("flower_sound", .25)
    end;
    function c:Start()
        o()
        c.AnimState:PlayAnimation("in_" .. c.variation)
        c.AnimState:PushAnimation("idle_" .. c.variation)
        if c.buffed then
            local p = 1 + (math.random(unpack(TUNING.THE_FORGE_ITEM_PACK.PKC_LIVINGSTAFF.SCALE_RNG)) + math.random()) / 100;
            c.Transform:SetScale(p, p, p)
        end ;
        c.components.pkc_colourfader:StartFade({ 0, 0.3, 0.1 }, 650 * a, function(c)
            c:DoTaskInTime(350 * a, function()
                c.components.pkc_colourfader:StartFade({ 0, 0, 0 }, 457 * a)
            end)
        end)
    end;
    function c:Kill(q)
        local r = q and math.random() or 0;
        c:DoTaskInTime(r, function(c)
            o()
            c.AnimState:PushAnimation("out_" .. c.variation, false)
            c:ListenForEvent("animover", c.Remove)
        end)
    end;
    c.OnLoad = c.Kill;
    c:DoTaskInTime(0, c.Start)
    return c
end;
local function s()
    local c = CreateEntity()
    c.entity:AddTransform()
    c.entity:AddAnimState()
    c.entity:AddNetwork()
    c.AnimState:SetBank("lavaarena_heal_flowers")
    c.AnimState:SetBuild("lavaarena_heal_flowers_fx")
    c.AnimState:SetMultColour(0, 0, 0, 0)
    c:AddTag("pkc_healingcircle")
    if not TheWorld.ismastersim then
        return c
    end ;
    c.variation = tostring(math.random(1, 6))
    c.AnimState:PlayAnimation("in_" .. c.variation)
    c.AnimState:PushAnimation("idle_" .. c.variation)
    c:DoTaskInTime(12, c.Remove)
    c.OnLoad = c.Remove;
    return c
end;
return Prefab("pkc_healingcircle", b, nil, prefabs), Prefab("pkc_healingcircle_bloom", n, nil, nil), Prefab("pkc_healingcircle_center", s, nil, nil)