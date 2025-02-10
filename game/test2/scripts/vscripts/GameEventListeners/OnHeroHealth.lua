
-- 英雄生命值监听函数
function Main:ListenHeroHealth(heroes)
    -- 获取当前的挑战模式ID
    local challengeId = self.currentChallenge

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
        local challengeFunctionName = "OnHeroHealth_" .. challengeName
        if self[challengeFunctionName] then
            -- 调用对应的处理函数，并传递英雄列表
            self[challengeFunctionName](self, heroes)
        else
            print("没有找到对应挑战模式的处理函数: " .. challengeName)
        end
    else
        print("未知的挑战模式ID: " .. tostring(challengeId))
    end
end



        -- -- 确保英雄存在且有效
        -- if not heros or heros:IsNull() then
        --     return
        -- end

        -- -- 移除之前的监听
        -- if self.heroHealthTimer then
        --     Timers:RemoveTimer(self.heroHealthTimer)
        -- end

        -- -- 监听英雄当前生命值占最大生命值的百分比
        -- self.heroHealthTimer = Timers:CreateTimer(0.1, function()
        --     -- 检查英雄是否仍然存在且有效
        --     if not heros or heros:IsNull() then
        --         return nil
        --     end

        --     -- 检查duel.endduel状态，如果为true，停止监听
        --     if hero_duel.EndDuel then
        --         return nil
        --     end

        --     -- 获取英雄当前生命值和最大生命值
        --     local currentHealth = heros:GetHealth()
        --     local maxHealth = heros:GetMaxHealth()

        --     -- 计算生命值百分比
        --     local healthPercentage = (currentHealth / maxHealth) * 100
        --     healthPercentage = math.ceil(healthPercentage)
            
        --     -- 打印英雄名字和当前生命值百分比
        --     --print(hero:GetUnitName() .. " 当前生命值为 " .. currentHealth .. ", 最大生命值为 " .. maxHealth .. ", 生命值百分比为 " .. healthPercentage .. "%")

        --     if healthPercentage > 100 then
        --         healthPercentage = 100
        --     end

        --     -- 更新Shadow Shaman的血量百分比
        --     if self.currentChallenge == Main.Challenges.CD0_1skill_online then
        --         hero_duel:UpdateShadowShamanHealth(newHero0, healthPercentage)
        --     else
        --         hero_duel:UpdateShadowShamanHealth(newHero, healthPercentage)
        --     end
        --     -- 继续监听
        --     return 0.1
        -- end)