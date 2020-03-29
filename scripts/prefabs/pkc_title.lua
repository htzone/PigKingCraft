--
-- 头部标识
-- Author: 大猪猪
-- Date: 2016/11/01
--

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	
	local label = inst.entity:AddLabel()
	label:SetFont(NUMBERFONT)
	label:SetFontSize(30)
	label:SetWorldOffset(0, 3, 0)
	label:SetColour(1, 1, 1)
	label:SetText("")
	label:Enable(true)

	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	
	inst.entity:SetPristine()
	--inst.lable = label

	if not TheWorld.ismastersim then
		return inst
	end	

	inst.persists = false
	
	return inst
end

return Prefab("pkc_title", fn)