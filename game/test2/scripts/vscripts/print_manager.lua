-- print_manager.lua
PrintManager = PrintManager or {
    lastPrint = {},
    printCooldown = 5
}

function PrintManager:ShouldPrint(message)
    local currentTime = GameRules:GetGameTime()
    if not self.lastPrint[message] or currentTime - self.lastPrint[message] > self.printCooldown then
        self.lastPrint[message] = currentTime
        return true
    end
    return false
end

function PrintManager:PrintMessage(message)
    -- print("PrintManager当前匹配ID:" .. Main.currentMatchID)




    print(message)
end

function PrintManager:GetHeroChineseName(heroName)
    for _, hero in ipairs(heroes_precache) do
        if hero.name == heroName then
            return hero.chinese
        end
    end
    return "未知英雄"
end

function PrintManager:FormatAbilityMessage(caster, ability)
    local abilityName = ability:GetAbilityName()
    local heroName = caster:GetUnitName()
    local heroChineseName = self:GetHeroChineseName(heroName)
    local currentTime1 = Time()
    local formattedTime = string.format("%.2f", currentTime1)
    
    -- -- 如果是巫医的特定技能，打印modifier信息
    -- if abilityName == "witch_doctor_voodoo_switcheroo" then
    --     local count = 0
    --     local timer = Timers:CreateTimer(function()
    --         if count >= 20 then -- 2秒内执行20次(每0.1秒一次)
    --             return nil
    --         end
            
    --         local modifiers = caster:FindAllModifiers()
    --         print("--- 当前所有Modifier (时间: " .. formattedTime .. ") ---")
    --         for _, mod in ipairs(modifiers) do
    --             if mod and not mod:IsNull() then
    --                 local remainingTime = mod:GetRemainingTime()
    --                 local duration = mod:GetDuration()
    --                 local remainingText = remainingTime >= 0 and string.format("%.1f秒", remainingTime) or "永久"
    --                 local durationText = duration >= 0 and string.format("%.1f秒", duration) or "永久"
                    
    --                 print(string.format("  - 名称：%s\n    剩余时间：%s\n    总持续时间：%s", 
    --                     mod:GetName(), remainingText, durationText))
    --             end
    --         end
    --         print("--------------------")
            
    --         count = count + 1
    --         return 0.1
    --     end)
    -- end
    
    if Main.currentMatchID then
        Main:createLocalizedMessage(
            "[LanPang_RECORD][",
            Main.currentMatchID,
            "]",
            "[释放技能]",
            {localize = true, text = heroName},
            "释放了",
            {localize = true, text = "DOTA_Tooltip_Ability_" .. abilityName}
        )
    end




    return "[DOTA_RECORD] " .. heroChineseName .. ": 放了 " .. abilityName
end