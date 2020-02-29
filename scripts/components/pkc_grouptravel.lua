--
-- Created by IntelliJ IDEA.
-- User: hetao
-- Date: 2017/2/18
-- Time: 23:02
-- To change this template use File | Settings | File Templates.
--

local default_dist_cost = 32
local max_sanity_cost = 15
local min_hunger_cost = 5
local sanity_cost_ratio = 20/75
local find_dist = (max_sanity_cost / sanity_cost_ratio - min_hunger_cost) * default_dist_cost

local ownershiptag = 'uid_private'
local traveltag = 'FastTravelling'
local FTSignTag = 'fast_travel'

local PKC_GROUPTRAVEL = Class(function(self, inst)
    self.inst = inst
    self.destinations = {}
    self.site = nil
    self.totalsites = 0
    self.currentplayer = nil
    self.traveltask = nil
    self.dist_cost = default_dist_cost
    self.inst:AddTag(FTSignTag)
    self.ownership = false
end)

local function IsNearDanger(inst)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return true
    end
    local burnable = inst.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return true
    end
    if inst:HasTag("spiderwhisperer") then
        return FindEntity(inst, 10,
            function(target)
                return (target.components.combat ~= nil and target.components.combat.target == inst)
                        or (not (target:HasTag("player") or target:HasTag("spider"))
                        and (target:HasTag("monster") or target:HasTag("pig")))
            end,
            nil, nil, { "monster", "pig", "_combat" }) ~= nil
    end
    return FindEntity(inst, 10,
        function(target)
            return (target.components.combat ~= nil and target.components.combat.target == inst)
                    or (target:HasTag("monster") and not target:HasTag("player"))
        end,
        nil, nil, { "monster", "_combat" }) ~= nil
end

function PKC_GROUPTRAVEL:ListDestination(traveller)
    if traveller == nil then return	end
    if not traveller.components.pkc_group then return end
    local groupId = traveller.components.pkc_group:getChooseGroup()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local dests = TheSim:FindEntities(x, y, z, find_dist, {FTSignTag, "pkc_group"..groupId})
    local dest = {}

    for k,v in pairs(dests) do
        if v ~= self.inst and v.components.pkc_grouptravel and not (v.components.pkc_grouptravel.ownership and v:HasTag(ownershiptag) and traveller.userid ~= nil and not v:HasTag('uid_'..traveller.userid)) then
            table.insert(dest, v)
        end
    end

    self.destinations = dest
    self.site = self.site or #dest
    self.totalsites = #dest
end

