--@name 猪王争霸（PigKingCraft）
--@description MOD主入口

--[[
写个MOD真TM累，写完了既没有钱还要被骂，哎呀，好气啊╮(╯_╰)╭
有人说为什么要写，老子喜欢你管的着么(┙>∧<)┙へ┻┻
扩展和完善PVP玩法，欢迎加入QQ群--575726583，诚招会写MOD和画画的大神_(:3 」∠)_
]]--

--自定义Prefab
PrefabFiles = {
"pkc_pigkings",
"pkc_title",
"pkc_pigs",
"pkc_pighouses",
"pkc_eyeturret",
"pkc_range",
}

local require = GLOBAL.require
--自定义工具函数（常用的工具函数放这里）
require "pkc_utils" 
--全局变量（全局变量放这里）
modimport("scripts/pkc_global")
--全局常量
modimport("scripts/pkc_constant")
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
--规则设定
modimport("scripts/init/pkc_rules")
