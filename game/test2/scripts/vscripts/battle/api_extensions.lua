function CDOTA_Buff:IsFearDebuff()
    local tables = {}
    self:CheckStateToTable(tables)
    
    for state_name, mod_table in pairs(tables) do
        if tostring(state_name) == tostring(MODIFIER_STATE_FEARED) then
             return true
        end
    end
    return false
end

function CDOTA_Buff:IsTauntDebuff()
    local tables = {}
    self:CheckStateToTable(tables)
    
    for state_name, mod_table in pairs(tables) do
        if tostring(state_name) == tostring(MODIFIER_STATE_TAUNTED) then
             return true
        end
    end
    return false
end

function CDOTA_BaseNPC:IsLeashed()
    if not IsServer() then return end
    
    for _, mod in pairs(self:FindAllModifiers()) do
        local tables = {}
        mod:CheckStateToTable(tables)
        local bkb_allowed = true
    
        if mod:GetAbility() then 
            local behavior = mod:GetAbility():GetAbilityTargetFlags()
    
            if bit.band(behavior, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) == 0 and self:IsDebuffImmune() then 
                bkb_allowed = false
            end 
        end 
    
        if bkb_allowed == true then 
            for state_name, mod_table in pairs(tables) do
                if tostring(state_name) == tostring(MODIFIER_STATE_TETHERED) then
                     return true
                end
            end
        end
    end
    return false
end

CDOTA_BaseNPC.GetPurgableDebuffsCount = function(self)
    -- 直接获取单位身上所有的modifier对象
    local allModifiers = self:FindAllModifiers()
    local count = 0
    
    -- 遍历检查每个modifier
    for _, modifier in ipairs(allModifiers) do
        -- 检查是否是debuff
        if modifier and modifier:IsDebuff() then
            -- 获取创建该modifier的技能
            local ability = modifier:GetAbility()
            
            -- 如果能获取到技能，检查其可驱散性
            if ability then
                local abilityName = ability:GetAbilityName()
                local keyValues = GetAbilityKeyValuesByName(abilityName)
                
                -- 检查是否可驱散
                if keyValues and keyValues["SpellDispellableType"] == "SPELL_DISPELLABLE_YES" then
                    count = count + 1
                end
            end
        end
    end
    
    -- 始终返回数字
    return count
end

CDOTA_BaseNPC.GetPurgableBuffsCount = function(self)
    -- 直接获取单位身上所有的modifier对象
    local allModifiers = self:FindAllModifiers()
    local count = 0
    
    -- 遍历检查每个modifier
    for _, modifier in ipairs(allModifiers) do
        -- 检查是否是增益buff（非debuff）
        if modifier and not modifier:IsDebuff() then
            -- 获取创建该modifier的技能
            local ability = modifier:GetAbility()
            
            -- 如果能获取到技能，检查其可驱散性
            if ability then
                local abilityName = ability:GetAbilityName()
                local keyValues = GetAbilityKeyValuesByName(abilityName)
                
                -- 检查是否可驱散
                if keyValues and keyValues["SpellDispellableType"] == "SPELL_DISPELLABLE_YES" then
                    count = count + 1
                end
            end
        end
    end
    
    -- 始终返回数字
    return count
end

--使用说明
--获取单位的真实所有者

