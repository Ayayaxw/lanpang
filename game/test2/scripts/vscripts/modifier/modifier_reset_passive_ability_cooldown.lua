modifier_reset_passive_ability_cooldown = class({})

function modifier_reset_passive_ability_cooldown:IsHidden() return true end
function modifier_reset_passive_ability_cooldown:IsPurgable() return false end

function modifier_reset_passive_ability_cooldown:OnCreated(params)
    if IsServer() then
        self.last_trigger_time = 0

    end
end

function modifier_reset_passive_ability_cooldown:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_reset_passive_ability_cooldown:OnAttackLanded(event)
    if IsServer() then
        local now = GameRules:GetGameTime()
        local attacker = event.attacker
        local target = event.target
        


        -- 确保是持有该modifier的单位发起的有效攻击
        if attacker == self:GetParent() and 
           attacker:GetTeamNumber() ~= target:GetTeamNumber() and -- 排除友军攻击
           not attacker:IsIllusion() then -- 排除幻象
            

            
            -- 遍历单位的所有技能
            for i = 0, attacker:GetAbilityCount() - 1 do
                local ability = attacker:GetAbilityByIndex(i)
                
                -- 检查技能是否有效、不是隐藏的、是被动技能、正在冷却中
                if ability and 
                   not ability:IsNull() and 
                   not ability:IsHidden() and 
                   ability:IsPassive() and 
                   ability:GetCooldownTimeRemaining() > 0 then
                    
                    -- 第一次重置冷却时间
                    ability:EndCooldown()
                    
                    -- 延迟一帧后再次重置冷却
                    local abilityRef = ability -- 保存技能引用，避免在定时器中出现问题
                    Timers:CreateTimer(0.05, function()
                        if abilityRef and not abilityRef:IsNull() then
                            abilityRef:EndCooldown()
                        end
                    end)
                end
            end
        end
    end
end