--
-- 快速采集
-- Author: 大猪猪
-- Date: 2016/10/23
--
GLOBAL.PKC_IS_FAST_HAND = GetModConfigData("is_fast_hand")
if GLOBAL.PKC_IS_FAST_HAND then
    modimport("scripts/mods/scripts/pkc_fasthand_server")
    modimport("scripts/mods/scripts/pkc_fasthand_client")
end


