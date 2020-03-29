--
-- 属性显示
-- Author: RedPig
-- Date: 2016/11/05
--

local _G = GLOBAL

local GetGlobal=function(gname,default)
    local res=_G.rawget(_G,gname)
    if res == nil and default ~= nil then
        _G.rawset(_G,gname,default)
        return default
    end
    return res
end

local mods = GetGlobal("mods",{})

local GetTime = _G.GetTime
local TheNet = _G.TheNet
local CLIENT_SIDE =	 _G.TheNet:GetIsClient() or (TheNet:GetIsServer() and not TheNet:IsDedicated())

local tonumber = _G.tonumber
local food_order = 0
local food_style = 0
local food_estimation = -1
local show_food_units = -1

local MY_STRINGS =
{
    {armor = "护甲: " }, --A
    {aggro = "攻击: " }, --B
    {cookpot = "也许会是" }, --C (Crock Pot)
    {dmg = "伤害: " }, --D
    {electric = "电力: " }, --E --electric power
    {food = "食物: "},
    {S2="现在是夏天，" }, --G
    {health= "生命: " }, --H --for food
    {warm = "保温: " }, --I --winter insulation
    {kill = "击杀: " }, --J  --for Canibalism 18 mod
    {kills = "击杀数: " }, --K  --for Canibalism 18 mod
    {loyal = "忠诚: " }, --L  --pigman and bunnyman
    {S4="现在是秋天，" }, --M
    {remaining_days = "剩余天数" }, --N
    {owner = "所有者: " }, --O --support of various mods
    {power = "力量: "}, --P --usually means strengths of a weapon but not physical damage
    {hunger= "饥饿: " }, --Q
    {range = "伤害范围: " }, --R  --for range weapon or for mobs
    {sanity= "理智: " }, --S
    {thickness = "厚度: " }, --T
    {units_of = "个单位的" }, --U
    {resist = "抵抗: " }, --V --against sleep darts, ice staff etc
    {waterproof = "防水: " }, --W
    {heal = "治愈: " }, --X
    {fishes = "鱼数: " }, --Y  --in a pond
    {fish = "鱼: " }, --Z
    {sec= "秒数: " },  --for cooking in Crock Pot
    {love = "喜爱: " },
    {summer = "隔热: "} , --summer insulation
    {absorb = "吸收: "} ,
    {S3="现在是春天，" }, --
    {is_admin = "这是管理员！\n他不进行游戏，\n所以不要理他。" },
    {temperature = "温度" },
    {hp= "基本生命: "} , --for characters
    {armor_character = "基本防御: " },
    {sanity_character = "基本理智: " }, --S
    {fuel = "燃料: " }, --F --for firepit
    {speed = "速度: " },
    {uses_of = "次使用的" },
    {obedience = "服从: " },
    {S1="现在是冬天，" },
    {dmg_character = "伤害: " },
    {perish = "" }, --P -- Spoil in N days. -usually means strengths of weapon but not physical damage
}

SHOWME_STRINGS = {
    loyal = "臣服", --for very loyal pigman with loyalty over 9000
    of = " 属于 ", -- X of Y (reserved)
    units_1 = "1 单位 ",
    units_many = " 单位 ",
    uses_1 = "1 次已使用，共 ",
    uses_many = " 次已使用，共 ", --X uses of Y, where X > 1
    days = " 天后腐烂", --Spoil in N days.
}

FOOD_TAGS = {
    veggie = "蔬菜",
    fruit = "水果",
    monster = "怪物",
    sweetener = "糖类",
    meat = "肉类",
    fish = "鱼类",
    magic = "魔法",
    egg = "蛋类",
    decoration = "首饰",
    dairy = "乳制品",
    fat = "油脂",
    inedible = "不可食用",
    frozen = "冰冻",
    seed = "种子",

    --Waiter 101
    fungus = "菌类", --all mushroom caps + cutlichen
    mushrooms = "蘑菇", --all mushroom caps
    poultry = "禽肉",
    wings = "翅膀", --about batwing
    seafood = "海鲜",
    nut = "坚果",
    cactus = "仙人掌",
    starch = "淀粉类", --about corn, pumpkin, cave_banana
    grapes = "葡萄", --grapricot
    citrus = "柑橘类", --grapricot_cooked, limon
    tuber = "块茎", --yamion
    shellfish = "贝类", --limpets, mussel

    --BEEFALO MILK and CHEESE mod
    rawmilk = "生奶",

    --Camp Cuisine: Re-Lunched
    bulb = "荧光果", --lightbulb
    spices = "香料",
    challa = "辫子面包", -- Challah bread
    flour = "面粉", --flour

    --Chocolate
    cacao_cooked == "可可",
}

MY_DATA = {}
for i,v in ipairs(MY_STRINGS) do
    for k,str in pairs(v) do --одна пара
        MY_DATA[k] = {
            desc = str,
            id = i,
            sym = string.char(i+64), -- A+
            fn = nil, --Function to return the proper string. By default: desc + " " + param1
            percent = nil, --To add "%" at the end of the number
        }
        v.key = k
        break
    end
