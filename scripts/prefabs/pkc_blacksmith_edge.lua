local a = { Asset("ANIM", "anim/sword_buster.zip"), Asset("ANIM", "anim/swap_sword_buster.zip") }
local b = { "weaponsparks_fx", "sunderarmordebuff", "superjump_fx", "reticulearc", "reticulearcping" }
local function c()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end;
local function d(e, f)
    if f ~= nil then
        local g, h, i = e.Transform:GetWorldPosition()
        local j = f.x - g;
        local k = f.z - i;
        local l = j * j + k * k;
        if l <= 0 then
            return e.components.reticule.targetpos
        end ;
        l = 6.5 / math.sqrt(l)
        return Vector3(g + j * l, 0, i + k * l)
    end
end;
local function m(e, n, o, p, q, r)
    local g, h, i = e.Transform:GetWorldPosition()
    o.Transform:SetPosition(g, 0, i)
    local s = -math.atan2(n.z - i, n.x - g) / DEGREES;
    if p and r ~= nil then
        local t = o.Transform:GetRotation()
        local u = s - t;
        s = Lerp(u > 180 and t + 360 or u < -180 and t - 360 or t, s, r * q)
    end ;
    o.Transform:SetRotation(s)
end;
local function v(e, w)
    w.AnimState:OverrideSymbol("swap_object", "swap_sword_buster", "swap_sword_buster")
    w.AnimState:Show("ARM_carry")
    w.AnimState:Hide("ARM_normal")
end;
local function x(e, w)
    w.AnimState:Hide("ARM_carry")
    w.AnimState:Show("ARM_normal")
end;
local function y(e, z, A)
    SpawnPrefab("pkc_weaponsparks_fx"):SetPosition(z, A)
    if A and A.components.combat and z then
        A.components.combat:SetTarget(z)
    end
end;
local function B(e, C, n)
    C:PushEvent("combat_parry", { direction = e:GetAngleToPoint(n), duration = e.components.parryweapon.duration, weapon = e })
end;
local function D(e, C)
    e.components.pkc_rechargeable:StartRecharge()
end;
local function E(e)
    SpawnPrefab("superjump_fx"):SetTarget(e)
end;
local function F()
    local e = CreateEntity()
    e.entity:AddTransform()
    e.entity:AddAnimState()
    e.entity:AddNetwork()
    MakeInventoryPhysics(e)
    e.nameoverride = "lavaarena_heavyblade"
    e.AnimState:SetBank("sword_buster")
    e.AnimState:SetBuild("sword_buster")
    e.AnimState:PlayAnimation("idle")
    e:AddTag("parryweapon")
    e:AddTag("rechargeable")
    e:AddComponent("aoetargeting")
    e.components.aoetargeting:SetAlwaysValid(true)
    e.components.aoetargeting.reticule.reticuleprefab = "reticulearc"
    e.components.aoetargeting.reticule.pingprefab = "reticulearcping"
    e.components.aoetargeting.reticule.targetfn = c;
    e.components.aoetargeting.reticule.mousetargetfn = d;
    e.components.aoetargeting.reticule.updatepositionfn = m;
    e.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    e.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    e.components.aoetargeting.reticule.ease = true;
    e.components.aoetargeting.reticule.mouseenabled = true;
    e.entity:SetPristine()
    if not TheWorld.ismastersim then
        return e
    end ;
    e:AddComponent("aoespell")
    e.components.aoespell:SetAOESpell(B)
    e:AddComponent("equippable")
    e.components.equippable:SetOnEquip(v)
    e.components.equippable:SetOnUnequip(x)
    e:AddComponent("pkc_helmsplitter")
    e.components.pkc_helmsplitter:SetOnHelmSplitFn(E)
    e.components.pkc_helmsplitter.damage = 100;
    e:AddComponent("inspectable")
    e:AddComponent("inventoryitem")
    e.components.inventoryitem.imagename = "lavaarena_heavyblade"
    e:AddComponent("parryweapon")
    e.components.parryweapon.duration = 5;
    e.components.parryweapon:SetOnParryStartFn(D)
    e:AddComponent("pkc_rechargeable")
    e.components.pkc_rechargeable:SetRechargeTime(TUNING.THE_FORGE_ITEM_PACK.PKC_BLACKSMITH_EDGE.COOLDOWN)
    e:AddComponent("pkc_reticule_spawner")
    e.components.pkc_reticule_spawner:Setup(unpack({ "aoehostiletarget", 0.9 }))
    e:AddComponent("weapon")
    e.components.weapon:SetDamage(30)
    e.components.weapon:SetDamageType(DAMAGETYPES.PHYSICAL)
    return e
end;
require "class"
require "util"
CustomPrefab = Class(Prefab, function(self, a, b, c, d, e, f, g, h, i, j)
    Prefab._ctor(self, a, b, c, d, e)
    self.name = a;
    self.atlas = f and resolvefilepath(f) or resolvefilepath("images/inventoryimages.xml")
    self.imagefn = type(g) == "function" and g or nil;
    self.image = self.imagefn == nil and g or "torch.tex"
    self.swap_build = i;
    local k = { common_head1 = { swap = { "swap_hat" }, hide = { "HAIR_NOHAT", "HAIR", "HEAD" }, show = { "HAT", "HAIR_HAT", "HEAD_HAT" } }, common_head2 = { swap = { "swap_hat" }, show = { "HAT" } }, common_body = { swap = { "swap_body" } }, common_hand = { swap = { "swap_object" }, hide = { "ARM_normal" }, show = { "ARM_carry" } } }
    self.swap_data = k[j] ~= nil and k[j] or j
end)
return CustomPrefab("pkc_blacksmith_edge", F, a, b, nil, "images/inventoryimages.xml", "lavaarena_heavyblade.tex", TUNING.THE_FORGE_ITEM_PACK.BLACKSMITH_EDGE, "swap_sword_buster", "common_hand")