--@name 猪王争霸（PigKingCraft）
--@description MOD入口

--扩展和完善PVP玩法，欢迎加入<猪人联盟>，QQ群--575726583

--自定义Prefab
PrefabFiles = {
"pkc_bigpig",
"pkc_redpig",
"pkc_longpig",
"pkc_cuipig",
"pkc_title",
}

local require = GLOBAL.require
--自定义工具函数（常用的工具函数放这里）
require "pkc_utils" 
--全局变量（全局变量放这里）
modimport("scripts/pkc_global")
--对话设定
modimport("scripts/pkc_speech")
--分数设定
modimport("scripts/pkc_gamescore")
--世界初始化
modimport("scripts/init/pkc_worldinit") 
--玩家初始化
modimport("scripts/init/pkc_playerinit")
--Prefab初始化
modimport("scripts/init/pkc_prefabinit") 
--RPC处理
modimport("scripts/init/pkc_rpchandler")
--阵营选择
modimport("scripts/init/pkc_choosegroup") 
--基地生成
modimport("scripts/init/pkc_producebase")
--约束条件设定
modimport("scripts/init/pkc_rules")
