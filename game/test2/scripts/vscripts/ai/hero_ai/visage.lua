if VisageFamiliarCoordinator == nil then
    VisageFamiliarCoordinator = {
        lastCastTime = 0,
        stunRefreshWindow = 0.3,  -- 眩晕刷新窗口
        castLockDuration = 0.3    -- 施法锁定时间
    }
end

function VisageFamiliarCoordinator:RecordCast()
    self.lastCastTime = GameRules:GetGameTime()
    print(string.format("[VisageFamiliarCoordinator] 记录石化时间: %.2f", self.lastCastTime))
end

function VisageFamiliarCoordinator:CanCastAgain()
    local currentTime = GameRules:GetGameTime()
    local timeSinceLastCast = currentTime - self.lastCastTime
    local canCast = timeSinceLastCast >= self.castLockDuration
    
    print(string.format("[VisageFamiliarCoordinator] 当前时间: %.2f, 上次施法时间: %.2f, 间隔: %.2f, 是否可以施法: %s", 
        currentTime, self.lastCastTime, timeSinceLastCast, tostring(canCast)))
    
    -- 如果已经过了很长时间（比如5秒），重置lastCastTime
    if timeSinceLastCast > 5.0 then
        self.lastCastTime = 0
        print("[VisageFamiliarCoordinator] 重置施法时间")
        return true
    end
    
    return canCast
end

-- 添加重置函数
function VisageFamiliarCoordinator:Reset()
    self.lastCastTime = 0
    print("[VisageFamiliarCoordinator] 手动重置施法时间")
end

return VisageFamiliarCoordinator