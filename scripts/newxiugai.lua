GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local armor_bramble =  GLOBAL.AllRecipes["armor_bramble"]
if armor_bramble  then
	armor_bramble.ingredients	= {Ingredient("livinglog", 6), Ingredient("boneshard", 6)}
end	

TUNING.SHADOWWAXWELL_LIFE = 150
TUNING.WOLFGANG_HUNGER = 250
TUNING.WOLFGANG_START_HUNGER = 167
TUNING.WOLFGANG_START_MIGHTY_THRESH = 187.5
TUNING.WOLFGANG_END_MIGHTY_THRESH = 183
TUNING.WOLFGANG_START_WIMPY_THRESH = 83
TUNING.WOLFGANG_END_WIMPY_THRESH = 87.5

TUNING.WOLFGANG_HEALTH_MIGHTY = 220
TUNING.WOLFGANG_HEALTH_NORMAL = 180
TUNING.WOLFGANG_HEALTH_WIMPY = 150

TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX = 1.5
TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN = 1.25
TUNING.WOLFGANG_ATTACKMULT_NORMAL = 1
TUNING.WOLFGANG_ATTACKMULT_WIMPY_MAX = .75
TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN = .5
		

local function EndBlockSoulHealFX(v)
    v.blocksoulhealfxtask = nil
end

local function DoHeal(inst)
    local targets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < TUNING.WORTOX_SOULHEAL_RANGE * TUNING.WORTOX_SOULHEAL_RANGE then
            table.insert(targets, v)
        end
    end
    if #targets > 0 then
        local amt = 10 - math.min(8, #targets) + 1
        for i, v in ipairs(targets) do
            --always heal, but don't stack visual fx
            v.components.health:DoDelta(amt, nil, inst.prefab)
            if v.blocksoulhealfxtask == nil then
                v.blocksoulhealfxtask = v:DoTaskInTime(.5, EndBlockSoulHealFX)
                local fx = SpawnPrefab("wortox_soul_heal_fx")
                fx.entity:AddFollower():FollowSymbol(v.GUID, v.components.combat.hiteffectsymbol, 0, -50, 0)
                fx:Setup(v)
            end
        end
    end
end

local wortox_soul_common = require "prefabs/wortox_soul_common"
if wortox_soul_common ~= nil then
	wortox_soul_common.DoHeal = DoHeal
end