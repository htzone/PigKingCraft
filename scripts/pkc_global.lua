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
		BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "大猪猪", color = "#4DA0FF", head_color = "#1985FF", score_color = "#0E4199"},
		REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "红猪猪", color= "#FF1A1A", head_color = "#FF0000", score_color = "#9E130E"},
		LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "龙猪猪", color = "#47ED47", head_color = "#009A3A", score_color = "#005205"},
		CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "崔猪猪", color = "#A58DFF", head_color = "#7900FF", score_color = "#5D0694"},
	}
	--保存目前存在的组
	GLOBAL.EXIST_GROUP = {
	}
	--猪王的生命值
	GLOBAL.PIGKING_HEALTH = 200
	--下线掉落所有物品(附近有敌人时)
	GLOBAL.LEVAE_DROP_EVERYTHING = true
	--开始无敌时间（秒）
	GLOBAL.INVINCIBLE_TIME = 20
	--玩家死亡自动复活时间（秒）
	GLOBAL.PLAYER_REVIVE_TIME = 30
	--猪王财产保护范围
	GLOBAL.PIGKING_RANGE = 50
	--保存分数
	GLOBAL.GROUP_SCORE = {}
	--获取胜利需要分数
	GLOBAL.WIN_SCORE = 10000
	