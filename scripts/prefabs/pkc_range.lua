--
-- 领地范围显示
-- Author: RedPig
-- Date: 2016/11/01
--

local assets=
{
	Asset("ANIM", "anim/firefighter_range.zip")    
}

local RANGE_INDICATOR_SCALE = 1

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	trans:SetScale(RANGE_INDICATOR_SCALE, RANGE_INDICATOR_SCALE, RANGE_INDICATOR_SCALE)
	inst.entity:AddNetwork()
	
	if not TheWorld.ismastersim then
		return inst
    end

    inst.entity:SetPristine()
	
    anim:SetBank("firefighter_placement")
    anim:SetBuild("firefighter_range")
    anim:PlayAnimation("idle")
    
	anim:SetOrientation(ANIM_ORIENTATION.OnGround)
    anim:SetLayer(LAYER_BACKGROUND)
    anim:SetSortOrder(3)
	
	inst.persists = false
    inst:AddTag("FX")
	inst:AddTag("pkc_range_indicator")

	--inst:DoTaskInTime(PIGKING_RANGE_SHOW_TIME, function() inst:Remove() end)
    return inst
end

return Prefab( "pkc_range", fn, assets) 