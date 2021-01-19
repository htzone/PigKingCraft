
local function ontraveller(self, traveller)
	self.inst.replica.pkc_travelable:SetTraveller(traveller)
end

local default_dist_cost = 32
local max_sanity_cost = 15
local min_hunger_cost = 5
local sanity_cost_ratio = 20 / 75
local find_dist = (max_sanity_cost / sanity_cost_ratio - min_hunger_cost) * default_dist_cost

local ownershiptag = "uid_private"

local Travelable =
	Class(
	function(self, inst)
		self.inst = inst
		self.inst:AddTag("pkc_travelable")

		self.dist_cost = default_dist_cost
		self.traveller = nil
		self.destinations = {}
		self.travellers = {}

		self.onclosepopups = function(traveller)
			if traveller == self.traveller then
				self:EndTravel()
			end
		end

		self.generatorfn = nil
	end,
	nil,
	{
		traveller = ontraveller
	}
)

local function IsNearDanger(traveller)
	local hounded = TheWorld.components.hounded
	if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
		return true
	end
	local burnable = traveller.components.burnable
	if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
		return true
	end
	--if traveller:HasTag("spiderwhisperer") then
	--	return FindEntity(
	--		traveller,
	--		10,
	--		function(target)
	--			return (target.components.combat ~= nil and target.components.combat.target == traveller)
	--					or (not (target:HasTag("player") or target:HasTag("spider"))
	--					and (target:HasTag("monster") or target:HasTag("pig")))
	--		end,
	--		nil,
	--		nil,
	--		{"monster", "pig", "_combat"}
	--	) ~= nil
	--end
	--local entity = FindEntity(
	--	traveller,
	--	10,
	--	function(target)
	--		return (target.components.combat ~= nil and target.components.combat.target == traveller)
	--				or (target:HasTag("monster") and not target:HasTag("player"))
	--				or (not target:HasTag("playerghost")
	--				and target.components.pkc_group and traveller.components.pkc_group
	--				and not traveller.components.pkc_group:isSameGroup(target))
	--	end,
	--	nil,
	--	nil,
	--	{"monster", "_combat"})

	local entity = FindEntity(
		traveller,
		10,
		function(target)
			return (target.components.combat ~= nil and target.components.combat.target == traveller)
					or (target.components.pkc_group and traveller.components.pkc_group
					and not traveller.components.pkc_group:isSameGroup(target))
		end,
		nil,
		nil,
		{"monster", "_combat"})
	return entity ~= nil
end

function Travelable:ListDestination(traveller)
	if not traveller.components.pkc_group then return end
	local groupId = traveller.components.pkc_group:getChooseGroup()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local dests = TheSim:FindEntities(x, y, z, find_dist, {"pkc_travelable", "pkc_group"..groupId})
	self.destinations = {}

	for _, v in pairs(dests) do
		if v and v.components.pkc_travelable then
			table.insert(self.destinations, v)
		elseif v and v:HasTag("player") and v ~= traveller
				and v.components.pkc_group and traveller.components.pkc_group
				and v.components.pkc_group:getChooseGroup() == traveller.components.pkc_group:getChooseGroup() then
			table.insert(self.destinations, v)
		end
	end

	self.totalsites = #self.destinations
	self.site = self.totalsites
end

-- 入口：开始传送
function Travelable:BeginTravel(traveller)
	local comment = self.inst.components.talker

	-- 旅行前的一系列检查工作
	if not traveller then -- 没有旅行者
		if comment then
			comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH4)
		end
		return
	end
	-- 摸了不是自己队伍的路牌
	local talk = traveller.components.talker
	if traveller.components.pkc_group and self.inst.pkc_group_id
			and traveller.components.pkc_group:getChooseGroup() ~= self.inst.pkc_group_id then
		if talk then talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH3) end
		return
	end
	-- 目前有人在传送还轮不到你
	if self.traveller then
		if comment then
			comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH15)
		elseif talk then
			talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH15)
		end
		return
	elseif IsNearDanger(traveller) then -- 附近有危险不能传送
		if talk then
			talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH16)
		elseif comment then
			comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH16)
		end
		return
	end

	local isInTask = false
	for _, v in pairs(self.travellers) do
		if v == traveller then
			isInTask = true -- 是否正处在传送状态
			break
		end
	end

	if self.inst.teleportCoolDown == nil or isInTask then
		self.inst:StartUpdatingComponent(self)
		-- 找到所有需要传送的点
		self:ListDestination(traveller)
		self:MakeInfos()
		self:CancelTravel(traveller)
		self.travellers = {}
		self.traveller = traveller
		self.inst:ListenForEvent("ms_closepopups", self.onclosepopups, traveller)
		self.inst:ListenForEvent("onremove", self.onclosepopups, traveller)

		if traveller.HUD ~= nil then
			self.screen = traveller.HUD:ShowTravelScreen(self.inst)
		end
	else
		self:CancelTravel(traveller)
		self:Travel(traveller, self.site)
	end
