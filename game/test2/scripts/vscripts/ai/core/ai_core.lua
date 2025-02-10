-- ai_core.lua

AICore = {}

function AICore:CreateBehaviorSystem(behaviors)
    local system = {}
    system.behaviors = behaviors
    system.currentBehavior = nil

    function system:Think()
        if self.currentBehavior then
            local status = self.currentBehavior:Think()
            if status == "complete" then
                self.currentBehavior = nil
            end
        end

        if not self.currentBehavior then
            self.currentBehavior = self:ChooseNextBehavior()
            if self.currentBehavior then
                self.currentBehavior:Begin()
            end
        end
    end

    function system:ChooseNextBehavior()
        for _, behavior in pairs(self.behaviors) do
            if behavior:Evaluate() > 0 then
                return behavior
            end
        end
        return nil
    end

    return system
end
