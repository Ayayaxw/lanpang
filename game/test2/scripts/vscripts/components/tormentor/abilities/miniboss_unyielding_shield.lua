LinkLuaModifier("modifier_miniboss_unyielding_shield_custom", "components/tormentor/abilities/miniboss_unyielding_shield.lua", LUA_MODIFIER_MOTION_NONE)

miniboss_unyielding_shield_custom = miniboss_unyielding_shield_custom or class({})

function miniboss_unyielding_shield_custom:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end

function miniboss_unyielding_shield_custom:GetIntrinsicModifierName()
	return "modifier_miniboss_unyielding_shield_custom"
end

---------------------------------------------------------------------------------------------------

modifier_miniboss_unyielding_shield_custom = modifier_miniboss_unyielding_shield_custom or class({})

function modifier_miniboss_unyielding_shield_custom:IsHidden()
	return false
end

function modifier_miniboss_unyielding_shield_custom:IsDebuff()
	return false
end

function modifier_miniboss_unyielding_shield_custom:IsPurgable()
	return false
end

function modifier_miniboss_unyielding_shield_custom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_TOOLTIP2,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_DAMAGE_HPLOSS,  -- 关键：生命移除专用钩子
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE, -- 添加：忽略施法角度
		MODIFIER_PROPERTY_DISABLE_TURNING, -- 添加：禁止转向属性
		MODIFIER_EVENT_ON_ATTACK_RECORD 
	}
end

function modifier_miniboss_unyielding_shield_custom:GetModifierDisableTurning()
	return 1
end

-- 添加：忽略施法角度限制
function modifier_miniboss_unyielding_shield_custom:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_miniboss_unyielding_shield_custom:OnAttackRecord(params)
    if not IsServer() then return end    
    -- 检查是否是被攻击的目标
    if params.target == self:GetParent() then
        local attacker = params.attacker
        -- 检查攻击者是否拥有riki_innate_backstab技能
        if attacker:HasAbility("riki_innate_backstab") then
			attacker:AddNewModifier(attacker, backstab_ability, "modifier_hidden_break", {duration = 0.5})
        end
	elseif attacker:HasAbility("riki_innate_backstab") and HasModifier(attacker, "modifier_hidden_break") then
		attacker:RemoveModifierByName("modifier_hidden_break")
    end
end


function modifier_miniboss_unyielding_shield_custom:OnDamageHPLoss(event)
    if event.unit == self:GetParent() then

		--设置生命值为1
		event.unit:SetHealth(1)
        return false  -- 完全拦截
    end
end


function modifier_miniboss_unyielding_shield_custom:OnCreated()
	if not IsServer() then return end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	parent:EmitSound("Miniboss.Tormenter.Spawn")

	self.minArmor = ability:GetSpecialValueFor("min_armor")

	-- This delay is required because the tormentor team is not set yet when the modifier is created
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("delay"), function()
		local deaths = Tormentors:GetDeaths(parent.tormentorTeam)

		self.bonusShieldPerDeath = ability:GetSpecialValueFor("absorb_bonus_per_death") * deaths
		self.bonusRegenPerDeath = ability:GetSpecialValueFor("regen_bonus_per_death") * deaths

		self.maxShield = ability:GetSpecialValueFor("damage_absorb") + self.bonusShieldPerDeath
		self.currentShield = self.maxShield
		self.regenPerSecond = ability:GetSpecialValueFor("regen_per_second") + self.bonusRegenPerDeath
		self.regenPerSecondThink = self.regenPerSecond * FrameTime()

		self:SetHasCustomTransmitterData(true)
		self:StartIntervalThink(FrameTime())
	end, FrameTime())
end

function modifier_miniboss_unyielding_shield_custom:OnRefresh()
	self:OnCreated()

	-- Tell the client that we need to get the properties again
	if IsServer() then self:SendBuffRefreshToClients() end
end

function modifier_miniboss_unyielding_shield_custom:AddCustomTransmitterData()
	return {
		currentShield = self.currentShield,
		maxShield = self.maxShield,
		regenPerSecond = self.regenPerSecond, -- sent to client only because of MODIFIER_PROPERTY_TOOLTIP2
	}
end

function modifier_miniboss_unyielding_shield_custom:HandleCustomTransmitterData(data)
	self.currentShield = data.currentShield
	self.maxShield = data.maxShield
	self.regenPerSecond = data.regenPerSecond
end

function modifier_miniboss_unyielding_shield_custom:OnIntervalThink()
	self.currentShield = math.min(self.currentShield + self.regenPerSecondThink, self.maxShield)
	self:SendBuffRefreshToClients()
end

function modifier_miniboss_unyielding_shield_custom:GetModifierIncomingDamageConstant(event)
	-- Return the max health on the client if it's a max report, otherwise return the current health
	if IsClient() then
		if event.report_max then
			return self.maxShield
		else
			return self.currentShield
		end
	else
		local damage = event.damage

		-- Don't do anything if damage is 0 or somehow negative
		if damage <= 0 then
			return 0
		end

		-- Don't react to damage with HP removal flag
		if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS then
			return 0
		end

		-- Don't block more than remaining hp
		local barrier_hp = self.currentShield
		local block_amount = math.min(damage, barrier_hp)

		-- Reduce barrier hp
		self.currentShield = self.currentShield - block_amount

		if block_amount > 0 then
			-- Visual effect
			local parent = self:GetParent()
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, parent, block_amount, nil)
		end

		-- Tell the client that we need to update the health property
		self:SendBuffRefreshToClients()

		-- EmitSoundOnClient("Miniboss.Tormenter.Target", event.attacker)
		event.attacker:EmitSound("Miniboss.Tormenter.Target")

		return -block_amount
	end
end

function modifier_miniboss_unyielding_shield_custom:OnTooltip()
	return self.maxShield
end

function modifier_miniboss_unyielding_shield_custom:OnTooltip2()
	return self.regenPerSecond
end

function modifier_miniboss_unyielding_shield_custom:GetModifierPhysicalArmorBonus()
    if not IsServer() then return end

	local parent = self:GetParent()
	if self.checkArmor then
		return 0
	else
		self.checkArmor = true
		local base_armor = parent:GetPhysicalArmorBaseValue()
		local current_armor = parent:GetPhysicalArmorValue(false)
		self.checkArmor = false
		local min_armor = self.minArmor
		if current_armor < min_armor then
			return min_armor - current_armor
		end
	end
	return 0
end