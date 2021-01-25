local a = { Asset("ANIM", "anim/lavaarena_firestaff_meteor.zip") }
local b = { Asset("ANIM", "anim/lavaarena_fire_fx.zip") }
local c = { "pkc_infernalstaff_meteor_splash", "pkc_infernalstaff_meteor_splashhit" }
local d = { "pkc_infernalstaff_meteor_splashbase" }
local e = TUNING.THE_FORGE_ITEM_PACK.PKC_INFERNALSTAFF.ALT_RADIUS;
local function f()
    local g = CreateEntity()
    g.entity:AddTransform()
    g.entity:AddAnimState()
    g.entity:AddNetwork()
    g.AnimState:SetBank("lavaarena_firestaff_meteor")
    g.AnimState:SetBuild("lavaarena_firestaff_meteor")
    g.AnimState:PlayAnimation("crash")
    g.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    g:AddTag("FX")
    g:AddTag("NOCLICK")
    g:AddTag("notarget")
    g.entity:SetPristine()
    if not TheWorld.ismastersim then
        return g
    end ;
    g.AttackArea = function(g, h, i, j)
        i.meteor = g;
        g.attacker = h;
        g.owner = i;
        g.Transform:SetPosition(j:Get())
    end;
    g:ListenForEvent("animover", function(g)
        g:DoTaskInTime(FRAMES * 3, function(g)
            SpawnPrefab("pkc_infernalstaff_meteor_splash"):SetPosition(g:GetPosition())
            local k = {}
            local l, m, n = g:GetPosition():Get()
            local o = TheSim:FindEntities(l, m, n, e, nil, { "player", "companion" })
            for p, q in ipairs(o) do
                if g.attacker ~= nil and q ~= g.attacker and q.entity:IsValid() and q.entity:IsVisible() and (q.components.health and not q.components.health:IsDead() or q.components.workable and q.components.workable:CanBeWorked() and q.components.workable:GetWorkAction()) then
                    table.insert(k, q)
                end
            end ;
            if g.owner.components.weapon and g.owner.components.weapon:HasAltAttack() then
                g.owner.components.weapon:DoAltAttack(g.attacker, k, nil, "explosive")
            end ;
            g.owner.components.aoespell:OnSpellCast(g.attacker, o)
            g:Remove()
        end)
    end)
    g.OnLoad = g.Remove;
    return g
end;
local function r()
    local g = CreateEntity()
    g.entity:AddTransform()
    g.entity:AddAnimState()
    g.entity:AddSoundEmitter()
    g.entity:AddNetwork()
    g.AnimState:SetBank("lavaarena_fire_fx")
    g.AnimState:SetBuild("lavaarena_fire_fx")
    g.AnimState:PlayAnimation("firestaff_ult")
    g.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    g.AnimState:SetFinalOffset(1)
    g:AddTag("FX")
    g:AddTag("NOCLICK")
    g.entity:SetPristine()
    if not TheWorld.ismastersim then
        return g
    end ;
    g.SetPosition = function(g, j)
        g.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/meteor_strike")
        g.Transform:SetPosition(j:Get())
        SpawnPrefab("pkc_infernalstaff_meteor_splashbase"):SetPosition(j)
    end;
    g:ListenForEvent("animover", g.Remove)
    g.OnLoad = g.Remove;
    return g
end;
local function s()
    local g = CreateEntity()
    g.entity:AddTransform()
    g.entity:AddAnimState()
    g.entity:AddNetwork()
    g.AnimState:SetBank("lavaarena_fire_fx")
    g.AnimState:SetBuild("lavaarena_fire_fx")
    g.AnimState:PlayAnimation("firestaff_ult_projection")
    g.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    g.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    g.AnimState:SetLayer(LAYER_BACKGROUND)
    g.AnimState:SetSortOrder(3)
    g:AddTag("FX")
    g:AddTag("NOCLICK")
    g.entity:SetPristine()
    if not TheWorld.ismastersim then
        return g
    end ;
    g.SetPosition = function(g, j)
        g.Transform:SetPosition(j:Get())
    end;
    g:ListenForEvent("animover", g.Remove)
    g.OnLoad = g.Remove;
    return g
end;
local function t()
    local g = CreateEntity()
    g.entity:AddTransform()
    g.entity:AddAnimState()
    g.entity:AddNetwork()
    g.AnimState:SetBank("lavaarena_fire_fx")
    g.AnimState:SetBuild("lavaarena_fire_fx")
    g.AnimState:PlayAnimation("firestaff_ult_hit")
    g.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    g.AnimState:SetFinalOffset(1)
    g:AddTag("FX")
    g:AddTag("NOCLICK")
    g.entity:SetPristine()
    if not TheWorld.ismastersim then
        return g
    end ;
    g.SetTarget = function(g, u)
        g.Transform:SetPosition(u:GetPosition():Get())
        local v = u:HasTag("minion") and .5 or (u:HasTag("largecreature") and 1.3 or .8)
        g.AnimState:SetScale(v, v)
    end;
    g:ListenForEvent("animover", g.Remove)
    g.OnLoad = g.Remove;
    return g
end;
return Prefab("pkc_infernalstaff_meteor", f, a, c), Prefab("pkc_infernalstaff_meteor_splash", r, b, d), Prefab("pkc_infernalstaff_meteor_splashbase", s, b), Prefab("pkc_infernalstaff_meteor_splashhit", t, b)