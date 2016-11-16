----[[声明全局变量]]----

	--游戏语言
	GLOBAL.GAME_LANGUAGE = GetModConfigData("language")
	--分组数
	GLOBAL.GROUP_NUM = GetModConfigData("group_num")
	--基地间的距离
	GLOBAL.GROUP_DISTANCE = 200
	
	--大猪猪势力
	GLOBAL.GROUP_BIGPIG_ID= 1	--0x10
	--红猪猪势力
	GLOBAL.GROUP_REDPIG_ID = 2	 --0x11
	--龙猪猪势力
	GLOBAL.GROUP_LONGPIG_ID= 3	
	--崔猪猪势力
	GLOBAL.GROUP_CUIPIG_ID = 4	
	
	--介绍弹框STRING
	GLOBAL.STRINGS.UI.INTRO = {
		TITLE = "猪王争霸",
		SUBTITLE = "游戏玩法介绍",
		DESC = [[
		本游戏的玩法是...
		]],
		NEXT = "开始游戏",
	}
	--阵营弹框STRING
	GLOBAL.STRINGS.UI.CHOOSEGROUP = {
		TITLE = "阵营选择",
		SUBTITLE = "请选择你要投靠的势力",
		BIGPIG = "大猪猪势力",
		REDPIG = "红猪猪势力",
		LONGPIG = "龙猪猪势力",
		CUIPIG = "崔猪猪势力",
	}
	--阵营信息
	GLOBAL.GROUP_INFOS = {
		BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "大猪猪", color = "#0C6CEC", },
		REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "红猪猪", color= "#FF0000", },
		LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "龙猪猪", color = "#33B80F", },
		CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "崔猪猪", color = "#FADE07", },
	}
	--猪王的生命值
	GLOBAL.PIGKING_HEALTH = 500
	--下线掉落所有物品
	GLOBAL.LEVAE_DROP_EVERYTHING = GetModConfigData("levae_drop_everything")
	--开始无敌时间（秒）
	GLOBAL.INVINCIBLE_TIME = 20
	--玩家死亡自动复活时间（秒）
	GLOBAL.PLAYER_REVIVE_TIME = 30
	--猪王财产保护范围
	GLOBAL.PIGKING_RANGE = 50
