LinkLuaModifier( "modifier_caipan", "caipan.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if caipan == nil then
	caipan = class({})
end
function caipan:GetIntrinsicModifierName()
	return "modifier_caipan"
end
---------------------------------------------------------------------
--Modifiers
if modifier_caipan == nil then
	modifier_caipan = class({})
end
function modifier_caipan:OnCreated(params)
	if IsServer() then
	end
end
function modifier_caipan:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_caipan:OnDestroy()
	if IsServer() then
	end
end
function modifier_caipan:DeclareFunctions()
	return {
	}
end