end


local function DefaultDisplayFn(arr)
    if arr.data == nil then
        return arr.param_str
    end
    if arr.data.sign ~= nil and (tonumber(arr.param[1]) or -1) >= 0 then
        arr.param[1] = "+" .. tostring(arr.param[1])
    end
    local s = arr.data.desc .. " " .. tostring(arr.param[1])
    if arr.data.percent ~= nil then
        s = s .. "%"
    end
    return s
end
CallDefaultDisplayFn = DefaultDisplayFn

MY_DATA.hp.fn = function(arr)
    local cur,mx = arr.param[1], arr.param[2]
    return cur .. " / " .. mx
end
MY_DATA.owner.fn = function(arr)
    return arr.data.desc .. " " .. arr.param_str
end
MY_DATA.loyal.fn = function(arr)
    if (tonumber(arr.param[1]) or 0) > 9000 then
        return arr.data.desc .. " " .. SHOWME_STRINGS.loyal
    end
    return DefaultDisplayFn(arr)
end

MY_DATA.sanity_character.percent = true
MY_DATA.sanity.sign = true
MY_DATA.dmg_character.percent = true
MY_DATA.dmg_character.sign = true
MY_DATA.speed.percent = true
MY_DATA.speed.sign = true
MY_DATA.temperature.sign = true
MY_DATA.armor.percent = true
MY_DATA.armor_character.percent = true
MY_DATA.armor_character.sign = true
MY_DATA.waterproof.percent = true


local is_Fahrenheit = false
local function ConvertTemperature(val)
    if not val then
        return "???"
    end
    if is_Fahrenheit then
        return math.floor(1.8*(val) + 32.5).."\176F"
    else
        return math.floor(val/2 + 0.5) .. "\176C"
    end
end

MY_DATA.temperature.sign = true
MY_DATA.temperature.fn = function(arr)
    arr.param[1] = ConvertTemperature(tonumber(arr.param[1]))
    return DefaultDisplayFn(arr)
end

MY_DATA.cookpot.fn = function(arr)
    local product = tostring(arr.param[1] or 0)
    return arr.data.desc .. " " .. (_G.STRINGS.NAMES[string.upper(product)] or product)
end
MY_DATA.food.fn = function(arr)
    local hg,sn,hp = arr.param[1],arr.param[2],arr.param[3]
    if food_order <= 1 then
        if food_style <= 1 then
            return MY_DATA.hunger.desc .. " "..hg.." / "..MY_DATA.sanity.desc.." "..sn.." / "..MY_DATA.health.desc.." "..hp
        else
            return hg.." / "..sn.." / "..hp
        end
    else
        if food_style <= 1 then
            return MY_DATA.health.desc.." "..hp.." / "..MY_DATA.hunger.desc.." "..hg.." / "..MY_DATA.sanity.desc.." "..sn
        else
            return hp.." / "..hg.." / "..sn
        end
    end
end
MY_DATA.units_of.fn = function(arr)
    local s = FOOD_TAGS[arr.param[2]]
    s = s ~= "" and s or arr.param[2] --If translation exists.
    if arr.param[1] == "1" then
        return SHOWME_STRINGS.units_1 .. s
    else
        return arr.param[1] .. SHOWME_STRINGS.units_many .. s
    end
end
MY_DATA.uses_of.fn = function(arr)
    if arr.param[1] == "1" then
        return SHOWME_STRINGS.uses_1 .. arr.param[2]
    else
        return arr.param[1] .. SHOWME_STRINGS.uses_many .. arr.param[2]
    end
end
MY_DATA.perish.fn = function(arr)
    return arr.data.desc .. " " .. arr.param[1] .. SHOWME_STRINGS.days
end

MY_DATA.heal.sign = true
MY_DATA.fuel.percent = true
MY_DATA.obedience.percent = true
if show_food_units == 0 or show_food_units == 2 then
    MY_DATA.units_of.hidden = true --Work on client only.
end


do
    local support_languages = { ru = true, chs = true, cht = true, br = true, pl = true, }
    --For override: name=file. Example: ,cht="chs",

    AddPrefabPostInit("world",function(inst)
        local lang = _G.LanguageTranslator.defaultlang --print("LANG=",lang)
        if lang == nil then
            return
        end
        if support_languages[lang] ~= nil then
            if support_languages[lang] ~= true then --алиас
                lang = support_languages[lang]
            end
            --modimport("showme_"..lang..".lua")
            --modimport("showme_chs.lua")
        end
        --print(MY_STRINGS_OVERRIDE)
        if MY_STRINGS_OVERRIDE ~= nil then --Меняем локальный перевод (в т.ч. для хоста).
            for k,tr in pairs(MY_STRINGS_OVERRIDE) do
                local data = MY_DATA[k]
                if data ~= nil then
                    data.desc = tr
                    --else MY_STRINGS[k] = {tr}
                end
            end
        end
        --print(MY_STRINGS.aggro[1])
    end)
