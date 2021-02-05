--
-- 对话设定
-- Author: RedPig
-- Date: 2016/11/20
--

--游戏语言
if GetModConfigData("language") == "chinese" then
	--BOSS名字
	GLOBAL.BOSS_NAME = {
		deerclops = {NAME = "巨鹿"},
		moose = {NAME = "巨鸭"},
		bearger = {NAME = "巨熊"},
		dragonfly = {NAME = "龙蝇"},
		minotaur = {NAME = "远古犀牛"},
		malbatross = {NAME = "邪天翁"},
		pkc_leifking = {NAME = "树精长老"},
		pkc_bunnymanking = {NAME = "兔人国王"},
		pkc_mermking = {NAME = "鱼人国王"},
		pkc_rockyking = {NAME = "石虾国王"},
	}
	
	--语气词
	GLOBAL.MODAL_WORDS = {
	"阿西吧",
	"玛莎卡",
	"害怕",
	}

	--常用词汇
	GLOBAL.CLOSE = "关闭"

	--玩家话语
	GLOBAL.PKC_SPEECH = {
		COMMA = "，",
		EXCLA = "！",
		QUEST = "？",
		GROUP_HASBE_KILLED = "不！我的队伍已经被消灭了！！！",
		REVIVE_TIPS1 = {
			SPEECH1 = "\n \n \n \n 还有%s秒复活 \n \n 已死亡%s次",
		},
		REVIVE_TIPS2 = "啊，我要复活啦！",
		BELONG_TIPS = {
			SPEECH1 = "我属于 ",
			SPEECH2 = " 阵营！",
		},
		GROUP_JOIN = {
			SPEECH1 = " 选择加入了 ",
			SPEECH2 = " 阵营！",
			SPEECH3 = "我要保护我们的",
			SPEECH4 = "！",
		},
		PIGKING_PROTECT = {
			SPEECH1 = "可惜，受敌方猪王保护！",
			SPEECH2 = "可惜，不能这么做！",
			SPEECH3 = "可惜，和平时期不能这么做！",
			SPEECH4 = "离敌人建筑太近了，我不能这么做！",
			SPEECH5 = "离得太近，我不能这么做！",
		},
		GRAVESTONE_TIPS = {
			SPEECH1 = "沉睡的地方",
			SPEECH2 = "可惜，",
			SPEECH3 = "已是曾经的辉煌！",
		},
		KILLED_ANNOUNCE = {
			SPEECH1 = " 已被 ",
			SPEECH2 = " 击杀啦！！！",
		},
		WINDIALOG_VICTORY_TITLE = "胜利！好鸡动！",
		WINDIALOG_FAILURE_TITLE = "失败！好气呀！",
		WINDIALOG_CONTENT = {
			SPEECH1 = "恭喜 ",
			SPEECH2 = " 阵营 取得了最后的胜利！！！",
		},
		WINDIALOG_WIN_BUTTON = "无敌是多寂寞",
		WINDIALOG_FAILED_BUTTON = "向大佬们低头",
		WORLDRESET_TIPS = {
			SPEECH1 = "注意啦，注意啦 ，世界将在30秒后重置！！！",
			SPEECH2 = "世界马上重置了，请老老实实待着吧！！！",
		},
		PLAYER_LOSE_TIPS = "不，我们居然输了！！！",
		KINGBEKILLED_ANNOUNCE = {
			SPEECH1 = "首领 已被 ",
			SPEECH2 = " 击杀！！！",
		},
		GROUP_SMASH = {
			SPEECH1 = "不好啦，",
			SPEECH2 = "阵营 已被 ",
			SPEECH3 = "阵营 消灭啦！！！",
			SPEECH4 = " 消灭啦！！！",
		},
		GROUP_BEKILLED = "灭",
		AUTO_CLEAR = {
		SPEECH1 = "注意，注意，扔地上超过",
		SPEECH2 = "天的东西将被清理掉哦！！！",
		},
		CLEANING = "垃圾自动清理中...",
		PEACE_TIME_TIPS = {
			SPEECH1 = "注意！和平时期结束啦， 战争开始了！",
			SPEECH2 = "离和平期结束还有",
			SPEECH3 = "天！",
			SPEECH4 = "啊，和平期结束啦，战争开始了！",
		},
		PIGKING = {
			SPEECH1 = "猪猪爱你们哟！",
			SPEECH2 = "我们家的猪王正在被攻击！！！",
			SPEECH3 = "麻麻，我好像升级了！！！",
			CHAT = {
			"猪猪爱你们哟！",
			"猪人喜欢熟食！",
			"我想长大哎！",
			"能给我吃的么！",
			"我能飞么！",
			"记得保护我哦！",
			},
		},
		EYETURRET = {
			SPEECH1 = "我们家的眼球塔正在被攻击！！！",
		},
		PIGHOUSE = {
			SPEECH1 = "我们家的猪人房正在被砸！！！",
		},
		STRUCTURE = {
			SPEECH1 = "我们家的建筑正在被攻击！！！",
		},
		PIGCLICK = {
			--"我们需要升级猪王获得更多的土地！",
			--"我们需要升级猪王获得更强的猪人战士！",
			--"获得足够的分数可以升级猪王！",
			"用金子可以雇佣猪人！！！",
		},
		PIG_MAN_TALK = {
			SPEECH1 = "猪人讨厌粑粑！！！",
		},
		GO_HOME = {
			SPEECH1 = "准备回城！",
			SPEECH2 = "回城中断！",
			SPEECH3 = "还有",
			SPEECH4 = "秒回城！",
			SPEECH5 = "精神值过低，不能传送！",
			SPEECH6 = "饥饿值过低，不能传送！",
			SPEECH7 = "按C键可以回城哦！！！",
		},
		GROUP_SIGN = {
			SPEECH1 = " \n \n \n本队已有传送牌数量为：%d \n 目前允许的最大数目为：%d",
			SPEECH2 = "本队传送牌数量已达到限制\n目前允许的最大数目为：%d \n请升级猪王以解锁更多",
			SPEECH3 = "这是敌方队伍的传送牌！",
			SPEECH4 = "没有可传送的目的地",
			SPEECH5 = "没有可传送的目的地",
			SPEECH6 = "目标不再可到达",
			SPEECH7 = "尸体是无法传送的",
			SPEECH8 = "不安全的旅行",
			SPEECH9 = "目标不再可到达",
			SPEECH10 = "状态不佳无法传送",
			SPEECH11 = "%s秒后开始传送",
			SPEECH12 = "靠近，保持姿势！",
			SPEECH13 = "选择目的地",
			SPEECH14 = "说摸了我？",
			SPEECH15 = "还没轮到你.",
			SPEECH16 = "现在旅行不安全.",
			SPEECH17 = "未知目的地.",
			SPEECH18 = "请靠近此处",
			SPEECH19 = "我状态不好，不能传送",
			SPEECH20 = "%d秒后开始传送",
			SPEECH21 = "我正在被传送！",
			SPEECH22 = "目的地不再可达",
			SPEECH23 = "我们不运送尸体",
			SPEECH24 = "离我太远了，请靠近我",
			SPEECH25 = "现在旅行不安全.",
			SPEECH26 = "家",
		},
		GROUP_PIGHOUSE = {
			SPEECH1 = " \n \n \n猪王附近已有猪房数量为：%d \n目前允许的最大数目为：%d",
			SPEECH2 = "猪王附近猪房数量已达最大限制\n目前允许的最大数目为：%d\n请升级猪王以解锁更多",
		},
		PREVENT_BADBOY = {
			SPEECH1 = "不是我建造的 \n 需要活过10天才能砸！",
		},
		SPRINT = {
			SPEECH1 = "冲啊！",
			SPEECH2 = "充气完毕！",
			SPEECH3 = "太饿了，冲不了！",
			SPEECH4 = "按Shift键可以冲刺！！！",
		},
		SCORE_KILL_NUM = {
			SPEECH1 = "击杀:",
			SPEECH2 = "分数:",
			SPEECH3 = "第%d名",
		},
		COUNT_POINTS = {
			SPEECH1 = "请勿离开房间，猪王们正在拼命地统计分数...",
		},
		CHAT_QUEUE = {
			SPEECH1 = "对所有人说",
			SPEECH2 = "对队伍内说",
			SPEECH3 = "[队伍内] ",
			SPEECH4 = "[所有人] ",
		},
		ANNOUNCE_SPEECH = {
			"猪王争霸：如果为PVP模式，击杀对面的猪王或是赢得足够高的分数都可以获得比赛的胜利！",
			"猪王争霸：按Shift键可以短暂冲刺，按C键可以回城，请善用这两点！",
			"猪王争霸：按Y键队伍内聊天，按U键所有人聊天！",
			"猪王争霸：按Y键输入 '#投降' 或 '#sur' 可以发起投降，达到投降最低人数即可投降成功！",
			"猪王争霸：通过路牌传送可以很快到达到同组路牌或玩家的附近，减少跑路时间！",
			"猪王争霸：善待猪人，猪人们或许能成为你的好帮手！",
			"猪王争霸：分组生存对抗，最后剩下的阵营将会是比赛的胜利者！",
			"猪王争霸：按Y键输入 '#投降' 或 '#gg' 可以发起投降，达到投降最低人数即可成功投降！",
			"猪王争霸：如果是月圆之夜请小心家里的猪哦！",
			"猪王争霸：给猪人粑粑可以让其放弃跟随你！",
			"猪王争霸：死亡会随机掉落，死的次数越多复活需要的时间就会越久！",
		},
		SURRENDER_SPEECH = {
			SPEECH1 = "#投降",
			SPEECH2 = "󰀕执行结果：无效投票，您已经发起过投降了",
			SPEECH3 = "󰀕执行结果：发起投降成功 %d / %d， 我们马上就要投降了！！！",
			SPEECH4 = "󰀕执行结果：发起投降 %d / %d， 最少还差%d个发起才能成功投降",
			SPEECH5 = "%s 阵营发起了投降，马上就要执行投降操作了！！！",
			SPEECH6 = "%s 阵营投降成功，%s 阵营已经被消灭了！！！",
		},
		MONSTER_POINT = {
			SPEECH1 = "世界异变开始了...",
			SPEECH2 = "不好了，%s 从混沌之门里边出来了！！！",
			SPEECH3 = "不好了，怪物们又开始蠢蠢欲动了...",
		},
	}
	
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_BIG = "大猪猪战士" 
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_RED = "红猪猪战士" 
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_CUI = "崔猪猪战士" 
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_LONG = "龙猪猪战士" 

	GLOBAL.STRINGS.NAMES.PKC_BIGPIG = "大猪猪" 
	GLOBAL.STRINGS.NAMES.PKC_REDPIG = "红猪猪" 
	GLOBAL.STRINGS.NAMES.PKC_CUIPIG = "崔猪猪" 
	GLOBAL.STRINGS.NAMES.PKC_LONGPIG = "龙猪猪" 
	
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_BIG = "大猪猪炮塔" 
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_RED = "红猪猪炮塔" 
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_CUI = "崔猪猪炮塔" 
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_LONG = "龙猪猪炮塔"
	
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_BIG = "大猪猪房"
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_RED = "红猪猪房"
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_CUI = "崔猪猪房"
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_LONG = "龙猪猪房"

	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_BIG = "大猪猪传送牌"
	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_RED = "红猪猪传送牌"
	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_CUI = "崔猪猪传送牌"
	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_LONG = "龙猪猪传送牌"

	GLOBAL.STRINGS.NAMES.HOMESIGN = "传送牌"
	GLOBAL.STRINGS.RECIPE_DESC.HOMESIGN = "可以把你传送到其他传送牌附近"

