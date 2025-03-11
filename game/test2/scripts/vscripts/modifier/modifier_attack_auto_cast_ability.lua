modifier_attack_auto_cast_ability = class({})

function modifier_attack_auto_cast_ability:IsHidden() return true end
function modifier_attack_auto_cast_ability:IsPurgable() return false end

function modifier_attack_auto_cast_ability:OnCreated(params)
    if IsServer() then
        self.ability_index = params.ability_index or 0 -- 默认使用第二个技能槽（0-based索引）
        self.last_trigger_time = 0 -- 初始化最后触发时间
        self.cooldown = 0.05 -- 冷却时间（秒）
    end
end

function modifier_attack_auto_cast_ability:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED -- 监听攻击命中事件
    }
end

function modifier_attack_auto_cast_ability:OnAttackLanded(event)
    if IsServer() then
        local now = GameRules:GetGameTime()
        local attacker = event.attacker
        local target = event.target
        
        -- 冷却检查和时间更新
        if now - self.last_trigger_time < self.cooldown then
            return
        end

        -- 确保是持有该modifier的单位发起的有效攻击
        if attacker == self:GetParent() and 
           attacker:GetTeamNumber() ~= target:GetTeamNumber() and -- 排除友军攻击
           not attacker:IsIllusion() then -- 排除幻象
            
            local ability = attacker:GetAbilityByIndex(self.ability_index)
            if ability and not ability:IsNull() then

                self.last_trigger_time = now
                
                -- 执行技能
                if ability.OnSpellStart then
                    ability:OnSpellStart()
                end

            end
        end
    end
end