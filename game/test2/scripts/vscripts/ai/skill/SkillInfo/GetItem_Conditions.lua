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
    ["item_sphere"] = {
        function(self, caster, item, log)
            return false
        end
    },
    ["item_quelling_blade"] = {
        function(self, caster, item, log)
            return false
        end
    },
    ["item_power_treads"] = {
        function(self, caster, item, log)
            return false
        end
    },
    ["item_urn_of_shadows"] = {
        function(self, caster, item, log)
            local charges = item:GetCurrentAbilityCharges()
            self:log(string.format("魂匣当前充能: %d", charges))
            
            if charges > 0 then
                return true
            else
                return false
            end
        end
    },


        

    ["item_shadow_amulet"] = {
        function(self, caster, item, log)
            if not item then return false end
            
            self.Ally = self:FindBestAllyHeroTarget(
                caster,
                item,
                nil,
                nil,
                "nearest_to_enemy"  -- 优先给离敌人最近的友军加静电护盾
            )
            
            return self.Ally ~= nil
        end
    },


    ["item_refresher"] = {
        function(self, caster, item, log)
            if not item then 
                log("刷新球: 物品不存在")
                return false 
            end
            
            -- 检查蓝量是否足够
            if caster:GetMana() <= 700 then
                log(string.format("刷新球: 蓝量不足（当前: %d，需要: 700）", caster:GetMana()))
                return false
            end
            
            -- 存储所有符合条件的技能
            local validAbilities = {}
            local foundValidAbility = false
            
            -- 获取单位所有技能
            for i = 0, caster:GetAbilityCount() - 1 do
                local ability = caster:GetAbilityByIndex(i)
                
                if not ability then
                    log("刷新球: 技能槽位为空")
                    goto continue
                end
                
                -- 检查技能名称是否包含special_bonus
                local abilityName = ability:GetName()
                if string.find(abilityName, "special_bonus") then
                    log(string.format("刷新球: 技能 %s 是天赋技能，忽略", abilityName))
                    goto continue
                end
                
                -- 检查技能是否隐藏
                if ability:IsHidden() and not caster:GetUnitName() == "npc_dota_hero_invoker" then
                    log(string.format("刷新球: 技能 %s 被隐藏", ability:GetName()))
                    goto continue
                end
                
                -- 检查技能冷却时间是否大于5秒
                local cooldown = ability:GetCooldown(ability:GetLevel())
                if cooldown <= 5 then
                    log(string.format("刷新球: 技能 %s 冷却时间不足5秒（当前: %.1f）", ability:GetName(), cooldown))
                    goto continue
                end
                
                -- 检查是否是开关类技能
                if ability:IsToggle() then
                    log(string.format("刷新球: 技能 %s 是开关类技能", ability:GetName()))
                    goto continue
                end
                
                
                -- 检查是否是被禁用的技能
                if self.disabledSkills[caster:GetUnitName()] and self:IsDisabledSkill(ability:GetAbilityName(), caster:GetUnitName()) then
                    log(string.format("刷新球: 技能 %s 被禁用", ability:GetName()))
                    goto continue
                end
                
                -- 检查是否是被动技能
                if ability:IsPassive() then
                    log(string.format("刷新球: 技能 %s 是被动技能", ability:GetName()))
                    goto continue
                end
                
                -- 如果所有条件都满足，加入 validAbilities
                table.insert(validAbilities, ability)
                foundValidAbility = true
                
                ::continue::
            end
            
            -- 如果没有符合条件的技能，返回false
            if #validAbilities == 0 then
                log("刷新球: 没有符合条件的技能")
                return false
            end
            
            -- 检查是否所有符合条件的技能都在冷却中
            local allOnCooldown = true
            for _, ability in ipairs(validAbilities) do
                if ability:IsCooldownReady() then
                    log(string.format("刷新球: 技能 %s 不在冷却中", ability:GetName()))
                    allOnCooldown = false
                end
            end
            
            if allOnCooldown then
                log("刷新球: 所有技能都在冷却中，可以使用")
                return true
            else
                log("刷新球: 有技能不在冷却中，不满足使用条件")
                return false
            end
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