end

function Travelable:MakeInfos()
	local infos = ""
	for i, destination in ipairs(self.destinations) do
		local name = nil
		if destination:HasTag("player") then
			name = destination.name
			print("player name:"..tostring(destination.name))
			print("player color:"..tostring(getPlayerColorByUserId(destination.userid)))
		else
			name = destination.components.writeable and destination.components.writeable:GetText() or "~nil"
		end
		local cost_hunger = min_hunger_cost
		local cost_sanity = 0
		local xi, yi, zi = self.inst.Transform:GetWorldPosition()
		local xf, yf, zf = destination.Transform:GetWorldPosition()
		local dist = math.sqrt((xi - xf) ^ 2 + (zi - zf) ^ 2)

		cost_hunger = cost_hunger + math.ceil(dist / self.dist_cost)
		cost_sanity = cost_hunger * sanity_cost_ratio
		if TheWorld.state.season == "winter" then
			cost_sanity = cost_sanity * 1.25
		elseif TheWorld.state.season == "summer" then
			cost_sanity = cost_sanity * 0.75
		end

		if destination == self.inst then
			cost_hunger = 0
			cost_sanity = 0
		end

		local isPlayer = destination:HasTag("player")
		infos = infos .. (infos == "" and "" or "\n") .. i .. "\t" .. name
				.. "\t" .. cost_hunger
				.. "\t" .. cost_sanity
				.. "\t" .. tostring(isPlayer)
	end
	self.inst.replica.pkc_travelable:SetDestInfos(infos)
end

local function getPlayersToTravel(self, operator)
	local players = {}
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local nearPlayers = TheSim:FindEntities(x, y, z, 5)
	for _, v in ipairs(nearPlayers) do
		if v and v:HasTag("player") and not v:HasTag("playerghost")
				and operator.components.pkc_group and v.components.pkc_group
				and operator.components.pkc_group:isSameGroup(v) then
			table.insert(players, v)
		end
	end
	return players
end

local function getCoolDownTime(self, destination)
	if destination then
		if destination:HasTag("player") then
			return PLAYER_TELEPORT_TIME
		else
			return SIGN_TELEPORT_TIME
		end
	end
	return 10
end

local function canTeleport(destination, comment, talk)
	local canTeleport = false
	if destination and destination:HasTag("pkc_travelable") then
		if destination:HasTag("player") then
			if destination:HasTag("playerghost") then
				canTeleport = false
				if comment then
					comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH23)
				elseif talk then
					talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH23)
				end
			else
				canTeleport = true
			end
		else
			canTeleport = true
		end
	end
	return canTeleport
end

local function travelTask(self, traveller, destination, comment, talk, cost_hunger, cost_sanity)
	self.inst:DoTaskInTime(1, function()
		if self.inst.teleportCoolDown then
			if self.inst.teleportCoolDown > 1 then
				self.inst.teleportCoolDown = self.inst.teleportCoolDown - 1
				if comment then
					comment:Say(string.format(PKC_SPEECH.GROUP_SIGN.SPEECH20, self.inst.teleportCoolDown))
					self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
				end
				if math.random(10) / 10 >= 0.9 and destination and destination:HasTag("player")
						and destination.components.talker then
					destination.components.talker:Say(PKC_SPEECH.GROUP_SIGN.SPEECH21)
				end
				travelTask(self, traveller, destination, comment, talk, cost_hunger, cost_sanity)
			else
				if canTeleport(destination) then
					local travellers = getPlayersToTravel(self, traveller)
					for _, who in pairs(travellers) do
						if destination == nil or not destination:IsValid() then
							if comment then
								comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH22)
							elseif talk then
								talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH22)
							end
						elseif who == nil or (who.components.health and who.components.health:IsDead()) then
							if comment then
								comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH23)
							end
						elseif not who:IsNear(self.inst, 10) then
							if comment then
								comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH24)
							end
						elseif IsNearDanger(who) then
							if talk then
								talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH25)
							elseif comment then
								comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH25)
							end
						elseif who.components.hunger and who.components.hunger.current >= cost_hunger
								and who.components.sanity and who.components.sanity.current >= cost_sanity then
							-- /follow
							who.components.hunger:DoDelta(-cost_hunger)
							who.components.sanity:DoDelta(-cost_sanity)
							pkc_teleport(who, destination, -1)
							-- follow
							if who.components.leader and who.components.leader.followers then
								for kf, vf in pairs(who.components.leader.followers) do
									pkc_teleport(kf, destination, 1)
								end
							end

							local inventory = who.components.inventory
							if inventory then
								for ki, vi in pairs(inventory.itemslots) do
									if vi.components.leader and vi.components.leader.followers then
										for kif, vif in pairs(vi.components.leader.followers) do
											pkc_teleport(kif, destination, 1)
										end
									end
								end
							end

							local container = inventory:GetOverflowContainer()
							if container then
								for kb, vb in pairs(container.slots) do
									if vb.components.leader and vb.components.leader.followers then
										for kbf, vbf in pairs(vb.components.leader.followers) do
											pkc_teleport(kbf, destination, -1)
										end
									end
								end
							end
						else
							if talk then
								talk:Say(PKC_SPEECH.GROUP_SIGN.SPEECH19)
							elseif comment then
								comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH19)
							end
						end
					end
					self.travellers = {}
					self.inst.teleportCoolDown = nil
				end
			end
		end
	end)
