--
-- 玩家复活任务组件
-- Author: RedPig
-- Date: 2017/02/22
--

--让玩家在一段时间内无敌
local function makePlayerInvincible(player, timeDelay)
    if player and player.components.health and not player.components.health:IsDead() then
        if player.components.health.invincible == false then
            player.components.health:SetInvincible(true)
        end
        if player._fx == nil then
            player._fx = SpawnPrefab("forcefieldfx")
            if player._fx then
                player._fx.entity:SetParent(player.entity)
                player._fx.Transform:SetPosition(0, 0.2, 0)
            end
            player:DoTaskInTime(timeDelay, function()
                if player then
                    if player.components.health and player.components.health.invincible == true then
                        player.components.health:SetInvincible(false)
                    end
                    if player._fx then
                        player._fx:kill_fx()
                        player._fx:Remove()
                        player._fx = nil
                    end
                end
            end)
        end
    end
end

local PKC_PLAYER_REVIVE_TASK = Class(function(self, inst)
    self.inst = inst
    self.deathNum = 0
    self.reviveTime = -1

    if TheNet:GetIsServer() then
        --监听玩家死亡
        self.inst:ListenForEvent("death", function(inst)
            if inst then
                self.reviveTime = PLAYER_REVIVE_TIME + 10 * self.deathNum
                self.deathNum = self.deathNum + 1
                self:ExeReviveTask()
            end
        end)

        --监听玩家复活
        self.inst:ListenForEvent("respawnfromghost", function(inst, data)
            if inst then
                if inst.pkc_hasBeKilled then --重置死亡标记
                    inst.pkc_hasBeKilled = nil
                end
                inst.components.pkc_playerrevivetask.reviveTime = -1
                inst:DoTaskInTime(4.3, function()
                    makePlayerInvincible(inst, PKC_REVIVE_INVINCIBLE_TIME)
                end)
            end
        end)
    end
end, nil, {})

--复活计时任务
function PKC_PLAYER_REVIVE_TASK:ExeReviveTask()
    local inst = self.inst
    inst:DoTaskInTime(1, function()
        if inst then
            if self.reviveTime ~= nil and self.reviveTime > 1 then
                self.reviveTime = self.reviveTime - 1
                if inst.components.talker then
                    inst.components.talker:Say(string.format(PKC_SPEECH.REVIVE_TIPS1.SPEECH1, self.reviveTime, self.deathNum))
                end
                self:ExeReviveTask()
            else
                if not TheWorld:HasTag("cave") then
                    inst:DoTaskInTime(0, function()
                        if inst and inst.components.pkc_group and inst.components.pkc_group:getBasePos() ~= nil then
                            local x, y, z = unpack(inst.components.pkc_group:getBasePos())
                            inst.Physics:Teleport(x, 0, z)
                        end
                    end)
                    inst:DoTaskInTime(.5, function()
                        if inst and inst.components.talker then
                            inst.components.talker:Say(PKC_SPEECH.REVIVE_TIPS2)
                        end
                    end)
                    inst:DoTaskInTime(3, function()
                        if inst then
                            inst:PushEvent("respawnfromghost")
                        end
                    end)
                else
                    inst:PushEvent("respawnfromghost")
                end
            end
        end
    end)
end

function PKC_PLAYER_REVIVE_TASK:OnSave()
    return
    {
        deathNum = self.deathNum,
        reviveTime = self.reviveTime,
    }
end

function PKC_PLAYER_REVIVE_TASK:OnLoad(data)
    if data ~= nil then
        if data.deathNum ~= nil then
            self.deathNum = data.deathNum
        end
        if data.reviveTime ~= nil then
            self.reviveTime = data.reviveTime
            if self.reviveTime > 1 then
                self:ExeReviveTask()
            end
        end
    end
end

return PKC_PLAYER_REVIVE_TASK

