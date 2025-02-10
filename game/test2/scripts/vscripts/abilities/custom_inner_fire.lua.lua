LinkLuaModifier( "modifier_custom_inner_fire", "abilities/custom_inner_fire.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if custom_inner_fire == nil then
	custom_inner_fire = class({})
end
function custom_inner_fire:GetIntrinsicModifierName()
	return "modifier_custom_inner_fire"
end
---------------------------------------------------------------------
--Modifiers
if modifier_custom_inner_fire == nil then
	modifier_custom_inner_fire = class({})
end
function modifier_custom_inner_fire:OnCreated(params)
	if IsServer() then
	end
end
function modifier_custom_inner_fire:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_custom_inner_fire:OnDestroy()
	if IsServer() then
	end
end
function modifier_custom_inner_fire:DeclareFunctions()
	return {
	}
end