(function() {
    const MAX_MESSAGES = 10;
    let messageQueue = [];

    function initialize() {
        $.Msg("Left hero attack panel initialized");
        GameEvents.Subscribe("left_hero_attack_info", onLeftHeroAttack);
    }

    function onLeftHeroAttack(data) {
        // $.Msg("Received attack info:", data);
    
        const isReversedMode = $('#CurrentGameModeLabel').text.includes('反转');
        const attackerName = "npc_dota_hero_" + data.attacker.replace("npc_dota_hero_", "");
        const targetName = "npc_dota_hero_" + data.target.replace("npc_dota_hero_", "");
        
        let message = "";
        if (data.attackType === "normal_attack") {
            message = formatNormalAttackMessage(attackerName, targetName, data.damage, isReversedMode);
        } else if (data.attackType === "ability_attack") {
            const abilityName = "DOTA_Tooltip_ability_" + data.abilityName;
            message = formatAbilityAttackMessage(attackerName, targetName, abilityName, data.damage, isReversedMode);
        }
        
        addMessage(message);
    
        // $.Msg("Formatted message:", message);
    }

    function formatNormalAttackMessage(attacker, target, damage, isReversed) {
        const attackerLocalized = $.Localize("#" + attacker);
        const attackerFormatted = isReversed ? reverseString(attackerLocalized) : attackerLocalized;
        return {
            attacker: attackerFormatted,
            target: $.Localize("#" + target),
            damage: parseFloat(damage).toFixed(1),
            isNormal: true
        };
    }

    function formatAbilityAttackMessage(attacker, target, ability, damage, isReversed) {
        const attackerLocalized = $.Localize("#" + attacker);
        const attackerFormatted = isReversed ? reverseString(attackerLocalized) : attackerLocalized;
        return {
            attacker: attackerFormatted,
            target: $.Localize("#" + target),
            ability: $.Localize("#" + ability),
            damage: parseFloat(damage).toFixed(1),
            isNormal: false
        };
    }

    function reverseString(str) {
        return str.split('').reverse().join('');
    }

    function addMessage(messageData) {
        messageQueue.unshift({ data: messageData, time: Game.GetGameTime() });
        if (messageQueue.length > MAX_MESSAGES) {
            messageQueue.pop();
        }
        updateDisplay();
    }

    function updateDisplay() {
        const currentTime = Game.GetGameTime();
        for (let i = 0; i < MAX_MESSAGES; i++) {
            const messagePanel = $(`#Message${i}`);
            if (i < messageQueue.length) {
                const message = messageQueue[i];
                const timeDiff = currentTime - message.time;
                if (timeDiff < 3.8) {  // 将时间稍微缩短，以确保完全消失
                    updateMessagePanel(messagePanel, message.data);
                    messagePanel.RemoveClass("Hidden");
                    let opacity = Math.max(0, 1 - (timeDiff / 3.8));  // 使用线性衰减
                    opacity = opacity < 0.1 ? 0 : parseFloat(opacity.toFixed(3)); // 设置最小阈值并限制小数位数
                    messagePanel.style.opacity = opacity.toString();
                } else {
                    messagePanel.AddClass("Hidden");
                    messagePanel.style.opacity = '0';  // 确保完全透明
                }
            } else {
                messagePanel.AddClass("Hidden");
                messagePanel.style.opacity = '0';  // 确保完全透明
            }
        }
    }

    function updateMessagePanel(panel, data) {
        panel.RemoveAndDeleteChildren();
        
        let attackerLabel = $.CreatePanel("Label", panel, "");
        attackerLabel.AddClass("HeroNameLeft");
        attackerLabel.text = data.attacker;  // 直接使用已本地化的文本
    
        let actionLabel = $.CreatePanel("Label", panel, "");
        actionLabel.text = "对";
    
        let targetLabel = $.CreatePanel("Label", panel, "");
        targetLabel.AddClass("HeroNameRight");
        targetLabel.text = data.target;  // 直接使用已本地化的文本
    
        if (data.isNormal) {
            let normalAttackLabel = $.CreatePanel("Label", panel, "");
            normalAttackLabel.text = "进行了普通攻击，造成了";
        } else {
            let abilityLabel = $.CreatePanel("Label", panel, "");
            abilityLabel.text = "释放了";
    
            let abilityNameLabel = $.CreatePanel("Label", panel, "");
            abilityNameLabel.AddClass("AbilityName");
            abilityNameLabel.text = data.ability;  // 直接使用已本地化的文本
    
            let damageLabel = $.CreatePanel("Label", panel, "");
            damageLabel.text = "，造成了";
        }
    
        let damageValueLabel = $.CreatePanel("Label", panel, "");
        damageValueLabel.AddClass("DamageValue");
        damageValueLabel.text = data.damage;
    
        let damageUnitLabel = $.CreatePanel("Label", panel, "");
        damageUnitLabel.text = "点伤害";
    }

    function update() {
        updateDisplay();
        $.Schedule(0.1, update);
    }

    initialize();
    update();
})();


