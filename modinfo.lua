-- This information tells other players more about the mod
name = "111猪王争霸(PigKingCraft)(开发版)III"
description = [[
<饥荒分组生存与对抗>
允许你和你的队友一起对抗其他队伍的成员，最多可分四组，保卫你的猪王，并通过生存和对抗得分赢得比赛的胜利。
<重要>
★需要在无尽和玩家对战模式下开启该模组。
★按Shift键冲刺，C键回城，Y键队伍聊天，U键所有人聊天，按Y输入#投降 即可发起投降。
★比赛结束后会自动重置世界，如果想关闭该功能可在模组配置界面进行配置。
点击右下方的“配置模组”可设置更多选项。                 ↓↓↓

<Team Survival and PvP>
Team survival and protect your pig king, 4 teams at most.
<Important Tips>
You need to open this mod in endless and PvP mode. Press 'Shift' key to sprint, 'C' to go home, 'Y' to team chat, 'U' to everyone chat, Press 'Y' and input '#sur' to surrender.
You can configure other setting in the module configuration page.↓↓↓
]]
--"在这个世界上别太依赖任何人，因为当你在黑暗中挣扎的时候，连你的影子也会离开你." 猪王如是说...
author = "RedPig, 大猪猪"
version = "3.0.9"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10
api_version_dst = 10

priority = -9999

---- Can specify a custom icon for this mod!
--icon_atlas = "modicon.xml"
--icon = "modicon.tex"

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = true

--This lets the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"pkc","redpig","pvp","hard","challenge","group","pigking"}

icon_atlas = "modicon.xml"
icon = "modicon.tex"

--如果是搭建专属服务器，可通过两种方式更改MOD配置。
--一种是直接修改该modinfo文件各配置项的default值（注意UTF-8编码格式）。
--另一种是在modoverride文件中进行配置，具体配置详情请参考链接http://www.lyun.me/lyun/427。

