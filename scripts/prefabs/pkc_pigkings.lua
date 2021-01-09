--
-- 重写猪王们
-- Author: RedPig
-- Date: 2016/11/01
--

local assets =
{
    Asset("ANIM", "anim/pig_king.zip"),
    Asset("SOUND", "sound/pig.fsb"),
	Asset("ANIM", "anim/pigkingbig.zip"),
	Asset("ANIM", "anim/pigkingred.zip"),
	Asset("ANIM", "anim/pigkinglong.zip"),
	Asset("ANIM", "anim/pigkingcui.zip"),
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

--礼物列表
local giftsTable = {
	redgem = 30,
	bluegem = 30,
	pigskin = 30,
	livinglog = 10,
	silk = 100,
	poop = 200,
	spidergland = 50,
	boards = 100,
	gears = 10,
	walrus_tusk = 5,
	papyrus = 50,
	tentaclespots = 20,
	beefalowool = 30,
	cutreeds = 50,
	feather_robin = 50,
	feather_crow = 50,
	feather_robin_winter = 50,
	feather_canary = 50,
	stinger = 100,
	durian = 50,
	dragonfruit = 50,
	wormlight = 30,
	turf_carpetfloor = 200,
	turf_checkerfloor = 200,
	horn = 20,
	krampus_sack = 1,
	nightmarefuel = 100,
	healingsalve = 150,
	bandage = 100,
}

--扔礼物
local function throwGifts(inst)
	inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
    local gift_num = 2
	local gift_name = nil
    for k = 1, gift_num do
		gift_name = pkc_weightedChoose(giftsTable)
        local nug = SpawnPrefab(gift_name)
        local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 5.5, 0)
        
        nug.Transform:SetPosition(pt:Get())
        local down = TheCamera:GetDownVec()
        local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        local sp = math.random() * 4 + 2
        nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))
    end
end

--猪王的恩惠
local function morningFunny(inst)
	inst.AnimState:PlayAnimation("cointoss")
	inst.happy = false
	inst.endhappytask = nil
	inst.AnimState:PushAnimation("happy")
	inst.AnimState:PushAnimation("idle", true)
	inst:DoTaskInTime(20/30, throwGifts)
	inst:DoTaskInTime(1.5, onplayhappysound)
	inst.happy = true
	if inst.endhappytask ~= nil then
		inst.endhappytask:Cancel()
	end
	inst.endhappytask = inst:DoTaskInTime(1, onendhappytask)
end