end



--Попытка определить клиентские моды и отправить их через RPC
AddModRPCHandler("ShowMe","AOS",function(inst)
    --Вызов этой функции означает отключение подсказок на деревьях для данного игрока.
    inst.has_AlwaysOnStatus = true
end)

--Учитывать ли статус порчи для конкретного пользователя.
AddModRPCHandler("ShowMe","Estimate",function(inst)
    --Вызов этой функции означает отключение подсказок на деревьях для данного игрока.
    inst.should_Estimate_Stale = true
end)


--Залезаем в клиентский интерфейс с целью уменьшить показываемую температуру
if CLIENT_SIDE then
    --Делаем самую правильную в мире функцию "AddPlayersPostInit"
    --GetGlobal("mods",{})
    --if not _G.rawget(_G,"mods") then _G.rawset(_G,"mods",{}) end
    if not mods.player_preinit_fns then
        mods.player_preinit_fns={}
        --Dirty hack
        local old_MakePlayerCharacter = _G.require("prefabs/player_common")
        local function new_MakePlayerCharacter(...)
            local inst=old_MakePlayerCharacter(...)
            for _,v in ipairs(mods.player_preinit_fns) do
                v(inst)
            end
            return inst
        end
        _G.package.loaded["prefabs/player_common"] = new_MakePlayerCharacter
    end

    local function AddPlayersPreInit(fn)
        table.insert(mods.player_preinit_fns,fn)
    end

    local player_postinit_fns = {}
    local function AddPlayersPostInit(fn) -- <<<--------- Вот она!
        table.insert(player_postinit_fns,fn)
    end

    local done_players = {}
    AddPlayersPreInit(function(inst)
        local s = inst.prefab or inst.name
        if not done_players[s] then
            done_players[s] = true
            AddPrefabPostInit(s,function(inst)
                for _,v in ipairs(player_postinit_fns) do
                    v(inst)
                end
            end)
        end
    end)

    local player_afterinit_fns = {}
    local function AddPlayersAfterInit(fn) --Нулевой таймер после
        table.insert(player_afterinit_fns,fn)
    end
    AddPlayersPostInit(function(inst) --Задаем нулевой таймер
        if #player_afterinit_fns > 0 then
            inst:DoTaskInTime(0,function(inst)
                for i=1,#player_afterinit_fns do
                    player_afterinit_fns[i](inst)
                end
            end)
        end
    end)


    --Проверка температуры. Обратный формат и приведение к универсальному Цельсию.
    local tonumber = _G.tonumber
    local function FixTemperature(s)
        if type(s) ~= "string" then
            return s --Вообще не строка. Что за?
        end
        --На конце может быть один из конкретных вариантов строки.
        local sep = s:find("\176",1,true)
        if not sep then
            return s --Разделитель не найден.
        end
        local pre, pst = tonumber(s:sub(1,sep-1)), s:sub(sep+1)
        if not pre then
            return s --Первая часть строки не является числом.
        end
        if pst == "C" then
            return s --Это Цельсий. Не надо конвертировать.
        elseif pst == "F" then
            --Фаренгейт. Сложный случай. В целом тоже не надо трогать. Но меняем локальные настройки на Фаренгейт.
            is_Fahrenheit = true
            return s
        else
            --Иначе (по умолчанию) считаем, что температура в игровых единицах. Исправляем это дело на Цельсий.
            return ConvertTemperature(pre) --TODO: Есть небольшая погрешность в уменьшение. При температуре 5.1 покажется цифра 2, хотя должна 3.
        end
    end

    --Функция исправления интерфейса на клиенте. Запускается для всех игроков при появлении.
    local function FixClient(inst)
        if inst ~= _G.ThePlayer then
            return
        end

        --По-хакерски добавляем отправку настроек предпочтения показа еды
        if food_estimation == 1 then
            --print("SendRPC")
            SendModRPCToServer(MOD_RPC.ShowMe.Estimate)
        end

        local status = inst.HUD and inst.HUD.controls and inst.HUD.controls.status
        if not status then
            print("ERROR SHOW_ME: Can't fix client side status!")
            return
        end
        local AOS
        if status.temperature then
            AOS = true
            local old_SetString = status.temperature.num.SetString
            status.temperature.num.SetString = function(self,s)
                return old_SetString(self,FixTemperature(s))
            end
        end
        if status.worldtemp then
            AOS = true
            local old_SetString = status.worldtemp.num.SetString
            status.worldtemp.num.SetString = function(self,s)
                return old_SetString(self,FixTemperature(s))
            end
        end
        if AOS then
            SendModRPCToServer(MOD_RPC.ShowMe.AOS)
        end
    end
    AddPlayersAfterInit(FixClient)
end



