(function() {
    function Initialize() {
        const rootPanel = $.GetContextPanel();
        
        // 创建主容器
        const container = $.CreatePanel('Panel', rootPanel, 'HeroAbilityContainer');
        container.AddClass('AbilityContainer');

        // 创建基础技能行
        const basicAbilitiesRow = $.CreatePanel('Panel', container, 'BasicAbilities');
        basicAbilitiesRow.AddClass('AbilityRow');

        // 创建天赋图标容器
        const talentContainer = $.CreatePanel('Panel', container, 'TalentIconContainer');
        talentContainer.AddClass('TalentIconContainer');
        
        // 创建天赋图标
        const talentDisplay = $.CreatePanel('DOTAHudTalentDisplay', talentContainer, 'TalentDisplay');
        talentDisplay.AddClass('TalentIcon');

        // 创建神杖和晶碎行
        const upgradeRow = $.CreatePanel('Panel', container, 'UpgradeAbilities');
        upgradeRow.AddClass('AbilityRow');

        // 获取英雄信息
        const hero = Players.GetLocalPlayerPortraitUnit();
        if (!hero) return;

        // 加载基础技能
        let abilitySlots = [];
        for (let i = 0; i < 32; i++) {
            const ability = Entities.GetAbility(hero, i);
            if (!ability) continue;
            
            // 检查技能是否隐藏
            if (Abilities.IsHidden(ability)) continue;
            
            // 检查是否是基础技能
            const abilityName = Abilities.GetAbilityName(ability);
            const behavior = Abilities.GetBehavior(ability);
            
            // 创建技能槽位
            const abilitySlot = $.CreatePanel('Panel', basicAbilitiesRow, `Ability${i}`);
            abilitySlot.AddClass('AbilitySlot');
            
            // 创建技能图标
            CreateAbilityImage(abilitySlot, abilityName);
            abilitySlots.push(abilitySlot);
        }

        // 创建神杖技能槽位
        const scepterSlot = $.CreatePanel('Panel', upgradeRow, 'Scepter');
        scepterSlot.AddClass('UpgradeSlot');
        const scepterAbility = GetScepterAbility(hero);
        if (scepterAbility) {
            CreateAbilityImage(scepterSlot, Abilities.GetAbilityName(scepterAbility));
        }

        // 创建晶碎技能槽位
        const shardSlot = $.CreatePanel('Panel', upgradeRow, 'Shard');
        shardSlot.AddClass('UpgradeSlot');
        const shardAbility = GetShardAbility(hero);
        if (shardAbility) {
            CreateAbilityImage(shardSlot, Abilities.GetAbilityName(shardAbility));
        }
    }

    function GetScepterAbility(hero) {
        // 获取神杖技能的逻辑
        // 需要根据具体游戏API实现
        return null;
    }

    function GetShardAbility(hero) {
        // 获取晶碎技能的逻辑
        // 需要根据具体游戏API实现
        return null;
    }

    function CreateAbilityImage(parent, abilityName) {
        const abilityImage = $.CreatePanel('DOTAAbilityImage', parent, '');
        abilityImage.abilityname = abilityName;
        abilityImage.SetPanelEvent('onmouseover', () => ShowAbilityTooltip(abilityImage, abilityName));
        abilityImage.SetPanelEvent('onmouseout', () => HideAbilityTooltip(abilityImage));
    }

    function ShowAbilityTooltip(panel, abilityName) {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, abilityName);
    }

    function HideAbilityTooltip(panel) {
        $.DispatchEvent('DOTAHideAbilityTooltip');
    }

    // 监听英雄选择变化
    function OnHeroSelectionChanged() {
        // 清除现有内容
        const rootPanel = $.GetContextPanel();
        rootPanel.RemoveAndDeleteChildren();
        // 重新初始化
        Initialize();
    }

    // 注册事件监听
    $.RegisterForUnhandledEvent('DOTAHeroSelectionEnd', OnHeroSelectionChanged);
    
    // 初始化
    Initialize();
})();