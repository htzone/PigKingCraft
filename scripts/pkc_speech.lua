--@name pkc_speech
--@description 对话设定
--@auther redpig
--@date 2016-11-20

--游戏语言

if GetModConfigData("language") == "chinese" then
	--BOSS名字
	GLOBAL.BOSS_NAME = {
		deerclops = {NAME = "巨鹿"},
		moose = {NAME = "巨鸭"},
		bearger = {NAME = "巨熊"},
		dragonfly = {NAME = "龙蝇"},
		minotaur = {NAME = "远古犀牛"},
	}
	
	--语气词
	GLOBAL.MODAL_WORDS = {
	"阿西吧",
	"玛莎卡",
	"害怕",
	}

	--玩家话语
	GLOBAL.PKC_SPEECH = {
		COMMA = "，",
		EXCLA = "！",
		QUEST = "？",
		GROUP_HASBE_KILLED = "不！我的队伍已经被消灭了！！！",
		REVIVE_TIPS1 = {
			SPEECH1 = "还有",
			SPEECH2 = "秒复活",
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
			"我们需要升级猪王获得更多的土地！",
			"我们需要升级猪王获得更强的猪人战士！",
			"获得足够的分数可以升级猪王！",
		},
		GO_HOME = {
			SPEECH1 = "准备回城！",
			SPEECH2 = "回城中断！",
			SPEECH3 = "还有",
			SPEECH4 = "秒回城！",
			SPEECH5 = "精神值过低，不能传送！",
			SPEECH6 = "饥饿值过低，不能传送！",
			SPEECH7 = "按B键还可以回城哦!!!",
		},
	}
else
	GLOBAL.BOSS_NAME = {
		deerclops = {NAME = "Deerclops"},
		moose = {NAME = "Moose"},
		bearger = {NAME = "Bearger"},
		dragonfly = {NAME = "Dragonfly"},
		minotaur = {NAME = "Minotaur"},
	}
	GLOBAL.MODAL_WORDS = {
	"Unbelievable",
	}
	--玩家话语
	GLOBAL.PKC_SPEECH = {
		COMMA = ",",
		EXCLA = "!",
		QUEST = "?",
		GROUP_HASBE_KILLED = "No!  My team  has  been  wiped  out !",
		REVIVE_TIPS1 = {
			SPEECH1 = "I will revive in ",
			SPEECH2 = " sec.",
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
			"Upgrading your pigking means more lands！",
			"Upgrading your pigking means more powerful pigmans！",
			"Give enough points to Upgrad your pigking!",
		},
		GO_HOME = {
			SPEECH1 = "Home Teleport!",
			SPEECH2 = "Teleport Shutdown!",
			SPEECH3 = "Teleport to home in ",
			SPEECH4 = " sec !",
			SPEECH5 = "I dont have enough sanity to teleport!",
			SPEECH6 = "I dont have enough hunger to teleport!",
			SPEECH7 = "Pressing key B can go back to the base!!!\nPressing key B can go back to the base!!!\nPressing key B can go back to the base!!!",
		},
	}
end

	
