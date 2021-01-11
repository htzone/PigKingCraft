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
			SPEECH5 = "离猪王太近，我不能这么做！",
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
		WINDIALOG_FAILED_BUTTON = "向黑恶势力低头",
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
			SPEECH2 = "猪王正在遭受攻击！！！",
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
		PIGCLICK = {
			--"我们需要升级猪王获得更多的土地！",
			--"我们需要升级猪王获得更强的猪人战士！",
			--"获得足够的分数可以升级猪王！",
			"用金子可以雇佣猪人！！！",
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
			SPEECH1 = " \n \n \n本队已有传送牌数量为：%d，最多为%d",
			SPEECH2 = "本队传送牌数量已达到限制\n最多数量为：",
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
			SPEECH1 = " \n \n \n猪王附近已有猪房数量为：",
			SPEECH2 = "猪王附近猪房数量已达到限制\n最多数量为：",
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
			SPEECH1 = "请勿离开房间，猪王正在拼命地统计分数...",
		},
		MONSTER_POINT = {
			SPEECH1 = "不好了，巨熊降临，世界的平衡即将被打破啦！！！",
		},
		CHAT_QUEUE = {
			SPEECH1 = "对所有人说",
			SPEECH2 = "对队伍内说",
		}
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


	--pkc_pighouse_big
else
	GLOBAL.BOSS_NAME = {
		deerclops = {NAME = "Deerclops"},
		moose = {NAME = "Moose"},
		bearger = {NAME = "Bearger"},
		dragonfly = {NAME = "Dragonfly"},
		minotaur = {NAME = "Minotaur"},
		malbatross = {NAME = "Malbatross"},
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
			SPEECH5 = "It's so close to pigking that I cant do this!",
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
			SPEECH2 = "Our pigking is under attack!!!",
			SPEECH3 = "Level Up! I become a bigger pig!",
			CHAT = {
			"Im happy today!",
			"I like you.",
			"I want to grow up.",
			"Please protect me.",
			"I need cooked food.",
			},
		},
		PIGCLICK = {
			--"Upgrading your pigking means more lands!",
			--"Upgrading your pigking means more powerful pigmans!",
			--"Give enough points to Upgrad your pigking!",
			"pigs like golds!!!",
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
			SPEECH1 = " \n \n \nThe number of Our Team's Signs is: %d, Max num is:%d",
			SPEECH2 = "The number of Signs has reached the maximum: ",
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
			SPEECH1 = " \n \n \nThe number of Pighouse is：",
			SPEECH2 = "The number of PigHouse has reached the maximum：",
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
		MONSTER_POINT = {
			SPEECH1 = "Be careful! The bearger has come to this world...",
		},
		CHAT_QUEUE = {
			SPEECH1 = "To Every One",
			SPEECH2 = "To Group",
		}
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

	
