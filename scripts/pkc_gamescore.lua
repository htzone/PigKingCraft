--
-- 分数设定
-- Author: RedPig
-- Date: 2016/11/18
--

--分数设定
GLOBAL.GAME_SCORE = {
	--击杀
	KILL = {
		PLAYER = 50, --玩家
		KING = 1000, --猪王首领
		pkc_pigman_big = 10, --战斗猪人
		pkc_pigman_red = 10,
		pkc_pigman_cui = 10,
		pkc_pigman_long = 10,
		walrus = 20, --海象
		warg = 50, --狗王
		spiderqueen = 50, --蜘蛛女王
		rook = 40, --战车
		bishop = 20, --主教
		knight = 10, --发条骑士
		leif = 25, --树精
		leif_sparse = 50, --稀有树精 
		hound = 3, --狗
		icehound = 5, --冰狗
		firehound = 5, --火狗
		tentacle = 20, --触手
		deerclops = 1000, --巨鹿
		moose = 500, --巨鸭
		mossling = 25, --小鸭
		bearger = 1000, --巨熊
		dragonfly = 2000, --龙蝇
		beequeen = 2000, --蜂后
		minotaur = 1000, --远古犀牛
		worm = 20, --远古虫子
		slurper = 10, --缀食者
		merm = 10, --鱼人
		krampus = 40, --坎普斯
		spider_warrior = 5, --黄蜘蛛
		spider = 2, --蜘蛛
		lightninggoat = 10, --电羊
		pigguard = 10, --猪守卫
		pkc_pigguard = 10, --猪守卫
		tallbird = 15, --高鸟
		crawlinghorror = 2, --爬行暗影怪
		terrorbeak = 4, --尖嘴暗影怪
		koalefant_summer = 10, --夏象
		koalefant_winter = 10, --冬象
		beefalo = 10, --牛
		malbatross = 500,-- 不知道什么鸟 就叫海鸥吧
		
	},
	
	--贡献
	GIVE = {
		--基本原材料
		cutgrass = 1, --草
		twigs = 1, --树枝
		flint = 1,--燧石
		rocks = 1,--岩石
		nitre = 2,--硝石
		log = 1,--木头
		marble = 2, --大理石
		thulecite_pieces = 2, --铥矿碎片
		spidergland = 2, -- 蜘蛛腺体
		silk = 2, --蜘蛛丝
		pigskin = 5, --猪皮
		goldnugget = 2, --金子
		nightmarefuel = 2, --噩梦燃料
		houndstooth = 2, --犬牙
		charcoal = 1,--木炭
		cutreeds = 4,--采下的芦苇
		
		--中级原材料
		tentaclespots = 10, --触手皮
		slurtleslime = 20, --蜗牛粘液
		slurtle_shellpieces = 20, --蜗牛龟壳
		thulecite = 10, --铥矿石
		papyrus = 16, --纸
		livinglog = 20, --活木头
		horn = 20, --牛角
		feather_crow = 2,--乌鸦羽毛
		feather_robin = 4,--红雀羽毛
		feather_robin_winter = 6,--雪雀羽毛
		feather_canary = 8,
		coontail = 10, --浣熊尾巴
		lightninggoathorn = 15, --电羊角
		beardhair = 10, --胡子
		beefalowool = 5, --牛毛
		boards = 4,--木板
		cutstone = 4,--石砖
		rope = 4, --绳子
		lightbulb = 2, --荧光果
		
		--高级原材料
		gears = 25, --齿轮
		walrus_tusk = 50,--海象牙
		slurper_pelt = 50, --缀食者之皮
		deerclops_eyeball = 100, --巨鹿眼球
		minotaurhorn = 1000, --远古守护者角
		bearger_fur = 20, --熊皮
		goose_feather = 30, --鹿鸭羽毛
		dragon_scales = 30,  --蜻蜓鳞片

		--宝石
		purplegem = 20, --紫宝石
		greengem = 20, --绿宝石
		orangegem = 20, --橙宝石
		yellowgem = 20, --黄宝石
		bluegem = 20, --蓝宝石
		redgem = 20,--红宝石
		
		--食物（猪人喜欢熟食）
		--素的
		red_cap_cooked = 2, --煮熟的红蘑菇
		green_cap_cooked = 2, --煮熟的绿蘑菇
		blue_cap_cooked = 2, --煮熟的蓝蘑菇
		carrot_cooked = 5, --熟胡萝卜
		berries_cooked = 3, --熟浆果
		honey = 3, --蜂蜜
		taffy = 5, --太妃糖
		dragonfruit_cooked = 15, --熟火龙果
		pomegranate_cooked = 15, --熟石榴
		corn_cooked = 10, --熟玉米
		eggplant_cooked = 10, --熟茄子
		jammypreserves = 15, --果酱蜜饯
		fruitmedley = 15, --水果拼盘
		perogies = 15, --半圆小酥饼
		waffles  = 20, --华夫饼
		dragonpie = 25, --龙馅饼
		stuffedeggplant = 25, --香酥茄盒
		wormlight = 20, --远古虫子果
		cookedmandrake = 50, --熟曼特拉草
		mandrakesoup = 70, --曼德拉草汤
		cave_banana_cooked = 8, --熟洞穴香蕉
		watermelonicle = 20, --西瓜冰
		icecream = 15, --冰激淋
		flowersalad = 15, --花沙拉
		
		--荤的
		trunk_cooked = 20, --熟象鼻
		cookedsmallmeat = 4, --小熟肉
		cookedmeat = 8, --大熟肉
		smallmeat_dried = 10, --小干肉
		meat_dried = 20, --大干肉
		fish_cooked = 8, --熟鱼
		drumstick_cooked = 5, --熟鸡腿
		tallbirdegg_cooked = 20, --熟高鸟蛋
		kabobs = 15, --肉串
		butterflymuffin = 30, --奶油松饼
		frogglebunwich = 15, --青蛙圆面包三明治
		pumpkincookie = 20, --南瓜饼
		honeyham = 30, --蜜汁火腿
		powcake = 30, --芝士蛋糕
		butter = 15, --黄油
		baconeggs = 25, --鸡蛋火腿
		bonestew = 30, --肉汤
		fishtacos  = 30, --玉米饼包炸鱼
		turkeydinner = 30, --火鸡正餐
		fishsticks = 20, --鱼肉条
		honeynuggets = 30, --甜蜜金砖
		meatballs = 15, --肉丸
		eel_cooked = 10, --熟鳗鱼
		unagi = 20, --鳗鱼料理
		batwing_cooked = 10, --熟蝙蝠翅膀
		monsterlasagna = 1, --怪物千层饼
		bird_egg_cooked = 2, --煎蛋
		goatmilk = 20, --羊奶
		hotchili = 20, --咖喱

		--TODO
	},
}

for k, _ in pairs(GLOBAL.GAME_SCORE.GIVE) do
	AddPrefabPostInit(k, function(inst)
		if GLOBAL.TheWorld.ismastersim then
			if not inst.components.tradable then
				inst:AddComponent("tradable")
			end
		end
	end)
end

	