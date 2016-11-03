----[[声明全局变量]]----

	--游戏语言
	GLOBAL.GAME_LANGUAGE = GetModConfigData("language")
	--分组数
	GLOBAL.GROUP_NUM = GetModConfigData("group_num")
	--游戏中一天的时间（秒）
	GLOBAL.GAME_DAY_TIME = GLOBAL.TUNING.TOTAL_DAY_TIME
	
	--大猪猪势力
	GLOBAL.GROUP_BIGPIG_ID= 1	--0x10
	--红猪猪势力
	GLOBAL.GROUP_REDPIG_ID = 2	--0x11
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
	}
	
	--基地间的距离
	GLOBAL.GROUP_DISTANCE=GetModConfigData("group_distance")
	
	
	