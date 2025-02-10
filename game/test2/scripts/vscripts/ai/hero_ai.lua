-- hero_ai.lua

require("ai/core/common_ai")

require("ai/hero_ai/earth_spirit_ai")  -- 导入特定的英雄AI

HeroAI = {}

function HeroAI.CreateAIForHero(hero, overallStrategy, heroStrategy, thinkInterval)
    local heroName = hero:GetUnitName()
    if heroName == "XXX" then
        return EarthSpiritAI.new(hero, overallStrategy, heroStrategy, thinkInterval)
    else
        return CommonAI.new(hero, overallStrategy, heroStrategy, thinkInterval)  -- 创建并返回通用AI的实例
    end
end
