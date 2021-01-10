--
-- 角色平衡组件
-- Author: RedPig
-- Date: 2017/2/23
--

--设置人物移动速度
local function setRunSpeed(player, speed)
    if player and player.components.locomotor then
        if player.components.locomotor.runspeed then
            player.components.locomotor.runspeed = speed
        end
    end
end

--平衡老奶奶
local function balanceWickerbottom(self)
    --self.inst.components.builder:UnlockRecipe("book_sleep")
    if not self.inst.components.sanity then
        self.inst:AddComponent("sanity")
    end
    self.inst.components.sanity.dapperness = TUNING.DAPPERNESS_MED_LARGE
end

--平衡小丑
local function balancewWes(self)
    setRunSpeed(self.inst, 7.5)
    if not self.inst.components.sanityaura then
        self.inst:AddComponent("sanityaura")
    end
    self.inst.components.sanityaura.aura = TUNING.SANITYAURA_MED
end

local PKC_CHARACTER_BALANCE = Class(function(self, inst)
    self.inst = inst
    self:Balance()
    self.inst:ListenForEvent("respawnfromghost", function(inst, data)
        if inst then
            inst:DoTaskInTime(5, function()
                if inst and not inst.components.pkc_characterbalance then
                    inst:AddComponent("pkc_characterbalance")
                end
                inst.components.pkc_characterbalance:Balance()
            end)
        end
    end)
end, nil, {})

function PKC_CHARACTER_BALANCE:Balance()
    if self.inst then
        if self.inst.prefab == "wickerbottom" then --老奶奶
            balanceWickerbottom(self)
        elseif self.inst.prefab == "wes" then --小丑
            balancewWes(self)
        end
    end
end

function PKC_CHARACTER_BALANCE:OnSave()
    return
    {

    }
end

function PKC_CHARACTER_BALANCE:OnLoad(data)
    if data ~= nil then

    end
end

return PKC_CHARACTER_BALANCE
