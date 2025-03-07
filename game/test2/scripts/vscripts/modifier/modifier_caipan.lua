if not modifier_caipan then
    modifier_caipan = class({})
end

function modifier_caipan:IsHidden()
    return true
end

function modifier_caipan:IsPurgable()
    return false
end

function modifier_caipan:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
    }
end

function modifier_caipan:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_caipan:FindHigherGround(currentPos, initialRadius)
    local searchRadius = initialRadius
    local maxRadius = 2000
    local gridSize = 32
    
    while searchRadius <= maxRadius do
        local bestPoint = nil
        local closestDistance = searchRadius
        
        for x = -searchRadius, searchRadius, gridSize do
            for y = -searchRadius, searchRadius, gridSize do
                local testPos = Vector(currentPos.x + x, currentPos.y + y, 0)
                -- Only consider points where Y coordinate is greater than -900
                if testPos.y > -900 then
                    local height = GetGroundHeight(testPos, self:GetParent())
                    
                    -- 只寻找高度为128的地点
                    if height == 128 then
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
    
    return nil
end

function modifier_caipan:ClearTreesAroundPoint(point, radius)
    local trees = GridNav:GetAllTreesAroundPoint(point, radius, false)
    for _, tree in pairs(trees) do
        if tree:IsStanding() then
            tree:CutDown(self:GetParent():GetTeamNumber())
        end
    end
end

function modifier_caipan:OnIntervalThink()
    if IsServer() then
        local caipan = self:GetParent()
        local caipanPos = caipan:GetAbsOrigin()
        
        -- 寻找附近300范围内的所有单位
        local units = FindUnitsInRadius(
            caipan:GetTeamNumber(),
            caipanPos,
            nil,
            300,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        
        -- 检查每个单位
        for _, unit in pairs(units) do
            if unit ~= caipan then
                local unitPos = unit:GetAbsOrigin()
                -- 如果单位和裁判在同一高度
                if math.abs(unitPos.z - caipanPos.z) < 5 then
                    local bestPoint = self:FindHigherGround(unitPos, 200)
                    
                    if bestPoint then
                        -- Clear trees within 300 units of the teleport point
                        self:ClearTreesAroundPoint(bestPoint, 300)
                        -- Wait a short moment for tree destruction to complete
                        
                        FindClearSpaceForUnit(unit, bestPoint, true)
                    else
                        print("裁判")
                        local currentGroundHeight = GetGroundHeight(unitPos, unit)
                        if currentGroundHeight > 0 then
                            FindClearSpaceForUnit(unit, Vector(unitPos.x, unitPos.y, currentGroundHeight), true)
                        end
                    end
                end
            end
        end
    end
end