local function OnIsNight(inst, isnight)
    if isnight then
        inst.components.trader:Disable()
        inst.AnimState:PlayAnimation("sleep_pre")
        inst.AnimState:PushAnimation("sleep_loop", true)
		if inst.Light then
			inst.Light:Enable(true)
		end
    else
		if inst.Light then
			inst.Light:Enable(false)
		end
        inst.components.trader:Enable()
        inst.AnimState:PlayAnimation("sleep_pst")
        inst.AnimState:PushAnimation("idle", true)
		--猪王的恩惠
		inst:DoTaskInTime(5, function()
			if inst then
				if inst.components.talker then
					inst.components.talker:Say(PKC_SPEECH.PIGKING.CHAT[math.random(#(PKC_SPEECH.PIGKING.CHAT))])
				end
				morningFunny(inst)
			end
		end)
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

--遭受攻击时调用
local function attacked_fn(inst, data)
	--敢打我，群起而攻之
	inst.components.combat:ShareTarget(data.attacker, 30,
	function(dude) 
		return (dude:HasTag("eyeturret") or dude:HasTag("pig")) and dude.components.pkc_group and inst.components.pkc_group 
		and dude.components.pkc_group:getChooseGroup() == inst.components.pkc_group:getChooseGroup() 
	end,
	45)
	--猪王被攻击时提示玩家
	if not inst.isUnderAttack then
		for _, player in pairs(AllPlayers) do 
			if player and player.components.pkc_group and inst.components.pkc_group 
			and player.components.pkc_group:getChooseGroup() == inst.components.pkc_group:getChooseGroup()
			then
				player:DoTaskInTime(0, function ()	
					if player and player.components.talker then
						player.components.talker:Say(PKC_SPEECH.PIGKING.SPEECH2)
					end
				end)
			end
		end
		inst.isUnderAttack = true
		inst:DoTaskInTime(math.random(4, 8), function()
			inst.isUnderAttack = false
		end)
	end
end

--死亡
local function death_fn(inst)
--	if inst and inst.components.maprevealer then
--		--local beKilledKing = inst.components.pkc_group:getChooseGroup() or 0
--		--TheWorld:PushEvent("pkc_kingbekilled", {inst = inst, king = beKilledKing})
--		inst.components.maprevealer:Stop()
--		if inst.icon ~= nil then
--			inst.icon:Remove()
--			inst.icon = nil
--		end
--	end
end

--显示猪王保护范围
local function showRangeIndicator(inst, scale)
	inst:DoTaskInTime(.5, function ()	
		local pos = Point(inst.Transform:GetWorldPosition())
		local indicators = TheSim:FindEntities(pos.x, pos.y, pos.z, 2, {"pkc_range_indicator"})
		for _, v in pairs(indicators) do
			if v then
				v:Remove()
				v = nil
			end
		end
		inst.rangeIndicator = SpawnPrefab("pkc_range")
		if inst.rangeIndicator then
			--local currentscale = inst.rangeIndicator.Transform:GetScale()
			inst.rangeIndicator.Transform:SetScale(1 * scale, 1 * scale, 1 * scale)
			inst.rangeIndicator.Transform:SetPosition(pos.x, pos.y, pos.z)
		end
	end)
end

--删除猪王时调用
local function onPigkingRemove(inst)
	local pos = Point(inst.Transform:GetWorldPosition())
	local range_indicators = TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"pkc_range_indicator"})
	for i,v in ipairs(range_indicators) do
		if v:IsValid() then
			v:Remove()
		end
	end
end

--升级附近的猪人
local function upgradeNearPigman(inst, level)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 100, {"pkc_pigman"})
	for _, pigman in pairs(ents) do
		if pigman and not pigman:HasTag("burnt") then
			local scale = 1 + 0.05 * level
			local damage = PKC_PIGMAN_DAMAGE + (0.1 * PKC_PIGMAN_DAMAGE) * level
			local health = PKC_PIGMAN_HEALTH + (0.1 * PKC_PIGMAN_HEALTH) * level
			local attack_period = PKC_PIGMAN_ATTACKPERIOD - 0.02 * level
			pigman.Transform:SetScale(scale, scale, scale)
			local fx1 = SpawnPrefab("small_puff")
			if fx1 then
				fx1.Transform:SetScale(2, 2, 2)
				fx1.Transform:SetPosition(Vector3(pigman.Transform:GetWorldPosition()):Get())
			end
			--pigman:AddTag("pkc_level"..level)
			pigman.pkc_level = level
			if pigman.components.combat then
				 pigman.components.combat:SetDefaultDamage(damage)
				 pigman.components.combat:SetAttackPeriod(attack_period)
			end
			if pigman.components.health then
				 pigman.components.health:SetMaxHealth(health)
			end
		end
	end
end

