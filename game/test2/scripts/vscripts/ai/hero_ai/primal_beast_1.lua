-- PrimalBeastAI1.lua

PrimalBeastAI1 = {}


PrimalBeastAI1.__index = PrimalBeastAI1


function PrimalBeastAI1:log(...)
    if DEBUG_MODE then
        print(string.format("AI [%s]: ", self.id), ...)
    end
end

function PrimalBeastAI1:constructor(entity)
    if not entity then
        self:log("错误: entity 为 nil")
    else
        self:log("PrimalBeastAI1 instance created for entity: " .. entity:GetUnitName())
    end
    self.entity = entity
    self.currentState = AIStates.Idle
    self.lastKnownPosition = nil
    self.currentTimer = nil
    self.id = tostring(entity:entindex())
end

function PrimalBeastAI1.new(entity)
    local instance = setmetatable({}, PrimalBeastAI1)
    instance:constructor(entity)
    return instance
end

function PrimalBeastAI1:Think()
    local entity = self.entity
    self:log("PrimalBeastAI1:Think called for entity: " .. (entity and entity:GetUnitName() or "nil"))

    if not entity or not entity:IsAlive() then
        local respawnTime = entity and entity:GetRespawnTime() or 0
        self:log(string.format("英雄死亡，等待复活... 复活剩余时间: %.2f 秒", respawnTime))
        return respawnTime + 1.0
    end

    if self.currentState == AIStates.CastSpell then
        self:log("正在施法中，跳过本次 AI 思考过程")
        return 0.1
    end

    self:log("开始寻找目标...")
    local target = CommonAI:FindHeroTarget(entity)
    if not target then
        target = CommonAI:FindTarget(entity)
    end

    if target then
        self:UseFirstSkill(target)
    else
        self:Idle()
    end
end


function PrimalBeastAI1:UseFirstSkill(target)
    if not self.entity:IsSilenced() and not self.entity:IsHexed() then
        local firstSkill = self.entity:FindAbilityByName("primal_beast_onslaught")
        if firstSkill and firstSkill:IsCooldownReady() then
            self:log(self, "使用第一个技能")
            self.entity:CastAbilityOnTarget(target, firstSkill, -1)
            Timers:CreateTimer(4.0, function()
                local commonAI = CommonAI.new(self.entity)  -- 重新初始化CommonAI
                return commonAI:Think(self.entity)  -- 调用CommonAI的逻辑
            end)
        end
    end
end

function PrimalBeastAI1:UseSecondSkill(target)
    if not self.entity:IsSilenced() and not self.entity:IsHexed() then
        local secondSkill = self.entity:FindAbilityByName("primal_beast_second_skill")
        if secondSkill and secondSkill:IsCooldownReady() then
            self:log(self, "使用第二个技能")
            self.entity:CastAbilityOnTarget(target, secondSkill, -1)
            -- 回到通用AI逻辑
            CommonAI.Think(self)
        end
    end
end
