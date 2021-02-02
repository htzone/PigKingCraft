--
-- 分数设定
-- Author: RedPig, 大猪猪, 龙飞
-- Date: 2016/11/18
--

----[[声明全局变量]]----

	--测试模式
	--GLOBAL.PKC_ISTEST = GetModConfigData("is_test")
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
	--怪物据点
	GLOBAL.PKC_MONSTER_POINT = GetModConfigData("monster_point_switch")
	--物品自动清理超过时间(秒)
	GLOBAL.PKC_AUTO_DELETE_TIME = 100
	--世界自动清理间隔时间(天)
	GLOBAL.PKC_WORLD_DELETE_INTERVAL = 5
	--世界自动清理超过时间(天)
	GLOBAL.PKC_WORLD_DELETE_TIME = 3
	--下线掉落所有物品(只在当附近有敌人时)
	GLOBAL.PKC_LEVAE_DROP_EVERYTHING = true
	--开始无敌时间（秒）
	GLOBAL.PKC_INVINCIBLE_TIME = 30
	--复活无敌时间（秒）
	GLOBAL.PKC_REVIVE_INVINCIBLE_TIME = 20
	--玩家死亡初始自动复活时间（秒）
	GLOBAL.PLAYER_REVIVE_TIME = 10
	--玩家传送所需时间（秒）
	GLOBAL.PLAYER_TELEPORT_TIME = 10
	--木牌传送所需时间（秒）
	GLOBAL.SIGN_TELEPORT_TIME = 10
	--猪王财产最大保护范围（码）
	GLOBAL.PIGKING_RANGE = 50
	--冲刺冷却时间
	GLOBAL.PKC_SPRINT_COOLDOWN = 9
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
	--猪人守卫生命值
	GLOBAL.TUNING.PIG_GUARD_HEALTH = 400

	if not GLOBAL.STRINGS.CHARACTERS.WEBBER then
		GLOBAL.STRINGS.CHARACTERS.WEBBER = {DESCRIBE = {}}
	end
	if not GLOBAL.STRINGS.CHARACTERS.WATHGRITHR then
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR = {DESCRIBE = {}}
	end

	--自定义STRING
	if GLOBAL.GAME_LANGUAGE == "chinese" then
		GLOBAL.STRINGS.NAMES.HOMESIGN = "传送路牌"
		GLOBAL.STRINGS.RECIPE_DESC.HOMESIGN = "能将你传送到其他路牌附近."

		local desc_red = "那是红色军团的头盔！"
		local desc_blu = "那是蓝色军团的头盔！"
		local desc_gre = "那是绿色军团的头盔！"
		local desc_pur = "那是紫色军团的头盔！"

		GLOBAL.STRINGS.PIG_TALK_FIND_CONTAINER = {"找个东西装一下吧！", "箱子满了我就不能放了", "找个地方放一下", "主人们有更多的箱子么", "我拿了点东西回来"}
		GLOBAL.STRINGS.PIG_TALK_FIND_GROUND_ITEM = { "主人们太懒了！", "还是我来收拾烂摊子吧！", "捡起来放箱子吧！", "发现可疑物！", "看我发现了什么！" }
		GLOBAL.STRINGS.PIG_TALK_HARVEST_ITEM = { "大丰收啊！", "猪人喜欢劳动！", "要是我能偷偷吃点就好了！", "绝对不能吃！这是主人们的", "又到了收获的季节", "我是勤劳的猪人" }
		GLOBAL.STRINGS.PIG_TALK_FERTILIZER_ITEM = { "植物需要施肥！", "猪人喜欢劳动！", "用我的便便滋润它！", "给你表演个魔术" }
		GLOBAL.STRINGS.PIG_FIND_POOP_ITEM = { "哪里有便便？", "找坨便便！", "需要屎来滋润它", "怎么办，庄稼枯萎了！" }
		GLOBAL.STRINGS.NAMES.PKC_SPARTAHELMUT = "红色军团头盔"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_SPARTAHELMUT = "高贵身份的象征，队伍专属装备."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_SPARTAHELMUT = desc_red

		GLOBAL.STRINGS.NAMES.PKC_EWECUSHAT = "蓝色军团头盔"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_EWECUSHAT = "高贵身份的象征，队伍专属装备."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_EWECUSHAT = desc_blu

		GLOBAL.STRINGS.NAMES.PKC_BIRCHNUTHAT = "绿色军团头盔"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_BIRCHNUTHAT = "高贵身份的象征，队伍专属装备."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre

		GLOBAL.STRINGS.NAMES.PKC_SUMMERBANDANA = "紫色军团头盔"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_SUMMERBANDANA = "高贵身份的象征，队伍专属装备."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_SUMMERBANDANA = desc_pur

		GLOBAL.STRINGS.NAMES.PKC_BLACKSMITH_EDGE = GLOBAL.STRINGS.NAMES.LAVAARENA_HEAVYBLADE
		GLOBAL.STRINGS.RECIPE_DESC.PKC_BLACKSMITH_EDGE = "Blacksmith Edge from The Forge S2"

		GLOBAL.STRINGS.NAMES.PKC_LIVINGSTAFF = GLOBAL.STRINGS.NAMES.HEALINGSTAFF;
		GLOBAL.STRINGS.RECIPE_DESC.PKC_LIVINGSTAFF = "Living Staff from The Forge S1"

		GLOBAL.STRINGS.NAMES.PKC_FORGEDARTS = GLOBAL.STRINGS.NAMES.BLOWDART_LAVA;
		GLOBAL.STRINGS.RECIPE_DESC.PKC_FORGEDARTS = "Darts from The Forge S1"

		GLOBAL.STRINGS.NAMES.INFERNALSTAFF = GLOBAL.STRINGS.NAMES.FIREBALLSTAFF;
		GLOBAL.STRINGS.RECIPE_DESC.INFERNALSTAFF = "Infernal Staff from The Forge S1"

		GLOBAL.STRINGS.UI.PKC_CLOSE = "关闭"
		GLOBAL.STRINGS.UI.PKC_PLAYER_PRE = "玩家："
		GLOBAL.STRINGS.UI.PKC_UNKNOWN = "未知"
		GLOBAL.STRINGS.UI.PKC_HUNGER = "饥饿消耗："
		GLOBAL.STRINGS.UI.PKC_SANITY = "理智消耗："
		GLOBAL.STRINGS.UI.PKC_CURRENT = "当前"
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
				head_tag = "♠", score_color = "#0E4199", pighouse_color = "#4DA0FF", pigman_color = "#4DA0FF",
					   short_name = "蓝队"},
			REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "红猪猪", color= "#FF1A1A", head_color = "#FF0000",
				head_tag = "♥", score_color = "#9E130E", pighouse_color = "#FF908D", pigman_color = "#FF908D",
					   short_name = "红队"},
			LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "龙猪猪", color = "#47ED47", head_color = "#009A3A",
				head_tag = "♣", score_color = "#005205", pighouse_color = "#6FDB6F", pigman_color = "#6FDB6F",
					   short_name = "绿队"},
			CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "崔猪猪", color = "#A58DFF", head_color = "#7900FF",
				head_tag = "♦", score_color = "#5D0694", pighouse_color = "#A58DFF", pigman_color = "#A58DFF",
					   short_name = "紫队"},
		}
		--名字简写
		GLOBAL.SHORT_NAME = {
			BIGPIG = "蓝队",
			REDPIG = "红队",
			LONGPIG = "绿队",
			CUIPIG = "紫队",
		}
	else
		GLOBAL.STRINGS.NAMES.HOMESIGN = "Transmission Signboard"
		GLOBAL.STRINGS.RECIPE_DESC.HOMESIGN = "It can teleport you to other signboard."

		local desc_red = "That's the red group helmet!"
		local desc_blu = "That's the blue group helmet!"
		local desc_gre = "That's the green group helmet!"
		local desc_pur = "That's the purple group helmet!"

		GLOBAL.STRINGS.PIG_TALK_FIND_CONTAINER = {"Find something to put", "I can't put into the chest if it's full", "Are there any more chests here?"}
		GLOBAL.STRINGS.PIG_TALK_FIND_GROUND_ITEM = { "The hosts are too lazy!", "Let me help you clean up the mess!", "Pick it up and put it in the box!", "Suspicious objects found!" }
		GLOBAL.STRINGS.PIG_TALK_HARVEST_ITEM = { "Great harvest!", "Pig man like to work!", "If only I could steal some!" }
		GLOBAL.STRINGS.PIG_TALK_FERTILIZER_ITEM = { "Plants need fertilizer!", "Pig man like to work!", "Moisten it with my poop!", "I'll show you a magic trick!" }
		GLOBAL.STRINGS.PIG_FIND_POOP_ITEM = { "Where is the poop?", "Look for shit!", "What to do? The crops are withered!" }
		GLOBAL.STRINGS.NAMES.PKC_SPARTAHELMUT = "Red Group Helmet"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_SPARTAHELMUT = "The symbol of noble, can let pig man follow you."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_SPARTAHELMUT = desc_red
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_SPARTAHELMUT = desc_red

		GLOBAL.STRINGS.NAMES.PKC_EWECUSHAT = "Blue Group Helmet"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_EWECUSHAT = "The symbol of noble, can let pig man follow you."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_EWECUSHAT = desc_blu
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_EWECUSHAT = desc_blu

		GLOBAL.STRINGS.NAMES.PKC_BIRCHNUTHAT = "Green Group Helmet"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_BIRCHNUTHAT = "The symbol of noble, can let pig man follow you."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_BIRCHNUTHAT = desc_gre

		GLOBAL.STRINGS.NAMES.PKC_SUMMERBANDANA = "Purple Group Helmet"
		GLOBAL.STRINGS.RECIPE_DESC.PKC_SUMMERBANDANA = "The symbol of noble, can let pig man follow you."
		GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PKC_SUMMERBANDANA = desc_pur
		GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PKC_SUMMERBANDANA = desc_pur

		GLOBAL.STRINGS.NAMES.PKC_BLACKSMITH_EDGE = GLOBAL.STRINGS.NAMES.LAVAARENA_HEAVYBLADE
		GLOBAL.STRINGS.RECIPE_DESC.PKC_BLACKSMITH_EDGE = "Blacksmith Edge from The Forge S2"

		GLOBAL.STRINGS.NAMES.PKC_LIVINGSTAFF = GLOBAL.STRINGS.NAMES.HEALINGSTAFF;
		GLOBAL.STRINGS.RECIPE_DESC.PKC_LIVINGSTAFF = "Living Staff from The Forge S1"

		GLOBAL.STRINGS.NAMES.PKC_FORGEDARTS = GLOBAL.STRINGS.NAMES.BLOWDART_LAVA;
		GLOBAL.STRINGS.RECIPE_DESC.PKC_FORGEDARTS = "Darts from The Forge S1"

		GLOBAL.STRINGS.NAMES.INFERNALSTAFF = GLOBAL.STRINGS.NAMES.FIREBALLSTAFF;
		GLOBAL.STRINGS.RECIPE_DESC.INFERNALSTAFF = "Infernal Staff from The Forge S1"

		GLOBAL.STRINGS.UI.PKC_CLOSE = "close"
		GLOBAL.STRINGS.UI.PKC_PLAYER_PRE = "Player:"
		GLOBAL.STRINGS.UI.PKC_UNKNOWN = "UnKnown"
		GLOBAL.STRINGS.UI.PKC_HUNGER = "Hunger cost："
		GLOBAL.STRINGS.UI.PKC_SANITY = "Sanity cost:"
		GLOBAL.STRINGS.UI.PKC_CURRENT = "Current"
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
				LONGPIG = "GRN PIG",
				CUIPIG = "PUR PIG",
			},
		}
		--阵营信息
		GLOBAL.PKC_GROUP_INFOS = {
			BIGPIG = { id = GLOBAL.GROUP_BIGPIG_ID, name = "BLUPIG", color = "#4DA0FF", head_color = "#1958FF",
				head_tag = "♠", score_color = "#0E4199", pighouse_color = "#4DA0FF", pigman_color = "#4DA0FF",
					   short_name = "BLU"},
			REDPIG = { id = GLOBAL.GROUP_REDPIG_ID, name = "REDPIG", color= "#FF1A1A", head_color = "#FF0000",
				head_tag = "♥", score_color = "#9E130E", pighouse_color = "#FF908D", pigman_color = "#FF908D",
					   short_name = "RED"},
			LONGPIG = { id = GLOBAL.GROUP_LONGPIG_ID, name = "GREPIG", color = "#47ED47", head_color = "#009A3A",
				head_tag = "♣", score_color = "#005205", pighouse_color = "#6FDB6F", pigman_color = "#6FDB6F",
						short_name = "GRN"},
			CUIPIG = { id = GLOBAL.GROUP_CUIPIG_ID, name = "PURPIG", color = "#A58DFF", head_color = "#7900FF",
				head_tag = "♦", score_color = "#5D0694", pighouse_color = "#A58DFF", pigman_color = "#A58DFF",
					   short_name = "PUR"},
		}
		--名字简写
		GLOBAL.SHORT_NAME = {
			BIGPIG = "BLU",
			REDPIG = "RED",
			LONGPIG = "GRN",
			CUIPIG = "PUR",
		}
	end
	
	GLOBAL.GROUP_ORDER = {
		"BIGPIG",
		"REDPIG",
		"LONGPIG",
		"CUIPIG",
	}

	--弹窗类型
	GLOBAL.WIN_POPDIALOG = 1
	--保存当前存在的队伍
	GLOBAL.CURRENT_EXIST_GROUPS = {}
	--保存队伍分数
	GLOBAL.GROUP_SCORE = {}
	--保存玩家基本信息
	GLOBAL.PKC_PLAYER_INFOS = {}
	--保存玩家得分信息
	GLOBAL.PKC_PLAYER_SCORES = {}