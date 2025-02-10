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
