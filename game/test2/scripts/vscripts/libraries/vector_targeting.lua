if not VectorTarget then 
	VectorTarget = class({})
end

ListenToGameEvent("game_rules_state_change", function()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		VectorTarget:Init()
	end
end, nil)

function VectorTarget:Init()
	print("[VT] Initializing VectorTarget...")
	local mode = GameRules:GetGameModeEntity()
	mode:SetExecuteOrderFilter(Dynamic_Wrap(VectorTarget, 'OrderFilter'), VectorTarget)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(VectorTarget, 'OnAbilityLearned'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(VectorTarget, 'OnItemBought'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(VectorTarget, 'OnItemPickup'), self)

	CustomGameEventManager:RegisterListener("check_ability", Dynamic_Wrap(VectorTarget, "OnAbilityCheck"))
end

-- 这个库提供了向量目标定位的功能，允许技能指定起点和方向
-- 实现了类似于月之暗面破碎飞弧等向量目标技能的功能


function VectorTarget:OrderFilter(event)
	if not event.units["0"] then return true end
	local unit = EntIndexToHScript(event.units["0"])
	local ability = EntIndexToHScript(event.entindex_ability)

	if not ability or not ability.GetBehaviorInt then return true end
	local behavior = ability:GetBehaviorInt()

	-- check if the ability exists and if it is Vector targeting
	if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then

		if event.order_type == DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION then
			ability.vectorTargetPosition2 = Vector(event.position_x, event.position_y, 0)
		end

		if event.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
			ability.vectorTargetPosition = Vector(event.position_x, event.position_y, 0)
			local position = ability.vectorTargetPosition
			local position2 = ability.vectorTargetPosition2
			local direction = (position2 - position):Normalized()

			--Change direction if just clicked on the same position
			if position == position2 then
				direction = (position - unit:GetAbsOrigin()):Normalized()
			end
			direction = Vector(direction.x, direction.y, 0)
			ability.vectorTargetDirection = direction

			local function OverrideSpellStart(self, position, direction)
				self:OnVectorCastStart(position, direction)
			end
			ability.OnSpellStart = function(self) return OverrideSpellStart(self, position, direction) end
		end
	end
	return true
end

function VectorTarget:UpdateNettable(ability)
	local vectorData = {
		startWidth = ability:GetVectorTargetStartRadius(),
		endWidth = ability:GetVectorTargetEndRadius(),
		castLength = ability:GetVectorTargetRange(),
		dual = ability:IsDualVectorDirection(),
		ignoreArrow = ability:IgnoreVectorArrowWidth(),
	}
	CustomNetTables:SetTableValue("vector_targeting", tostring(ability:entindex()), vectorData)
end

function VectorTarget:OnAbilityLearned(event)
	local playerID = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local ability = hero:FindAbilityByName(event.abilityname)

	if not ability or not ability.GetBehaviorInt then return true end
	local behavior = ability:GetBehaviorInt()

	-- check if the ability exists and if it is Vector targeting
	if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
		VectorTarget:UpdateNettable(ability)
	end
end

function VectorTarget:OnItemPickup(event)
	local index = event.item_entindex
	if not index then
		index = event.ItemEntityIndex
	end
	local ability = EntIndexToHScript(index)

	if not ability or not ability.GetBehaviorInt then return true end
	local behavior = ability:GetBehaviorInt()

	-- check if the item exists and if it is Vector targeting
	if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
		VectorTarget:UpdateNettable(ability)
	end
end

function VectorTarget:OnItemBought(event)
	local playerID = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

	for i=0, 15 do
		local item = hero:GetItemInSlot(i)
		if item and item.GetBehaviorInt then
			local behavior = item:GetBehaviorInt()
			if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
				VectorTarget:UpdateNettable(item)
			end
		end
	end
end

function VectorTarget:OnAbilityCheck(event)
	local ability = EntIndexToHScript(event.abilityIndex)
	VectorTarget:UpdateNettable(ability)
end

function CDOTABaseAbility:GetVectorTargetRange()
	return 800
end 

function CDOTABaseAbility:GetVectorTargetStartRadius()
	return 125
end 

function CDOTABaseAbility:GetVectorTargetEndRadius()
	return self:GetVectorTargetStartRadius()
end 

function CDOTABaseAbility:GetVectorPosition()
	return self.vectorTargetPosition
end 

function CDOTABaseAbility:GetVector2Position() -- world click
	return self.vectorTargetPosition2
end 

function CDOTABaseAbility:GetVectorDirection()
	return self.vectorTargetDirection
end 

function CDOTABaseAbility:OnVectorCastStart(vStartLocation, vDirection)
	print("Vector Cast")
end

function CDOTABaseAbility:UpdateVectorValues()
	VectorTarget:UpdateNettable(self)
end

function CDOTABaseAbility:IsDualVectorDirection()
	return false
end

function CDOTABaseAbility:IgnoreVectorArrowWidth()
	return false
end

-- 添加一个实用函数，用于以编程方式释放矢量施法技能（单位+方向版本）
function CDOTABaseAbility:CastVectorAbilityOnTarget(target, direction)
    -- 获取目标位置
    local target_pos = target:GetAbsOrigin()
    
    -- 如果direction是角度而不是向量，转换为向量
    if type(direction) == "number" then
        local angle_rad = math.rad(direction)
        direction = Vector(math.cos(angle_rad), math.sin(angle_rad), 0)
    end
    
    -- 确保方向是规范化的向量
    direction = Vector(direction.x, direction.y, 0):Normalized()
    
    -- 计算终点位置（用于设置vectorTargetPosition2）
    local cast_range = self:GetVectorTargetRange()
    local end_pos = target_pos + direction * cast_range
    
    -- 修改：直接模拟OrderFilter的逻辑
    local caster = self:GetCaster()
    
    -- 1. 模拟第一次点击，设置vectorTargetPosition2
    self.vectorTargetPosition2 = end_pos
    
    -- 2. 模拟第二次点击，设置vectorTargetPosition和direction
    self.vectorTargetPosition = target_pos
    self.vectorTargetDirection = direction
    
    -- 3. 重写OnSpellStart为调用OnVectorCastStart
    local original_OnSpellStart = self.OnSpellStart
    local function OverrideSpellStart(selfRef)
        selfRef:OnVectorCastStart(target_pos, direction)
    end
    self.OnSpellStart = OverrideSpellStart
    
    -- 4. 设置施法目标和位置
    caster:SetCursorCastTarget(target)
    caster:SetCursorPosition(target_pos)
    
    -- 5. 触发技能释放
    self:CastAbility()
    
    -- 6. 恢复原始OnSpellStart
    self.OnSpellStart = original_OnSpellStart
    
    print("[VT] 程序化施放矢量技能，目标: " .. target:GetName() .. ", 方向: " .. tostring(direction))
    return true
end

-- 添加简化方法，允许用一个角度值来指定方向
function CDOTABaseAbility:CastVectorAbilityOnTargetWithAngle(target, angle_degrees)
    local angle_rad = math.rad(angle_degrees)
    local direction = Vector(math.cos(angle_rad), math.sin(angle_rad), 0)
    return self:CastVectorAbilityOnTarget(target, direction)
end

