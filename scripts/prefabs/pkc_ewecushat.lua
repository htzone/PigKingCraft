local assets =
{ 
    Asset("ANIM", "anim/pkc_ewecushat.zip"),
    Asset("ANIM", "anim/ewecushat_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/pkc_ewecushat.xml"),
    Asset("IMAGE", "images/inventoryimages/pkc_ewecushat.tex"),
}

local prefabs = 
{
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "ewecushat_swap", "swap_hat")
	
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
end

local function OnUnequip(inst, owner) 

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
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pkc_ewecushat")
    inst.AnimState:SetBuild("pkc_ewecushat")
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
	
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMORWOOD, 0.85)
	
    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "pkc_ewecushat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pkc_ewecushat.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
	
	if TheSim:GetGameID()=="DST" or IsDLCEnabled(REIGN_OF_GIANTS) then
		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)
	end
	
    return inst
end


return  Prefab("common/inventory/pkc_ewecushat", fn, assets, prefabs)