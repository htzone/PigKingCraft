--
-- 一些Prefab的初始化
-- Author: RedPig
-- Date: 2016/10/23
--

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--获取当前的猪王等级
local function getPigkingLevel(pigkingId)
	local needLevelUpScore = GLOBAL.WIN_SCORE / #(GLOBAL.PIGKING_LEVEL_CONSTANT)
	local currentLevel = 1
	if pigkingId ==  GLOBAL.GROUP_BIGPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP1_SCORE
		currentLevel = math.floor(currentScore / needLevelUpScore) + 1
	elseif pigkingId ==  GLOBAL.GROUP_REDPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP2_SCORE
		currentLevel = math.floor(currentScore / needLevelUpScore) + 1
	elseif pigkingId ==  GLOBAL.GROUP_LONGPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP3_SCORE
		currentLevel = math.floor(currentScore / needLevelUpScore) + 1
	elseif pigkingId ==  GLOBAL.GROUP_CUIPIG_ID then
		local currentScore = GLOBAL.GROUP_SCORE.GROUP4_SCORE
		currentLevel = math.floor(currentScore / needLevelUpScore) + 1
	end
	return currentLevel
end

--通过组件模拟prefab
local ComponentPrefabs = {
	"gravestone",
}

local function addComponent(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:AddComponent("pkc_prefabs")
	end
end

for _,v in pairs(ComponentPrefabs) do
	AddPrefabPostInit(v, addComponent) --组件实现的prefab,减少定义prefab的麻烦
end

--变大
local toBigTable = {
	{name = "deerclops", size = 1.5},
	{name = "moose", size = 1.5},
	{name = "bearger", size = 1.5},
}

local function toBig(inst, size)
	local mobSize = size or 1.5
	if inst and inst.Transform then
		local currentscale = inst.Transform:GetScale()
		if currentscale < 1.5 then
			inst.Transform:SetScale(currentscale * mobSize, currentscale * mobSize, currentscale * mobSize)
		end
	end	
end

for _, v in pairs(toBigTable) do
	AddPrefabPostInit(v.name, function(inst) toBig(inst, v.size) end)
end

local pkc_pigmans = {
"pkc_pigman_big",
"pkc_pigman_red",
"pkc_pigman_cui",
"pkc_pigman_long",
}

--猪人成长
local function grow(inst)
	if inst and inst.Transform then
		if inst.components.pkc_group then
			local level = getPigkingLevel(inst.components.pkc_group:getChooseGroup())
			local scale = 1 + 0.025 * level
			local damage = GLOBAL.PKC_PIGMAN_DAMAGE + (0.025 * GLOBAL.PKC_PIGMAN_DAMAGE) * level
			local health = GLOBAL.PKC_PIGMAN_HEALTH + (0.1 * GLOBAL.PKC_PIGMAN_HEALTH) * level
			local attack_period = GLOBAL.PKC_PIGMAN_ATTACKPERIOD - 0.01 * level
			inst.Transform:SetScale(scale, scale, scale)
			inst.pkc_level = level
			if inst.components.combat then
				 inst.components.combat:SetDefaultDamage(damage)
				 inst.components.combat:SetAttackPeriod(attack_period)
			end
			if inst.components.health then
				 inst.components.health:SetMaxHealth(health)
			end
		end
	end
end

for _, v in pairs(pkc_pigmans) do
	AddPrefabPostInit(v, grow)
end

--消除季节boss们之间的仇恨
local seasonBoss = {
	"deerclops",
	"bearger",
	"dragonfly",
	"moose",
}

local function seasonBossKeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target) and not target:HasTag("pkc_seasonboss")
end

