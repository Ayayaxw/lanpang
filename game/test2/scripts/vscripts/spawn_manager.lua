spawn_manager = {}

-- 清除并生成小兵的函数
function spawn_manager.spawn_creatures(self, initialCreepCount, creepName, team)
    -- 初始化击杀计数器
    self.killedCount = 0
    self.creepCount = initialCreepCount

    -- 查找所有单位
    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
                                    DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
    -- 删除特定的小兵
    for _, unit in pairs(units) do
        if unit:GetUnitName() == creepName then
            unit:RemoveSelf()
        end
    end

    -- 在 (0, 0, 0) 位置生成指定数量的小兵
    for i = 1, initialCreepCount do
        local spawnPos = Vector(100, -500, 0)
        CreateUnitByName(creepName, spawnPos, true, nil, nil, team)
    end
end

-- 当小兵被击杀时调用
function spawn_manager:OnCreepKilled(unitName, newHero, duration)
    if unitName == "npc_dota_creep_goodguys_melee_upgraded_mega" then
        -- 增加击杀数量
        self.killedCount = self.killedCount + 1

        -- 发送击杀数量更新到前端
        CustomGameEventManager:Send_ServerToAllClients("update_creep_count", {count = self.killedCount})

        -- 如果所有小兵被击杀完，则停止计时并对英雄施加效果
        if self.killedCount == self.creepCount then
            CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
            self.allCreepsKilled = true  -- 设置标志，表示小兵已全部击杀

            -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = duration })
            newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = duration })
            newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = duration })
            newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = duration })
            newHero:StartGesture(ACT_DOTA_VICTORY)

                        -- 发送一个事件到所有客户端，通知它们调整相机距离
                        -- 锁定摄像机到玩家身上
            local playerID = newHero:GetPlayerOwnerID()
            if playerID then
                PlayerResource:SetCameraTarget(playerID, newHero)
                
                -- 在几秒后释放摄像机
                Timers:CreateTimer(2, function()
                    PlayerResource:SetCameraTarget(playerID, nil)
                end)
            end

            -- 在英雄头上播放决斗胜利的动画和音效
            local particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_commander_duel_arcana.vpcf", PATTACH_OVERHEAD_FOLLOW, newHero)
            ParticleManager:SetParticleControl(particle, 0, newHero:GetAbsOrigin())

            ParticleManager:ReleaseParticleIndex(particle)

            -- 播放音效
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", newHero)
        end
    end
end

function spawn_manager.SpawnCreeps()
    local spawnLocation = Vector(0, -100, 0)
    local team = DOTA_TEAM_NEUTRALS

    -- 每隔两秒检查是否应该生成一个小兵
    Timers:CreateTimer({
        endTime = 5,  -- 初始延迟
        callback = function()
            if Main.shouldSpawnCreeps then
                Main.spawnCount = Main.spawnCount + 1
                if Main.spawnCount % 5 == 0 then
                    CreateUnitByName("npc_dota_creep_goodguys_ranged_upgraded_mega", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                else
                    CreateUnitByName("npc_dota_creep_goodguys_melee_upgraded_mega", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                end
            end
            return 1.0  -- 指定1秒后再次执行此函数
        end
    })
end

return spawn_manager
