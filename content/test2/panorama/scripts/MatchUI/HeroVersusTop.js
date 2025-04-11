(function() {
    var lastLeftHealth = 100;
    var lastRightHealth = 100;
    var leftAnimationInfo = { isAnimating: false, targetWidth: 100 };
    var rightAnimationInfo = { isAnimating: false, targetWidth: 100 };

    GameEvents.Subscribe("update_unit_status", function(event) {
        OnUpdateUnitStatus(event);
    });

    function OnUpdateUnitStatus(data) {
        updateHealthAndManaBar(data.Left, 'Left');
        updateHealthAndManaBar(data.Right, 'Right');

        // 更新英雄属性面板
        updateHeroStatsPanel(data.Left, 'Left');
        updateHeroStatsPanel(data.Right, 'Right');
    }


    function updateHeroStatsPanel(heroData, side) {
        var container = $('#' + side + 'HeroStatsContainer');
        container.RemoveAndDeleteChildren();

        var stats = [
            { name: 'averageDamage', icon: 'icon_damage_psd.vtex', label: '攻击力', path: 'hud/reborn/' },
            { name: 'armor', icon: 'icon_armor_psd.vtex', label: '护甲', path: 'hud/reborn/' },
            { name: 'attackSpeed', icon: 'icon_attack_speed_psd.vtex', label: '攻速', path: 'hud/reborn/' },
            { name: 'magicResistance', icon: 'icon_magic_resist_psd.vtex', label: '魔抗', path: 'hud/reborn/' },
            { name: 'moveSpeed', icon: 'icon_speed_psd.vtex', label: '移速', path: 'hud/reborn/' },
            { name: 'strength', icon: 'mini_primary_attribute_icon_strength_psd.vtex', label: '力量', path: 'primary_attribute_icons/' },
            { name: 'agility', icon: 'mini_primary_attribute_icon_agility_psd.vtex', label: '敏捷', path: 'primary_attribute_icons/' },
            { name: 'intellect', icon: 'mini_primary_attribute_icon_intelligence_psd.vtex', label: '智力', path: 'primary_attribute_icons/' },
        ];

        stats.forEach(function(stat) {
            var statPanel = $.CreatePanel('Panel', container, '');
            statPanel.AddClass('HeroStatPanel');

            if (side === 'Left') {
                // 左侧：图标在左，值在右
                var icon = $.CreatePanel('Image', statPanel, '');
                icon.SetImage('s2r://panorama/images/' + stat.path + stat.icon);
                icon.AddClass('HeroStatIcon');

                var valueLabel = $.CreatePanel('Label', statPanel, '');
                valueLabel.text = heroData[stat.name];
                valueLabel.AddClass('HeroStatValue');
            } else {
                // 右侧：值在左，图标在右
                var valueLabel = $.CreatePanel('Label', statPanel, '');
                valueLabel.text = heroData[stat.name];
                valueLabel.AddClass('HeroStatValue');

                var icon = $.CreatePanel('Image', statPanel, '');
                icon.SetImage('s2r://panorama/images/' + stat.path + stat.icon);
                icon.AddClass('HeroStatIcon');
            }
        });
    }
    

    function updateHealthAndManaBar(heroData, side) {
        var healthPercentage = (heroData.currentHealth / heroData.maxHealth) * 100;
        var manaPercentage = (heroData.currentMana / heroData.maxMana) * 100;
        var lastHealth = side === 'Left' ? lastLeftHealth : lastRightHealth;
        var animationInfo = side === 'Left' ? leftAnimationInfo : rightAnimationInfo;
        
        // 更新实际血条
        var hpBar = $('#' + side + 'HPBarFG');
        if (!isNaN(healthPercentage) && healthPercentage >= 0) {
            hpBar.style.width = healthPercentage + '%';
            $('#' + side + 'HPBarTextContainer').style.width = (healthPercentage === 0 ? 3 : Math.max(5, healthPercentage)) + '%';
        } else {
            $('#' + side + 'HPBarTextContainer').style.width = '0%';
            //$.Msg("警告：健康百分比无效：" + healthPercentage);
        }
    
        // 根据生命值百分比切换血条样式
        if (healthPercentage < 33) {
            hpBar.RemoveClass('normal_hp_bar');
            hpBar.RemoveClass('healthy_hp_bar');
            hpBar.AddClass('low_hp_bar');
        } else if (healthPercentage >= 66) {
            hpBar.RemoveClass('normal_hp_bar');
            hpBar.RemoveClass('low_hp_bar');
            hpBar.AddClass('healthy_hp_bar');
        } else {
            hpBar.RemoveClass('low_hp_bar');
            hpBar.RemoveClass('healthy_hp_bar');
            hpBar.AddClass('normal_hp_bar');
        }
        
        // 更新过渡血条
        if (healthPercentage < lastHealth) {
            var midBar = $('#' + side + 'HPBarMID');
            animationInfo.targetWidth = healthPercentage;
            
            if (!animationInfo.isAnimating) {
                animationInfo.isAnimating = true;
                animate(side);
            }
        }
        
        // 更新魔法条
        if (!isNaN(manaPercentage) && manaPercentage > 0) {
            $('#ShieldBar' + side).style.width = manaPercentage + '%';
        } else {
            $('#ShieldBar' + side).style.width = '0%';
        }
        
        // 更新血量值显示,只显示当前血量
        $('#' + side + 'HPBarText').text = Math.floor(heroData.currentHealth);
        
        // 更新lastHealth
        if (side === 'Left') {
            lastLeftHealth = healthPercentage;
        } else {
            lastRightHealth = healthPercentage;
        }
    }

    function animate(side) {
        var animationInfo = side === 'Left' ? leftAnimationInfo : rightAnimationInfo;
        var midBar = $('#' + side + 'HPBarMID');
        var currentWidth = parseFloat(midBar.style.width) || 100;

        if (Math.abs(currentWidth - animationInfo.targetWidth) > 0.1) {
            var newWidth = currentWidth - (currentWidth - animationInfo.targetWidth) * 0.1;
            midBar.style.width = newWidth + '%';
            $.Schedule(0.05, function() { animate(side); }); 
        } else {
            midBar.style.width = animationInfo.targetWidth + '%';
            animationInfo.isAnimating = false;
        }
    }
    // 新增：更新modifier图标的函数
    function updateModifierIcons(modifiers, side) {
        var container = $('#' + side + 'TeamModifiers');
        container.RemoveAndDeleteChildren();

        modifiers.forEach(function(modifier) {
            var modifierIcon = $.CreatePanel('Image', container, '');
            modifierIcon.SetImage('file://{images}/custom_game/' + modifier.texture + '.png');
            modifierIcon.AddClass('ModifierIcon');

            // 可选：添加工具提示
            modifierIcon.SetPanelEvent('onmouseover', function() {
                $.DispatchEvent('DOTAShowTextTooltip', modifierIcon, modifier.name);
            });
            modifierIcon.SetPanelEvent('onmouseout', function() {
                $.DispatchEvent('DOTAHideTextTooltip');
            });
        });
    }
})();