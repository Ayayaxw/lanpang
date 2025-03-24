-- 存储当前追踪的单位和计时器ID
local trackingUnits = nil
local trackingTimerId = nil

-- 视角高度参数
local MIN_CAMERA_HEIGHT = 800 -- 最小视角高度
local PADDING_FACTOR = 1.3 -- 视野冗余因子

-- 开始视角监察函数
function Main:StartUnitsFocusTracking(unitTable)
    -- 保存需要追踪的单位表
    trackingUnits = unitTable
    
    -- 如果已有计时器在运行，先停止它
    if trackingTimerId then
        Timers:RemoveTimer(trackingTimerId)
    end
    
    -- 创建计时器，每帧更新单位中心点和视角高度
    trackingTimerId = Timers:CreateTimer(function()
        -- 确保单位表有效
        if not trackingUnits or #trackingUnits == 0 then
            return nil
        end
        
        -- 计算所有有效单位的中心点
        local centerX = 0
        local centerY = 0
        local validUnits = 0
        
        for _, unit in pairs(trackingUnits) do
            if unit and not unit:IsNull() and unit:IsAlive() then
                local position = unit:GetAbsOrigin()
                centerX = centerX + position.x
                centerY = centerY + position.y
                validUnits = validUnits + 1
            end
        end
        
        -- 如果没有有效单位，停止追踪
        if validUnits == 0 then
            return nil
        end
        
        -- 计算平均位置作为中心点
        centerX = centerX / validUnits
        centerY = centerY / validUnits
        local centerPoint = Vector(centerX, centerY, 0)
        
        -- 计算距离最远的单位到中心点的距离
        local maxDistance = 0
        for _, unit in pairs(trackingUnits) do
            if unit and not unit:IsNull() and unit:IsAlive() then
                local position = unit:GetAbsOrigin()
                local distance = (position - centerPoint):Length2D()
                if distance > maxDistance then
                    maxDistance = distance
                end
            end
        end
        
        -- 计算合适的视角高度（添加冗余空间）
        local cameraHeight = math.max(maxDistance * PADDING_FACTOR, MIN_CAMERA_HEIGHT)
        
        -- 创建发送到前端的数据
        local cameraData = {
            center_x = centerX,
            center_y = centerY,
            height = cameraHeight
        }
        
        -- 发送数据到前端
        CustomGameEventManager:Send_ServerToAllClients("update_camera_focus", cameraData)
        
        -- 每0.03秒执行一次（约30fps）
        return 0.03
    end)
    
    print("已开始单位视角追踪")
    return true
end

-- 停止视角监察函数
function Main:StopUnitsFocusTracking()
    if trackingTimerId then
        Timers:RemoveTimer(trackingTimerId)
        trackingTimerId = nil
        trackingUnits = nil
        print("已停止单位视角追踪")
        
        -- 通知前端停止视角跟踪
        CustomGameEventManager:Send_ServerToAllClients("stop_camera_focus", {})
        return true
    end
    return false
end

return Main 