configuration_options =
{
	{
        name = "language",
        label = "游戏语言(Language)",
        options =
        {
			{description = "English", data = "english", hover = "English" },
            {description = "中文", data = "chinese", hover = "中文"},
        },
        default = "chinese",
    },
	{
        name = "win_score",
        label = "总分设置(TotalScore)",
        options =
        {
            {description = "1000分", data = 1000, hover = "闪电战"},
			{description = "2000分", data = 2000, hover = "2000"},
			{description = "3000分", data = 3000, hover = "3000"},
			{description = "4000分", data = 4000, hover = "4000"},
			{description = "5000分", data = 5000, hover = "5000"},
            {description = "10000分", data = 10000, hover = "竞赛" },
			{description = "50000分", data = 50000, hover = "50000" },
			{description = "100000分", data = 100000, hover = "持久战" },
			{description = "无尽(Endless)", data = 999999, hover = "Endless" },
        },
        default = 10000,
    },
	{
        name = "random_group",
        label = "队伍选择(Team Selection)",
        options =
        {
			{description = "随机队伍(RandomTeam)", data = true, hover = "随机队伍(Random Team)" },
            {description = "指定队伍(SpecifyTeam)", data = false, hover = "指定队伍(Specify Team)"},
        },
        default = true,
    },
	{
        name = "group_num",
        label = "分组数(TeamNum)",
        options =
        {
            {description = "2组", data = 2, hover = "2"},
            {description = "3组", data = 3, hover = "3" },
			{description = "4组", data = 4, hover = "4" },
        },
        default = 2,
    },
	{
        name = "peace_time",
        label = "和平时期(PeacefulDays)",
        options =
        {
			{description = "无(None)", data = 0, hover = "none" },
			{description = "5天", data = 5, hover = "5days" },
            {description = "7天", data = 7, hover = "7days"},
			{description = "10天", data = 10, hover = "10days"},
			{description = "15天", data = 15, hover = "15days"},
			{description = "20天", data = 20, hover = "20days"},
			{description = "30天", data = 30, hover = "30days"},
            {description = "50天", data = 50, hover = "50days"},
            {description = "100天", data = 100, hover = "100days"},
            {description = "永远和平(Forever)", data = 99999, hover = "forever"},
        },
        default = 0,
    },
	{
        name = "pigking_health",
        label = "猪王生命(PigKingHealth)",
        options =
        {
			{description = "500", data = 500, hover = "500血" },
			{description = "1000", data = 1000, hover = "1000血" },
			{description = "2000", data = 2000, hover = "2000血" },
			{description = "3000", data = 3000, hover = "3000血" },
			{description = "4000", data = 4000, hover = "4000血" },
			{description = "5000", data = 5000, hover = "5000血" },
			{description = "10000", data = 10000, hover = "10000血" },
			{description = "20000", data = 20000, hover = "20000血" },
			{description = "30000", data = 30000, hover = "30000血" },
			{description = "40000", data = 40000, hover = "40000血" },
			{description = "50000", data = 50000, hover = "50000血" },
			{description = "不可杀(CanNotBeKilled)", data = -1, hover = "Can not be killed" },
        },
        default = 5000,
    },
	{
        name = "give_start_item",
        label = "初始物品(HaveStartItems)",
        options =
        {
            {description = "无(No)", data = false, hover = "不要与其他初始物品MOD一起开/Don't turn on with other initial items mod"},
            {description = "有(Yes)", data = true, hover = "不要与其他初始物品MOD一起开/Don't turn on with other initial items mod" },
        },
        default = true,
    },
	{
        name = "auto_reset_world",
        label = "结束自动重置世界(AutoResetAfterWin)",
        options =
        {
			{description = "否(No)", data = false, hover = "否/No" },
            {description = "是(Yes)", data = true, hover = "赢取胜利后自动重置世界/If auto regenerate world after win"},
        },
        default = true,
    },
	{
        name = "init_eyeturret_num",
        label = "初始防御塔数(EyeTurretNum)",
        options =
        {
			{description = "1", data = 1, hover = "Eyeturret num near pigking"},
            {description = "2", data = 2, hover = "Eyeturret num near pigking"},
			{description = "3", data = 3, hover = "Eyeturret num near pigking"},
			{description = "4", data = 4, hover = "Eyeturret num near pigking"},
			{description = "5", data = 5, hover = "Eyeturret num near pigking"},
			{description = "6", data = 6, hover = "Eyeturret num near pigking"},
        },
        default = 6,
    },
	{
        name = "init_pighouse_num",
        label = "初始防御猪人房数(PigHouseNum)",
        options =
        {
			{description = "1", data = 1, hover = "Pig house num near pigking"},
            {description = "2", data = 2, hover = "Pig house num near pigking"},
			{description = "3", data = 3, hover = "Pig house num near pigking"},
			{description = "4", data = 4, hover = "Pig house num near pigking"},
			{description = "5", data = 5, hover = "Pig house num near pigking"},
			{description = "6", data = 6, hover = "Pig house num near pigking"},
        },
        default = 6,
    },
    {
        name = "prevent_bad_boy",
        label = "防止队友恶意破坏(LimitBadBoy)",
        options =
        {
            {description = "开启(Yes)", data = true, hover = "防止队友恶意破坏开启/Prevent malicious damage by teammates"},
            {description = "关闭(No)", data = false, hover = "防止队友恶意破坏关闭/Prevent malicious damage by teammates"},
        },
        default = true,
    },
    {
        name = "is_long_autumn",
        label = "秋天较长模式(IsLongAutumn)",
        options =
        {
            {description = "否(No)", data = false, hover = "No" },
            {description = "是(Yes)", data = true, hover = "秋天的时间会比其他季节的时间长，占比为4:1:1:1/The Autumn length is longer than other seasons"},
        },
        default = true,
    },
    {
        name = "is_fast_hand",
        label = "快速采集开关(FastHandSwitch)",
        options =
        {
            {description = "关闭(OFF)", data = false, hover = "OFF" },
            {description = "打开(ON)", data = true, hover = "ON"},
        },
        default = true,
    },
    {
        name = "monster_point_switch",
        label = "怪物据点开关(MonsterPointSwitch)",
        options =
        {
            {description = "关闭(OFF)", data = false, hover = "OFF" },
            {description = "打开(ON)", data = true, hover = "ON"},
        },
        default = true,
    },
    {
        name = "portal_spawn_boss",
        label = "第12天出生点安置Boss(PortalSpawnBoss)",
        options =
        {
            {description = "否(No)", data = false, hover = "No." },
            {description = "是(Yes)", data = true, hover = "Yes, spawn boss on day 12."},
        },
        default = true,
    },
}