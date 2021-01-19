local assets =
{ 
    Asset("ANIM", "anim/pkc_spartahelmut1.zip"),
    Asset("ANIM", "anim/spartahelmut_swap2.zip"),

    Asset("ATLAS", "images/inventoryimages/pkc_spartahelmut1.xml"),
    Asset("IMAGE", "images/inventoryimages/pkc_spartahelmut.tex"),
}

local prefabs = 
{
}

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "spartahelmut_swap2", "swap_hat")
	
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
	
	if owner and not owner:HasTag("spartan") then
		owner:AddTag("spartan")
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
	if owner and owner:HasTag("spartan") then
		owner:RemoveTag("spartan")
	end
end

--local function spellFn(inst, target, pos)
--    local owner = inst.components.inventoryitem.owner
--    if owner then
--        print("pkc owner:"..tostring(owner.prefab))
--    end
--    if target then
--        print("pkc target:"..tostring(target.prefab))
--    end
--end

local function fn()

    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pkc_spartahelmut")
    inst.AnimState:SetBuild("pkc_spartahelmut1")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("spartahat")

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
	
	inst:AddComponent("tradable")
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "pkc_spartahelmut"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pkc_spartahelmut1.xml"
		
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
	
	if TheSim:GetGameID()=="DST" or IsDLCEnabled(REIGN_OF_GIANTS) then
		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)
	end

    --inst:AddComponent("spellcaster")
    --inst.components.spellcaster.canuseontargets = true
    --inst.components.spellcaster.canonlyuseonworkable = true
    --inst.components.spellcaster.canonlyuseoncombat = true
    --inst.components.spellcaster.quickcast = true
    --inst.components.spellcaster:SetSpellFn(spellFn)

    return inst
end

return  Prefab("common/inventory/pkc_spartahelmut", fn, assets, prefabs)