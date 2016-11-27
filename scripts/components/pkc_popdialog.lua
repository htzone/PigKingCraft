--@name pkc_popdialog
--@description 简单弹框组件
--@auther redpig
--@date 2016-11-20

local PopupDialogScreen = require("screens/popupdialog")
local Text = require "widgets/text"

return Class(function(self, inst)
	self.inst = inst
	self.message = nil
	self.title = nil
	self.buttonText = nil
	self._message = net_string(self.inst.GUID, "message._message", "messagedirty")
	self._title = net_string(self.inst.GUID, "message._title", "titledirty")
	self._buttonText = net_string(self.inst.GUID, "message._buttonText", "buttonTextdirty")
	self._show = net_bool(self.inst.GUID, "message._show", "showdirty")

	local function OnMessageDirty(inst)
		self.message = self._message:value()
	end

	local function OnTitleDirty(inst)
		self.title = self._title:value()
	end
	
	local function OnButtonTextdirty(inst)
		self.buttonText = self._buttonText:value()
	end

	local function OnShowDirty(inst)
		--客机显示
		local screen = PopupDialogScreen(self._title:value(), self._message:value(), { { text = self._buttonText:value(), cb = function() TheFrontEnd:PopScreen() end } })
		TheFrontEnd:PushScreen( screen )
	end
	
	if not TheWorld.ismastersim then
		self.inst:ListenForEvent("messagedirty", OnMessageDirty)
		self.inst:ListenForEvent("titledirty", OnTitleDirty)
		self.inst:ListenForEvent("buttonTextdirty", OnButtonTextdirty)
		self.inst:ListenForEvent("showdirty", OnShowDirty)
	end
	
	--设置标题
	function self:setTitle(title)
		self.title = title
		self._title:set(title)
	end

	--设置内容
	function self:setMessage(message)
		self.message = message
		self._message:set(message)
	end
	
	--设置按钮文字
	function self:setButtonText(text)
		self.buttonText = text
		self._buttonText:set(text)
	end
	
	function self:show()
		local screen = PopupDialogScreen(self.title, self.message, { { text = self.buttonText, cb = function() TheFrontEnd:PopScreen() end } })
		TheFrontEnd:PushScreen( screen )
		self._show:set(true)
	end

end)