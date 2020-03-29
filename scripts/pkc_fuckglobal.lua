--
-- 去Global
-- Author: 大猪猪
-- Date: 2016/10/03
--

--local function FuckGlobalUsingMetatable()
--	GLOBAL.setmetatable(env, {
--		__index = function(t, k)
--			if k ~= "PrefabFiles" and k ~= "Assets" and k ~= "clothing_exclude" then
--				return GLOBAL[k] and GLOBAL[k] or nil
--			end
--		end,
--	})
--end
--FuckGlobalUsingMetatable()

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})