(function() {
    const MAX_MESSAGES = 10;
    let messageQueue = [];

    function initialize() {
        $.Msg("Right hero attack panel initialized");
        GameEvents.Subscribe("right_hero_attack_info", onRightHeroAttack);
    }

    function onRightHeroAttack(data) {
        // $.Msg("Received attack info:", data);
    
        const isReversedMode = $('#CurrentGameModeLabel').text.includes('反转');
        const attackerName = "npc_dota_hero_" + data.attacker.replace("npc_dota_hero_", "");
        const targetName = "npc_dota_hero_" + data.target.replace("npc_dota_hero_", "");
        
        let message = "";
        if (data.attackType === "normal_attack") {
            message = formatNormalAttackMessage(attackerName, targetName, data.damage, isReversedMode);
        } else if (data.attackType === "ability_attack") {
            const abilityName = "DOTA_Tooltip_ability_" + data.abilityName;
            message = formatAbilityAttackMessage(attackerName, targetName, abilityName, data.damage, isReversedMode);
        }
        
        addMessage(message);
    
        // $.Msg("Formatted message:", message);
    }

    function formatNormalAttackMessage(attacker, target, damage, isReversed) {
        const targetLocalized = $.Localize("#" + target);
        const targetFormatted = isReversed ? reverseString(targetLocalized) : targetLocalized;
        return {
            attacker: $.Localize("#" + attacker),
            target: targetFormatted,
            damage: parseFloat(damage).toFixed(1),
            isNormal: true
        };
    }

    function formatAbilityAttackMessage(attacker, target, ability, damage, isReversed) {
        const targetLocalized = $.Localize("#" + target);
        const targetFormatted = isReversed ? reverseString(targetLocalized) : targetLocalized;
        return {
            attacker: $.Localize("#" + attacker),
            target: targetFormatted,
            ability: $.Localize("#" + ability),
            damage: parseFloat(damage).toFixed(1),
            isNormal: false
        };
    }

    function reverseString(str) {
        return str.split('').reverse().join('');
    }

    function addMessage(messageData) {
        messageQueue.unshift({ data: messageData, time: Game.GetGameTime() });
        if (messageQueue.length > MAX_MESSAGES) {
            messageQueue.pop();
        }
        updateDisplay();
    }

    function updateDisplay() {
        const currentTime = Game.GetGameTime();
        for (let i = 0; i < MAX_MESSAGES; i++) {
            const messagePanel = $(`#RightMessage${i}`);
            if (i < messageQueue.length) {
                const message = messageQueue[i];
                const timeDiff = currentTime - message.time;
                if (timeDiff < 3.8) {
                    updateMessagePanel(messagePanel, message.data);
                    messagePanel.RemoveClass("Hidden");
                    let opacity = Math.max(0, 1 - (timeDiff / 3.8));
                    
                    // 将opacity限制在0到1之间，并保留两位小数
                    opacity = Math.min(1, Math.max(0, parseFloat(opacity.toFixed(2))));
                    
                    messagePanel.style.opacity = opacity.toString();
                } else {
                    messagePanel.AddClass("Hidden");
                    messagePanel.style.opacity = '0';
                }
            } else {
                messagePanel.AddClass("Hidden");
                messagePanel.style.opacity = '0';
            }
        }
    }

    function updateMessagePanel(panel, data) {
        panel.RemoveAndDeleteChildren();
        
        // 创建一个容器来包含所有文本元素
        let contentContainer = $.CreatePanel("Panel", panel, "");
        contentContainer.AddClass("MessageContent");
        
        let attackerLabel = $.CreatePanel("Label", contentContainer, "");
        attackerLabel.AddClass("HeroNameRight");
        attackerLabel.text = data.attacker;
    
        let actionLabel = $.CreatePanel("Label", contentContainer, "");
        actionLabel.text = "对";
    
        let targetLabel = $.CreatePanel("Label", contentContainer, "");
        targetLabel.AddClass("HeroNameLeft");
        targetLabel.text = data.target;
    
        if (data.isNormal) {
            let normalAttackLabel = $.CreatePanel("Label", contentContainer, "");
            normalAttackLabel.text = "进行了普通攻击，造成了";
        } else {
            let abilityLabel = $.CreatePanel("Label", contentContainer, "");
            abilityLabel.text = "释放了";
    
            let abilityNameLabel = $.CreatePanel("Label", contentContainer, "");
            abilityNameLabel.AddClass("AbilityName");
            abilityNameLabel.text = data.ability;
    
            let damageLabel = $.CreatePanel("Label", contentContainer, "");
            damageLabel.text = "，造成了";
        }
    
        let damageValueLabel = $.CreatePanel("Label", contentContainer, "");
        damageValueLabel.AddClass("DamageValue");
        damageValueLabel.text = data.damage;
    
        let damageUnitLabel = $.CreatePanel("Label", contentContainer, "");
        damageUnitLabel.text = "点伤害";
    }

    function update() {
        updateDisplay();
        $.Schedule(0.1, update);
    }

    initialize();
    update();
})();