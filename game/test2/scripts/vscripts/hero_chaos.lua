function Main:StopScoreBoardMonitor()
    if self.scoreMonitorTimer then
        Timers:RemoveTimer(self.scoreMonitorTimer)
        self.scoreMonitorTimer = nil
    end
end


function Main:PreCreateHeroes(heroType)
    local data = self.heroSequence[heroType]
    if not data then
        print(string.format("[Arena] 错误：无效的英雄属性类型: %d", heroType))
        return false
    end

    for i = data.currentIndex, data.totalCount do
        local heroData = data.sequence[i]
        
        if not heroData.entity then
            local heroName = heroData.name
            
            print(string.format("[Arena] 准备创建英雄: %s (序号: %d)", 
                heroData.chinese, i))
            
            if self.createUnitHeroes[heroName] then
                -- 使用对应阵营的母体
                local parentHero = self.parentHeroes[heroType]
                
                if not parentHero then
                    print(string.format("[Arena] 错误：未找到阵营 %d 的母体", heroType))
                    return
                end 
                
                CreateHeroHeroChaos(
                    0,
                    heroName,
                    1,  -- 固定使用命石1
                    self.SPAWN_POINT_FAR,
                    data.team,
                    false,
                    parentHero,
                    function(createdHero)
                        if not createdHero then
                            print(string.format("[Arena] 错误：创建英雄失败: %s", heroData.chinese))
                            return
                        end
                        
                        if heroName == "npc_dota_hero_weaver" then
                            print("[Arena] 检测到编织者，立即升至最高等级")
                            HeroMaxLevel(createdHero)
                        end
                        
                        heroData.entity = createdHero
                        self:SetupInitialBuffs(createdHero)
                        
                        print(string.format("[Arena] 成功创建英雄: %s", heroData.chinese))
                    end
                )
            else
                -- 使用CreateHero创建
                local facet = self.heroFacets[heroName] or 1
                print(string.format("[Arena] 命石: %d", facet))
                
                CreateHero(
                    0,
                    heroName,
                    facet,
                    self.SPAWN_POINT_FAR,
                    data.team,
                    false,
                    function(createdHero)
                        if not createdHero then
                            print(string.format("[Arena] 错误：创建英雄失败: %s", heroData.chinese))
                            return
                        end
                        
                        -- 编织者特殊处理
                        if heroName == "npc_dota_hero_weaver" then
                            print("[Arena] 检测到编织者，立即升至最高等级")
                            HeroMaxLevel(createdHero)
                        end
                        
                        -- 记录创建的英雄实体
                        heroData.entity = createdHero
                        
                        -- 设置初始状态
                        self:SetupInitialBuffs(createdHero)
                        
                        print(string.format("[Arena] 成功创建英雄: %s", heroData.chinese))
                    end
                )
                return true  -- 成功开始创建一个英雄
            end
        else
            print(string.format("[Arena] 英雄已存在，继续查找下一个: %s", heroData.chinese))
        end
    end

    print(string.format("[Arena] 提示：属性 %d 的英雄已全部创建完成", heroType))
    return false
end