end

local function teleportToTarget(self, traveller, destination, cost_hunger, cost_sanity)
	local comment = self.inst.components.talker
	local talk = traveller.components.talker
	if self.inst.teleportCoolDown == nil then
		self.inst.teleportCoolDown = getCoolDownTime(self, destination)
		self.inst:DoTaskInTime(0, function()
			if comment then
				comment:Say(PKC_SPEECH.GROUP_SIGN.SPEECH18)
				self.inst.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
			end
		end)
		travelTask(self, traveller, destination, comment, talk, cost_hunger, cost_sanity)
	end
end

function Travelable:Travel(traveller, index)
	local destination = self.destinations[index]
	if traveller and destination then
		self.site = index
		local comment = self.inst.components.talker
		local talk = traveller.components.talker

		-- Site information
		local desc
		if destination:HasTag("player") then
			desc = destination and destination.name or "无名"
		else
			desc = destination and destination.components.writeable and destination.components.writeable:GetText()
		end
		local description = desc and string.format('"%s"', desc) or PKC_SPEECH.GROUP_SIGN.SPEECH17
		local information = ""
		local cost_hunger = min_hunger_cost
		local cost_sanity = 0
		local xi, _, zi = self.inst.Transform:GetWorldPosition()
		local xf, _, zf = destination.Transform:GetWorldPosition()
		local dist = math.sqrt((xi - xf) ^ 2 + (zi - zf) ^ 2)

		if destination and destination:HasTag("pkc_travelable") then
			table.insert(self.travellers, traveller)

			cost_hunger = cost_hunger + math.ceil(dist / self.dist_cost)
			cost_sanity = cost_hunger * sanity_cost_ratio
			if TheWorld.state.season == "winter" then
				cost_sanity = cost_sanity * 1.25
			elseif TheWorld.state.season == "summer" then
				cost_sanity = cost_sanity * 0.75
			end

			information = "去: " .. description .. " (" .. string.format("%.0f", self.site) .. "/"
					.. string.format("%.0f", self.totalsites) .. ")" .. "\n" .. "饥饿: "
					.. string.format("%.0f", cost_hunger) .. "\n" .. "理智: "
					.. string.format("%.1f", cost_sanity)
			if comment then
				comment:Say(string.format(information), 3)
			elseif talk then
				talk:Say(string.format(information), 3)
			end

			teleportToTarget(self, traveller, destination, cost_hunger, cost_sanity)
		elseif comment then
			comment:Say("目的地无法到达.")
		elseif talk then
			talk:Say("目的地无法到达.")
		end
	end
	self:EndTravel()
end

function Travelable:CancelTravel(traveller)
	self.inst.teleportCoolDown = nil
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
end

function Travelable:EndTravel()
	if self.traveller ~= nil then
		self.inst:StopUpdatingComponent(self)

		if self.screen ~= nil then
			self.traveller.HUD:CloseTravelScreen()
			self.screen = nil
		end

		self.inst:RemoveEventCallback("ms_closepopups", self.onclosepopups, self.traveller)
		self.inst:RemoveEventCallback("onremove", self.onclosepopups, self.traveller)

		if IsXB1() then
			if self.traveller:HasTag("player") and self.traveller:GetDisplayName() then
				local ClientObjs = TheNet:GetClientTable()
				if ClientObjs ~= nil and #ClientObjs > 0 then
					for i, v in ipairs(ClientObjs) do
						if self.traveller:GetDisplayName() == v.name then
							self.netid = v.netid
							break
						end
					end
				end
			end
		end

		self.traveller = nil
	elseif self.screen ~= nil then
		--Should not have screen and no traveller, but just in case...
		if self.screen.inst:IsValid() then
			self.screen:Kill()
		end
		self.screen = nil
	end
end

--------------------------------------------------------------------------
--Check for auto-closing conditions
--------------------------------------------------------------------------

function Travelable:OnUpdate(dt)
	if self.traveller == nil then
		self.inst:StopUpdatingComponent(self)
	elseif (self.traveller.components.rider ~= nil and self.traveller.components.rider:IsRiding()) or not (self.traveller:IsNear(self.inst, 3) and CanEntitySeeTarget(self.traveller, self.inst)) then
		self:EndTravel()
	end
end

--------------------------------------------------------------------------

function Travelable:OnRemoveFromEntity()
	self:EndTravel()
	self.inst:RemoveTag("pkc_travelable")
end

Travelable.OnRemoveEntity = Travelable.EndTravel

return Travelable
