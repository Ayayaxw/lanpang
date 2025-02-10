LinkLuaModifier( "modifier_my_arrow", "my_arrow.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if my_arrow == nil then
	my_arrow = class({})
end
function my_arrow:GetIntrinsicModifierName()
	return "modifier_my_arrow"
end
---------------------------------------------------------------------
--Modifiers
if modifier_my_arrow == nil then
	modifier_my_arrow = class({})
end
function modifier_my_arrow:OnCreated(params)
	if IsServer() then
	end
end
function modifier_my_arrow:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_my_arrow:OnDestroy()
	if IsServer() then
	end
end
function modifier_my_arrow:DeclareFunctions()
	return {
	}
end