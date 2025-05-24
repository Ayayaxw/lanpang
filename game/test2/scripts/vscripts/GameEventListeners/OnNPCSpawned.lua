-- 在文件顶部或适当的位置定义这个变量
local DEBUG_PRINT = true

-- 定义一个debug打印函数
local function DebugPrint(message)
    if DEBUG_PRINT then
        print(message)
    end
end

function Main:isExcludedUnit(unit)
    local unitName = unit:GetUnitName()

    local excludedUnits = {
        "npc_dota_thinker",
        "npc_dota_observer_wards",
        "npc_dota_sentry_wards",
        "npc_dota_rattletrap_cog",
        "npc_dota_clinkz_skeleton_archer",
        "npc_dota_zeus_cloud",
        "npc_dota_troll_warlord_axe",
        "npc_dota_base_additive",
        "npc_dota_unit_undying_zombie",
        "npc_dota_unit_undying_tombstone",
        "npc_dota_beastmaster_hawk",
        "double_on_death_mega",
        "npc_dota_looping_sound",
        "npc_dota_unit_undying_zombie_torso",
        "npc_dota_wisp_spirit",
        "npc_dota_muerta_revenant",
        "npc_dota_wraith_king_skeleton_warrior",
        "ward",
        "mantle_unit",
        "npc_dota_ember_spirit_remnant"

    }
    -- 检查单位名称是否在排除列表中
    for _, excludedName in ipairs(excludedUnits) do
        if unitName == excludedName then
            return true
        end
    end

    -- 检查是否有幻象禁锢modifier或者猴子大的士兵modifier
    if unit:HasModifier("modifier_bane_fiends_grip_illusion") or 
    unit:HasModifier("modifier_hoodwink_decoy_illusion") or 
    unit:HasModifier("modifier_monkey_king_fur_army_soldier") then
        return true
    end

    return false
end


function Main:OnNPCSpawned(event)
    local spawnedUnit = EntIndexToHScript(event.entindex)

    local unitName = spawnedUnit:GetUnitName() or "未知单位"
    if unitName and unitName ~= "" then
        DebugPrint("单位生成：" .. unitName)
    end

    if Main.currentChallenge == Main.Challenges.CreepChallenge_100Creeps then 
        if unitName == "npc_dota_warlock_minor_imp" then
            DebugPrint("在100小兵挑战中检测到魔童")
            Timers:CreateTimer(0.8, function()
                if spawnedUnit and not spawnedUnit:IsNull() then
                    spawnedUnit:RemoveSelf()
                    DebugPrint("术士魔童已移除")
                end
                DebugPrint("函数结束：移除术士魔童的Timer结束")
                return nil
            end)
        end
    else
        if unitName and unitName ~= "" then
            --DebugPrint("检查单位1：" .. unitName)
        end

        local aiUnitKeywords = {
            "npc_dota_lone_druid_bear"
        }
        if self:isExcludedUnit(spawnedUnit) then
            DebugPrint("单位坐标：" .. tostring(spawnedUnit:GetAbsOrigin()))
            
            -- 打印thinker的基本信息
            DebugPrint("===== Thinker基本信息 =====")
            
            -- 尝试获取所有者
            local owner = spawnedUnit:GetOwner()
            if owner and not owner:IsNull() then
                DebugPrint("所有者: " .. (owner:GetName() or "未知") .. " / " .. (owner:GetUnitName() or "未知"))
            else
                DebugPrint("所有者: 无")
            end
            
            -- 尝试获取classname
            local classname = spawnedUnit:GetClassname()
            DebugPrint("实体类名: " .. (classname or "未知"))
            
            -- 尝试获取实体名称
            DebugPrint("实体名称: " .. (spawnedUnit:GetName() or "未知"))
            
            -- 尝试获取实体索引
            DebugPrint("实体索引: " .. spawnedUnit:GetEntityIndex())
            
            DebugPrint("============================")
            DebugPrint("函数结束：单位在排除列表中")
            return
        end

        Timers:CreateTimer(0.03, function()
            if not spawnedUnit or spawnedUnit:IsNull() then
                DebugPrint("函数结束：单位已不存在或无效")
                return
            end
        
            local unitName = spawnedUnit:GetUnitName()
            
            if not unitName then
                DebugPrint("函数结束：无法获取单位名称")
                return
            end
        


            local isIllusion = spawnedUnit:IsIllusion()
            if spawnedUnit:IsIllusion() then
                spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_kv_editor", {})
            end
            if not isIllusion and spawnedUnit:IsInvulnerable() and not spawnedUnit:HasModifier("modifier_dazzle_nothl_projection_soul_debuff") then
                if unitName and unitName ~= "" then
                    --DebugPrint("函数结束：忽略非幻象的无敌单位: " .. unitName)
                end
                return
            end

            local shouldAddAI = not spawnedUnit:IsRealHero() or spawnedUnit:IsIllusion() or spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") or spawnedUnit:HasModifier("modifier_dazzle_nothl_projection_soul_debuff")
            
            for _, keyword in ipairs(aiUnitKeywords) do
                if string.find(unitName, keyword) then
                    shouldAddAI = true
                    break
                end
            end

            if shouldAddAI then
                --print("需要添加AI")
                local teamNumber = spawnedUnit:GetTeamNumber()
                local foundAI = false
                for unit, aiInfo in pairs(AIs) do
                    if unit and IsValidEntity(unit) and not unit:IsNull() then
                        if unit:GetTeamNumber() == teamNumber then
                            if unitName and unitName ~= "" then
                                DebugPrint("找到同阵营的 AI，正在为 " .. unitName .. " 创建 AI")
                            end
                            local originalAI = aiInfo.ai
                            local overallStrategy = originalAI.global_strategy
                            local heroStrategy = originalAI.hero_strategy
                            CreateAIForHero(spawnedUnit, overallStrategy, heroStrategy)
                            if unitName and unitName ~= "" then
                                DebugPrint("已成功为 " .. unitName .. " 创建 AI 并继承策略")
                            end
                            foundAI = true
                            break
                        end
                    end
                end
                
                if not foundAI then
                    if unitName and unitName ~= "" then
                        --DebugPrint("没有找到同阵营的 AI，无法为 " .. unitName .. " 创建 AI")
                    end
                end
            else
                if unitName and unitName ~= "" then
                    --DebugPrint(unitName .. " 是真实英雄")
                end
            end
            
            --DebugPrint("函数结束：AI处理Timer完成")
            return nil
        end)
    end

    local challengeId = self.currentChallenge

    local challengeName
    for name, id in pairs(Main.Challenges) do
        if id == challengeId then
            challengeName = name
            break
        end
    end

    if challengeName then
        local challengeFunctionName = "OnNPCSpawned_" .. challengeName
        if self[challengeFunctionName] then
            self[challengeFunctionName](self, spawnedUnit, event)
        else
            --DebugPrint("函数结束：没有找到对应挑战模式的处理函数: " .. challengeName)
        end
    else
        --DebugPrint("函数结束：未知的挑战模式ID: " .. tostring(challengeId))
    end
end