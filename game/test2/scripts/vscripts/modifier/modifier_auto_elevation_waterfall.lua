if not modifier_auto_elevation_waterfall then
    modifier_auto_elevation_waterfall = class({})
end

modifier_auto_elevation_waterfall.BOUNDARY = {
    X_MIN = -6959,
    X_MAX = -5070,
    Y_MIN = -794,
    Y_MAX = 1060
}

function modifier_auto_elevation_waterfall:IsHidden()
    return true
end

function modifier_auto_elevation_waterfall:IsPurgable()
    return false
end

modifier_auto_elevation_waterfall.excluded_modifiers = {
    ["modifier_ursa_earthshock_move"] = true,
    ["modifier_pangolier_shield_crash_jump"] = true,
    ["modifier_phoenix_icarus_dive"] = true
}

function modifier_auto_elevation_waterfall:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
    }
end

function modifier_auto_elevation_waterfall:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_auto_elevation_waterfall:IsOutOfBounds(pos)
    local bounds = self.BOUNDARY
    local margin = 1000 -- 超出边界的容许距离

    -- 检查是否超出边界太远
    if pos.x < (bounds.X_MIN - margin) or 
       pos.x > (bounds.X_MAX + margin) or
       pos.y < (bounds.Y_MIN - margin) or
       pos.y > (bounds.Y_MAX + margin) then
        return true
    end
    return false
end

function modifier_auto_elevation_waterfall:FindHigherGround(currentPos, initialRadius)
    local searchRadius = initialRadius
    local maxRadius = 2000
    local gridSize = 32
    local bounds = self.BOUNDARY
    
    -- 从当前位置开始搜索
    while searchRadius <= maxRadius do
        local bestPoint = nil
        local closestDistance = searchRadius
        
        for x = -searchRadius, searchRadius, gridSize do
            for y = -searchRadius, searchRadius, gridSize do
                local testPos = Vector(currentPos.x + x, currentPos.y + y, 0)
                -- 确保测试点在矩形范围内
                if testPos.x >= bounds.X_MIN and testPos.x <= bounds.X_MAX and
                   testPos.y >= bounds.Y_MIN and testPos.y <= bounds.Y_MAX then
                    local height = GetGroundHeight(testPos, self:GetParent())
                    
                    -- 只寻找高度为128或以上的地点
                    if height >= 128 then
                        local distance = (Vector(currentPos.x, currentPos.y, 0) - Vector(testPos.x, testPos.y, 0)):Length2D()
                        if distance < closestDistance then
                            closestDistance = distance
                            bestPoint = Vector(testPos.x, testPos.y, height)
                        end
                    end
                end
            end
        end
        
        if bestPoint then
            return bestPoint
        end
        
        searchRadius = searchRadius + 200
    end
    
    -- 如果在当前位置周围找不到，从中心点开始找
    local centerX = (bounds.X_MIN + bounds.X_MAX) / 2
    local centerY = (bounds.Y_MIN + bounds.Y_MAX) / 2
    local startPos = Vector(centerX, centerY, 0)
    searchRadius = initialRadius
    
    while searchRadius <= maxRadius do
        local bestPoint = nil
        local closestDistance = searchRadius
        
        for x = -searchRadius, searchRadius, gridSize do
            for y = -searchRadius, searchRadius, gridSize do
                local testPos = Vector(startPos.x + x, startPos.y + y, 0)
                if testPos.x >= bounds.X_MIN and testPos.x <= bounds.X_MAX and
                   testPos.y >= bounds.Y_MIN and testPos.y <= bounds.Y_MAX then
                    local height = GetGroundHeight(testPos, self:GetParent())
                    
                    if height >= 128 then
                        local distance = (startPos - Vector(testPos.x, testPos.y, 0)):Length2D()
                        if distance < closestDistance then
                            closestDistance = distance
                            bestPoint = Vector(testPos.x, testPos.y, height)
                        end
                    end
                end
            end
        end
        
        if bestPoint then
            return bestPoint
        end
        
        searchRadius = searchRadius + 200
    end
    
    return nil
end


function modifier_auto_elevation_waterfall:ClearTreesAroundPoint(point, radius)
    local trees = GridNav:GetAllTreesAroundPoint(point, radius, false)
    for _, tree in pairs(trees) do
        if tree:IsStanding() then
            tree:CutDown(self:GetParent():GetTeamNumber())
        end
    end
end

function modifier_auto_elevation_waterfall:HasExcludedModifier()
    local unit = self:GetParent()
    
    -- 检查单位是否有排除列表中的任何一个modifier
    for modifier_name, _ in pairs(self.excluded_modifiers) do
        if unit:HasModifier(modifier_name) then
            return true
        end
    end
    
    return false
end

function modifier_auto_elevation_waterfall:IsInvulnerable()
    local unit = self:GetParent()
    return unit:IsInvulnerable() or unit:IsOutOfGame() or unit:HasModifier("modifier_invulnerable")
end

function modifier_auto_elevation_waterfall:OnIntervalThink()
    if IsServer() then
        local unit = self:GetParent()
        
        if not unit:IsAlive() then return end
        if self:HasExcludedModifier() then return end
        
        local currentPos = unit:GetAbsOrigin()
        
        -- 如果高度太低，无论是否无敌都要传送
        if currentPos.z <= 0 then
            local bestPoint = self:FindHigherGround(currentPos, 200)
            if bestPoint then
                if GridNav:IsTraversable(bestPoint) and not GridNav:IsBlocked(bestPoint) then
                    self:ClearTreesAroundPoint(bestPoint, 300)
                    Timers:CreateTimer(0.1, function()
                        if unit:IsAlive() then
                            FindClearSpaceForUnit(unit, bestPoint, true)
                        end
                    end)
                end
            end
        -- 如果是超出边界太远，则需要检查是否无敌
        elseif self:IsOutOfBounds(currentPos) and not self:IsInvulnerable() then
            local bestPoint = self:FindHigherGround(currentPos, 200)
            if bestPoint then
                if GridNav:IsTraversable(bestPoint) and not GridNav:IsBlocked(bestPoint) then
                    self:ClearTreesAroundPoint(bestPoint, 300)
                    Timers:CreateTimer(0.1, function()
                        if unit:IsAlive() then
                            FindClearSpaceForUnit(unit, bestPoint, true)
                        end
                    end)
                end
            end
        end
    end
end