function Main:DeployHero(heroType, isInitialSpawn)
    local data = self.heroSequence[heroType]
    if not data then return end
    
    -- 检查索引是否有效
    if data.currentIndex > #data.sequence then
        print(string.format("[Arena] 错误：当前索引 %d 超出英雄序列长度 %d", 
            data.currentIndex, #data.sequence))
        return
    end
    local deployIndex = data.currentIndex
    
    -- 初始化等待计数器
    local waitCount = 0
    local MAX_WAIT_TIME = 15 -- 最多等待10秒

    -- 检查当前位置是否有可用的英雄，如果没有则等待
    local function waitForHero()
        waitCount = waitCount + 1
        
        -- 超过最大等待时间
        if waitCount > MAX_WAIT_TIME then
            print(string.format("[Arena] 错误：等待属性 %d 当前位置 %d 的英雄超时", heroType, deployIndex))
            return nil
        end

        local heroData = data.sequence[deployIndex]  -- 使用保存的索引
        if not heroData or not heroData.entity then
            print(string.format("[Arena] 等待属性 %d 当前位置 %d 的英雄就绪...（%d/%d）", 
                heroType, deployIndex, waitCount, MAX_WAIT_TIME))
            return 1 -- 1秒后重试
        end

        -- 找到可用英雄，开始部署流程
        local hero = heroData.entity
        local spawnPoint = self:GetSpawnPointForType(heroType, isInitialSpawn,hero)
        
        -- 计算朝向
        local direction = (self.ARENA_CENTER - spawnPoint):Normalized()
        -- 转换为角度
        local angle = VectorToAngles(direction)
        -- 设置英雄朝向
        hero:SetAngles(angle.x, angle.y, angle.z)
        
        -- 根据英雄类型选择特效
        local particleName = ""
        if heroType == 1 then -- 力量英雄，红色
            particleName = "particles/red/teleport_start_ti6_lvl2.vpcf"
        elseif heroType == 2 then -- 敏捷英雄，绿色
            particleName = "particles/green/teleport_start_ti8_lvl2.vpcf"
        elseif heroType == 4 then -- 智力英雄，蓝色
            particleName = "particles/blue/teleport_start_ti7_lvl3.vpcf"
        elseif heroType == 8 then -- 全才英雄，紫色
            particleName = "particles/purple/teleport_start_ti9_lvl2.vpcf"
        end
        
        -- 播放传送特效
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, spawnPoint)
        
        -- 4秒后开始传送
        Timers:CreateTimer(1.0, function()
            -- 移除隐身相关的buff
            if hero:HasModifier("modifier_wearable") then
                hero:RemoveModifierByName("modifier_wearable")
            end
            FindClearSpaceForUnit(hero, spawnPoint, true)

            -- 根据是否是初始生成决定延迟时间
            local delay = isInitialSpawn and 10.0 or 0.5
            print(string.format("[Arena] 英雄 %s 将在 %.1f 秒后移除无敌状态", hero:GetUnitName(), delay))

            Timers:CreateTimer(delay, function()
                -- 移除无敌状态
                if hero:HasModifier("modifier_invulnerable") then
                    hero:RemoveModifierByName("modifier_invulnerable")
                    hero:Purge(false, true, false, false, false)
                end
                
                -- 清理传送特效
                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 创建AI并设置战斗状态
                CreateAIForHero(hero,{"攻击无敌单位"})
                self:SetupCombatBuffs(hero)
                
                -- 执行英雄特殊效果
                local heroStrategy = hero.ai and hero.ai.heroStrategy or nil
                self:HeroBenefits(hero:GetUnitName(), hero, heroStrategy)
                
                -- -- 米波特殊处理
                -- if hero:GetUnitName() == "npc_dota_hero_meepo" then
                --     Timers:CreateTimer(0.1, function()
                --         local meepos = FindUnitsInRadius(
                --             hero:GetTeam(),
                --             hero:GetAbsOrigin(),
                --             nil,
                --             FIND_UNITS_EVERYWHERE,
                --             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                --             DOTA_UNIT_TARGET_HERO,
                --             DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                --             FIND_ANY_ORDER,
                --             false
                --         )
                        
                --         for _, meepo in pairs(meepos) do
                --             if meepo:HasModifier("modifier_meepo_divided_we_stand") and 
                --                meepo:IsRealHero() and 
                --                meepo ~= hero then
                --                 local overallStrategy = hero.ai and hero.ai.overallStrategy or nil
                --                 local heroStrategy = hero.ai and hero.ai.heroStrategy or nil
                --                 CreateAIForHero(meepo, overallStrategy, heroStrategy)
                --             end
                --         end
                --     end)
                -- end
                
                self:StartAbilitiesMonitor(hero)
            end)
        end)

        return nil -- 不再继续等待
    end

    -- 开始等待循环
    Timers:CreateTimer(waitForHero)
end

function Main:Initialize_Hero_Chaos_UI()
    print("[Arena] Starting UI initialization...")
    
    -- 分数面板始终显示
    CustomGameEventManager:Send_ServerToAllClients("show_hero_chaos_score", {})
    
    -- 只有在showTeamPanel为true时才显示队伍面板
    if self.showTeamPanel then
        print("[Arena] Sending show_hero_chaos_container event")
        CustomGameEventManager:Send_ServerToAllClients("show_hero_chaos_container", {})
        
        -- 设置需要的面板
        local activeTypes = {}
        for type, typeInfo in pairs(self.teamTypes) do
            table.insert(activeTypes, typeInfo.type)
        end
        
        print("[Arena] Sending setup_hero_chaos_panels event with types:", table.concat(activeTypes, ", "))
        CustomGameEventManager:Send_ServerToAllClients("setup_hero_chaos_panels", {
            types = activeTypes
        })
    end

    print("[Arena] UI initialization completed")
end


-- 当需要更新UI数据时
function Main:UpdateTeamPanelData()
    if not self.showTeamPanel then
        return
    end

    -- 遍历所有在 teamTypes 中定义的队伍
    for type, teamData in pairs(self.teamTypes) do  -- type就是1,2这样的数字
        local heroSequence = self.heroSequence[type]  -- 直接使用type
        if heroSequence then
            -- 获取当前英雄
            local currentData = heroSequence.sequence[heroSequence.currentIndex]
            local currentHero = currentData and currentData.entity and currentData.entity:GetUnitName()
            
            -- 获取下一个英雄
            local nextHeroIndex = heroSequence.currentIndex + 1
            local nextHeroData = heroSequence.sequence[nextHeroIndex]
            local nextHero = nextHeroData and nextHeroData.entity and nextHeroData.entity:GetUnitName()

            -- 使用teamStats中的deaths来获取已死亡英雄数量
            local deadHeroes = heroSequence.teamStats.deaths or 0

            -- 构建数据
            local data = {
                type = teamData.type,  -- 直接使用type
                currentHero = currentHero,
                nextHero = nextHero,
                remainingHeroes = #heroSequence.sequence - deadHeroes,
                totalHeroes = #heroSequence.sequence,
                kills = heroSequence.teamStats.kills or 0,
                deadHeroes = deadHeroes
            }
            
            -- 添加中文打印信息
            print("==== 队伍状态更新 ====")
            print(string.format("队伍类型: %s (%s)", teamData.type, teamData.name))
            print(string.format("当前英雄: %s", currentHero or "无"))
            print(string.format("下一个英雄: %s", nextHero or "无"))
            print(string.format("总英雄数: %d", #heroSequence.sequence))
            print(string.format("已死亡英雄: %d", deadHeroes))
            print(string.format("剩余英雄: %d", #heroSequence.sequence - deadHeroes))
            print(string.format("队伍击杀数: %d", heroSequence.teamStats.kills or 0))
            print("========================")
            
            CustomGameEventManager:Send_ServerToAllClients("update_team_data", data)
        end
    end
end


function Main:InitialPreCreateHeroes()
    -- 先创建母体，再创建英雄
    local PARENT_SPAWN_POINT = Vector(9999, 9999, 128)
    self.parentHeroes = {}
    local hPlayer = PlayerResource:GetPlayer(0)

    -- 团队到DOTA_TEAM的映射
    local teamMapping = {
        [1] = DOTA_TEAM_BADGUYS,    -- 红队
        [2] = DOTA_TEAM_GOODGUYS,   -- 绿队
        [4] = DOTA_TEAM_CUSTOM_1,   -- 蓝队
        [8] = DOTA_TEAM_CUSTOM_2    -- 紫队
    }

    -- 创建四个阵营的母体函数
    local function CreateParentHeroes(callback)
        local remaining = 4
        
        for heroType, team in pairs(teamMapping) do
            DebugCreateHeroWithVariant(hPlayer, "npc_dota_hero_chen", 1, team, false,
                function(parentHero)
                    if parentHero then
                        parentHero:SetAbsOrigin(PARENT_SPAWN_POINT)
                        self.parentHeroes[heroType] = parentHero
                        print(string.format("创建母体成功，阵营: %d, 队伍: %d", heroType, team))
                        
                        remaining = remaining - 1
                        if remaining == 0 and callback then
                            callback()
                        end
                    end
                end)
        end
    end

    -- 创建英雄的函数
    local function CreateHeroes()
        local heroTypes = {}
        -- 从teamTypes中获取所有type
        for type, _ in pairs(self.teamTypes) do
            table.insert(heroTypes, type)
        end
        
        -- 确定每种属性预创建的英雄数量
        local heroesPerType = math.max(self.preCreatePerTeam, self.heroesPerTeam)
        local totalTime = 10
        local interval = totalTime / (#heroTypes * heroesPerType)
        
        local currentIndex = 0
        for _, heroType in ipairs(heroTypes) do
            for i = 1, heroesPerType do
                Timers:CreateTimer(interval * currentIndex, function()
                    self:PreCreateHeroes(heroType)
                end)
                currentIndex = currentIndex + 1
            end
        end
    end

    -- 先创建母体，完成后再创建英雄
    CreateParentHeroes(CreateHeroes)
end


function Main:GetTeamIndex(heroType)
    local index = 1
    for _, teamData in pairs(self.teamTypes) do
        if tonumber(teamData.type) == heroType then
            return index
        end
        index = index + 1
    end
    return 1  -- 默认返回1
end

function Main:GetSpawnPointForType(heroType, isInitialSpawn, hero)
    if isInitialSpawn then
        if self.heroesPerTeam <= 1 then
            -- 单个英雄时使用序号来决定角度
            local teamIndex = self:GetTeamIndex(heroType)
            local totalTeams = 0
            for _ in pairs(self.teamTypes) do totalTeams = totalTeams + 1 end
            local angle = (teamIndex - 1) * (2 * math.pi / totalTeams)
            
            local x = self.ARENA_CENTER.x + self.SPAWN_DISTANCE * math.cos(angle)
            local y = self.ARENA_CENTER.y + self.SPAWN_DISTANCE * math.sin(angle)
            return Vector(x, y, self.ARENA_CENTER.z)
        else
            -- 多个英雄时在直线上均匀分布
            local x = self.ARENA_CENTER.x
            local teamIndex = self:GetTeamIndex(heroType)
            local baseOffset = 200
            
            -- 根据队伍序号决定位置
            if teamIndex == 1 then 
                x = self.ARENA_CENTER.x + self.SPAWN_DISTANCE + baseOffset  -- 右边
            elseif teamIndex == 2 then 
                x = self.ARENA_CENTER.x - self.SPAWN_DISTANCE - baseOffset  -- 左边
            elseif teamIndex == 3 then 
                x = self.ARENA_CENTER.x + self.SPAWN_DISTANCE + (baseOffset * 2)  -- 更右边
            elseif teamIndex == 4 then 
                x = self.ARENA_CENTER.x - self.SPAWN_DISTANCE - (baseOffset * 2)  -- 更左边
            end
            
            -- 增加垂直方向的总范围
            local totalHeight = self.SPAWN_DISTANCE * 3.0
            
            -- 如果英雄数量大于5，进一步增加间距
            if self.heroesPerTeam > 5 then
                totalHeight = self.SPAWN_DISTANCE * 4.0
            end
            
            local stepSize = totalHeight / (self.heroesPerTeam - 1)
            local verticalOffset = (self.currentDeployIndex - 1) * stepSize - totalHeight/2
            
            local y = self.ARENA_CENTER.y + verticalOffset
            return Vector(x, y, self.ARENA_CENTER.z)
        end
    else
        local spawnDistance = 600 -- 默认距离

        -- 根据heroType设置不同的spawn距离
        if heroType == 1 then
            spawnDistance = 600
        elseif heroType == 2 then
            spawnDistance = 600
        elseif heroType == 4 then
            spawnDistance = 600
        elseif heroType == 8 then
            spawnDistance = 600
        end

        -- 如果是远程英雄，减少生成距离
        if hero and hero:IsRangedAttacker() then
            spawnDistance = spawnDistance - 200
        end

        local timeBasedOffset = GameRules:GetGameTime() * 17.53
        local randomAngle = RandomFloat(0, 2 * math.pi) + timeBasedOffset % (2 * math.pi)
        
        local x = self.ARENA_CENTER.x + spawnDistance * math.cos(randomAngle)
        local y = self.ARENA_CENTER.y + spawnDistance * math.sin(randomAngle)
        return Vector(x, y, self.ARENA_CENTER.z)
    end
end



function Main:Start_Hero_Chaos_ScoreBoardMonitor()
    if self.scoreMonitorTimer then
        Timers:RemoveTimer(self.scoreMonitorTimer)
    end

    self.scoreMonitorTimer = Timers:CreateTimer(0.1, function()
        if hero_duel.EndDuel == true then
            return nil
        end

        -- 收集团队数据
        local teamData = {}

        -- 收集团队数据
        for heroType, typeInfo in pairs(self.teamTypes) do
            if self.heroSequence[heroType] then
                table.insert(teamData, {
                    type = typeInfo.type,
                    name = typeInfo.name,
                    kills = self.heroSequence[heroType].teamStats.kills or 0,
                    damage = self.heroSequence[heroType].teamStats.damage or 0
                })
            end
        end

        -- 按击杀数排序，如果击杀数相同则按伤害排序
        table.sort(teamData, function(a, b)
            if a.kills == b.kills then
                return a.damage > b.damage
            end
            return a.kills > b.kills
        end)


        -- 收集当前场上英雄数据
        local currentHeroes = {}
        for heroType, data in pairs(self.heroSequence) do
            local currentHero = data.sequence[data.currentIndex]
            if currentHero then
                table.insert(currentHeroes, {
                    type = self.teamTypes[heroType].type,
                    name = currentHero.chinese,
                    kills = currentHero.kills or 0,
                    damage = currentHero.damage or 0
                })
            end
        end

        -- 对当前场上英雄进行排序
        table.sort(currentHeroes, function(a, b)
            if a.kills == b.kills then
                return a.damage > b.damage
            end
            return a.kills > b.kills
        end)


        -- 收集个人数据
        local heroData = {}
        for heroType, data in pairs(self.heroSequence) do
            for i = 1, data.currentIndex do
                local hero = data.sequence[i]
                if hero then
                    table.insert(heroData, {
                        type = self.teamTypes[heroType].type,
                        name = hero.chinese,
                        kills = hero.kills or 0,
                        damage = hero.damage or 0
                    })
                end
            end
        end

        -- 按击杀数排序，如果击杀数相同则按伤害排序
        table.sort(heroData, function(a, b)
            if a.kills == b.kills then
                return a.damage > b.damage
            end
            return a.kills > b.kills
        end)

        -- 发送数据到前端
        CustomGameEventManager:Send_ServerToAllClients("update_hero_chaos_score", {
            teamTypes = self.teamTypes,  -- Add team types to the event data
            teams = teamData,
            currentHeroes = currentHeroes,
            heroes = heroData
        })

        return 0.1
    end)
end