--Works only on host.
if TheNet and TheNet:GetIsServer() then
    require = _G.require





    --Detecting enabled mods
    local mod_names	 --названия всех модов (чтобы не дергать джвижок)
    local mod_names_nover --названия модов с обрезанной версией (если смысловая часть достаточно длинная)
    mod_names = {}
    mod_names_nover = {}
    local function GetAllModNames()
        if not (_G.KnownModIndex and _G.KnownModIndex.savedata and _G.KnownModIndex.savedata.known_mods
                and _G.ModManager and _G.ModManager.enabledmods)
        then
            return
        end
        local folders = {} --ассоциативный массив включенных модов (по папкам)
        for _,v in ipairs(_G.ModManager.enabledmods) do
            folders[v]=true
        end
        for folder, mod in pairs(_G.KnownModIndex.savedata.known_mods) do
            local name = mod.modinfo.name
            if name then
                mod_names[name]=folders[folder] and true or false
                --print("NEW_MOD: "..name.." "..tostring(mod_names[name]))
                local s=string.match(name,"^(.-)([0-9%._ ]+)$")
                if s then
                    mod_names_nover[s]=name --обрезаем номер версии с конца
                    --вместо true сохраняем полное имя мода (чтобы идентифицировать его в системе)
                else
                    mod_names_nover[name]=name
                end
            end
        end
    end
    GetAllModNames()
    mods.mod_names = mod_names
    mods.mod_names_nover = mod_names_nover


    local function SearchForModsByName()
        if mods.active_mods_by_name then
            return --Уже проинициализировано. Либо полная несовместимость.
        end
        mods.active_mods_by_name = {}
        if not (_G.KnownModIndex and _G.KnownModIndex.savedata and _G.KnownModIndex.savedata.known_mods) then
            print("ERROR COMMON LIB: Can't find KnownModIndex!")
            return
        end
        for name,mod in pairs(_G.KnownModIndex.savedata.known_mods) do
            if (mod.enabled or mod.temp_enabled or _G.KnownModIndex:IsModForceEnabled(name)) --Мод активен
                    and not mod.temp_disabled --И не отключен
            then
                local real_name = mod.modinfo.name
                if real_name == nil then
                    print("SHOW_ME ERROR: real_name of a mod is nil,",tostring(name))
                    --TODO: error if TUNING.STAR_DEBUG
                else
                    mods.active_mods_by_name[real_name] = true
                end
            end
        end
    end
    SearchForModsByName()

    local is_HealthInfo = mods.active_mods_by_name["Health Info"] --Check it to decide, is there a reason to show hp in description.
    local is_DisplayFoodValues = mods.active_mods_by_name["Display food values"]
    --TODO: Эта проверка нужна на клиенте!
    local is_AlwaysOnStatus = mods.active_mods_by_name["Combined Status"] or mods.active_mods_by_name["Always On Status"]
    --_G.arr(mod_names)

    local cooking = require("cooking")
    local ing = cooking.ingredients

    local ww
    AddPrefabPostInit("world",function(inst)
        ww = inst.state
    end)

    local function GetPerishTime(inst,c)
        local modifier = 1
        local owner = c.inventoryitem and c.inventoryitem.owner or nil
        if owner == nil and c.occupier ~= nil then
            owner = c.occupier:GetOwner() --Для птичек?
        end

        if owner ~= nil then
            if owner:HasTag("fridge") then
                if inst:HasTag("frozen") and not owner:HasTag("nocool") and not owner:HasTag("lowcool") then
                    modifier = TUNING.PERISH_COLD_FROZEN_MULT
                else
                    modifier = TUNING.PERISH_FRIDGE_MULT
                end
            elseif owner:HasTag("spoiler") then
                modifier = TUNING.PERISH_GROUND_MULT
                --elseif owner:HasTag("cage") and inst:HasTag("small_livestock") then
                --	modifier = TUNING.PERISH_CAGE_MULT
            end
        else
            modifier = TUNING.PERISH_GROUND_MULT
        end

        if inst:GetIsWet() then
            modifier = modifier * TUNING.PERISH_WET_MULT
        end


        if ww.temperature < 0 then
            if inst:HasTag("frozen") and not c.perishable.frozenfiremult then
                modifier = TUNING.PERISH_COLD_FROZEN_MULT
            else
                modifier = modifier * TUNING.PERISH_WINTER_MULT
            end
        end

        if c.perishable.frozenfiremult then
            modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
        end

        if ww.temperature > TUNING.OVERHEAT_TEMP then
            modifier = modifier * TUNING.PERISH_SUMMER_MULT
        end

        if c.perishable.localPerishMultiplyer then
            modifier = modifier * c.perishable.localPerishMultiplyer
        end

        modifier = modifier * TUNING.PERISH_GLOBAL_MULT

        local old_val = c.perishable.perishremainingtime
        if old_val ~= nil then
            local delta = old_val / modifier
            return delta
        end
    end



    --Новая функция
    local desc_table
    local function cn(key,param1,param2,param3)
        local data = MY_DATA[key]
        if data == nil then
            return
        end
        if param1 == nil then
            table.insert(desc_table, data.sym)
            return
        end
        if param2 == nil then
            table.insert(desc_table, data.sym ..tostring(param1))
            return
        end
        if param3 == nil then
            table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2))
            return
        end
        table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2) .. "," ..tostring(param3))
        return
    end

    --nice round function
    local round2=function(num, idp)
        return _G.tonumber(string.format("%." .. (idp or 0) .. "f", num))
    end

    local is_admin
    local last_user_talbe = {}
    --Проверяет, является ли чел админом.
    local function IsAdmin(viewer)
        if is_admin ~= nil then
            return is_admin
        end
        if not (viewer and viewer.userid) then
            return false
        end
        for i=1,#last_user_talbe do
            local user = last_user_talbe[i]
            if user.userid == viewer.userid then
                is_admin = user.admin or false
                return is_admin
            end
        end
        last_user_talbe = _G.TheNet:GetClientTable()
        for i=1,#last_user_talbe do
            local user = last_user_talbe[i]
            if user.userid == viewer.userid then
                is_admin = user.admin or false
                return is_admin
            end
        end
    end


    local function name_by_id(userid)
        for i,v in ipairs(_G.AllPlayers) do
            if v.userid == userid then
                return v.name
            end
        end
        return "---Unknown---"
    end
    --GetGlobal("name_by_id",name_by_id)

    function GetTestString(item,viewer) --Отныне форкуемся от Tell Me, ибо всё сложно.
        --line_cnt = 0
        desc_table = {} --старый desc отменяется

        is_admin = nil
        local prefab = item.prefab
        local c=item.components
        local has_owner = false --Выводим инфу о владельце лишь ОДИН раз!
        if (prefab=="evergreen" or prefab=="deciduoustree") and not viewer.has_AlwaysOnStatus then
            --if not is_AlwaysOnStatus then --TODO: Do not check! NB!
            local w=_G.TheWorld.state
            local tt=round2(w.temperature,1)
            if w.iswinter then cn("S1")
            elseif w.issummer then cn("S2")
            elseif w.isspring then cn("S3")
            elseif w.isautumn then cn("S4")
            end
            cn("remaining_days",w.remainingdaysinseason)
            cn("temperature",tt)
        elseif c.health and not item.grow_stage then --Health, Hunger, Sanity Bar
            local h=c.health
            --cheat
            if item.is_admin then
                cn("is_admin")
                return desc_table[1]
            end

            if not is_HealthInfo then --c.health
                local mx=math.ceil(h.maxhealth-h.minhealth)
                local cur=math.ceil(h.currenthealth-h.minhealth)
                if cur>mx then cur=mx end
                cn("hp",cur,mx)
            end
            if c.hunger and c.hunger:GetPercent()<=0.5 then
                cn("hunger",round2(c.hunger.current,1))
            end
            if c.sanity and c.sanity:GetPercent()<=0.5 then
                local sanity = round2(math.floor(c.sanity:GetPercent()*100+0.5),1)
                cn("sanity_character",sanity)
            end
            if c.follower then
                if c.follower.leader and c.follower.leader:IsValid() and c.follower.leader:HasTag("player")
                        and c.follower.leader.name and c.follower.leader.name ~= ""
                then
                    cn("owner",c.follower.leader.name)
                    has_owner = true
                end
                if c.follower.maxfollowtime then
                    mx = c.follower.maxfollowtime
                    cur = math.floor(c.follower:GetLoyaltyPercent()*mx+0.5)
                    if cur>0 then
                        cn("loyal",cur,mx)
                    end
                end
            end
            if item.kills and item.kills>0 then
                cn(item.kills==1 and "kill" or "kills",item.kills)
            end
            if item.aggro and item.aggro>0 then
                cn("aggro",item.aggro)
            end
            if c.combat and c.combat.damagemultiplier and c.combat.damagemultiplier ~= 1 then
                local perc = c.combat.damagemultiplier - 1
                cn("dmg_character",round2(perc*100,0))
            end
            if h.absorb~=0 or h.playerabsorb~=0 then
                local perc = 1-(1-h.absorb)*(1-h.playerabsorb)
                cn("armor_character",round2(perc*100,0))
            end
            if item.asunaheal_score and item.prefab == "asuna" and TUNING.ASUNA_HEAL_SCORE_SWORD
                    and item.asunaheal_score < TUNING.ASUNA_HEAL_SCORE_SWORD
            then
                local asuna_proof = round2(math.floor((item.asunaheal_score/TUNING.ASUNA_HEAL_SCORE_SWORD)*100+0.5),0)
                if asuna_proof > 99 then
                    asuna_proof = 99
                end
                table.insert(desc_table, "$Asuna Proof: "..asuna_proof.."%")
            end
            --inst.components.domesticatable:GetObedience()
            if c.domesticatable ~= nil and c.domesticatable.GetObedience ~= nil then
                local obedience = c.domesticatable:GetObedience()
                if obedience ~= 0 then
                    cn("obedience",round2(obedience*100,0))
                end
            end
        elseif prefab~="rocks" and prefab~="flint" then --No rocks and flint
            --Part 1: primary info
            if c.stewer and c.stewer.product and c.stewer.IsCooking and c.stewer:IsCooking() then
                local tm=round2(c.stewer.targettime-_G.GetTime(),0)
                if tm<0 then tm=0 end
                cn("cookpot", c.stewer.product)
                cn("sec",tm)
            end
            --Part 2: secondary info
            if c.armor and c.armor.absorb_percent and type(c.armor.absorb_percent)=="number" then
                local r=c.armor.absorb_percent
                cn("armor",round2(r*100,0))
                --Support of absorption mod.
                if item.phys and (item.phys.blunt or item.phys.pierc or item.phys.slash) then
                    local p = item.phys
                    cn("absorb",(p.blunt or 0).." / "..(p.pierc or 0).." / "..(p.slash or 0))
                end
            end
            if item.damage and type(item.damage)=="number" and item.damage>0 then
                cn("dmg",round2(item.damage,1))
            elseif c.weapon ~= nil and c.weapon.damage and type(c.weapon.damage)=="number" and c.weapon.damage>0 then
                cn("dmg",round2(c.weapon.damage,1))
                --Support of absobtion mod.
                if item.phys_dmg then
                    local p = item.phys_dmg == "blunt" and "Blunt" or (
                    item.phys_dmg == "pierc" and "Piercing" or (
                    item.phys_dmg == "slash" and "Slashing" or nil
                    )
                    )
                    if p ~= nil then
                        table.insert(desc_table, "$Type: "..p)
                    end
                end
            elseif c.zupalexsrangedweapons ~= nil
                    and c.zupalexsrangedweapons.GetArrowBaseDamage ~= nil
                    and type(c.zupalexsrangedweapons.GetArrowBaseDamage) == "function"
            then
                local dmg = c.zupalexsrangedweapons:GetArrowBaseDamage()
                if dmg ~= nil and type(dmg) == "number" and dmg > 0 then
                    cn("dmg",round2(dmg,1))
                end
            end
            if c.weapon and c.weapon.damage and type(c.weapon.attackrange)=="number" and c.weapon.attackrange>0.3 then
                cn("range",round2(c.weapon.attackrange,1))
            elseif c.projectile and c.projectile.damage and type(c.projectile.range)=="number" and c.projectile.range>0.3 then
                cn("range",round2(c.projectile.range,1))
            elseif c.combat and c.combat.damage and type(c.combat.attackrange)=="number" and c.combat.attackrange>2.5 then
                cn("range",round2(c.combat.attackrange,1))
            end
            if c.insulator and c.insulator.insulation and type(c.insulator.insulation)=="number" and c.insulator.insulation~=0 then
                if c.insulator.SetInsulationEx then --ServerMod
                    local winter,summer = c.insulator:GetInsulationEx()
                    if winter~=0 then
                        cn("warm",round2(winter,0))
                    end
                    if summer~=0 then
                        cn("summer",round2(summer,0))
                    end
                elseif c.insulator.GetInsulation then
                    local insul,typ = c.insulator:GetInsulation()
                    if typ == _G.SEASONS.WINTER then
                        cn("warm",round2(insul,0))
                    elseif typ == _G.SEASONS.SUMMER then
                        cn("summer",round2(insul,0))
                    end
                end
            end
            if c.dapperness and c.dapperness.dapperness and type(c.dapperness.dapperness)=="number" and c.dapperness.dapperness~=0 then
                local sanity = round2(c.dapperness.dapperness*54,1)
                cn("sanity",sanity)
            elseif c.equippable and c.equippable.dapperness and type(c.equippable.dapperness)=="number" and c.equippable.dapperness~=0 then
                local sanity = round2(c.equippable.dapperness*54,1)
                cn("sanity",sanity)
            end
            if c.equippable and c.equippable.walkspeedmult and c.equippable.walkspeedmult ~= 1 then
                local added_speed = math.floor((c.equippable.walkspeedmult - 1)*100+0.5)
                cn("speed",added_speed)
            end
            if c.dapperness and c.dapperness.mitigates_rain and item.prefab ~= "umbrella" then
                cn("waterproof","90")
            elseif item.protect_from_rain then
                cn("waterproof",round2((item.protect_from_rain)*100,0))
            elseif c.waterproofer then
                local effectiveness = _G.tonumber(c.waterproofer.effectiveness) or 0
                if effectiveness ~= 0 then
                    cn("waterproof",round2((effectiveness)*100,0))
                else
                    --desc = (desc=="" and "" or (desc.."\n")).."Waterproofer"
                end
            end
            if c.edible and not is_DisplayFoodValues then
                local can_eat = false
                if viewer and viewer.components.eater then
                    can_eat = viewer.components.eater:CanEat(item)
                end
                if can_eat then
                    local should_Estimate_Stale = viewer and viewer.should_Estimate_Stale --client priority
                    if not should_Estimate_Stale then
                        should_Estimate_Stale = food_estimation ~= 0
                    end
                    local hp,hg,sn
                    if should_Estimate_Stale and c.edible.GetSanity then
                        --print("Estimate")
                        hp=round2(c.edible:GetHealth(viewer),1)
                        hg=round2(c.edible:GetHunger(viewer),1)
                        sn=round2(c.edible:GetSanity(viewer),1)
                    else
                        --print("Not Estimate")
                        hp=round2(c.edible.healthvalue,1)
                        hg=round2(c.edible.hungervalue,1)
                        sn=round2(c.edible.sanityvalue,1)
                    end
                    if viewer ~= nil and viewer.FoodValuesChanger ~= nil then
                        local hp2, hg2, sn2 = viewer:FoodValuesChanger(item)
                        if sn2 ~= nil then
                            --print("++")
                            hp=round2(hp2,1)
                            hg=round2(hg2,1)
                            sn=round2(sn2,1)
                        end
                    end
                    if hp > 0 then
                        hp = "+" .. tostring(hp)
                    end
                    if hg > 0 then
                        hg = "+" .. tostring(hg)
                    end
                    if sn > 0 then
                        sn = "+" .. tostring(sn)
                    end
                    cn("food",hg,sn,hp)
                end
            end
            if c.perishable ~= nil and c.perishable.updatetask ~= nil then
                local time = GetPerishTime(item, c)
                if time ~= nil then
                    cn("perish",round2(time/TUNING.TOTAL_DAY_TIME,1))
                end
            end
            if ing[prefab] and show_food_units ~= 2 then -- ==2 means that food info is forbidden on the server.
                for k,v in pairs(ing[prefab].tags) do
                    if k~="precook" and k~="dried" then
                        cn("units_of",v,k)
                    end
                end
            end
            if c.healer then
                cn("heal",round2(c.healer.health,1))
            end
            if c.finiteuses then
                local mult = 1
                if c.finiteuses.consumption then
                    for k,v in pairs(c.finiteuses.consumption) do
                        mult = 1/v
                    end
                end
                local cur = math.floor(c.finiteuses.current * mult + 0.5)
                if c.finiteuses.current > cur then
                    cur = cur + 1
                end
                cn("uses_of",cur,c.finiteuses.total * mult)
            end
            if c.temperature and c.temperature.current and type(c.temperature.current) == "number" then
                cn("temperature",round2(c.temperature.current,1))
            end
            if c.fueled and c.fueled:GetPercent()>0 and item:HasTag("structure") then
                cn("fuel",round2(c.fueled:GetPercent()*100,0))
            end
            if c.instrument and type(c.instrument.range)=="number" and c.instrument.range>0.4 then
                cn("range",round2(c.instrument.range,0))
            end
            if c.crystallizable and c.crystallizable.formation --support of Krizor's mod
                    and c.crystallizable.formation.thickness
                    and type(c.crystallizable.formation.thickness)=="table"
                    and c.crystallizable.formation.thickness.current
                    and c.crystallizable.formation.thickness.current>0
            then
                cn("thickness",round2(c.crystallizable.formation.thickness.current,1))
            end
            if c.mine then
                if c.mine.nick then
                    cn("owner",c.mine.nick)
                    has_owner = true
                end
            end
            if not has_owner then
                if item.stealable and item.stealable.owner and item.stealable.owner ~= "_?\1" then
                    cn("owner",item.stealable.owner)
                    has_owner = true
                elseif item.owner and type(item.owner)=="string" and string.sub(item.owner,1,3) ~= "KU_" then
                    --Мы не знаем, что за имя. Но это "владелец". Так что надо вывести. И это точно не user_id.
                    cn("owner",item.owner)
                    has_owner = true
                end
            end
            --Check prefabs?
            if prefab=="panflute" then
                --desc = cn("power","10")
            elseif prefab=="blowdart_sleep" then
            elseif prefab=="pond" or prefab=="pond_mos" then
                cn(c.fishable.fishleft==1 and "fish" or "fishes",c.fishable.fishleft)
            elseif prefab=="aqvarium" and item.data then
                if item.data.seeds and item.data.seeds>0 then
                    table.insert(desc_table, "$Seeds: "..tostring(item.data.seeds))
                end
                if item.data.meat and item.data.meat>0 then
                    table.insert(desc_table, "$Meat: "..tostring(item.data.meat))
                    --desc = cn(desc,item.data.meat,"Meat:",true)
                end
                local need_wet= item.data.need_wet or 60
                if item.data.wet and item.data.wet>0 and item.data.wet<need_wet then
                    table.insert(desc_table, "$Water: "..tostring(round2(100*item.data.wet/need_wet).."%"))
                    --desc = cn(desc,round2(100*item.data.wet/need_wet).."%","Water:",true)
                end
                if item.total_heat then
                    local temp = item.total_heat/10 --+ _G.TheWorld.state.temperature
                    if temp>40 then temp = 40 end
                    if temp>=0 then
                        cn("temperature",tostring(round2(temp,1)))
                    end
                end
            end
            --Charges: lightning rod / lamp
            if item.chargeleft and item.chargeleft > 0 then
                table.insert(desc_table, "$Days left: "..tostring(math.floor(item.chargeleft+0.5)))
            end
        end
        --Depending from weapon info:
        if viewer and type(viewer)=="table" and viewer.components and viewer.components.inventory then
            local weapon = viewer.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
            if weapon then
                if weapon.prefab=="icestaff" and c.freezable then
                    cn("resist",c.freezable.resistance)
                elseif (weapon.prefab=="blowdart_sleep" or weapon.prefab=="panflute") and c.sleeper then
                    cn("resist",c.sleeper.resistance)
                end
            end
        end
        if item.inlove and item.inlove>0 then
            if prefab=="chester" then
                cn("love",item.inlove/10)
            else
                cn("love",item.inlove)
            end
        end
        return table.concat(desc_table,"\2")
    end
