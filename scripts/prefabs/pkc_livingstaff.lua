local a = { Asset("ANIM", "anim/healingstaff.zip"), Asset("ANIM", "anim/swap_healingstaff.zip") }
local b = { "forge_blossom_projectile", "forge_blossom_hit_fx", "lavaarena_healblooms", "reticuleaoe", "reticuleaoeping", "reticuleaoefriendlytarget" }
local c = 4 * FRAMES;
local function d(e, f)
    f.AnimState:OverrideSymbol("swap_object", "swap_healingstaff", "swap_healingstaff")
    f.AnimState:Show("ARM_carry")
    f.AnimState:Hide("ARM_normal")
end;
local function g(e, f)
    f.AnimState:Hide("ARM_carry")
    f.AnimState:Show("ARM_normal")
end;
local function h()
    local i = ThePlayer;
    local j = TheWorld.Map;
    local k = Vector3()
    for l = 6, 0, -.25 do
        k.x, k.y, k.z = i.entity:LocalToWorldSpace(l, 0, 0)
        if j:IsPassableAtPoint(k:Get()) and not j:IsGroundTargetBlocked(k) then
            return k
        end
    end ;
    return k
end;
local function m(e, n, k)
    e:DoTaskInTime(0.9, function()
        local o = e.heal_rate;
        local p = false;
        if n.components.pkc_buffable then
            o = (o + n.components.pkc_buffable:GetBuffData("spell_heal_rate")) * (n.components.pkc_buffable:GetBuffData("heal_dealt_mult") + 1)
            p = o > e.heal_rate
        end ;
        local q = SpawnAt("pkc_healingcircle", k)
        local r = q.components.pkc_heal_aura;
        r.heal_rate = o;
        r.caster = n;
        q.buffed = p;
        e.components.pkc_rechargeable:StartRecharge()
        TheWorld:PushEvent("healingcircle_spawned")
        e.components.aoespell:OnSpellCast(n)
    end)
end;
local function s(e, t, u)
    e.SoundEmitter:PlaySound("dontstarve/common/lava_arena/heal_staff")
    local v = (u:GetPosition() - t:GetPosition()):GetNormalized() * 1.2;
    local w = SpawnPrefab("forge_blossom_hit_fx")
    w.Transform:SetPosition((t:GetPosition() + v):Get())
    w.AnimState:SetScale(0.8, 0.8)
end;
local function x()
    local e = CreateEntity()
    e.entity:AddTransform()
    e.entity:AddAnimState()
    e.entity:AddSoundEmitter()
    e.entity:AddNetwork()
    MakeInventoryPhysics(e)
    e.nameoverride = "healingstaff"
    e.AnimState:SetBank("healingstaff")
    e.AnimState:SetBuild("healingstaff")
    e.AnimState:PlayAnimation("idle")
    e:AddTag("magicweapon")
    e:AddTag("rechargeable")
    e:AddTag("rangedweapon")
    e:AddComponent("aoetargeting")
    e.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    e.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    e.components.aoetargeting.reticule.targetfn = h;
    e.components.aoetargeting.reticule.validcolour = { 0, 1, .5, 1 }
    e.components.aoetargeting.reticule.invalidcolour = { 0, .4, 0, 1 }
    e.components.aoetargeting.reticule.ease = true;
    e.components.aoetargeting.reticule.mouseenabled = true;
    e.projectiledelay = c;
    e.entity:SetPristine()
    if not TheWorld.ismastersim then
        return e
    end ;
    e.castsound = "dontstarve/common/lava_arena/spell/heal"
    e.heal_rate = 6;
    e:AddComponent("pkc_reticule_spawner")
    e.components.pkc_reticule_spawner:Setup(unpack({ "aoefriendlytarget", 0.9 }))
    e:AddComponent("aoespell")
    e.components.aoespell:SetAOESpell(m)
    e.components.aoespell:SetSpellType("heal")
    e:AddComponent("equippable")
    e.components.equippable:SetOnEquip(d)
    e.components.equippable:SetOnUnequip(g)
    e:AddComponent("inspectable")
    e:AddComponent("inventoryitem")
    e.components.inventoryitem.imagename = "healingstaff"
    e:AddComponent("pkc_rechargeable")
    e.components.pkc_rechargeable:SetRechargeTime(24)
    e:AddComponent("weapon")
    e.components.weapon:SetDamage(10)
    e.components.weapon:SetRange(10, 20)
    e.components.weapon:SetProjectile("forge_blossom_projectile")
    e.components.weapon:SetDamageType(DAMAGETYPES.MAGIC)
    e.components.weapon:SetOnProjectileLaunch(s)
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
return CustomPrefab("pkc_livingstaff", x, a, b, nil, "images/inventoryimages.xml", "healingstaff.tex", TUNING.THE_FORGE_ITEM_PACK.LIVINGSTAFF, "swap_healingstaff", "common_hand")