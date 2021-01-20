--
-- 全局常量
-- Author: RedPig
-- Date: 2016/10/03
--

------[[声明全局常量]]----
	local TUNING = GLOBAL.TUNING
	--巨鹿生命值
	TUNING.DEERCLOPS_HEALTH = TUNING.DEERCLOPS_HEALTH * 2
	--巨鸭生命值
	TUNING.MOOSE_HEALTH = TUNING.MOOSE_HEALTH * 2
	--巨熊生命值
	TUNING.BEARGER_HEALTH = TUNING.BEARGER_HEALTH * 2.5
	--女武神初始物品
	TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WATHGRITHR = {"meat", "meat", "meat", "meat"}
	--维斯初始物品
	TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WES = {"tophat"}
	--维斯伤害系数
	TUNING.WES_DAMAGE_MULT = 0.95
	--温蒂生命值
	TUNING.WENDY_HEALTH = TUNING.WILSON_HEALTH * 0.8
	--阿比阿盖尔生命值
	TUNING.ABIGAIL_HEALTH = TUNING.WILSON_HEALTH * 4
	--读触手书消耗的脑残
	GLOBAL.READ_BOOK_TENTACLES_SANITY = 50
	--读催眠书消耗的脑残
	GLOBAL.READ_BOOK_SLEEP_SANITY = 20
	--秋天较长模式开关
	GLOBAL.PKC_IS_LONG_AUTUMN = GetModConfigData("is_long_autumn")
	if GLOBAL.PKC_IS_LONG_AUTUMN then
		TUNING.AUTUMN_LENGTH = 30
		TUNING.WINTER_LENGTH = 15
		TUNING.SPRING_LENGTH = 10
		TUNING.SUMMER_LENGTH = 5
		TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT = 30
	end
	
	--猪王等级对应数据
	GLOBAL.PIGKING_LEVEL_CONSTANT = {
		[1] = {LEVEL = 1, PIGKING_RANGE = 20, RANGE_SCALE = 1.75},
		[2] = {LEVEL = 2, PIGKING_RANGE = 22, RANGE_SCALE = 1.85},
		[3] = {LEVEL = 3, PIGKING_RANGE = 24, RANGE_SCALE = 1.95},
		[4] = {LEVEL = 4, PIGKING_RANGE = 26, RANGE_SCALE = 2.05},
		[5] = {LEVEL = 5, PIGKING_RANGE = 29, RANGE_SCALE = 2.15},
		[6] = {LEVEL = 6, PIGKING_RANGE = 32, RANGE_SCALE = 2.25},
		[7] = {LEVEL = 7, PIGKING_RANGE = 35, RANGE_SCALE = 2.35},
		[8] = {LEVEL = 8, PIGKING_RANGE = 38, RANGE_SCALE = 2.45},
		[9] = {LEVEL = 9, PIGKING_RANGE = 41, RANGE_SCALE = 2.55},
		[10] = {LEVEL = 10, PIGKING_RANGE = 45, RANGE_SCALE = 2.65},
	}
	
	--回城等待时间(秒)
	GLOBAL.GOHOME_WAIT_TIME = 10
	--回城精神消耗
	GLOBAL.GOHOME_SANITY_DELTA = 15
	--回城饥饿消耗
	GLOBAL.GOHOME_HUNGER_DELTA = 15
	--冲刺饥饿消耗
	GLOBAL.SPRINT_HUNGER_DELTA = 5
	--战斗猪人初始攻击力
	GLOBAL.PKC_PIGMAN_DAMAGE = 1.2 * TUNING.PIG_DAMAGE
	--战斗猪人初始生命值
	GLOBAL.PKC_PIGMAN_HEALTH = 400
	--战斗猪人初始攻击频率
	GLOBAL.PKC_PIGMAN_ATTACKPERIOD = 0.8 * TUNING.PIG_ATTACK_PERIOD
	--眼球塔攻击力
	GLOBAL.PKC_EYETURRET_DAMAGE = 30
	--眼球塔生命
	GLOBAL.PKC_EYETURRET_HEALTH = 1000
	--每队允许传送牌的数量
	GLOBAL.PKC_GROUPHOMESIGN_NUM = 30
	--猪王附近最大猪房数量
	GLOBAL.PKC_MAX_PIGHOUSE_NUM = 30
	GLOBAL.PKC_HOST = "www.redpig666.com"