local function changeForSeasonBoss(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:AddTag("pkc_seasonboss")
		inst:DoTaskInTime(1, function()
			if inst then
				if inst.prefab == "bearger" then
					--AOE伤害忽略
					function inst.components.combat:DoAreaAttack(target, range, weapon, validfn, stimuli)
						local hitcount = 0
						local x, y, z = target.Transform:GetWorldPosition()
						local ents = TheSim:FindEntities(x, y, z, range, { "_combat" }, {"pkc_seasonboss"})
						for i, ent in ipairs(ents) do
							if ent ~= target and
									ent ~= self.inst and
									self:IsValidTarget(ent) and
									(validfn == nil or validfn(ent)) then
								self.inst:PushEvent("onareaattackother", { target = target, weapon = weapon, stimuli = stimuli })
								ent.components.combat:GetAttacked(self.inst, self:CalcDamage(ent, weapon, self.areahitdamagepercent), weapon, stimuli)
								hitcount = hitcount + 1
							end
						end
						return hitcount
					end
				end
				inst.components.combat:SetKeepTargetFunction(seasonBossKeepTargetFn)
			end
		end)
	end
end

for _, v in pairs(seasonBoss) do
	AddPrefabPostInit(v, changeForSeasonBoss)
end

--让阿比盖尔不要攻击同盟
local function changeAbigailTarget(inst)
	if inst then
		if inst.components.combat and inst.components.aura and inst.auratest then
			local old_auratest = inst.auratest
			if not old_auratest then
				return
			end
			local function new_auratest(inst, target)
				local leader = inst.components.follower and inst.components.follower.leader or nil
				if target and leader
						and target.components.pkc_group and leader.components.pkc_group
						and target.components.pkc_group:getChooseGroup() == leader.components.pkc_group:getChooseGroup()
				then
					return false
				end
				return old_auratest(inst, target)
			end

			inst.components.combat:SetKeepTargetFunction(new_auratest)
			inst.components.aura.auratestfn = new_auratest
		end
	end
end
AddPrefabPostInit("abigail", changeAbigailTarget)

--增加怪物标签
local monster_list = {
	"merm",
	"tallbird"
}
local function setMonster(inst)
	if GLOBAL.TheWorld.ismastersim and inst then
		inst:AddTag("monster")
	end
end
for _, v in pairs(monster_list) do
	AddPrefabPostInit(v, setMonster)
end

--增加可交易属性
local tradable_item = {
	"poop",
}
local function addTradableAttr(item)
	if item and not item.components.tradable then
		item:AddComponent("tradable")
	end
end
for _, v in pairs(tradable_item) do
	AddPrefabPostInit(v, addTradableAttr)
end

--制造大箱子
local function PKC_LARGE_CHEST_CREATION(widgetanimbank, widgetpos, slot_x, slot_y, posslot_x, posslot_y)
	local params = {}
	params.pkc_largechest_big = {
		widget = {
			slotpos = {},
			animbank = widgetanimbank,
			animbuild = widgetanimbank,
			pos = widgetpos,
			side_align_tip = 160,
		},
		type = "chest",
	}
	params.pkc_largechest_red = {
		widget = {
			slotpos = {},
			animbank = widgetanimbank,
			animbuild = widgetanimbank,
			pos = widgetpos,
			side_align_tip = 160,
		},
		type = "chest",
	}
	params.pkc_largechest_cui = {
		widget = {
			slotpos = {},
			animbank = widgetanimbank,
			animbuild = widgetanimbank,
			pos = widgetpos,
			side_align_tip = 160,
		},
		type = "chest",
	}
	params.pkc_largechest_long = {
		widget = {
			slotpos = {},
			animbank = widgetanimbank,
			animbuild = widgetanimbank,
			pos = widgetpos,
			side_align_tip = 160,
		},
		type = "chest",
	}

	for y = slot_y, 0, -1 do
		for x = 0, slot_x do
			table.insert(params.pkc_largechest_big.widget.slotpos, GLOBAL.Vector3(80 * x - 346 * 2 + posslot_x, 80 * y - 100 * 2 + posslot_y, 0))
			table.insert(params.pkc_largechest_red.widget.slotpos, GLOBAL.Vector3(80 * x - 346 * 2 + posslot_x, 80 * y - 100 * 2 + posslot_y, 0))
			table.insert(params.pkc_largechest_cui.widget.slotpos, GLOBAL.Vector3(80 * x - 346 * 2 + posslot_x, 80 * y - 100 * 2 + posslot_y, 0))
			table.insert(params.pkc_largechest_long.widget.slotpos, GLOBAL.Vector3(80 * x - 346 * 2 + posslot_x, 80 * y - 100 * 2 + posslot_y, 0))
		end
	end

	local containers = require "containers"
	containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.pkc_largechest_big.widget.slotpos ~= nil and #params.pkc_largechest_big.widget.slotpos or 0)

	local old_widgetsetup = containers.widgetsetup
	function containers.widgetsetup(container, prefab, ...)
		local pref = prefab or container.inst.prefab
		if pref == "pkc_largechest_big"
				or pref == "pkc_largechest_red"
				or pref == "pkc_largechest_cui"
				or pref == "pkc_largechest_long" then
			local t = params[pref]
			if t ~= nil then
				for k, v in pairs(t) do
					container[k] = v
				end
				container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
			end
		else
			return old_widgetsetup(container, prefab, ...)
		end
	end
end
PKC_LARGE_CHEST_CREATION("ui_chest_5x16", GLOBAL.Vector3(360 - (80 * 4.5), 160, 0), 15, 4, 91, 42)

--放置队伍专属的眼球塔
AddPrefabPostInit("eyeturret_item", function(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	if inst.components.deployable then
		local oldDeploy = inst.components.deployable.ondeploy
		inst.components.deployable.ondeploy = function(inst, pt, deployer)
			if deployer and deployer.components.pkc_group then
				local turret = SpawnPrefab("eyeturret")
				local groupId = deployer.components.pkc_group:getChooseGroup()
				if groupId == GROUP_BIGPIG_ID then
					turret = SpawnPrefab("pkc_eyeturret_big")
				elseif groupId == GROUP_REDPIG_ID then
					turret = SpawnPrefab("pkc_eyeturret_red")
				elseif groupId == GROUP_LONGPIG_ID then
					turret = SpawnPrefab("pkc_eyeturret_long")
				elseif groupId == GROUP_CUIPIG_ID then
					turret = SpawnPrefab("pkc_eyeturret_cui")
				end
				if turret ~= nil and turret.Physics and turret.SoundEmitter then
					turret.Physics:SetCollides(false)
					turret.Physics:Teleport(pt.x, 0, pt.z)
					turret.Physics:SetCollides(true)
					turret:syncanim("place")
					turret:syncanimpush("idle_loop", true)
					turret.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
					inst:Remove()
				end
			else
				return oldDeploy(inst, pt, deployer)
			end
		end
	end
end)

--将一部分猪人房变成猪人守卫图腾（减少野外猪人房的数量）
AddPrefabPostInit("pighouse", function(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	inst:DoTaskInTime(0.1, function()
		if inst and not inst:HasTag("burnt") then
			local randomVal = math.random()
			if randomVal < 0.5 then
				local x, y, z = inst.Transform:GetWorldPosition()
				if x and y and z then
					local b = SpawnPrefab("pkc_pigtorch")
					if b and b:IsValid() and b.Transform then
						b.Transform:SetPosition(x, y, z)
					end
					inst:Remove()
				end
			end
		end
	end)
end)

--添加猪人守卫标签
AddPrefabPostInit("pigguard", function(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	if inst then
		inst:AddTag("pkc_hostile")
		inst:AddTag("monster")
	end
end)

--远古遗迹不可拆
AddPrefabPostInit("ancient_altar", function(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	if inst and inst.components.workable then
		inst.components.workable:SetWorkable(false)
	end
end)

--远程武器效果修改
AddComponentPostInit("weapon", function(self, inst)
	self.OriginalLaunchProjectile = self.LaunchProjectile
	if GLOBAL.TheWorld.ismastersim == false then return; end

	function self:LaunchProjectile(attacker, target)
		if attacker:HasTag("pkc_hostile_boss") then
			if attacker.prefab == "pkc_mermking" then
				if self.projectile then
					if self.onprojectilelaunch then
						self.onprojectilelaunch(self.inst, attacker, target)
					end
					local proj = SpawnPrefab(self.projectile)
					if proj then
						inst:AddTag("projectile")
						proj.persists = false
						proj:AddComponent("projectile")
						proj.components.projectile:SetSpeed(25)
						proj.components.projectile:SetHoming(false)
						proj.components.projectile:SetHitDist(0.8)
						proj.components.projectile:SetOnHitFn(function()
							local x1, y1, z1 = proj.Transform:GetWorldPosition()
							local ents = TheSim:FindEntities(x1, y1, z1, 5)
							for _,obj in pairs(ents) do
								if obj and not obj:HasTag("pkc_hostile")
										and not obj:HasTag("merm")
										and not obj:HasTag("tentacle")
										and obj.components.freezable then
									obj.components.freezable:AddColdness(2)
									obj.components.freezable:SpawnShatterFX()
								end
							end
							proj:Remove()
						end)
						proj.components.projectile:SetOnMissFn(proj.Remove)
						proj.components.projectile:SetOnThrownFn(function() proj:ListenForEvent("entitysleep", proj.Remove) end)
						local currentscale = proj.Transform:GetScale()
						proj.Transform:SetScale(currentscale*1,currentscale*8,currentscale*1)
						proj:DoPeriodicTask(.1, function()
							if proj then
								local x, y, z = proj.Transform:GetWorldPosition()
								local fx = SpawnPrefab("icespike_fx_"..math.random(1,4))
								local currentscale = fx.Transform:GetScale()
								fx.Transform:SetScale(currentscale*1.5,currentscale*4,currentscale*1.5)
								fx.Transform:SetPosition(x, y, z)
							end
						end)

						proj:DoTaskInTime(1, function()
							proj:Remove()
						end)
						-----------------------
						if proj.components.projectile then
							proj.Transform:SetPosition(attacker.Transform:GetWorldPosition() )
							proj.components.projectile:Throw(self.inst, target, attacker)
						elseif proj.components.complexprojectile then
							proj.Transform:SetPosition( attacker.Transform:GetWorldPosition() )
							proj.components.complexprojectile:Launch(Vector3( target.Transform:GetWorldPosition() ), attacker, self.inst)
						end
					end
				end
				return nil
			elseif attacker.prefab == "pkc_pigguardking" then
				if self.projectile then
					if self.onprojectilelaunch then
						self.onprojectilelaunch(self.inst, attacker, target)
					end

					local proj = SpawnPrefab(self.projectile)
					--------------------------
					if proj then
						proj.AnimState:SetBank("monkey_projectile")
						proj.AnimState:SetBuild("monkey_projectile")
						proj.AnimState:PlayAnimation("idle")
						local currentscale = proj.Transform:GetScale()
						proj.Transform:SetScale(currentscale*1.5,currentscale*1.5,currentscale*1.5)
						inst:AddTag("projectile")
						proj.persists = false
						proj:AddComponent("projectile")
						proj.components.projectile:SetSpeed(18)
						proj.components.projectile:SetHoming(false)
						proj.components.projectile:SetHitDist(0.3)
						proj.components.projectile.range = POOP_BOMB_DIST
						proj.components.projectile:SetOnThrownFn(function() proj:ListenForEvent("entitysleep", proj.Remove) end)
						proj.components.projectile:SetOnHitFn(OnHit_piggurad)
						proj.components.projectile:SetOnMissFn(OnMiss_piggurad)

						-----------------------
						if proj.components.projectile then
							proj.Transform:SetPosition(attacker.Transform:GetWorldPosition() )
							proj.components.projectile:Throw(self.inst, target, attacker)
						elseif proj.components.complexprojectile then
							proj.Transform:SetPosition( attacker.Transform:GetWorldPosition() )
							proj.components.complexprojectile:Launch(Vector3( target.Transform:GetWorldPosition() ), attacker, self.inst)
						end
					end
				end
				return nil
			end

		end

		return self:OriginalLaunchProjectile(attacker, target)
	end
end)

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "prey" }
local function retargetfn(inst)
	return FindEntity(
			inst,
			TUNING.TENTACLE_ATTACK_DIST,
			function(guy)
				if guy:HasTag("pkc_hostile") then
					return false
				end
				return guy.prefab ~= inst.prefab
						and guy.entity:IsVisible()
						and not guy.components.health:IsDead()
						and (guy.components.combat.target == inst or
						guy:HasTag("character") or
						guy:HasTag("monster") or
						guy:HasTag("animal"))
			end,
			RETARGET_MUST_TAGS,
			RETARGET_CANT_TAGS)
end

local function shouldKeepTarget(inst, target)
	local oldKeepTargetFn = inst.components.combat.keeptargetfn
	if target:HasTag("pkc_hostile") then
		return false
	end
	return oldKeepTargetFn and oldKeepTargetFn(inst, target)
end

--更改触手仇恨
AddPrefabPostInit("tentacle", function(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	if inst then
		if inst.components.combat then
			inst.components.combat:SetRetargetFunction(GetRandomWithVariance(2, 0.5), retargetfn)
			local oldKeepTargetFn = inst.components.combat.keeptargetfn
			inst.components.combat:SetKeepTargetFunction(function(inst, target)
				if target:HasTag("pkc_hostile") then
					return false
				end
				return oldKeepTargetFn and oldKeepTargetFn(inst, target)
			end)
		end
	end
end)

