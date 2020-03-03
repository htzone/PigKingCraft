--
-- author: RedPig
-- Date: 2017/2/23
--

--重写死亡掉落物品方法
--物品栏掉落30%
--背包掉落30%
--装备栏全掉落
--local function getItemslotsSize(self)
--	local itemslotsSize = 0
--	for i=1, self.maxslots do
--		local v = self.itemslots[i]
--		if v ~= nil then
--			itemslotsSize = itemslotsSize + 1
--		end
--	end
--	return itemslotsSize
--end
--
--local function getContainerlotsSize(self)
--
--end
--物品栏掉落30%
--	local itemslotsSize = getItemslotsSize(self)
--	local needDropitemslotsNum = math.ceil(itemslotsSize * 0.5)

--
--	for i=1, self.maxslots do
--		if i > needDropItemsNum then
--			break
--		end
--		local v = self.itemslots[math.random(1, self.maxslots)]
--		if v ~= nil then
--			self:DropItem(v, true, true)
--			i = i + 1
--		end
--	end

--背包掉落
--local containerlotsSize = 0
--local container = self:GetOverflowContainer()
--if container then
--    containerlotsSize = #(container.slots)
--    local needDropContainerNum = math.floor(containerlotsSize * 0.3)
--    local j = 0
--    for _, v in pairs(container.slots) do
--        if v ~= nil then
--            if j < needDropContainerNum then
--                self:DropItem(v, true, true)
--                j = j + 1
--            else
--                break
--            end
--        end
--    end
--end

local function updateWorld(inst)
    if GLOBAL.TheWorld.state.cycles >= 3 and not inst.regenerate then
        inst:DoTaskInTime(1, function(inst)
            GLOBAL.TheNet:Announce("世界4秒后重置啦！！！！")
        end)
        inst:DoTaskInTime(5, function(inst)
            --c_regenerateshard(true)
            inst.regenerate = true
            TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = ThePlayer, portalid = 1, worldid = 1 })
        end)
    end
end

local function addregenerate(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(inst) end)
    end
end

AddPrefabPostInit("world", addregenerate)
