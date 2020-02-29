--@name pkc_prefabinit
--@description prefab初始化
--@auther redpig
--@date 2016-10-23

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()

--获取当前的猪王等级
local function getPigkingLevel(pigkingId)
	local needLevelUpScore = GLOBAL.WIN_SCORE / 10
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
			local scale = 1 + 0.05 * level
			local damage = GLOBAL.PKC_PIGMAN_DAMAGE + (0.1 * GLOBAL.PKC_PIGMAN_DAMAGE) * level
			local health = GLOBAL.PKC_PIGMAN_HEALTH + (0.1 * GLOBAL.PKC_PIGMAN_HEALTH) * level
			local attack_period = GLOBAL.PKC_PIGMAN_ATTACKPERIOD - 0.02 * level
			inst.Transform:SetScale(scale, scale, scale)
			--inst:AddTag("pkc_level"..level)
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



