-- 定义一个函数，用于处理技能释放事件
function Main:OnAbilityUsed(event)


    local caster = EntIndexToHScript(event.caster_entindex)
    local target = caster:GetCursorCastTarget()
    -- 如果英雄释放的技能是doom_bringer_devour
    if event.abilityname == "doom_bringer_devour" then
        print("吞噬技能被使用")
        
        -- 确保有选中目标
        if target then
            Timers:CreateTimer(0.5, function()
            print("目标存在：" .. target:GetUnitName())
            
            -- 获取末日英雄的技能3和技能4（索引为2和3）
            local ability3 = caster:GetAbilityByIndex(3)
            local ability4 = caster:GetAbilityByIndex(4)
            
            -- 打印当前技能信息
            print("末日技能3名称: " .. (ability3 and ability3:GetAbilityName() or "无技能"))
            print("末日技能4名称: " .. (ability4 and ability4:GetAbilityName() or "无技能"))
            
            -- 检查技能3和技能4是否为空技能槽
            if ability3 and ability4 and ability3:GetAbilityName() == "doom_bringer_empty1" and ability4:GetAbilityName() == "doom_bringer_empty2" then
                print("检测到空技能槽，准备替换技能，将在2秒后执行")
                
                -- 获取目标的前两个技能
                local targetAbility1 = target:GetAbilityByIndex(0)
                local targetAbility2 = target:GetAbilityByIndex(1)
                
                -- 打印目标技能信息
                print("目标技能1: " .. (targetAbility1 and targetAbility1:GetAbilityName() or "无技能"))
                print("目标技能2: " .. (targetAbility2 and targetAbility2:GetAbilityName() or "无技能"))
                
                -- 使用定时器延迟2秒执行技能替换

                    print("开始执行技能替换")
                    
                    -- 如果目标有技能，则复制到末日的技能槽中
                    if targetAbility1 then
                        local ability1Name = targetAbility1:GetAbilityName()
                        print("正在替换技能1: " .. ability1Name)
                        caster:RemoveAbility("doom_bringer_empty1")
                        local newAbility1 = caster:AddAbility(ability1Name)
                        if newAbility1 then
                            newAbility1:SetLevel(4)
                            print("技能1替换并升级到4级成功")
                        else
                            print("技能1替换失败")
                        end
                    end
                    
                    if targetAbility2 then
                        local ability2Name = targetAbility2:GetAbilityName()
                        print("正在替换技能2: " .. ability2Name)
                        caster:RemoveAbility("doom_bringer_empty2")
                        local newAbility2 = caster:AddAbility(ability2Name)
                        if newAbility2 then
                            newAbility2:SetLevel(4)
                            print("技能2替换并升级到4级成功")
                        else
                            print("技能2替换失败")
                        end
                    end
                    
                    print("技能替换流程完成")

            else
                print("末日技能槽不符合替换条件")
            end
        end)
        else
            print("没有有效目标")
        end
    end

    local challengeId = self.currentChallenge

    -- 查找对应的挑战模式名称
    local challengeName
    for name, id in pairs(Main.Challenges) do
        if id == challengeId then
            challengeName = name
            break
        end
    end

    if challengeName then
        -- 构建处理函数的名称
        local challengeFunctionName = "OnAbilityUsed_" .. challengeName
        if self[challengeFunctionName] then
            -- 调用对应的处理函数
            self[challengeFunctionName](self, event)
        end
    end
end