--猪王升级时调用
local function onLevelUp(inst, data)
	if inst and data.pigking and data.level then
		if PIGKING_LEVEL_CONSTANT[data.level] then
			inst.Transform:SetScale(0.8 + 0.1 * data.level, 0.8 + 0.1 * data.level, 0.8 + 0.1 * data.level)
			showRangeIndicator(inst, PIGKING_LEVEL_CONSTANT[data.level].RANGE_SCALE)
			inst:DoTaskInTime(0, function()
				if inst then
					--说话
					if inst.components.talker then
						inst.components.talker:Say(PKC_SPEECH.PIGKING.SPEECH3)
					end
					--恩惠
					morningFunny(inst)
					--特效
					local x, y, z = inst.Transform:GetWorldPosition()
					local fx = SpawnPrefab("emote_fx")
					if fx then
						fx.Transform:SetPosition(x, y+2.2, z)
						local pigkingscale = inst.Transform:GetScale()
						local currentscale = fx.Transform:GetScale()
						fx.Transform:SetScale(currentscale*pigkingscale*2.5, currentscale*pigkingscale*2.5, currentscale*pigkingscale*2.5)
					end
					--增加生命值
					if inst and inst.components.health and not inst.components.health:IsDead() then
						local health_percent = inst.components.health:GetPercent()
						if health_percent and inst.initMaxHealth then
							inst.components.health:SetMaxHealth(inst.initMaxHealth + (PIGKING_HEALTH/10) * data.level)
							inst.components.health:SetPercent(health_percent)
							upgradeNearPigman(inst, data.level)
						end
					end
					--print("pigking max health:"..inst.components.health.maxhealth)
					--print("pigking current health:"..inst.components.health.currenthealth)
				end
		end)
		end
	end
end

--掉落
local pigking_loot_table = {"meat","meat","meat","meat","meat","meat","meat","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget",}

local function mapinit(inst)
	if inst.icon == nil and not inst:HasTag("burnt") then
		inst.icon = SpawnPrefab("globalmapicon")
		inst.icon.MiniMapEntity:SetIsFogRevealer(true)
		inst.icon:TrackEntity(inst)
	end
end

