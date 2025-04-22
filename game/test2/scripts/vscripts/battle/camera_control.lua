if not CameraControl then
    CameraControl = {}
end

-- 初始化相机控制系统
function CameraControl:Initialize()
    -- 初始化数据
    CameraControl.cameraData = {
        units = {},      -- 所有单位表
        lastSync = 0,    -- 上次同步时间
        active = true    -- 系统是否激活
    }
    
    -- 发送初始化消息给前端
    CustomGameEventManager:Send_ServerToAllClients("camera_initialize", {})
    
    print("相机控制系统初始化")
    return true
end

-- 停止相机控制系统
function CameraControl:Stop()
    if CameraControl.cameraData then
        CameraControl.cameraData.active = false
        
        -- 发送停止消息给前端
        CustomGameEventManager:Send_ServerToAllClients("camera_stop", {})
        
        print("相机控制系统停止")
        return true
    end
    return false
end

-- 同步单位数据到前端
function CameraControl:SyncUnitsToClient()
    local data = CameraControl.cameraData
    
    -- 如果系统未初始化或已停止，则不同步
    if not data or not data.active then 
        print("相机系统未初始化或已停止，跳过同步")
        return 
    end
    
    -- 构建单位数据
    local unitData = {}
    
    for i, unitInfo in ipairs(data.units) do
        local unit = unitInfo.unit
        
        -- 检查单位是否有效
        if unit and IsValidEntity(unit) and unit.IsAlive and unit:IsAlive() then
            local teamId = unitInfo.team
            local isHero = unit:IsHero()
            local entIndex = unit:GetEntityIndex()
            
            print("添加有效单位到数据包: " .. unit:GetUnitName() .. ", 队伍: " .. teamId)
            
            table.insert(unitData, {
                entityIndex = entIndex,
                team = teamId,
                isHero = isHero
            })
        end
    end
    
    -- 发送单位数据到前端
    print("准备发送单位数据，单位数量: " .. #unitData)
    
    -- 确保即使数组为空也发送有效结构
    local eventData = {
        units = unitData,
        count = #unitData  -- 明确添加计数字段
    }
    
    CustomGameEventManager:Send_ServerToAllClients("camera_units_update", eventData)
    
    -- 更新同步时间
    print("同步单位数据到前端完成")
    data.lastSync = GameRules:GetGameTime()
end

-- 添加单位到相机控制系统
function CameraControl:AddUnitToCameraControl(unit, team)
    if not unit or not unit:IsAlive() then return end
    
    local data = CameraControl.cameraData
    
    -- 如果系统未初始化或已停止，则不添加
    if not data or not data.active then return end
    
    -- 检查单位是否已存在
    for i, unitInfo in ipairs(data.units) do
        if unitInfo.unit == unit then
            return -- 单位已存在，不重复添加
        end
    end
    
    -- 添加新单位
    table.insert(data.units, {
        unit = unit,
        team = team
    })
    
    -- 立即同步单位数据
    CameraControl:SyncUnitsToClient()
end

-- 移除单位
function CameraControl:RemoveUnitFromCameraControl(unit)
    local data = CameraControl.cameraData
    
    -- 如果系统未初始化或已停止，则不处理
    if not data or not data.active then return end
    
    local removed = false
    
    -- 从单位表中移除
    for i = #data.units, 1, -1 do
        if data.units[i].unit == unit then
            table.remove(data.units, i)
            removed = true
        end
    end
    
    -- 如果有单位被移除，同步所有单位
    if removed then
        CameraControl:SyncUnitsToClient()
    end
    
    -- 同时发送单独的移除通知
    if unit and IsValidEntity(unit) then
        CustomGameEventManager:Send_ServerToAllClients("camera_unit_removed", {
            entityIndex = unit:GetEntityIndex()
        })
    end
end

-- 更新所有单位 (可在需要时手动调用)
function CameraControl:UpdateUnits()
    if CameraControl.cameraData and CameraControl.cameraData.active then
        CameraControl:SyncUnitsToClient()
    end
end

