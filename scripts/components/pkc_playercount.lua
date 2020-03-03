--@name pkc_playercount
--@description 
--@author redpig
--@date 2016-11-20

local PKC_PLAYER_COUNT = Class(function(self, inst)
	self.inst = inst
	self._players = net_string(self.inst.GUID, "pkc_playercount._players", "_playersDirty")
	
end,
nil,
{
})

function PKC_PLAYER_COUNT:addPlayer()

end


function PKC_PLAYER_COUNT:OnSave()
	return
	{	

	}
end

function PKC_PLAYER_COUNT:OnLoad(data)
	if data ~= nil then
	end
end

return PKC_PLAYER_COUNT