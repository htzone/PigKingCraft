--@name 猪王争霸（PigKingCraft）
--@description MOD主入口

--[[



                       ::
                      :;J7, :,                        ::;7:
                      ,ivYi, ,                       ;LLLFS:
                      :iv7Yi                       :7ri;j5PL
                     ,:ivYLvr                    ,ivrrirrY2X,
                     :;r@Wwz.7r:                :ivu@kexianli.
                    :iL7::,:::iiirii:ii;::::,,irvF7rvvLujL7ur
                   ri::,:,::i:iiiiiii:i:irrv177JX7rYXqZEkvv17
                ;i:, , ::::iirrririi:i:::iiir2XXvii;L8OGJr71i
              :,, ,,:   ,::ir@mingyi.irii:i:::j1jri7ZBOS7ivv,
                 ,::,    ::rv77iiiriii:iii:i::,rvLq@huhao.Li
             ,,      ,, ,:ir7ir::,:::i;ir:::i:i::rSGGYri712:
           :::  ,v7r:: ::rrv77:, ,, ,:i7rrii:::::, ir7ri7Lri
          ,     2OBBOi,iiir;r::        ,irriiii::,, ,iv7Luur:
        ,,     i78MBBi,:,:::,:,  :7FSL: ,iriii:::i::,,:rLqXv::
        :      iuMMP: :,:::,:ii;2GY7OBB0viiii:i:iii:i:::iJqL;::
       ,     ::::i   ,,,,, ::LuBBu BBBBBErii:i:i:i:i:i:i:r77ii
      ,       :       , ,,:::rruBZ1MBBqi, :,,,:::,::::::iiriri:
     ,               ,,,,::::i:  @arqiao.       ,:,, ,:::ii;i7:
    :,       rjujLYLi   ,,:::::,:::::::::,,   ,:i,:,,,,,::i:iii
    ::      BBBBBBBBB0,    ,,::: , ,:::::: ,      ,,,, ,,:::::::
    i,  ,  ,8BMMBBBBBBi     ,,:,,     ,,, , ,   , , , :,::ii::i::
    :      iZMOMOMBBM2::::::::::,,,,     ,,,,,,:,,,::::i:irr:i:::,
    i   ,,:;u0MBMOG1L:::i::::::  ,,,::,   ,,, ::::::i:i:iirii:i:i:
    :    ,iuUuuXUkFu7i:iii:i:::, :,:,: ::::::::i:i:::::iirr7iiri::
    :     :rk@Yizero.i:::::, ,:ii:::::::i:::::i::,::::iirrriiiri::,
     :      5BMBBBBBBSr:,::rv2kuii:::iii::,:i:,, , ,,:,:i@petermu.,
          , :r50EZ8MBBBBGOBBBZP7::::i::,:::::,: :,:,::i;rrririiii::
              :jujYY7LS0ujJL7r::,::i::,::::::::::::::iirirrrrrrr:ii:
           ,:  :@kevensun.:,:,,,::::i:i:::::,,::::::iir;ii;7v77;ii;i,
           ,,,     ,,:,::::::i:iiiii:i::::,, ::::iiiir@xingjief.r;7:i,
        , , ,,,:,,::::::::iiiiiiiiii:,:,:::::::::iiir;ri7vL77rrirri::
         :,, , ::::::::i:::i:::i:i::,,,,,:,::i:i:::iir;@Secbone.ii:::
                           单身狗，别看了...
                    A single dog（pig） is looking at you...

]]--

--自定义Prefab
PrefabFiles = {
    "pkc_homesigns",
    "pkc_pigkings",
    "pkc_title",
    "pkc_pigs",
    "pkc_pighouses",
    "pkc_eyeturret",
    "pkc_range",
}

modimport("scripts/newxiugai")

local require = GLOBAL.require
--自定义工具函数（常用的工具函数放这里）
require "pkc_utils"
--木牌传送
modimport("scripts/mods/pkc_fasttravel")
--属性显示
modimport("scripts/mods/pkc_showme")
--快速采集
modimport("scripts/mods/pkc_fasthand")
--去GLOBAL
modimport("scripts/pkc_fuckglobal")
--全局变量
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
--自动公告
modimport("scripts/init/pkc_announce")
--玩家积分信息
modimport("scripts/init/pkc_playerstatus_screen")
modimport("scripts/init/pkc_wwdxhz")
--敌对据点
modimport("scripts/init/pkc_hostilegroup")
--生物变大
modimport("scripts/init/pkc_mobtobig")
--modimport("scripts/init/pkc_studypy")
--TODO
--地图分组显示
--modimport("scripts/init/pkc_group_postion")
--怪物入侵
--modimport("scripts/init/pkc_monster_invasion")
--商店系统
--modimport("scripts/init/pkc_shop_system")

--人物修改部分