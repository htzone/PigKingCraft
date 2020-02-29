--@name pkc_title
--@description 头部名字
--@auther 大猪猪
--@date 2016-11-05

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