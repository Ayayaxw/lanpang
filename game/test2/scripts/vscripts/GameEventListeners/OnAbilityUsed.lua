-- 定义一个函数，用于处理技能释放事件
function Main:OnAbilityUsed(event)
    local caster = EntIndexToHScript(event.caster_entindex)
    
    if caster:GetUnitName() == self.currentHeroName then
        local abilityName = event.abilityname
        local heroName = caster:GetUnitName()
        local heroChineseName = self:GetHeroChineseName(heroName)
        local currentTime = Time()
        local formattedTime = string.format("%.2f", currentTime)
        print("[DOTA_RECORD] " .. heroChineseName .. ": 释放了" .. abilityName)
    end
end
