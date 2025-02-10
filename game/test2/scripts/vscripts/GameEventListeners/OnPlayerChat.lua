
function Main:OnPlayerChat(keys)
    GridNav:RegrowAllTrees()
    local playerID = keys.playerid
    local text = keys.text
    local player = PlayerResource:GetPlayer(playerID)

    if self.currentChallenge == Main.Challenges.CD0_1skill_online then
        -- 异步载入英雄并替换
        -- 检查是否存在玩家1
        if not PlayerResource:IsValidPlayerID(1) or not PlayerResource:GetPlayer(1) then
            -- 如果玩家1不存在，则创建玩家1并分配英雄nevermore
            self:CreatePlayer1()
        end

        if player then
            local firstHeroIndex, secondHeroIndex = string.match(text, "(%d+)%s+(%d+)")
    
            if player and firstHeroIndex and secondHeroIndex then
                firstHeroIndex = tonumber(firstHeroIndex)
                secondHeroIndex = tonumber(secondHeroIndex)
                
                if firstHeroIndex > 0 and firstHeroIndex <= #heroes_precache and secondHeroIndex > 0 and secondHeroIndex <= #heroes_precache then
                    local firstHeroInfo = heroes_precache[firstHeroIndex]
                    local secondHeroInfo = heroes_precache[secondHeroIndex]
                    
                    local firstHeroName = firstHeroInfo.name
                    local firstHeroChineseName = firstHeroInfo.chinese
                    local currentHero = player:GetAssignedHero()
                    self.currentHeroName = firstHeroName 

                    local secondHeroName = secondHeroInfo.name
                    local secondHeroChineseName = secondHeroInfo.chinese
                
                    if not hero_duel.EndDuel then
                        
                        local currentKills = PlayerResource:GetKills(playerID)
                        local currentTime = Time()
                        local formattedTime = string.format("%.2f", currentTime)
                        print("[DOTA_RECORD] " .. firstHeroChineseName .. ": 最终得分：" .. tostring(currentKills))
                    end
                    -- 预加载计数器
                    local precacheCount = 0

                    local function OnPrecacheComplete()
                        precacheCount = precacheCount + 1
                        if precacheCount == 2 then
                            -- 当两个英雄都预加载完成后，进行替换并设置新英雄
                            local newHero0 = PlayerResource:ReplaceHeroWith(0, firstHeroName, 0, 0)
                            local newHero1 = PlayerResource:ReplaceHeroWith(1, secondHeroName, 0, 0)

                            -- 检查新英雄是否为 nil
                            if not newHero0 then
                                print("错误：newHero0 是 nil")
                            else
                                print("成功替换玩家0的英雄为: " .. firstHeroName)
                            end

                            if not newHero1 then
                                print("错误：newHero1 是 nil")
                                --newHero1=CreateUnitByName(secondHeroName, Vector(1100, -3000, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
                            else
                                print("成功替换玩家1的英雄为: " .. secondHeroName)
                            end

                            if newHero0 and newHero1 then
                                self:Init_CD0_1skill_online(newHero0, newHero1, firstHeroChineseName, secondHeroChineseName)
                            else
                                print("错误：无法替换英雄")
                            end
                        end
                    end

                    PrecacheUnitByNameAsync(firstHeroName, OnPrecacheComplete)
                    PrecacheUnitByNameAsync(secondHeroName, OnPrecacheComplete)
                end
            end
        end
    else
        if player then
            local heroIndex, heroFacet = string.match(text, "^(%d+)%.(%d+)$")
            if heroIndex and heroFacet then
                heroIndex = tonumber(heroIndex)
                heroFacet = tonumber(heroFacet)
                if heroIndex and heroIndex > 0 and heroIndex <= #heroes_precache then
                    --CheckPlayerCountAndClear()
                    local heroInfo = heroes_precache[heroIndex]
                    local heroName = heroInfo.name
                    local heroChineseName = heroInfo.chinese

                    -- 获取当前英雄实例
                    local currentHero = player:GetAssignedHero()
                    -- 获取当前英雄的击杀数
                    --PrintAllPlayerIDs()
                    if currentHero then

                        -- 获取当前英雄的击杀数
                        local currentHeroName = currentHero:GetUnitName()
                        print("当前分配的英雄是：", currentHeroName)
                        -- 直接在这里进行英雄中文名的查找
                        local currentHeroChineseName = "未知英雄"
                        for _, data in ipairs(heroes_precache) do
                            if data.name == currentHeroName then
                                currentHeroChineseName = data.chinese
                                break
                            end
                        end

                        -- 根据当前挑战状态决定是否打印得分
                        local currentTime = Time()
                        local formattedTime = string.format("%.2f", currentTime)
                        if self.currentChallenge == Main.Challenges.HeroChallenge_ShadowShaman and not hero_duel.EndDuel then
                            local currentKills = PlayerResource:GetKills(playerID)
                            print("[DOTA_RECORD] " .. currentHeroChineseName .. ": 最终得分：" .. tostring(currentKills))
                        end

                        if self.currentChallenge == Main.Challenges.CreepChallenge and not spawn_manager.allCreepsKilled then
                            local currentKills = PlayerResource:GetKills(playerID)
                            print("[DOTA_RECORD] " .. currentHeroChineseName .. ": 最终得分：" .. tostring(currentKills))
                        end

                        if self.currentChallenge == Main.Challenges.CD0_1skill and not hero_duel.EndDuel then
                            local currentKills = PlayerResource:GetKills(playerID)
                            print("[DOTA_RECORD] " .. currentHeroChineseName .. ": 最终得分：" .. tostring(currentKills))
                        end

                        if self.currentChallenge == Main.Challenges.MonkeyKing and not hero_duel.EndDuel then
                            local currentKills = PlayerResource:GetKills(playerID)
                            print("[DOTA_RECORD] " .. currentHeroChineseName .. ": 最终得分：" .. tostring(currentKills))
                        end

                        if self.currentChallenge == Main.Challenges.HeroChallenge_illusion and not hero_duel.EndDuel and _G.totalKills then
                            local currentKills = PlayerResource:GetKills(playerID)
                            print("[DOTA_RECORD] " .. currentHeroChineseName .. ": 最终得分：" .. tostring(_G.totalKills))
                        end
                    end
                    self.currentHeroName = heroName  -- 更新当前选中的英雄
                    self:SetupNewHero(heroName, heroFacet, playerID, heroChineseName)
                end
            end
        end
    end
end
