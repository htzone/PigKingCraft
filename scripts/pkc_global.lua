----[[声明全局变量]]----

	--游戏语言
	GLOBAL.GAME_LANGUAGE = GetModConfigData("language")
	--分组数
	GLOBAL.GROUP_NUM = GetModConfigData("group_num")
	--获取胜利需要分数
	GLOBAL.WIN_SCORE = GetModConfigData("win_score")
	--赢取最终胜利后是否自动重置世界
	GLOBAL.AUTO_RESET_WORLD = GetModConfigData("auto_reset_world")
	--猪王的生命值
	GLOBAL.PIGKING_HEALTH = GetModConfigData("pigking_health")
	--给初始物品
	GLOBAL.GIVE_START_ITEM = GetModConfigData("give_start_item")
	--基地间的距离
	GLOBAL.GROUP_DISTANCE = 300
	--物品自动清理时间(秒)
	GLOBAL.AUTO_DELETE_TIME = 60
	--大猪猪势力
	GLOBAL.GROUP_BIGPIG_ID= 1	
	--红猪猪势力
	GLOBAL.GROUP_REDPIG_ID = 2	 
	--龙猪猪势力
	GLOBAL.GROUP_LONGPIG_ID= 3	
	--崔猪猪势力
	GLOBAL.GROUP_CUIPIG_ID = 4	
	
	--介绍弹框STRING
	if GLOBAL.GAME_LANGUAGE == "chinese" then
		GLOBAL.STRINGS.UI.INTRO = {
			TITLE = "猪王争霸",
			SUBTITLE = "玩法介绍",
			DESC = [[
				胜利条件
				★获取到足够高的分数★
				★杀掉其他阵营的猪王，只剩自己的猪王★
				两个条件任意达成其一就能取得胜利！
				提示
				★将一些有价值的物品给自己的猪王可以换取分数★
				★击杀玩家和部分怪物可以换取分数★
				★猪王附近的建筑和农作物会被保护★
				★自己阵营的猪王被杀时阵营会被解散，财产将被击杀势力占有★
			]],
			NEXT = "开始游戏",
		}
		--阵营弹框STRING
		GLOBAL.STRINGS.UI.CHOOSEGROUP = {
			TITLE = "阵营选择",
			SUBTITLE = "请选择你要投靠的势力",
			BUTTON_NAME = {
				BIGPIG = "大猪猪势力",
				REDPIG = "红猪猪势力",
				LONGPIG = "龙猪猪势力",
				CUIPIG = "崔猪猪势力",
			},
		}
		--阵营信息
		GLOBAL.GROUP_INFOS = {
			BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "大猪猪", color = "#4DA0FF", head_color = "#2D72FF", score_color = "#0E4199"},
			REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "红猪猪", color= "#FF1A1A", head_color = "#FF0000", score_color = "#9E130E"},
			LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "龙猪猪", color = "#47ED47", head_color = "#009A3A", score_color = "#005205"},
			CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "崔猪猪", color = "#A58DFF", head_color = "#7900FF", score_color = "#5D0694"},
		}
		--名字简写
		GLOBAL.SHORT_NAME = {
			BIGPIG = "大",
			REDPIG = "红",
			LONGPIG = "龙",
			CUIPIG = "崔",
		}
	else
		GLOBAL.STRINGS.UI.INTRO = {
			TITLE = "PigKingCraft",
			SUBTITLE = "Play Introduction",
			DESC = [[
				How Can Win
				★Get  enough  score  to  win★
				★Kill  all  other  group's  pigking  to  win★
				The final Victory can be reached by any one above !
				Tips
				★Give  some  valuable  prefabs  to  your  pigking  to  get  score★
				★Kill  other  group's  player  or  some  monster  boss  to  get  score★
				★The  structure  and  crops  near  pigking  will  be  protected★
				★If  your  pigking  was  killed,  your  group  will  be  disbanded★
			]],
			NEXT = "START",
		}
		--阵营弹框STRING
		GLOBAL.STRINGS.UI.CHOOSEGROUP = {
			TITLE = "ChooseGroup",
			SUBTITLE = "choose group you fight for",
			BUTTON_NAME = {
				BIGPIG = "BIGPIG",
				REDPIG = "REDPIG",
				LONGPIG = "LONGPIG",
				CUIPIG = "CUIPIG",
			},
		}
		--阵营信息
		GLOBAL.GROUP_INFOS = {
			BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "BIGPIG", color = "#4DA0FF", head_color = "#2D72FF", score_color = "#0E4199"},
			REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "REDPIG", color= "#FF1A1A", head_color = "#FF0000", score_color = "#9E130E"},
			LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "LONGPIG", color = "#47ED47", head_color = "#009A3A", score_color = "#005205"},
			CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "CUIPIG", color = "#A58DFF", head_color = "#7900FF", score_color = "#5D0694"},
		}
		--名字简写
		GLOBAL.SHORT_NAME = {
			BIGPIG = "Big",
			REDPIG = "Red",
			LONGPIG = "Long",
			CUIPIG = "Cui",
		}
	end
	
	GLOBAL.GROUP_ORDER = {
		"BIGPIG",
		"REDPIG",
		"LONGPIG",
		"CUIPIG",
	}
	--保存当前存在的队伍
	GLOBAL.CURRENT_EXIST_GROUPS = {
	}
	
	--下线掉落所有物品(附近有敌人时)
	GLOBAL.LEVAE_DROP_EVERYTHING = true
	--开始无敌时间（秒）
	GLOBAL.INVINCIBLE_TIME = 30
	--玩家死亡自动复活时间（秒）
	GLOBAL.PLAYER_REVIVE_TIME = 30
	--猪王财产保护范围
	GLOBAL.PIGKING_RANGE = 50
	--保存队伍分数
	GLOBAL.GROUP_SCORE = {}