ItemConditions = {
    ["item_sphere"] = {
        function(self, caster, item, log)
            return false  -- 始终返回false，表示始终禁用林肯法球的主动使用
        end
    },
    ["item_satanic"] = {
        function(self, caster, item, log)
            if self:containsStrategy(self.global_strategy, "满血开撒旦") then
            return true
            end
            local healthPercent = caster:GetHealthPercent()
            if log then
                log(string.format("撒旦使用检查: 当前血量 %.1f%%", healthPercent))
            end
            return healthPercent < 75
        end
    },
    ["item_mjollnir"] = {
        function(self, caster, item, log)
            if not item then return false end
            
            self.Ally = self:FindBestAllyHeroTarget(
                caster,
                item,
                {"modifier_item_mjollnir_static"},
                0.5,
                "nearest_to_enemy"  -- 优先给离敌人最近的友军加静电护盾
            )
            
            return self.Ally ~= nil
        end
    },
    ["item_disperser"] = {
        function(self, caster, item, log)
            if not item then return false end
            
            self.Ally = self:FindBestAllyHeroTarget(
                caster,
                item,
                {"modifier_disperser_movespeed_buff"},
                0.5,
                "nearest_to_enemy"  -- 优先给离敌人最近的友军加静电护盾
            )
            
            return self.Ally ~= nil
        end
    },
}

function CommonAI:FindConditionsForItem(itemName)
    return ItemConditions[itemName]
end

function CommonAI:CheckItemConditions(entity)
    self:log("检查物品条件")

    if not self.disabledItems then
        self.disabledItems = {}
    end

    local items = {}
    -- 检查物品栏位 0-8
    for i = 0, 8 do
        local item = entity:GetItemInSlot(i)
        if item and item:GetAbilityName() and item:IsCooldownReady() then
            table.insert(items, item)
        end
    end

    -- 检查中立物品栏位 (16)
    local neutralItem = entity:GetItemInSlot(16)
    if neutralItem and neutralItem:GetAbilityName() and neutralItem:IsCooldownReady() then
        table.insert(items, neutralItem)
    end

    -- 如果没有任何物品条件定义，记录日志并返回
    if not next(ItemConditions) then
        self:log("没有定义的物品条件")
        return
    end

    for _, item in ipairs(items) do
        local itemName = item:GetAbilityName()
        local conditions = self:FindConditionsForItem(itemName)

        if conditions then
            if conditions[1](self, entity, item, function(msg) self:log(msg) end) then
                
                self:log(string.format("物品 %s 条件满足", itemName))
                for i, disabledItem in ipairs(self.disabledItems) do
                    if disabledItem == itemName then
                        table.remove(self.disabledItems, i)
                        self:log(string.format("物品 %s 已从禁用列表中移除", itemName))
                        break
                    end
                end
            else
                if not self:tableContains(self.disabledItems, itemName) then
                    table.insert(self.disabledItems, itemName)
                end
            end
        end
    end
end