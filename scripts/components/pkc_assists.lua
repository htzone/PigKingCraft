--
-- pkc_assists 助攻组件
-- Author: RedPig
-- Date: 2021/2/6
--

local PKC_ASSISTS = Class(function(self, inst)
    self.inst = inst
end)

--生成基地并保存基地的位置
function PKC_ASSISTS:getAssistsPlayer() -- 参数是基地的个数
    if not self.inst.hasProduceBase then

    end
end

function PKC_ASSISTS:OnSave()
    return
    {
        hasProduceBase = self.inst.hasProduceBase,
    }
end

function PKC_ASSISTS:OnLoad(data)
    if data ~= nil then
        if data.hasProduceBase ~= nil then
            self.inst.hasProduceBase = data.hasProduceBase
        end
    end
end

return PKC_ASSISTS