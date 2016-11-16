-- This information tells other players more about the mod
name = " AAA猪王争霸（PVP）"
description = [[
PigKingCraft(PVP)
]]

author = "大猪猪, RedPig"
version = "1.0.7"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

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
server_filter_tags = {"pvp","hard","challenge","group"}

icon_atlas = "modicon.xml"
icon = "modicon.tex"

--如果是搭建专属服务器，可通过两种方式更改MOD配置。
--一种是直接修改该modinfo文件各配置项的默认值（注意UTF-8编码格式）。
--另一种是在modoverride文件中进行配置，具体配置详情请参考链接http://www.lyun.me/lyun/427。

configuration_options =
{
	{
        name = "language",
        label = "游戏语言(Language)",
        options =
        {
            {description = "中文(Chinese)", data = "chinese", hover = "中文"},
            {description = "英文(English)", data = "english", hover = "English" },
        },
        default = "chinese",
    },
	{
        name = "group_num",
        label = "分组数(GroupNum)",
        options =
        {
            {description = "2组", data = 2, hover = "2"},
            {description = "3组", data = 3, hover = "3" },
			{description = "4组", data = 4, hover = "4" },
        },
        default = 4,
    },
}