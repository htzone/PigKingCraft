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
		WINDIALOG_TITLE = "猪王争霸结果",
		WINDIALOG_CONTENT = {
			SPEECH1 = "恭喜 ",
			SPEECH2 = " 阵营 取得了最后的胜利！！！",
		},
		WINDIALOG_BUTTON = "向黑恶势力低头",
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
		GROUP_HASBE_KILLED = "No!  My  group  has  been  wiped  out !",
		REVIVE_TIPS1 = {
			SPEECH1 = "",
			SPEECH2 = "s  To  Revive",
		},
		REVIVE_TIPS2 = "well,  Im  coming  back !",
		BELONG_TIPS = {
			SPEECH1 = "Im  belong  to  ",
			SPEECH2 = " Group !",
		},
		GROUP_JOIN = {
			SPEECH1 = "  has  chosen  the  ",
			SPEECH2 = " Group！",
			SPEECH3 = "We  should  protect  our ",
			SPEECH4 = " !",
		},
		PIGKING_PROTECT = {
			SPEECH1 = "This  is  protected  by  Enemy  PigKing !",
			SPEECH2 = "I  cant  do  that!",
		},
		GRAVESTONE_TIPS = {
			SPEECH1 = "He's  already  asleep!",
			SPEECH2 = "The  pity  is  that ",
			SPEECH3 = "  is  a  history  of  glory!",
		},
		KILLED_ANNOUNCE = {
			SPEECH1 = "  was  killed  by ",
			SPEECH2 = " !!!",
		},
		WINDIALOG_TITLE = "PigKingCraft",
		WINDIALOG_CONTENT = {
			SPEECH1 = "Congratulations ",
			SPEECH2 = " Group  for winning the final Victory!!!",
		},
		WINDIALOG_BUTTON = "CLOSE",
		WORLDRESET_TIPS = {
			SPEECH1 = "The  world  will  be  regenerated  in  30s!!!",
			SPEECH2 = "World  Regenerate  Start !!!",
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
		GROUP_BEKILLED = "KO",
	}
end

	
