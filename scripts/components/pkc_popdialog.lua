--@name pkc_popdialog
--@description 简单弹框组件
--@author redpig
--@date 2016-11-20

local json = require "json"
local PopupDialogScreen = require("screens/popupdialog")
local Text = require "widgets/text"

return Class(function(self, inst)
	self.inst = inst
	self.data = nil
	self._show = net_bool(self.inst.GUID, "message._show", "showdirty")
	self._data = net_string(self.inst.GUID, "message._data", "datadirty")

	--客机获取数据
	local function OnDataDirty(inst)
		self.data = json.decode(self._data:value())
	end
	
	--客机显示
	local function OnShowDirty(inst)
		local data = json.decode(self._data:value())
		if data.type then
			if data.type == WIN_POPDIALOG then --胜利弹窗
				if data.winPlayers and next(data.winPlayers) ~= nil then
					local winPlayers = data.winPlayers
					local isWinner = false
					for userid, _ in pairs(winPlayers) do
						if ThePlayer.userid == userid then
							isWinner = true
							break
						end
					end
					local title = ""
					local button = ""
					if isWinner then
						title = PKC_SPEECH.WINDIALOG_VICTORY_TITLE
						button = PKC_SPEECH.WINDIALOG_WIN_BUTTON
					else
						title = PKC_SPEECH.WINDIALOG_FAILURE_TITLE
						button = PKC_SPEECH.WINDIALOG_FAILED_BUTTON
					end
					local screen = PopupDialogScreen(title, data.message, { { text = button, cb = function() TheFrontEnd:PopScreen() end } })
					TheFrontEnd:PushScreen( screen )

					local Namespace = "pkc_popDialog"
					local Action = "showWinDialog"
					inst:DoTaskInTime(0, function()
						SendModRPCToServer( MOD_RPC[Namespace][Action], self._data:value())
					end)
				end
			--elseif data.type == WIN_POPDIALOG then
			end 
		end
	end
	
	--设置客机回调的监听
	if not TheWorld.ismastersim then
		self.inst:ListenForEvent("datadirty", OnDataDirty)
		self.inst:ListenForEvent("showdirty", OnShowDirty)
	end
	
	--设置弹窗数据
	function self:setData(data)
		self.data = json.encode(data)
		self._data:set(json.encode(data))
	end
	
	--显示弹窗
	function self:show()		
		local data = json.decode(self.data)
		if data.type then
			if data.type == WIN_POPDIALOG then
				self:makeWinDialog()
			--elseif data.type == WIN_POPDIALOG then
			end
		end
	end
	
	--胜利弹窗
	function self:makeWinDialog()
		self._show:set(true) --触发客机调用
		local Namespace = "pkc_popDialog"
		local Action = "showWinDialog"
		if TheWorld.ismastersim and ThePlayer and not ThePlayer.hasShowWinDialog then
			ThePlayer.hasShowWinDialog = true
			MOD_RPC_HANDLERS[Namespace][MOD_RPC[Namespace][Action].id](ThePlayer, self.data)
		end
	end

end)