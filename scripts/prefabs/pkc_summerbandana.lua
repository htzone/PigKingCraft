local assets =
{ 
    Asset("ANIM", "anim/pkc_summerbandana.zip"),
    Asset("ANIM", "anim/summerbandana_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/pkc_summerbandana.xml"),
    Asset("IMAGE", "images/inventoryimages/pkc_summerbandana.tex"),
}

local prefabs = 
{
}

local function SummerBandana_OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "summerbandana_swap", "swap_hat")
	
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAT_HAIR")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")
	
	if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
        if TheSim:GetGameID()=="DST" then
			owner.AnimState:Show("HEAD_HAT")
		else
			owner.AnimState:Show("HEAD_HAIR")
		end
	end
	
	if inst.components.fueled then
		inst.components.fueled:StartConsuming()
	end
end

local function SummerBandana_OnUnequip(inst, owner) 

	if inst.components.fueled then
		inst.components.fueled:StopConsuming()
	end

    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        if TheSim:GetGameID()=="DST" then
			owner.AnimState:Hide("HEAD_HAT")
		else
			owner.AnimState:Hide("HEAD_HAIR")
		end
    end
end

local function fn()

    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pkc_summerbandana")
    inst.AnimState:SetBuild("pkc_summerbandana")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")

	if TheSim:GetGameID()=="DST" then
		inst.entity:AddNetwork()
		
		if not TheWorld.ismastersim then
			return inst
		end
		
		inst.entity:SetPristine()
		
	    MakeHauntableLaunch(inst)
	end
	
	inst:AddComponent("fueled")

	if TheSim:GetGameID()=="DST" then --Don't ask -M
		inst.components.fueled.fueltype = FUELTYPE.USAGE
	else
		inst.components.fueled.fueltype = "USAGE"
	end
	inst.components.fueled:InitializeFuelLevel(2500)
	inst.components.fueled:SetDepletedFn(inst.Remove)
	
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "pkc_summerbandana"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pkc_summerbandana.xml"
    
	if TheSim:GetGameID()=="DST" or IsDLCEnabled(REIGN_OF_GIANTS) then
		inst:AddComponent("insulator")
		inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
		inst.components.insulator:SetSummer()
	end
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(SummerBandana_OnEquip)
    inst.components.equippable:SetOnUnequip(SummerBandana_OnUnequip)

    return inst
end


return  Prefab("common/inventory/pkc_summerbandana", fn, assets, prefabs)