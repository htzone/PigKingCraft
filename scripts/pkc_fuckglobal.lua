--@name 草翻GOLBAL
--@description 原有全局变量和函数不用加GLOBAL前缀
--@author 大猪猪
--@date 2016-10-23

local function FuckGlobalUsingMetatable()
	GLOBAL.setmetatable(env, {
		__index = function(t, k)
			if k ~= "PrefabFiles" and k ~= "Assets" and k ~= "clothing_exclude" then
				return GLOBAL[k] and GLOBAL[k] or nil
			end
		end,
	})
end

--FuckGlobalUsingMetatable()
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})