end

do
    local function CheckUserHint(inst)
        local c = _G.ThePlayer and _G.ThePlayer.player_classified
        if c == nil then
            return ""
        end
        --c.showme_hint
        local i = string.find(c.showme_hint,';',1,true)
        if i == nil then
            return ""
        end
        local guid = _G.tonumber(c.showme_hint:sub(1,i-1))
        if guid ~= inst.GUID then --guid не совпадает
            return ""
        end
        return c.showme_hint:sub(i+1)
    end
    if CLIENT_SIDE then
        local old_inst
        local function UnpackData(str,div)
            local pos,arr = 0,{}
            -- for each divider found
            for st,sp in function() return string.find(str,div,pos,true) end do
                table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
                pos = sp + 1 -- Jump past current divider
            end
            table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
            return arr
        end

        local save_target
        local last_check_time = 0
        local LOCAL_STRING_CACHE = {}
        AddClassPostConstruct("widgets/hoverer",function(hoverer) --hoverer=self
            local old_SetString = hoverer.text.SetString
            hoverer.text.SetString = function(text,str) --text=self
                --print(tostring(str))
                local target = _G.TheInput:GetHUDEntityUnderMouse()
                if target ~= nil then
                    --target.widget.parent - это ItemTile
                    target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
                else
                    target = _G.TheInput:GetWorldEntityUnderMouse()
                end
                if target ~= nil then
                    --print(tostring(target))
                    local str2 = CheckUserHint(target)
                    if str2 ~= "" then
                        local cnt_newlines, _ = 0
                        while cnt_newlines < #str do
                            local ch = str:sub(#str-cnt_newlines,#str-cnt_newlines)
                            if ch ~= "\n" and ch ~= " " then
                                break
                            end
                            cnt_newlines = cnt_newlines + 1
                        end
                        if cnt_newlines > 0 then
                            str = str:sub(1,#str-cnt_newlines)
                        end
                        if string.find(str,"\n\n",1,true) ~= nil then
                            str = str:gsub("[\n]+","\n")
                        end
                        str2 = UnpackData(str2,"\2")
                        local arr2 = {}
                        for i,v in ipairs(str2) do
                            if v ~= "" then
                                local param_str = v:sub(2)
                                local data = { param = UnpackData(param_str,","), param_str=param_str }
                                local my_s = MY_STRINGS[string.byte(v:sub(1,1))-64]
                                if my_s ~= nil then
                                    data.data = MY_DATA[my_s.key]
                                end
                                table.insert(arr2,data)
                            end
                        end
                        arr2.str2= str2
                        str2=""
                        for i,v in ipairs(arr2) do
                            if v.data ~= nil and v.data.fn ~= nil then
                                str2=str2.. v.data.fn(v) .. "\n"
                            elseif v.hidden == nil then
                                str2=str2 .. DefaultDisplayFn(v) .. "\n"
                            end
                        end

                        str = str .. "\n" .. str2
                        cnt_newlines = 1
                        while cnt_newlines > 0 do
                            str = str .. "\n "
                            cnt_newlines = cnt_newlines - 1
                        end
                    end
                    if target ~= save_target or last_check_time + 1 < GetTime() then
                        save_target = target
                        last_check_time = GetTime()
                        SendModRPCToServer(MOD_RPC.ShowMeHint.Hint, save_target.GUID, save_target)
                    end
                else
                    --print("target nil")
                end
                return old_SetString(text,str)
            end
        end)
    end

    AddModRPCHandler("ShowMeHint", "Hint", function(player, guid, item)
        if player.player_classified == nil then
            print("ERROR: player_classified not found!")
            return
        end
        if item ~= nil and item.components ~= nil then
            local s = GetTestString(item,player)
            if s ~= "" then
                player.player_classified.net_showme_hint:set(guid..";"..s)
            end
        end
    end)

    --networking
    AddPrefabPostInit("player_classified",function(inst)
        inst.showme_hint = ""
        inst.net_showme_hint = _G.net_string(inst.GUID, "showme_hint", "showme_hint_dirty")
        if CLIENT_SIDE then
            inst:ListenForEvent("showme_hint_dirty",function(inst)
                inst.showme_hint = inst.net_showme_hint:value()
            end)
        end
    end)
end




