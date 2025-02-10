LinkLuaModifier( "modifier_divide_on_death", "abilities/divide_on_death.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if divide_on_death == nil then
	divide_on_death = class({})
end
function divide_on_death:GetIntrinsicModifierName()
	return "modifier_divide_on_death"
end
---------------------------------------------------------------------
--Modifiers
if modifier_divide_on_death == nil then
	modifier_divide_on_death = class({})
end
function modifier_divide_on_death:OnCreated(params)
	if IsServer() then
	end
end
function modifier_divide_on_death:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_divide_on_death:OnDestroy()
	if IsServer() then
	end
end
function modifier_divide_on_death:DeclareFunctions()
	return {
	}
end