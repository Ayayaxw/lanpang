function CommonAI:GetRealCastPoint(skill)
    if not skill then
        return 0  -- 或者返回一个默认值，或者记录错误
    end

    local castPoint = skill:GetCastPoint()

    -- 如果施法前摇时间为0，查找AbilityCastPoint属性的值
    if castPoint == 0 then
        local kv = skill:GetAbilityKeyValues()
        if kv and kv["AbilityCastPoint"] then
            castPoint = tonumber(kv["AbilityCastPoint"]) or 0
        end
    end

    -- 特殊处理某些技能
    if skill:GetAbilityName() == "centaur_hoof_stomp" then
        castPoint = 0.5
    end
    

    return castPoint
end