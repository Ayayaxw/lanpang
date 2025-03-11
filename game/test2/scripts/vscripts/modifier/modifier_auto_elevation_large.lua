if not modifier_auto_elevation_large then
    modifier_auto_elevation_large = class({})
end

function modifier_auto_elevation_large:IsHidden()
    return true
end

function modifier_auto_elevation_large:IsPurgable()
    return false
end

modifier_auto_elevation_large.excluded_modifiers = {
    ["modifier_ursa_earthshock_move"] = true,
    ["modifier_pangolier_shield_crash_jump"] = true,
    ["modifier_phoenix_icarus_dive"] = true,
    ["modifier_monkey_king_fur_army_soldier"] = true,
}

function modifier_auto_elevation_large:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
    }
end

function modifier_auto_elevation_large:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_auto_elevation_large:FindHigherGround(currentPos, initialRadius)
    local searchRadius = initialRadius
    local maxRadius = 2000
    local gridSize = 32
    
    -- 从当前位置开始搜索
    while searchRadius <= maxRadius do
        local bestPoint = nil
        local closestDistance = searchRadius
        
        for x = -searchRadius, searchRadius, gridSize do
            for y = -searchRadius, searchRadius, gridSize do
                local testPos = Vector(currentPos.x + x, currentPos.y + y, 0)
                -- 添加X坐标限制
                if testPos.y > -900 and testPos.x > -2000 and testPos.x < 2100 then
                    local height = GetGroundHeight(testPos, self:GetParent())
                    
                    -- 只寻找高度为128的地点
                    if height >= 128 and height < 200 then
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
    
    -- 如果在当前位置周围找不到，从(0, -900, 0)开始找
    searchRadius = initialRadius
    local startPos = Vector(0, -900, 0)
    
    while searchRadius <= maxRadius do
        local bestPoint = nil
        local closestDistance = searchRadius
        
        for x = -searchRadius, searchRadius, gridSize do
            for y = -searchRadius, searchRadius, gridSize do
                local testPos = Vector(startPos.x + x, startPos.y + y, 0)
                -- 添加X坐标限制
                if testPos.y > -900 and testPos.x > -2000 and testPos.x < 2100 then
                    local height = GetGroundHeight(testPos, self:GetParent())
                    
                    -- 只寻找高度为128的地点
                    if height >= 128 and height < 200 then
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

function modifier_auto_elevation_large:ClearTreesAroundPoint(point, radius)
    local trees = GridNav:GetAllTreesAroundPoint(point, radius, false)
    for _, tree in pairs(trees) do
        if tree:IsStanding() then
            tree:CutDown(self:GetParent():GetTeamNumber())
        end
    end
end

function modifier_auto_elevation_large:HasExcludedModifier()
    local unit = self:GetParent()
    
    -- 检查单位是否有排除列表中的任何一个modifier
    for modifier_name, _ in pairs(self.excluded_modifiers) do
        if unit:HasModifier(modifier_name) then
            return true
        end
    end
    
    return false
end

function modifier_auto_elevation_large:OnIntervalThink()
    if IsServer() then
        local unit = self:GetParent()
        
        -- 检查是否有排除的modifier
        if self:HasExcludedModifier() then
            return
        end
        
        local currentPos = unit:GetAbsOrigin()
        
        if currentPos.z <= 0 then
            local bestPoint = self:FindHigherGround(currentPos, 200)
            
            if bestPoint then
                -- Clear trees within 300 units of the teleport point
                self:ClearTreesAroundPoint(bestPoint, 300)
                -- Wait a short moment for tree destruction to complete
                
                FindClearSpaceForUnit(unit, bestPoint, true)
                
            else
                print("Warning: No suitable high ground found within 2000 units!")--打印单位名字
                print(unit:GetUnitName())--如果没有名字，就打印单位class
                if unit:GetUnitName() == "" then
                    print(unit:GetClassname())
                end
                local currentGroundHeight = GetGroundHeight(currentPos, unit)
                if currentGroundHeight > 0 then
                    FindClearSpaceForUnit(unit, Vector(currentPos.x, currentPos.y, currentGroundHeight), true)
                end
            end
        end
    end
end