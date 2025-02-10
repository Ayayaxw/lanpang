function Main:OnAttack(keys)
    -- local attacker = EntIndexToHScript(keys.entindex_attacker)
    -- local victim = EntIndexToHScript(keys.entindex_killed)
    -- local damage = keys.damage

    -- print("\n========== Attack Event Debug Info ==========")
    
    -- -- 打印基本信息
    -- print("Damage Amount:", damage)

    -- -- 打印被攻击者信息
    -- if victim then
    --     print("\n--- Victim Info ---")
    --     print("Name:", victim:GetUnitName())
    --     print("Team:", victim:GetTeamNumber())
    --     print("Is Hero:", victim:IsHero())
    --     print("Entity Index:", victim:GetEntityIndex())
    -- else
    --     print("\n--- Victim Info ---")
    --     print("Invalid victim entity")
    -- end

    -- -- 增强版的攻击者信息打印
    -- if attacker then
    --     print("\n--- Attacker Info ---")
    --     print("Name:", attacker:GetUnitName())
    --     print("Team:", attacker:GetTeamNumber())
    --     print("Is Hero:", attacker:IsHero())
    --     print("Is Illusion:", attacker:IsIllusion())
    --     print("Is Clone:", attacker:IsClone())
    --     print("Is Tempest Double:", attacker.IsTempestDouble and attacker:IsTempestDouble() or "N/A")
    --     print("Is Controllable:", attacker:IsControllableByAnyPlayer())
    --     print("Entity Index:", attacker:GetEntityIndex())
    --     print("PlayerID:", attacker:GetPlayerOwnerID())
    -- else
    --     print("\n--- Attacker Info ---")
    --     print("Invalid attacker entity")
    -- end

    -- -- 打印真实所有者信息
    -- print("\n--- Real Owner Info ---")
    -- local realOwner = self:GetRealOwner(attacker)
    -- if realOwner then
    --     print("\nFinal Real Owner:")
    --     print("Name:", realOwner:GetUnitName())
    --     print("Team:", realOwner:GetTeamNumber())
    --     print("Entity Index:", realOwner:GetEntityIndex())
    --     print("PlayerID:", realOwner:GetPlayerOwnerID())
    -- else
    --     print("\nNo real owner found")
    -- end

    -- print("\n===========================================\n")

    
    -- 处理特定英雄之间的交互
    if self.leftTeamHero1 and self.rightTeamHero1 then
        local attacker = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
        local target = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
        local inflictor = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor)
        
        -- print("攻击者:", attacker and attacker:GetUnitName() or "nil")
        -- print("目标:", target and target:GetUnitName() or "nil")
        -- print("技能:", inflictor and inflictor:GetName() or "nil")
        
        -- 如果attacker或target为nil，则直接返回
        if not attacker or not target then
            -- print("攻击者或目标无效")
            return
        end
    
        local damage = keys.damage
    
        if (attacker == self.leftTeamHero1 and target == self.rightTeamHero1) or
           (attacker == self.rightTeamHero1 and target == self.leftTeamHero1) then
            
            local attackerName = attacker:GetUnitName()
            local targetName = target:GetUnitName()
            local damageRounded = string.format("%.2f", damage or 0)
            local eventData = {
                attacker = attackerName,
                target = targetName,
                damage = damageRounded,
            }
    
            -- 根据Inflictor判断攻击类型和来源
            if inflictor then
                -- print("检测到技能:", inflictor:GetName())
                eventData.attackType = "ability_attack"
                eventData.abilityName = inflictor:GetName()
            else
                -- print("未检测到技能，判定为普通攻击")
                eventData.attackType = "normal_attack"
                eventData.abilityName = nil
            end
    
            -- -- 在发送事件之前打印数据
            -- print("准备发送的攻击信息:")
            -- for k, v in pairs(eventData) do
            --     print(k .. ": " .. tostring(v))
            -- end
            -- print("攻击信息结束")
    
            -- 发送事件到适当的接收函数
            if attacker == self.leftTeamHero1 then
                -- print("发送左方英雄攻击信息")
                CustomGameEventManager:Send_ServerToAllClients("left_hero_attack_info", eventData)
            else
                -- print("发送右方英雄攻击信息")
                CustomGameEventManager:Send_ServerToAllClients("right_hero_attack_info", eventData)
            end
        end
    end

    local attacker = EntIndexToHScript(keys.entindex_attacker)
    if attacker and attacker:GetUnitName() == self.currentHeroName then
        local ability = attacker:GetCurrentActiveAbility()
        if ability then
            local message = PrintManager:FormatAbilityMessage(attacker, ability)
            PrintManager:PrintMessage(message)
        end
    end

    -- -- 原有逻辑开始
    -- if self.currentChallenge == Main.Challenges.HeroChaos then
    --     local attacker = EntIndexToHScript(keys.entindex_attacker)
    --     local victim = EntIndexToHScript(keys.entindex_killed)
    --     local damage = keys.damage
    
    --     if attacker:IsHero() and attacker:GetTeamNumber() ~= victim:GetTeamNumber() then
    --         if not self.heroData then
    --             self.heroData = {}  -- 确保heroData存在
    --         end
    
    --         for _, hero in ipairs(self.heroData) do
    --             if hero.name == self:GetHeroChineseName(attacker:GetUnitName()) then
    --                 hero.damage = math.ceil(hero.damage + damage)  -- 采用进一法保留整数
    --                 break
    --             end
    --         end
    
    --         -- 将更新后的英雄数据转换为JSON字符串
    --         local heroDataJson = json.encode(self.heroData)
    --         -- 使用CustomGameEventManager将数据发送给前端JS
    --         CustomGameEventManager:Send_ServerToAllClients("update_hero_data", {heroData = heroDataJson})
    --     end
    -- end
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
        local challengeFunctionName = "OnAttack_" .. challengeName
        if self[challengeFunctionName] then
            -- 调用对应的处理函数
            self[challengeFunctionName](self, keys)
        else
            --print("没有找到对应挑战模式的处理函数: " .. challengeName)
        end
    else
        print("未知的挑战模式ID: " .. tostring(challengeId))
    end

end