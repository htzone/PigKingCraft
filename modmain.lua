--@name 猪王争霸（PigKingCraft）
--@description MOD入口
--@auther 大猪猪，RedPig
--@date 2016-10-23

PrefabFiles = {
"pkc_bigpig",
"pkc_redpig",
}

local require = GLOBAL.require
--自定义工具函数（常用的工具函数放这里）
require "pkc_utils" 
--全局变量（全局变量放这里）
modimport("scripts/pkc_global") 
--世界初始化
modimport("scripts/init/pkc_worldinit") 
--玩家初始化
modimport("scripts/init/pkc_playerinit") 
--阵营选择
modimport("scripts/init/pkc_choosegroup") 
--基地生成
modimport("scripts/init/pkc_produecebase")
