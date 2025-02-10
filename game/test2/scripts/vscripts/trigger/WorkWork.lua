require("app/index")

if WorkWork == nil  then
    WorkWork = ({}) end



function WorkWork_Moving(params)
    local trigger = params.caller
    local activator = params.activator

    -- 检查触发器和激活单位是否有效，并且单位名称是否为 "luosi"
    if not trigger or not activator or not IsValidEntity(activator) or not activator:IsAlive() or (activator:GetUnitName() ~= "luosi" ) then
        return
    end

    -- 创建一个定时器，使单位持续向东移动
    Timers:CreateTimer(function()
        -- 如果单位不存在或已经死亡，停止定时器
        if not IsValidEntity(activator) or not activator:IsAlive() then
            return nil
        end

        -- 检查单位是否有modifier_faceless_void_chronosphere_freeze
        if activator:HasModifier("modifier_faceless_void_chronosphere_freeze") then
            return 0.01  -- 如果有modifier，继续检查但不移动
        end

        -- 检查单位是否仍在触发器范围内
        local unitPos = activator:GetAbsOrigin()
        local triggerMin = trigger:GetBoundingMins() + trigger:GetAbsOrigin()
        local triggerMax = trigger:GetBoundingMaxs() + trigger:GetAbsOrigin()

        if unitPos.x >= triggerMin.x and unitPos.x <= triggerMax.x and
            unitPos.y >= triggerMin.y and unitPos.y <= triggerMax.y and
            unitPos.z >= triggerMin.z and unitPos.z <= triggerMax.z then
            
            -- 计算新的位置（向东移动）
            local newPos = Vector(unitPos.x + 5, unitPos.y, unitPos.z)
            
            -- 设置单位的新位置
            FindClearSpaceForUnit(activator, newPos, true)
            
            -- 0.01秒后再次执行
            return 0.01
        else
            -- 如果单位离开触发器范围，停止定时器
            return nil
        end
    end)
end
-- WorkWork_Leave 触发器函数
-- WorkWork_Leave 触发器函数
function WorkWork_Leave(params)
--[[     local trigger = params.caller
    local activator = params.activator

    -- 检查触发单位是否为真正的英雄
    if activator and IsValidEntity(activator) and activator:IsRealHero() then
        -- 搜索附近名为 "ringmaster" 的英雄
        local searchRadius = 2000 -- 搜索半径，可以根据需要调整
        local units = FindUnitsInRadius(
            activator:GetTeamNumber(),
            activator:GetAbsOrigin(),
            nil,
            searchRadius,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        local ringmaster = nil
        for _, unit in pairs(units) do
            if unit:GetUnitName() == "npc_dota_hero_ringmaster" then
                ringmaster = unit
                break
            end
        end

        if ringmaster and IsValidEntity(ringmaster) then
            -- 将 ringmaster 设置为敌对
            ringmaster:SetTeam(DOTA_TEAM_BADGUYS)
            ringmaster:RemoveModifierByName("modifier_disarmed")
            -- 移除玩家的控制权
            ringmaster:SetControllableByPlayer(-1, false)
            
            -- 可选：改变 ringmaster 的行为 AI
            CreateAIForHero(ringmaster)
            
            print("Ringmaster has turned against us!")
        else
            print("Ringmaster not found or is not a valid entity.")
        end
    else
        print("The leaving entity is not a real hero or is invalid.")
    end ]]
end


-- 辅助函数：在公屏上显示 luosi 数量
local function DisplayLuosiCount()
    GameRules:SendCustomMessage("当前区域内的 luosi 数量: " .. _G.luosiCount, 0, 0)
end
-- 确保 luosiCount 被正确初始化
if _G.luosiCount == nil then
    _G.luosiCount = 0
end


local function SetRingmasterHostileAndAttack()
    if _G.luosiCount >= 3 then
        local ringmaster = Entities:FindByName(nil, "npc_dota_hero_ringmaster")
        if ringmaster and IsValidEntity(ringmaster) and ringmaster:GetTeam() ~= DOTA_TEAM_BADGUYS then
            ringmaster:SetTeam(DOTA_TEAM_BADGUYS)
            ringmaster:SetControllableByPlayer(-1, false)
            GameRules:SendCustomMessage("百戏大王要严惩你！！！！", 0, 0)
            ringmaster:RemoveModifierByName("modifier_disarmed")
            CreateAIForHero(ringmaster)

        end
    end
end

function Work_end_In(params)
    local activator = params.activator

    if not activator or not IsValidEntity(activator) or not activator:IsAlive() or (activator:GetUnitName() ~= "luosi") then
        return
    end

    -- 让右边的发条技师做攻击动作
    if Main and Main.rightClockwerk then
        Main.rightClockwerk:StartGesture(ACT_DOTA_ATTACK)
    end

    -- 延迟 0.1 秒后检查 luosi 状态
    Timers:CreateTimer(0.4, function()
        -- 再次检查 luosi 是否还存在且存活
        if IsValidEntity(activator) and activator:IsAlive() then
            -- 如果还活着，就杀死它
            activator:ForceKill(false)
        end
    end)
end

function Work_end_Out(params)
--[[     local activator = params.activator

    if not activator or (activator:GetUnitName() ~= "luosi") then
        return
    end

    _G.luosiCount = math.max(0, (_G.luosiCount or 0) - 1)
    DisplayLuosiCount() ]]
end