CDOTA_BaseNPC.GetRealOwner = function(self)
    debug = debug or false  -- 默认为false
    
    local function PrintDebug(...)
        if debug then
            print(...)
        end
    end
    local function FindOwner(checkUnit, level)
        if not checkUnit or checkUnit:IsNull() then 
            PrintDebug("单位无效,返回nil")
            return nil 
        end

        local unitName = checkUnit:GetUnitName()
        PrintDebug("当前检查的单位:", unitName)
        
        -- 打印单位类型信息
        if checkUnit.IsIllusion and checkUnit:IsIllusion() then
            PrintDebug("该单位是幻象")
        end
        if checkUnit.IsRealHero and checkUnit:IsRealHero() then
            PrintDebug("该单位是真实英雄")
        end
        if checkUnit:IsClone() then
            PrintDebug("该单位是克隆体") 
        end
        if checkUnit:IsTempestDouble() then
            PrintDebug("该单位是风暴双雄分身")
        end

        -- 检查是否是电狗分身
        if checkUnit:IsTempestDouble() then
            PrintDebug(string.format("检测到电狗分身: %s (EntityID: %d)", checkUnit:GetUnitName(), checkUnit:entindex()))
            
            -- 检查分身的modifier
            local modifiers = checkUnit:FindAllModifiers()
            for _, modifier in pairs(modifiers) do
                local modifierName = modifier:GetName()
                if modifierName == "modifier_arc_warden_tempest_double" then
                    PrintDebug("检查modifier:", modifierName)
                    local caster = modifier:GetCaster()
                    if caster and not caster:IsNull() then
                        PrintDebug(string.format("找到电狗分身的主体: %s (EntityID: %d)", caster:GetUnitName(), caster:entindex()))
                        return caster
                    end
                end
            end
            PrintDebug("未找到电狗分身的主体")
        end

        -- 特殊处理德鲁伊熊
        if unitName and unitName:find("npc_dota_lone_druid_bear") then
            PrintDebug("检测到德鲁伊熊")
            
            -- 检查熊的modifier
            local modifiers = checkUnit:FindAllModifiers()
            for _, modifier in pairs(modifiers) do
                local modifierName = modifier:GetName()
                if modifierName == "modifier_lone_druid_spirit_bear_attack_check" then
                    local ability = modifier:GetAbility()
                    PrintDebug("检查modifier:", modifierName)
                    if ability and not ability:IsNull() then
                        local owner = ability:GetOwner()
                        if owner and not owner:IsNull() then
                            PrintDebug("通过技能找到德鲁伊熊的主人:", owner:GetUnitName())
                            return owner
                        end
                    end
                end
            end
            PrintDebug("未找到德鲁伊熊的主人")
        end

        -- 如果是幻象，通过playerID获取原始单位
        if checkUnit.IsIllusion and checkUnit:IsIllusion() then
            PrintDebug("开始查找幻象的原始英雄")
            
            -- 检查所有modifier
            local modifiers = checkUnit:FindAllModifiers()
            for _, modifier in pairs(modifiers) do
                local modifierName = modifier:GetName()
                -- 排除modifier_illusion，检查其他包含illusion的modifier
                if string.find(modifierName, "illusion") and modifierName ~= "modifier_illusion" then
                    local ability = modifier:GetAbility()
                    PrintDebug("检查modifier:", modifierName)
                    if ability and not ability:IsNull() then
                        local owner = ability:GetOwner()
                        if owner and not owner:IsNull() then
                            PrintDebug("通过技能找到幻象创造者:", owner:GetUnitName())
                            return owner
                        end
                    end
                end
            end
            PrintDebug("未找到幻象的主人")
        end

        -- 如果是真实英雄（非幻象），直接返回
        if checkUnit.IsRealHero and checkUnit:IsRealHero() and not checkUnit:IsIllusion() and not checkUnit:IsClone() then
            PrintDebug("当前单位是真实英雄,直接返回:", checkUnit:GetUnitName())
            return checkUnit
        end

        -- 如果是技能召唤物（比如雷云、地狱火等）
        if checkUnit.IsRealHero and not checkUnit:IsRealHero() then
            PrintDebug("检测到技能召唤物")
            local owner = checkUnit:GetOwnerEntity()
            if owner then

                if owner.IsRealHero and owner:IsRealHero() then
                    PrintDebug("找到技能召唤物的英雄主人:", owner:GetUnitName())
                    return owner
                end
                -- 如果owner是技能，尝试获取施法者
                if type(owner.GetCaster) == "function" then
                    PrintDebug("所有者是技能,尝试获取施法者")
                    local caster = owner:GetCaster()
                    if caster then
                        PrintDebug("通过技能找到施法者:", caster:GetUnitName())
                        return caster
                    else
                        PrintDebug("未找到技能施法者")
                    end
                end
            else
                PrintDebug("未找到召唤物的所有者")
            end
        end
                
        -- 处理米波克隆体情况
        if checkUnit:IsClone() then
            PrintDebug(string.format("检测到克隆体: %s (EntityID: %d)", checkUnit:GetUnitName(), checkUnit:entindex()))
            
            local mainMeepo = checkUnit:GetCloneSource()  -- 使用GetCloneSource()获取米波本体
            if mainMeepo and not mainMeepo:IsNull() then
                PrintDebug(string.format("找到米波克隆体的主体: %s (EntityID: %d)", mainMeepo:GetUnitName(), mainMeepo:entindex()))
                return mainMeepo
            end
            
            PrintDebug("未找到米波主体")
        end

        -- 检查召唤物属性
        local ownerEntity = checkUnit:GetOwnerEntity()
        if ownerEntity and ownerEntity ~= checkUnit and type(ownerEntity.IsValidEntity) == "function" and ownerEntity:IsValidEntity() then
            PrintDebug("找到GetOwnerEntity:", ownerEntity:GetUnitName())
            if ownerEntity.IsRealHero and ownerEntity:IsRealHero() then
                PrintDebug("通过GetOwnerEntity找到英雄主人:", ownerEntity:GetUnitName())
                return ownerEntity
            end
            PrintDebug("递归查找GetOwnerEntity的所有者,当前层级:", level)
            return FindOwner(ownerEntity, level + 1)
        else
            PrintDebug("GetOwnerEntity未找到有效所有者")
        end
        
        -- 检查直接所有者
        local owner = checkUnit:GetOwner()
        if not owner then 
            PrintDebug("GetOwner返回空,尝试通过playerID查找")
            -- 尝试通过playerID查找
            local playerID = checkUnit:GetPlayerOwnerID()
            if playerID and playerID >= 0 then
                PrintDebug("单位的playerID:", playerID)
                local heroOwner = PlayerResource:GetSelectedHeroEntity(playerID)
                if heroOwner then
                    PrintDebug("通过playerID找到英雄主人:", heroOwner:GetUnitName())
                    return heroOwner
                else
                    PrintDebug("通过playerID未找到英雄")
                end
            end
            PrintDebug("没有找到直接所有者,返回nil")
            return nil 
        end
        
        if owner and owner ~= checkUnit and type(owner.IsValidEntity) == "function" and owner:IsValidEntity() then
            PrintDebug("找到GetOwner:", owner:GetUnitName())
            PrintDebug("递归查找GetOwner的所有者,当前层级:", level)
            return FindOwner(owner, level + 1)
        end
        
        PrintDebug("所有查找方法均失败,返回nil")
        return nil
    end

    if not self or self:IsNull() then 
        PrintDebug("输入单位无效,返回nil")
        return nil 
    end
    PrintDebug("开始查找单位的真实所有者:", self:GetUnitName())
    return FindOwner(self, 1)
end