else
	GLOBAL.BOSS_NAME = {
		deerclops = {NAME = "Deerclops"},
		moose = {NAME = "Moose"},
		bearger = {NAME = "Bearger"},
		dragonfly = {NAME = "Dragonfly"},
		minotaur = {NAME = "Minotaur"},
		malbatross = {NAME = "Malbatross"},
		pkc_leifking = {NAME = "Leif King"},
		pkc_bunnymanking = {NAME = "Bunny Man King"},
		pkc_mermking = {NAME = "Merm King"},
		pkc_rockyking = {NAME = "Rocky King"},
	}

	GLOBAL.MODAL_WORDS = {
	"Unbelievable",
	}

	--常用词汇
	GLOBAL.CLOSE = "close"

	--玩家话语
	GLOBAL.PKC_SPEECH = {
		COMMA = ",",
		EXCLA = "!",
		QUEST = "?",
		GROUP_HASBE_KILLED = "No!  My team  has  been  wiped  out !",
		REVIVE_TIPS1 = {
			SPEECH1 = "\n \n \n \n I will revive in %s sec.\n \n death num: %s",
		},
		REVIVE_TIPS2 = "well,  Im  coming  back !",
		BELONG_TIPS = {
			SPEECH1 = "I  belong  to  ",
			SPEECH2 = " Team Group !",
		},
		GROUP_JOIN = {
			SPEECH1 = "  has  joined  the  ",
			SPEECH2 = " Group！",
			SPEECH3 = "We  need to protect  our ",
			SPEECH4 = " !",
		},
		PIGKING_PROTECT = {
			SPEECH1 = "It's  protected  by  Enemy  PigKing !",
			SPEECH2 = "Sorry, I  cant  do  that!",
			SPEECH3 = "Sorry, I  cant  do  that in peaceful days!",
			SPEECH4 = "It's so close to enemy pigking that I cant do this!",
			SPEECH5 = "It's so close and I cant do this!",
		},
		GRAVESTONE_TIPS = {
			SPEECH1 = "He's  already  asleep!",
			SPEECH2 = "It  is  sad  that ",
			SPEECH3 = "  is  now  a  history  of  glory!",
		},
		KILLED_ANNOUNCE = {
			SPEECH1 = "  was  killed  by ",
			SPEECH2 = " !!!",
		},
		WINDIALOG_VICTORY_TITLE = "Victory!  We won!",
		WINDIALOG_FAILURE_TITLE = "Failure! We lost!",
		WINDIALOG_CONTENT = {
			SPEECH1 = "The Winner is  ",
			SPEECH2 = "  Group !!!",
			SPEECH3 = "The Winner is  ",
			SPEECH4 = "  Group !!!",
		},
		WINDIALOG_WIN_BUTTON = "Congratulations!",
		WINDIALOG_FAILED_BUTTON = "Unbelievable!",
		WORLDRESET_TIPS = {
			SPEECH1 = "The  world  will  be  regenerated  in  30 sec !!!",
			SPEECH2 = "World  Regeneration  is  progress !!!",
		},
		PLAYER_LOSE_TIPS = "No,  We  have  lost  the  game！！！",
		KINGBEKILLED_ANNOUNCE = {
			SPEECH1 = "  King  was  killed  by ",
			SPEECH2 = "!!!",
		},
		GROUP_SMASH = {
			SPEECH1 = "Unfortunately,  ",
			SPEECH2 = " Group  was  defeated  by ",
			SPEECH3 = " Group !!!",
			SPEECH4 = "",
		},
		GROUP_BEKILLED = "K.O.",
		AUTO_CLEAR = {
		SPEECH1 = "Warning:the items dropped on the ground for more than ",
		SPEECH2 = " days will be cleared!",
		},
		CLEANING = "Commencing item cleanup now...",
		PEACE_TIME_TIPS = {
			SPEECH1 = "The Peace Time is Over!  It‘s about time!!!",
			SPEECH2 = "It is ",
			SPEECH3 = " days before war.",
			SPEECH4 = "The war is beginning!",
		},
		PIGKING = {
			SPEECH1 = "Im happy today!",
			SPEECH2 = "Our pig king is under attack!!!",
			SPEECH3 = "Level Up! I become a bigger pig!",
			CHAT = {
			"Im happy today!",
			"I like you.",
			"I want to grow up.",
			"Please protect me.",
			"I need cooked food.",
			},
		},
		EYETURRET = {
			SPEECH1 = "Our eye turret is under attack!!",
		},
		PIGHOUSE = {
			SPEECH1 = "Our pig house is under attack!!",
		},
		STRUCTURE = {
			SPEECH1 = "Our base is under attack!!",
		},
		PIGCLICK = {
			--"Upgrading your pigking means more lands!",
			--"Upgrading your pigking means more powerful pigmans!",
			--"Give enough points to Upgrad your pigking!",
			"You can hire pig man by gold!!!",
		},
		PIG_MAN_TALK = {
			SPEECH1 = "I hate poop!!!",
		},
		GO_HOME = {
			SPEECH1 = "Home Teleport!",
			SPEECH2 = "Teleport Shutdown!",
			SPEECH3 = "Teleport to home in ",
			SPEECH4 = " Sec!",
			SPEECH5 = "I have not enough sanity to teleport!",
			SPEECH6 = "I have not enough hunger to teleport!",
			SPEECH7 = "Press the 'B' key or 'C' key to teleport Home!!!",
		},
		GROUP_SIGN = {
			SPEECH1 = " \n \n \nThe number of Our Team's Signs is: %d \n Max num is:%d",
			SPEECH2 = "The number of Signs has reached the maximum: %d \n Upgrade pig king to unlock more",
			SPEECH3 = "This is the enemy's Teleport Sign",
			SPEECH4 = "No destination",
			SPEECH5 = "No destination",
			SPEECH6 = "The destination is no longer reachable",
			SPEECH7 = "The ghost cannot be transmitted!",
			SPEECH8 = "It's not safe near!",
			SPEECH9 = "No destination",
			SPEECH10 = "Bad state cannot be transmitted!",
			SPEECH11 = "Teleport in %s sec",
			SPEECH12 = "Keep close!",
			SPEECH13 = "Select destination",
			SPEECH14 = "Who touch me？",
			SPEECH15 = "It's not your turn yet",
			SPEECH16 = "It's not safe to travel now",
			SPEECH17 = "Unknown destination",
			SPEECH18 = "Please come closer",
			SPEECH19 = "I'm in poor condition",
			SPEECH20 = "Transmission starts in %d seconds",
			SPEECH21 = "Someone is teleporting to me!",
			SPEECH22 = "Destination no longer accessible!",
			SPEECH23 = "Ghosts cannot be teleported",
			SPEECH24 = "It's too far from me. Please come near me",
			SPEECH25 = "It's not safe to travel now",
			SPEECH26 = "Home",
		},
		GROUP_PIGHOUSE = {
			SPEECH1 = " \n \n \nThe number of pig house is：%d \n The max number allowed is %d at present",
			SPEECH2 = "The number of pig house has reached the maximum：%d \n Upgrade pig king to unlock more",
		},
		PREVENT_BADBOY = {
			SPEECH1 = "It's not my structure \n I need to survival for 10 day!",
		},
		SPRINT = {
			SPEECH1 = "Go!",
			SPEECH2 = "Charge finished!",
			SPEECH3 = "I'm so hungry!",
			SPEECH4 = "Press the key 'Shift' to sprint!!!",
		},
		SCORE_KILL_NUM = {
			SPEECH1 = "Kill:",
			SPEECH2 = "Points:",
			SPEECH3 = "No.%d",
		},
		COUNT_POINTS = {
			SPEECH1 = "Please dont leave the game, Pigking is counting your points...",
		},
		CHAT_QUEUE = {
			SPEECH1 = "To Everyone",
			SPEECH2 = "To Team",
			SPEECH3 = "[Team] ",
			SPEECH4 = "[Everyone] ",
		},
		ANNOUNCE_SPEECH = {
			"Tip: You can win the game by killing the hostile pig king or winning enough points!",
			"Tip：Press the 'Shift' key can sprint briefly, press the 'C' key can teleport to the home!",
			"Tip：Press 'Y' key to chat in the team, press 'U' key to chat with everyone!",
			"Tip：Press 'Y' to input '#surrender' to initiate a surrender!",
			"Tip：You can be transmitted to the other signs or players nearby by home sign!",
			"Tip：Be kind to pig man, pig man may become your good helper!",
			"Tip：Team survival and confrontation, the last remaining camp will be the winner of the game!",
		},
		SURRENDER_SPEECH = {
			SPEECH1 = "#surrender",
			SPEECH2 = "󰀕Execution Result: Invalid Vote, You have already initiated a surrender",
			SPEECH3 = "󰀕Execution result: Surrender Success %d / %d, we will surrender soon!!!",
			SPEECH4 = "󰀕Execution result: Initiate Surrender %d / %d, at least %d initiators are needed to surrender successfully",
			SPEECH5 = "%s group initiated the surrender, and the surrender operation will be executed soon!!!",
			SPEECH6 = "%s group has surrendered, %s was wiped out!!!",
		},
		MONSTER_POINT = {
			SPEECH1 = "The world is changing...",
			SPEECH2 = "Incredibly, %s has come to this world!!!",
			SPEECH3 = "Incredibly，The world is changing...",
		},
	}
	
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_BIG = "(BLU)Pig Man"
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_RED = "(RED)Pig Man"
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_CUI = "(PUR)Pig Man"
	GLOBAL.STRINGS.NAMES.PKC_PIGMAN_LONG = "(GRE)Pig Man"

	GLOBAL.STRINGS.NAMES.PKC_BIGPIG = "(BLU)Pigking"
	GLOBAL.STRINGS.NAMES.PKC_REDPIG = "(RED)Pigking"
	GLOBAL.STRINGS.NAMES.PKC_CUIPIG = "(PUR)Pigking"
	GLOBAL.STRINGS.NAMES.PKC_LONGPIG = "(GRE)Pigking"
	
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_BIG = "(BLU)Eyeturret"
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_RED = "(RED)Eyeturret"
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_CUI = "(PUR)Eyeturret"
	GLOBAL.STRINGS.NAMES.PKC_EYETURRET_LONG = "(GRE)Eyeturret"
	
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_BIG = "(BLU)Pighouse"
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_RED = "(RED)Pighouse"
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_CUI = "(PUR)Pighouse"
	GLOBAL.STRINGS.NAMES.PKC_PIGHOUSE_LONG = "(GRE)Pighouse"

	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_BIG = "(BLU)Sign"
	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_RED = "(RED)Sign"
	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_CUI = "(PUR)Sign"
	GLOBAL.STRINGS.NAMES.PKC_HOMESIGN_LONG = "(GRE)Sign"

	GLOBAL.STRINGS.NAMES.HOMESIGN = "Teleport Sign"
	GLOBAL.STRINGS.RECIPE_DESC.HOMESIGN = "It can send you to other signs"
end

	
