modifier_death_check_enchant = class({})

function modifier_death_check_enchant:IsHidden()
    return true
end

function modifier_death_check_enchant:IsDebuff()
    return false
end

function modifier_death_check_enchant:IsPurgable()
    return false
end

function modifier_death_check_enchant:RemoveOnDeath()
    return true
end

function modifier_death_check_enchant:OnCreated()
    if not IsServer() then return end
    -- 初始化操作（如果需要）
end

function modifier_death_check_enchant:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_death_check_enchant:OnDestroy()
    if not IsServer() then return end
    
    local parent = self:GetParent()

    -- 检查是否已触发OnDeath事件
    local unitIndex = parent:GetEntityIndex()
    
    if not Main.DeathEventTracking or not Main.DeathEventTracking[unitIndex] then

        -- 构建类似OnUnitKilled的处理逻辑
        local challengeId = Main.currentChallenge
        if not challengeId then

            return
        end
        
        -- 查找对应的挑战模式名称
        local challengeName
        for name, id in pairs(Main.Challenges) do
            if id == challengeId then
                challengeName = name
                break
            end
        end
        
        if challengeName then
            -- 构建处理函数的名称
            local challengeFunctionName = "OnUnitKilled_" .. challengeName
            if Main[challengeFunctionName] then

                -- 构造Main:OnUnitKilled_X函数需要的args参数
                local args = {
                    entindex_killed = unitIndex,
                    entindex_attacker = parent:GetPlayerOwnerID() or 0  -- 如果没有攻击者，使用0或其他默认值
                }
                print("调用对应的死亡处理函数,killedUnit:",parent:GetUnitName())
                -- 调用对应的死亡处理函数
                Main[challengeFunctionName](Main, parent, args)
            else
            end
        else
        end
    else
        -- 清理跟踪记录
        local attackerData = Main.DeathEventTracking[unitIndex]
        Main.DeathEventTracking[unitIndex] = nil

    end
    

end