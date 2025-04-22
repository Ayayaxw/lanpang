modifier_percentage_total_armor = class({})

function modifier_percentage_total_armor:IsHidden() return false end
function modifier_percentage_total_armor:IsPurgable() return true end

function modifier_percentage_total_armor:OnCreated()
    if not IsServer() then return end
    print("[修饰器_百分比_总护甲] 创建完成")
    self.bonus_percentage = 100  -- 默认100%加成
    self:StartIntervalThink(0.1)  -- 每0.1秒更新一次，避免频繁计算
    print("[修饰器_百分比_总护甲] 间隔思考已启动 (0.1秒)")
end

function modifier_percentage_total_armor:OnIntervalThink()
    if not IsServer() then return end
    print("[修饰器_百分比_总护甲] 间隔思考触发")
    
    local parent = self:GetParent()
    print(string.format("[修饰器] 父实体: %s (索引: %d)", parent:GetUnitName(), parent:GetEntityIndex()))
    
    -- 获取当前护甲信息（仅用于调试显示）
    local base_armor = parent:GetPhysicalArmorBaseValue()  -- 基础护甲
    
    -- 避免自循环计算：临时禁用此修饰器的护甲加成
    self.ignore_bonus = true
    -- 获取总护甲与额外护甲
    local total_armor = parent:GetPhysicalArmorValue(false)  -- 总护甲
    local bonus_armor = total_armor - base_armor  -- 计算额外护甲
    self.ignore_bonus = false
    
    print(string.format("[修饰器] 基础护甲: %.1f, 额外护甲 (通过计算): %.1f", base_armor, bonus_armor))
    print(string.format("[修饰器] 当前总护甲: %.1f", total_armor))
    print(string.format("[修饰器] 应用百分比加成: %d%%", self.bonus_percentage))
    
    -- 计算加成后的预期护甲值
    local expected_armor = total_armor * (1 + self.bonus_percentage/100)
    print(string.format("[修饰器] 预期加成后总护甲: %.1f", expected_armor))
    
    print("----------------------------------------")
end

function modifier_percentage_total_armor:DeclareFunctions()
    print("[修饰器_百分比_总护甲] 声明函数被调用")
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_TOTAL_PERCENTAGE
    }
end

function modifier_percentage_total_armor:GetModifierPhysicalArmorTotal_Percentage()
    -- 如果正在计算其他修饰器的值，忽略本修饰器的加成以避免循环
    if self.ignore_bonus then 
        print("[修饰器] 正在计算其他修饰器，返回0")
        return 0 
    end
    
    local percentage = self.bonus_percentage or 100
    print(string.format("[修饰器] 总护甲百分比加成: %d%%", percentage))
    return percentage
end

-- 设置百分比的公共方法
function modifier_percentage_total_armor:SetBonusPercentage(percentage)
    self.bonus_percentage = percentage
end