function PKC_GROUPTRAVEL:SelectDestination(traveller)
    if traveller == nil then return end
    if not traveller.components.pkc_group or self.inst.pkc_group_id == nil then return end

    self:ListDestination(traveller)
    local comment = self.inst.components.talker
    local talk = traveller.components.talker

    if self.ownership and self.inst:HasTag(ownershiptag) and traveller.userid ~= nil and not self.inst:HasTag('uid_'..traveller.userid) then
        if comment then comment:Say("这属于私人财产")
        elseif talk then talk:Say("这个属于私人财产") end
        return
    elseif self.inst.pkc_group_id ~= traveller.components.pkc_group:getChooseGroup() then
        if comment then comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH3)
        elseif talk then talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH3) end
        return
    elseif self.totalsites < 1 then
        if comment then comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH4)
        elseif talk then talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH4) end
        return
    end

    -- Restart travel tasks
    traveller:RemoveTag(traveltag)
    if traveller.untraveltask ~= nil then
        traveller.untraveltask:Cancel()
        traveller.untraveltask = nil
    end
    if self.traveltask ~= nil then
        self.traveltask:Cancel()
        self.traveltask = nil
    end
    if self.traveltask1 ~= nil then
        self.traveltask1:Cancel()
        self.traveltask1 = nil
    end
    if self.traveltask2 ~= nil then
        self.traveltask2:Cancel()
        self.traveltask2 = nil
    end
    if self.traveltask3 ~= nil then
        self.traveltask3:Cancel()
        self.traveltask3 = nil
    end
    if self.traveltask4 ~= nil then
        self.traveltask4:Cancel()
        self.traveltask4 = nil
    end
    if self.traveltask5 ~= nil then
        self.traveltask5:Cancel()
        self.traveltask5 = nil
    end
    if self.traveltask6 ~= nil then
        self.traveltask6:Cancel()
        self.traveltask6 = nil
    end
    if self.traveltask7 ~= nil then
        self.traveltask7:Cancel()
        self.traveltask7 = nil
    end
    if self.traveltask8 ~= nil then
        self.traveltask8:Cancel()
        self.traveltask8 = nil
    end
    if self.traveltask9 ~= nil then
        self.traveltask9:Cancel()
        self.traveltask9 = nil
    end
    if self.traveltask10 ~= nil then
        self.traveltask10:Cancel()
        self.traveltask10 = nil
    end

    -- Select next site
    if self.currentplayer ~= nil and self.currentplayer == traveller then
        self.site = self.site + 1
        if self.site > self.totalsites then self.site = 1 end
    end
    self.currentplayer = traveller
    local destination = self.destinations[self.site]
    if destination == nil then return end

    -- If next site is self, try next next site
    if destination == self.inst then
        self.site = self.site + 1
        if self.site > self.totalsites then self.site = 1 end
        destination = self.destinations[self.site]
        if destination == self.inst then
            return
        end
    end

    -- Site information
    local desc = destination and destination.components.writeable and destination.components.writeable:GetText()
    local description = desc and string.format('"%s"', desc) or "Unknown Destination"
    local information = ""
    local cost_hunger = min_hunger_cost
    local cost_sanity = 0
    local xi,yi,zi = self.inst.Transform:GetWorldPosition()
    local xf,yf,zf = destination.Transform:GetWorldPosition()
    local dist = math.sqrt((xi-xf)^2 + (zi-zf)^2)

    if destination and destination.components.pkc_grouptravel then
        traveller:AddTag(traveltag)
        traveller.untraveltask = traveller:DoTaskInTime(15, function() traveller:RemoveTag(traveltag) end)
        cost_hunger = cost_hunger + math.ceil(dist / self.dist_cost)
        cost_sanity = cost_hunger * sanity_cost_ratio
        if TheWorld.state.season == "winter" then
            cost_sanity = cost_sanity * 1.25
        elseif TheWorld.state.season == "summer" then
            cost_sanity = cost_sanity * 0.75
        end

        information = "To: "..description.." ("..string.format("%.0f", self.site).."/"..string.format("%.0f", self.totalsites)..")".."\n".."饥饿消耗: "..string.format("%.0f", cost_hunger).."\n".."精神消耗: "..string.format("%.1f", cost_sanity)
        if comment then
            comment:Say(string.format(information),3)
        elseif talk then
            talk:Say(string.format(information),3)
        end

        self.traveltask = self.inst:DoTaskInTime(12, function()
            local travellers = TheSim:FindEntities(xi, yi, zi, 4, {traveltag,"player"},{"playerghost"})

            for k, who in pairs(travellers) do
                if destination == nil or not destination:IsValid() then
                    if comment then comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH6)
                    elseif talk then talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH6) end
                elseif who == nil or (who.components.health and who.components.health:IsDead()) then
                    if comment then comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH7) end
                elseif IsNearDanger(who) then
                    if talk then talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH8)
                    elseif comment then comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH8) end
                elseif destination.components.pkc_grouptravel.ownership and destination:HasTag(ownershiptag) and who.userid ~= nil and not destination:HasTag('uid_'..who.userid) then
                    if comment then comment:Say("私人领地，不接受传送")
                    elseif talk then talk:Say("私人领地，不接受传送") end
                elseif who.components.hunger and who.components.hunger.current >= cost_hunger and who.components.sanity and who.components.sanity.current >= cost_sanity then
                    who.components.hunger:DoDelta(-cost_hunger)
                    who.components.sanity:DoDelta(-cost_sanity)
                    if who.Physics ~= nil then
                        who.Physics:Teleport(xf-1, 0, zf)
                    else
                        who.Transform:SetPosition(xf-1, 0, zf)
                    end

                    -- follow
                    if who.components.leader and who.components.leader.followers then
                        for kf,vf in pairs(who.components.leader.followers) do
                            if kf.Physics ~= nil then
                                kf.Physics:Teleport(xf+1, 0, zf)
                            else
                                kf.Transform:SetPosition(xf+1, 0, zf)
                            end
                        end
                    end

                    local inventory  = who.components.inventory
                    if inventory then
                        for ki, vi in pairs(inventory.itemslots) do
                            if vi.components.leader and vi.components.leader.followers then
                                for kif,vif in pairs(vi.components.leader.followers) do
                                    if kif.Physics ~= nil then
                                        kif.Physics:Teleport(xf, 0, zf+1)
                                    else
                                        kif.Transform:SetPosition(xf, 0, zf+1)
                                    end
                                end
                            end
                        end
                    end

                    local container = inventory:GetOverflowContainer()
                    if container then
                        for kb, vb in pairs(container.slots) do
                            if vb.components.leader and vb.components.leader.followers then
                                for kbf,vbf in pairs(vb.components.leader.followers) do
                                    if kbf.Physics ~= nil then
                                        kbf.Physics:Teleport(xf, 0, zf-1)
                                    else
                                        kbf.Transform:SetPosition(xf, 0, zf-1)
                                    end
                                end
                            end
                        end
                    end
                    -- /follow

                    traveller:RemoveTag(traveltag)
                    if traveller.untraveltask ~= nil then
                        traveller.untraveltask:Cancel()
                        traveller.untraveltask = nil
                    end
                else
                    if talk then talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH10)
                    elseif comment then comment:Say("别着急没到你呢") end
                end
            end
        end)
        self.traveltask10 = self.inst:DoTaskInTime(3, function() comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH12)
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask9 = self.inst:DoTaskInTime(4, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 9))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask8 = self.inst:DoTaskInTime(5, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 8))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask7 = self.inst:DoTaskInTime(6, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 7))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask6 = self.inst:DoTaskInTime(7, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 6))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask5 = self.inst:DoTaskInTime(8, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 5))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask4 = self.inst:DoTaskInTime(9, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 4))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask3 = self.inst:DoTaskInTime(10, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 3))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask2 = self.inst:DoTaskInTime(11, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 2))
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)
        self.traveltask1 = self.inst:DoTaskInTime(12, function() comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH11, 1), 1)
            self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end)

    elseif comment then
        comment:Say("目标无法传送")
    elseif talk then
        talk:Say("目标无法传送")
    end
end

return PKC_GROUPTRAVEL

