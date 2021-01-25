local a = { Asset("ANIM", "anim/lavaarena_hit_sparks_fx.zip") }
local function b()
    local c = CreateEntity()
    c.entity:AddTransform()
    c.entity:AddAnimState()
    c.entity:AddNetwork()
    c:AddTag("FX")
    c.AnimState:SetBank("hits_sparks")
    c.AnimState:SetBuild("lavaarena_hit_sparks_fx")
    c.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    c.AnimState:SetFinalOffset(1)
    c.entity:SetPristine()
    if not TheWorld.ismastersim then
        return c
    end ;
    c.SetPosition = function(c, d, e)
        local f = (d:GetPosition() - e:GetPosition()):GetNormalized() * (e.Physics ~= nil and e.Physics:GetRadius() or 1)
        f.y = f.y + 1 + math.random(-5, 5) / 10;
        c.Transform:SetPosition((e:GetPosition() + f):Get())
        c.AnimState:PlayAnimation("hit_3")
        c.AnimState:SetScale(d:GetRotation() > 0 and -.7 or .7, .7)
    end;
    c.SetPiercing = function(c, g, e)
        local f = (g:GetPosition() - e:GetPosition()):GetNormalized() * (e.Physics ~= nil and e.Physics:GetRadius() or 1)
        f.y = f.y + 1 + math.random(-5, 5) / 10;
        c.Transform:SetPosition((e:GetPosition() + f):Get())
        c.AnimState:PlayAnimation("hit_3")
        c.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        c.Transform:SetRotation(c:GetAngleToPoint(e:GetPosition():Get()) + 90)
    end;
    c.SetThrusting = function(c, g, e)
        local h = c:GetPosition()
        c.Transform:SetPosition(h.x, h.y + 1, h.z)
        c:SetPiercing(g, e)
    end;
    c.SetBounce = function(c, i)
        c.Transform:SetPosition(i:GetPosition():Get())
        c.AnimState:PlayAnimation("hit_2")
        c.AnimState:Hide("glow")
        c.AnimState:SetScale(i:GetRotation() > 0 and 1 or -1, 1)
    end;
    c:ListenForEvent("animover", c.Remove)
    c.OnLoad = c.Remove;
    return c
end;
return Prefab("pkc_weaponsparks_fx", b, a)