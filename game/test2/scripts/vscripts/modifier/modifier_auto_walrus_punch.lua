-- 自动海象神拳修饰器
modifier_auto_walrus_punch = class({})

function modifier_auto_walrus_punch:IsHidden() return false end
function modifier_auto_walrus_punch:IsDebuff() return false end
function modifier_auto_walrus_punch:IsPurgable() return false end

function modifier_auto_walrus_punch:OnCreated(kv)
    if not IsServer() then return end
    
    print("[Auto Walrus Punch] OnCreated 开始")
    
    -- 初始化计数器和时间戳
    self.frame_counter = 0
    self.last_frame_time = 0
    self.frame_attacked_targets = {} -- 记录每帧已攻击过的目标
    
    local parent = self:GetParent()
    -- 检查单位是否有海象神拳技能
    local ability_name = "tusk_walrus_punch"
    local walrus_punch_ability = parent:FindAbilityByName(ability_name)
    
    if not walrus_punch_ability then
        -- 如果没有此技能，添加技能
        print("[Auto Walrus Punch] 单位没有海象神拳技能，添加技能")
        walrus_punch_ability = parent:AddAbility(ability_name)
        
        -- 将技能升级到最高级（3级）
        walrus_punch_ability:SetLevel(3)
        walrus_punch_ability:ToggleAutoCast() -- 切换为自动施放
        print("[Auto Walrus Punch] 海象神拳技能已添加并升至3级")
        walrus_punch_ability:SetHidden(true)
    else
        -- 如果已有技能但未满级，则升级
        if walrus_punch_ability:GetLevel() < 3 then
            walrus_punch_ability:SetLevel(3)
            print("[Auto Walrus Punch] 已有海象神拳技能升至3级")
        else
            print("[Auto Walrus Punch] 单位已有3级海象神拳技能")
        end
        
        -- 确保自动施放开启
        if not walrus_punch_ability:GetAutoCastState() then
            walrus_punch_ability:ToggleAutoCast()
        end
    end
    
    -- 保存技能引用以便后续使用
    self.walrus_punch_ability = walrus_punch_ability
    
    -- 获取技能实体索引并修改KV数据
    local ability_index = walrus_punch_ability:GetEntityIndex()
    
    -- 创建需要修改的KV数据
    local kv_data = {
        AbilityCooldown = 0,
        AbilityManaCost = 0
    }
    
    -- 更新网络表
    CustomNetTables:SetTableValue("edit_kv", tostring(ability_index), kv_data)
    
    -- 确保英雄已应用modifier_kv_editor_specific_ability
    if not parent:HasModifier("modifier_kv_editor_specific_ability") then
        parent:AddNewModifier(parent, nil, "modifier_kv_editor_specific_ability", {})
    end
    
    print("[Auto Walrus Punch] OnCreated 完成")
end

function modifier_auto_walrus_punch:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end


-- 添加伤害事件处理
function modifier_auto_walrus_punch:OnTakeDamage(event)
    if not IsServer() then return end
    
    -- 限制每帧触发次数
    local current_frame_time = GameRules:GetGameTime()
    if current_frame_time > self.last_frame_time then
        -- 新的一帧，重置计数器和已攻击的目标记录
        self.frame_counter = 0
        self.frame_attacked_targets = {}
        self.last_frame_time = current_frame_time
    end
    
    -- 如果当前帧已达到最大触发次数，直接返回
    if self.frame_counter >= 50 then
        return
    end
    
    local parent = self:GetParent()
    local attacker = event.attacker
    local target = event.unit
    local inflictor = event.inflictor
    
    if not attacker or not target then
        return
    end
    
    -- 获取攻击者的真正主人
    local realOwner = attacker:GetRealOwner()
    
    -- 检查是不是modifier拥有者或其主人
    local isOwnerOrUnit = (attacker == parent) or (realOwner == parent)
    
    if isOwnerOrUnit and target ~= attacker and (inflictor or attacker ~= realOwner) and target:GetTeamNumber() ~= parent:GetTeamNumber() and target:IsAlive() then
        -- 检查该目标在当前帧是否已被攻击过
        local target_entindex = target:GetEntityIndex()
        if self.frame_attacked_targets[target_entindex] then
            -- 该目标在这一帧已经被攻击过，跳过
            return
        end
        
        -- 标记该目标在当前帧已被攻击
        self.frame_attacked_targets[target_entindex] = true
        
        -- 增加当前帧的计数器
        self.frame_counter = self.frame_counter + 1
        
        print("[Auto Walrus Punch] OnTakeDamage 事件触发")
        DeepPrintTable(event)
        
        print("[Auto Walrus Punch] 伤害事件触发，攻击者名称: " .. (attacker and attacker:GetUnitName() or "未知"))
        if realOwner then
            print("[Auto Walrus Punch] 攻击者主人: " .. realOwner:GetUnitName())
        end
        
        realOwner:PerformAttack(
            target,     -- 目标
            true,      -- 使用攻击法球效果
            true,       -- 处理攻击过程
            true,      -- 不跳过冷却
            false,      -- 不忽略隐身
            false,       -- 使用投射物
            false,      -- 不是假攻击
            true       -- 不是必定命中
        )
        
        print("[Auto Walrus Punch] 施加伤害完成: " .. damageAmount)
    end
end

function modifier_auto_walrus_punch:OnDestroy()
    if not IsServer() then return end
    
    print("[Auto Walrus Punch] OnDestroy")
    -- 可以选择在这里移除技能或保留
    -- 如果要移除技能，取消下面的注释
    -- local parent = self:GetParent()
    -- if parent and not parent:IsNull() then
    --     if self.walrus_punch_ability and not self.walrus_punch_ability:IsNull() then
    --         parent:RemoveAbility(self.walrus_punch_ability:GetAbilityName())
    --         print("[Auto Walrus Punch] 移除海象神拳技能")
    --     end
    -- end
end 