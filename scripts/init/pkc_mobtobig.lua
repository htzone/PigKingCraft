-- 生物变大
-- Created by IntelliJ IDEA.
-- User: RedPig
-- Date: 2017/3/17
-- Time: 19:45
-- To change this template use File | Settings | File Templates.
--

local initToBigTable = {
    "tallbird",
    "knight",
    "bishop",
    "rook",
    "rabbit",
    "pigguard",
    "penguin",
    "walrus",
}

local mobToBigTable  = {
    "spider",
    "spider_moon",
	"spider_warrior",
    "koalefant_summer",
    "koalefant_winter",
    "leif",
    "leif_sparse",
    "hound",
    "firehound",
    "icehound",
    "spiderqueen",
    "warg",
    "merm",
	"mermguard",
}

local function initToBig(inst)
    if GLOBAL.TheWorld.ismastersim and inst then
        inst:AddComponent("pkc_tobig")
        local randomval = math.random()
        inst.components.pkc_tobig:growTo(randomval)
    end
end

local function mobToBig(inst)
    if GLOBAL.TheWorld.ismastersim and inst then
        inst:AddComponent("pkc_tobig")
        if GLOBAL.PKC_CREATURE_TOBIG then
            local randomval = math.random()
            inst.components.pkc_tobig:growTo(randomval)
        end
    end
end

for _,v in pairs(initToBigTable) do
    AddPrefabPostInit(v, initToBig)
end

for _,v in pairs(mobToBigTable) do
    AddPrefabPostInit(v, mobToBig)
end

local function creatureToBigPlot(inst)
    if inst.ismastersim then
        inst:ListenForEvent("ms_cyclecomplete", function(inst)
            if GLOBAL.TheWorld.state.cycles >= (GLOBAL.PKC_BEGIN_TOBIG - 2) then
                GLOBAL.PKC_CREATURE_TOBIG = true
            end
        end)
    end
end

AddPrefabPostInit("world", creatureToBigPlot)