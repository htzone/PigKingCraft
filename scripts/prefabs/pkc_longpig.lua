--@name pkc_redpig
--@description 红猪首领
--@author RedPig
--@date 2016-11-01

local assets =
{
    Asset("ANIM", "anim/pig_king.zip"),
    Asset("SOUND", "sound/pig.fsb"),
	Asset("ANIM", "anim/pigkinglong.zip"),
}

local prefabs =
{
    "goldnugget",
}

local function ontradeforgold(inst, item)
    inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
    
    for k = 1, item.components.tradable.goldvalue do
        local nug = SpawnPrefab("goldnugget")
        local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 4.5, 0)
        
        nug.Transform:SetPosition(pt:Get())
        local down = TheCamera:GetDownVec()
        local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        --local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
        local sp = math.random() * 4 + 2
        nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))
    end
end

local function onplayhappysound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
end

local function onendhappytask(inst)
    inst.happy = false
    inst.endhappytask = nil
end

--从玩家那里获得物品
local function OnGetItemFromPlayer(inst, giver, item)
	if item and (containsKey(GAME_SCORE.GIVE, item.prefab) or item.components.tradable.goldvalue > 0) then
		local addScore = GAME_SCORE.GIVE[item.prefab]
		TheWorld:PushEvent("pkc_giveScoreItem", { getter = inst, giver = giver, item = item,  addScore = addScore})
		if item.components.tradable.goldvalue > 0 then
			inst.AnimState:PlayAnimation("cointoss")
		end
		inst.happy = false
		inst.endhappytask = nil
        inst.AnimState:PushAnimation("happy")
		inst.AnimState:PushAnimation("idle", true)
		if item.components.tradable.goldvalue > 0 then
			inst:DoTaskInTime(20/30, ontradeforgold, item)
			inst:DoTaskInTime(1.5, onplayhappysound)
		end
        inst.happy = true
        if inst.endhappytask ~= nil then
            inst.endhappytask:Cancel()
        end
        inst.endhappytask = inst:DoTaskInTime(1, onendhappytask)
	end
end

local function OnRefuseItem(inst, giver, item)
    inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingReject")
    inst.AnimState:PlayAnimation("unimpressed")
    inst.AnimState:PushAnimation("idle", true)
    inst.happy = false
end

local function AcceptTest(inst, item)
	return containsKey(GAME_SCORE.GIVE, item.prefab) or item.components.tradable.goldvalue > 0
end

local function OnIsNight(inst, isnight)
    if isnight then
        inst.components.trader:Disable()
        inst.AnimState:PlayAnimation("sleep_pre")
        inst.AnimState:PushAnimation("sleep_loop", true)
    else
        inst.components.trader:Enable()
        inst.AnimState:PlayAnimation("sleep_pst")
        inst.AnimState:PushAnimation("idle", true)
    end
end

--被攻击时播放动画
local function healthdelta_fn(inst, data)
	if inst and data then
		if data.newpercent > 0 and data.newpercent < data.oldpercent then
			inst.AnimState:PlayAnimation("happy")
			inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingReject")
		end
		if data.newpercent == 0 then
			inst.AnimState:PlayAnimation("sleep_pre")
			inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
		end
	end
end

--被攻击时让猪人群殴之
local function attacked_fn(inst, data)
	local attacker = data and data.attacker
	if attacker then
		if inst.components.combat:CanTarget(attacker) and not attacker:HasTag("pig") then
			inst.components.combat:ShareTarget(attacker, 100, function(dude)
				return dude:HasTag("pig")	
			end, 40)
		end
	end
end

--死亡
local function death_fn(inst)
	if inst then
	end
end

--掉落
local pigking_loot_table = {"meat","meat","meat","meat","meat","meat","meat","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget",}

local function fn()
    local inst = CreateEntity()

	--设置阵营
	inst:AddComponent("pkc_group")
	inst.components.pkc_group:setChooseGroup(GROUP_LONGPIG_ID)
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2, .5)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("pigking.png")
    inst.MiniMapEntity:SetPriority(1)

    inst.DynamicShadow:SetSize(10, 5)

    inst.Transform:SetScale(1, 1, 1)

    inst:AddTag("king")
	inst:AddTag("longpig")
	inst:AddTag("pkc_group3")
	inst:AddTag("pig")
	inst:AddTag("character")
    inst.AnimState:SetBank("Pig_King")
    inst.AnimState:SetBuild("pigkinglong")
    inst.AnimState:PlayAnimation("idle", true)

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("trader")
	
	--设置颜色
--	local r, g, b = HexToPercentColor(PKC_GROUP_INFOS.LONGPIG.color)
--	inst.AnimState:SetMultColour(r, g, b, 1)
	if PIGKING_HEALTH ~= -1 then
		--让猪王具备生命
		inst:AddComponent("pkc_addhealth")
		inst.components.pkc_addhealth:setMaxHealth(PIGKING_HEALTH) --设置最大生命值
		inst.components.pkc_addhealth:setOnHealthDelta(healthdelta_fn) --监听生命变化
		inst.components.pkc_addhealth:setOnAttackedFn(attacked_fn) --监听被攻击
		inst.components.pkc_addhealth:setDropLoot(pigking_loot_table) --设置掉落
		inst.components.pkc_addhealth:setDeathFn(death_fn) --监听死亡
		if inst.components.health then
			inst.components.health:StartRegen(100, 100)
		end
	end
	
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst:WatchWorldState("isnight", OnIsNight)
    OnIsNight(inst, TheWorld.state.isnight)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if inst.components.trader and inst.components.trader.enabled then
            OnRefuseItem(inst)
            return true
        end
        return false
    end)
	inst.components.inspectable:SetDescription("保卫龙猪猪！")
	inst:AddComponent("named")
	inst.components.named:SetName("龙猪猪")

    return inst
end

return Prefab("pkc_longpig", fn, assets, prefabs)