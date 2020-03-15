----[[声明全局变量]]----

	--测试模式
	GLOBAL.PKC_ISTEST = GetModConfigData("is_test")

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
	--随机队伍
	GLOBAL.RANDOM_GROUP = GetModConfigData("random_group")
	--和平期时间(天)
	GLOBAL.PEACE_TIME = GetModConfigData("peace_time")
	--猪王附近眼球塔数量
	GLOBAL.PKC_EYETURRET_NUM = GetModConfigData("init_eyeturret_num")
	--猪王猪人房数量
	GLOBAL.PKC_PIGHOUSE_NUM = GetModConfigData("init_pighouse_num")
	--防止玩家恶意破坏开关
	GLOBAL.PKC_PREVENT_BAD_BOY = GetModConfigData("prevent_bad_boy")

	--基地间的距离
	GLOBAL.GROUP_DISTANCE = (GLOBAL.GROUP_NUM > 2 and 350 or 400)
	--物品自动清理超过时间(秒)
	GLOBAL.PKC_AUTO_DELETE_TIME = 60
	--世界自动清理间隔时间(天)
	GLOBAL.PKC_WORLD_DELETE_INTERVAL = 5
	--世界自动清理超过时间(天)
	GLOBAL.PKC_WORLD_DELETE_TIME = 4
	--下线掉落所有物品(只在当附近有敌人时)
	GLOBAL.PKC_LEVAE_DROP_EVERYTHING = true
	--开始无敌时间（秒）
	GLOBAL.PKC_INVINCIBLE_TIME = 30
	--复活无敌时间（秒）
	GLOBAL.PKC_REVIVE_INVINCIBLE_TIME = 20
	--玩家死亡初始自动复活时间（秒）
	GLOBAL.PLAYER_REVIVE_TIME = 10
	--猪王财产最大保护范围（码）
	GLOBAL.PIGKING_RANGE = 50
	--冲刺冷却时间
	GLOBAL.PKC_SPRINT_COOLDOWN = 10
	--冲刺速度
	GLOBAL.PKC_SPRINT_SPEED = 2.7
	--生物变大
	GLOBAL.PKC_CREATURE_TOBIG = false
	--生物变大开始时间（天）
	GLOBAL.PKC_BEGIN_TOBIG = 5
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
			SUBTITLE = "【和平期】: "..GLOBAL.PEACE_TIME.."天   【总分】: "..GLOBAL.WIN_SCORE.."分  【猪王可杀】: "..(GLOBAL.PIGKING_HEALTH == -1 and "否" or "是"),
			DESC = (GLOBAL.PIGKING_HEALTH == -1 
			and [[
				胜利条件
				★获取到足够高的分数★
				达成该条件就能取得胜利！
				提示
				★将一些有价值的物品给自己的猪王可以换取分数★
				★击杀玩家和部分怪物可以换取分数★
				★猪王附近的建筑和农作物会被保护★
				★按键盘B键或C键可以回城，shift键冲刺★
			]]
			or [[
				胜利条件
				★获取到足够高的分数★
				★杀掉其他阵营的猪王，只剩自己的猪王★
				两个条件任意达成其一就能取得胜利！
				提示
				★可通过贡献物品给猪王或击杀怪物和玩家得分★
				★猪王附近的建筑和农作物会被保护★
				★自己阵营的猪王被杀时阵营会被解散，财产将被击杀势力占有★
				★按键盘B键或C键可以回城，shift键冲刺★
			]]),
			NEXT = "开始游戏",
			RANDOM_NEXT = "开始游戏",
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
		GLOBAL.PKC_GROUP_INFOS = {
			BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "大猪猪", color = "#4DA0FF", head_color = "#1958FF",
				head_tag = "♠", score_color = "#0E4199", pighouse_color = "#4DA0FF", pigman_color = "#4DA0FF"},
			REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "红猪猪", color= "#FF1A1A", head_color = "#FF0000",
				head_tag = "♥", score_color = "#9E130E", pighouse_color = "#FF908D", pigman_color = "#FF908D"},
			LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "龙猪猪", color = "#47ED47", head_color = "#009A3A",
				head_tag = "♣", score_color = "#005205", pighouse_color = "#6FDB6F", pigman_color = "#6FDB6F"},
			CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "崔猪猪", color = "#A58DFF", head_color = "#7900FF",
				head_tag = "♦", score_color = "#5D0694", pighouse_color = "#A58DFF", pigman_color = "#A58DFF"},
		}
		--名字简写
		GLOBAL.SHORT_NAME = {
			BIGPIG = "蓝队",
			REDPIG = "红队",
			LONGPIG = "绿队",
			CUIPIG = "紫队",
		}
	else
		GLOBAL.STRINGS.UI.INTRO = {
			TITLE = "PigKingCraft",
			SUBTITLE = "TotalScore: "..GLOBAL.WIN_SCORE.."   PeacefulDays: "..GLOBAL.PEACE_TIME.." days".."   PigKingCanBeKilled: "..(GLOBAL.PIGKING_HEALTH == -1 and "No" or "Yes"),
			DESC = (GLOBAL.PIGKING_HEALTH == -1 
			and [[
				<How To Play>
				★To win reach server-set score★
				<Tips>
				★Give some valuable items to your Pigking to get points.★
				★Kill enemies, monsters or bosses to get points.★
				★Buildings or crops near Pigking will be protected.★
				★Press the 'C' key to teleport Home, 'shift' key to sprint.★
			]] 
			or [[
				<How To Play>
				★To win reach server-set score★
				★or Kill all other teams' Pigking's★
				<Tips>
				★Give some valuable items to your Pigking to get points.★
				★Kill enemies, monsters or bosses to get points.★
				★Buildings or crops near Pigking will be protected.★
				★If your Pigking is killed, your team will be disbanded.★
				★Press the 'C' key to teleport Home, 'shift' key to sprint.★
			]]),
			NEXT = "START",
			RANDOM_NEXT = "START",
		}
		--阵营弹框STRING
		GLOBAL.STRINGS.UI.CHOOSEGROUP = {
			TITLE = "ChooseGroup",
			SUBTITLE = "choose pigking you fight for",
			BUTTON_NAME = {
				BIGPIG = "BLU PIG",
				REDPIG = "RED PIG",
				LONGPIG = "GRE PIG",
				CUIPIG = "PUR PIG",
			},
		}
		--阵营信息
		GLOBAL.PKC_GROUP_INFOS = {
			BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "BLUPIG", color = "#4DA0FF", head_color = "#1958FF",
				head_tag = "♠", score_color = "#0E4199", pighouse_color = "#4DA0FF", pigman_color = "#4DA0FF"},
			REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "REDPIG", color= "#FF1A1A", head_color = "#FF0000",
				head_tag = "♥", score_color = "#9E130E", pighouse_color = "#FF908D", pigman_color = "#FF908D"},
			LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "GREPIG", color = "#47ED47", head_color = "#009A3A",
				head_tag = "♣", score_color = "#005205", pighouse_color = "#6FDB6F", pigman_color = "#6FDB6F"},
			CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "PURPIG", color = "#A58DFF", head_color = "#7900FF",
				head_tag = "♦", score_color = "#5D0694", pighouse_color = "#A58DFF", pigman_color = "#A58DFF"},
		}
		--名字简写
		GLOBAL.SHORT_NAME = {
			BIGPIG = "Blu",
			REDPIG = "Red",
			LONGPIG = "Gre",
			CUIPIG = "Pur",
		}
	end
	
	GLOBAL.GROUP_ORDER = {
		"BIGPIG",
		"REDPIG",
		"LONGPIG",
		"CUIPIG",
	}
	
	--保存当前存在的队伍
	GLOBAL.CURRENT_EXIST_GROUPS = {}
	--保存队伍分数
	GLOBAL.GROUP_SCORE = {}
	--保存玩家的全局变量
	GLOBAL.PLAYERS = {}
	
	--弹窗类型
	GLOBAL.WIN_POPDIALOG = 1
	--保存玩家信息
	GLOBAL.PKC_PLAYER_INFOS = {}