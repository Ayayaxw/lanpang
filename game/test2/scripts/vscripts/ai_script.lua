-- ai_script.lua

if AIThink == nil then
    AIThink = class({})
end

function AIThink:Init(hero)
    self.hero = hero
    self:StartAI()
end

function AIThink:StartAI()
    Timers:CreateTimer(function()
        self:UseRoshanBanner()
        return self:Think()
    end)
    self:CastInnerFireAfter10Seconds()  -- 添加定期释放custom_inner_fire的调用
end

function AIThink:Think()
    if not self.hero:IsAlive() then
        return 1 -- 如果英雄死亡，1秒后再次检查
    end

    -- 获取场地上的所有超级兵
    local meleeCreeps = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS,
        Vector(0, 0, 0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    
    local rangedCreeps = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS,
        Vector(0, 0, 0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local totalCreeps = 0
    for _, creep in ipairs(meleeCreeps) do
        if creep:GetUnitName() == "npc_dota_creep_goodguys_melee_upgraded_mega" then
            totalCreeps = totalCreeps + 1
        end
    end

    for _, creep in ipairs(rangedCreeps) do
        if creep:GetUnitName() == "npc_dota_creep_goodguys_ranged_upgraded_mega" then
            totalCreeps = totalCreeps + 1
        end
    end

    -- 检查小兵数量并发送全图文本提示
    if totalCreeps >= 100 then
        local ability = self.hero:FindAbilityByName("custom_inner_fire")
        local endMessage = "当前小兵数量已经达到 " .. totalCreeps .. "!挑战结束！"
        GameRules:SendCustomMessage(endMessage, 0, 0)
        if ability and ability:IsCooldownReady() then
            self.hero:CastAbilityNoTarget(ability, -1)
        end
    elseif totalCreeps > 90 then
        local message = "警告：当前小兵数量已经达到 " .. totalCreeps .. "!"
        GameRules:SendCustomMessage(message, 0, 0)
    end

    return 1 -- 每秒检查一次
end

function AIThink:UseRoshanBanner()
    -- 查找物品栏中的Roshan Banner
    local bannerItem = nil
    for i = 0, 5 do
        local item = self.hero:GetItemInSlot(i)
        if item and item:GetName() == "item_roshans_banner" then
            bannerItem = item
            break
        end
    end

    -- 使用Roshan Banner
    if bannerItem then
        self.hero:CastAbilityOnPosition(self.hero:GetAbsOrigin(), bannerItem, self.hero:GetPlayerOwnerID())
    end
end

function AIThink:CastInnerFireAfter10Seconds()
    Timers:CreateTimer(10, function()
        if self.hero:IsAlive() then
            local ability = self.hero:FindAbilityByName("custom_inner_fire")
            
            if ability and ability:IsCooldownReady() then
                self.hero:CastAbilityNoTarget(ability, -1)
                print("释放")
            end
        end
    end)
end