--local PigKingSpeechTable = {
--	"猪王的保护范围！",
--	"我们需要升级猪王获得更多的土地！",
--	"我们需要升级猪王获得更强的猪人战士！",
--	"获得足够的分数可以升级猪王！",
--}
--
----点击猪王时调用
--local function onGetStatus(self, viewer)
--	local pigking = self.inst
--	pigking:DoTaskInTime(0, function ()
--		print("pkc_hastagking:"..pigking:HasTag("king"))
--		if pigking and pigking.components.talker then
--			pigking.components.talker:Say(PigKingSpeechTable[math.random(#PigKingSpeechTable)])
--		end
--	end)
--	return nil
--end

local function fn(group_id, build, name)
    local inst = CreateEntity()
	
	--添加头部显示组件
	--inst:AddComponent("pkc_headshow")
	
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
	--inst.MiniMapEntity:SetCanUseCache(false)
	--inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst.DynamicShadow:SetSize(10, 5)

    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst:AddTag("king")
	inst:AddTag("pig")
	inst:AddTag("eyeturret")
	inst:AddTag("character")
	--inst:AddTag("maprevealer")

    inst.AnimState:SetBank("Pig_King")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst.entity:SetPristine()

	--发光
	inst.entity:AddLight() 
	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(.6)
	inst.Light:SetRadius(4)
	--inst.Light:Enable(false)

	--设置阵营
	inst:AddComponent("pkc_group")
	inst.components.pkc_group:setChooseGroup(group_id)
	inst:AddComponent("talker")
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("trader")
	
	if PIGKING_HEALTH ~= -1 then
		--让猪王具备生命
		inst:AddComponent("pkc_addhealth")
		inst.components.pkc_addhealth:setMaxHealth(PIGKING_HEALTH) --设置最大生命值
		inst.components.pkc_addhealth:setOnHealthDelta(healthdelta_fn) --监听生命变化
		inst.components.pkc_addhealth:setOnAttackedFn(attacked_fn) --监听被攻击
		inst.components.pkc_addhealth:setDropLoot(pigking_loot_table) --设置掉落
		inst.components.pkc_addhealth:setDeathFn(death_fn) --监听死亡
		if inst.components.health then
			inst.initMaxHealth = inst.components.health.maxhealth
			inst.components.health:StartRegen(40, 5) --回血
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
	
	--显示猪王保护范围
	showRangeIndicator(inst, PIGKING_LEVEL_CONSTANT[1].RANGE_SCALE)
	
	--名字
	inst:AddComponent("inspectable")
	inst:AddComponent("named")
	inst.components.named:SetName(name)
	
	--猪王升级
	inst:AddComponent("pkc_levelup")
	inst.components.pkc_levelup:setLevelNum(10)
	inst.components.pkc_levelup:init()
	--监听猪王升级
	inst:ListenForEvent("pkc_pigkingLevelUp", onLevelUp)
	
	--监听被攻击
	--inst:ListenForEvent("attacked", onAttacked)
	--监听被删除
	inst:ListenForEvent("onremove", onPigkingRemove)
	
	--头部显示
	--inst.components.pkc_headshow:setHeadText(name.."<4352/5000>")
	--inst.components.pkc_headshow:setHeadColor(PKC_GROUP_INFOS.REDPIG.head_color)
	--inst.components.pkc_headshow:setChoose(true)

	--inst:AddComponent("maprevealer")
	--inst:DoTaskInTime(0, mapinit)

    return inst
end

--TEST
local function caculDistBetweenPigKingAndPlayer(inst)
	inst:DoPeriodicTask(3, function()
		local player = TheSim:FindFirstEntityWithTag("player")
		if player then
			local dist = inst:GetPosition():Dist(player:GetPosition()) 
			if dist then
				print("-----dist: "..dist)
			else
				print("-----dist: null")
			end
		else
			print("-----no player!!!!!")
		end
	end)
end

local function bigpigFn()
	local inst = fn(GROUP_BIGPIG_ID, "pigkingbig", "大猪猪")
	if not TheWorld.ismastersim then
        return inst
    end
	inst.components.inspectable:SetDescription("大猪猪爱吃肉！")
	inst:AddTag("bigpig")
	inst:AddTag("pkc_group1")
	inst.pkc_group_id = GROUP_BIGPIG_ID
	--发光
	local r, p, g = HexToPercentColor(PKC_GROUP_INFOS.BIGPIG.color)
	inst.Light:SetColour(r, p, g)
	inst.Light:Enable(false)
				
	return inst
end

local function redpigFn()
	local inst = fn(GROUP_REDPIG_ID, "pigkingred", "小红猪")
	if not TheWorld.ismastersim then
        return inst
    end
	inst.components.inspectable:SetDescription("万恶的小红猪！")
	inst:AddTag("redpig")
	inst:AddTag("pkc_group2")
	inst.pkc_group_id = GROUP_REDPIG_ID
	--发光
	local r, p, g = HexToPercentColor(PKC_GROUP_INFOS.REDPIG.color)
	inst.Light:SetColour(r, p, g)
	inst.Light:Enable(false)
	
	return inst
end

local function longpigFn()
	local inst = fn(GROUP_LONGPIG_ID, "pigkinglong", "龙猪猪")
	if not TheWorld.ismastersim then
       return inst
    end
	inst.components.inspectable:SetDescription("绿绿的龙猪猪！")
	inst:AddTag("longpig")
	inst:AddTag("pkc_group3")
	inst.pkc_group_id = GROUP_LONGPIG_ID
	--发光
	local r, p, g = HexToPercentColor(PKC_GROUP_INFOS.LONGPIG.color)
	inst.Light:SetColour(r, p, g)
	inst.Light:Enable(false)
	
	return inst
end

local function cuipigFn()
	local inst = fn(GROUP_CUIPIG_ID, "pigkingcui", "崔猪猪")
	if not TheWorld.ismastersim then
        return inst
    end
	inst.components.inspectable:SetDescription("可爱的崔猪猪！")
	inst:AddTag("cuipig")
	inst:AddTag("pkc_group4")
	inst.pkc_group_id = GROUP_CUIPIG_ID
	--发光
	local r, p, g = HexToPercentColor(PKC_GROUP_INFOS.CUIPIG.color)
	inst.Light:SetColour(r, p, g)
	inst.Light:Enable(false)
	
	return inst
end

return 
Prefab("pkc_bigpig", bigpigFn, assets, prefabs),
Prefab("pkc_redpig", redpigFn, assets, prefabs),
Prefab("pkc_longpig", longpigFn, assets, prefabs),
Prefab("pkc_cuipig", cuipigFn, assets, prefabs)
