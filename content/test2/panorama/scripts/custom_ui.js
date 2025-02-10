let currentAbilityIndex = 0;
const abilities = [0, 1, 2, 3]; // 对应技能槽位
const DISPLAY_TIME = 4.0; // 每个tooltip显示4秒

function ShowNextAbilityTooltip() {
    // 隐藏所有tooltip
    abilities.forEach(index => {
        $.DispatchEvent("DOTAHideAbilityTooltip");
    });

    // 获取当前英雄
    const hero = Players.GetLocalPlayerPortraitUnit();
    if (hero) {
        // 获取当前需要显示的技能
        const abilityIndex = abilities[currentAbilityIndex];
        const ability = Entities.GetAbility(hero, abilityIndex);
        
        if (ability && ability !== -1) {
            // 显示tooltip
            const abilityPanel = $("#ability_" + abilityIndex);
            if (abilityPanel) {
                $.DispatchEvent("DOTAShowAbilityTooltip", abilityPanel, ability);
            }
        }
    }

    // 更新索引
    currentAbilityIndex = (currentAbilityIndex + 1) % abilities.length;

    // 设置下一个显示的定时器
    $.Schedule(DISPLAY_TIME, ShowNextAbilityTooltip);
}

// 启动轮播
function StartTooltipCarousel() {
    ShowNextAbilityTooltip();
}

// 停止轮播
function StopTooltipCarousel() {
    $.CancelScheduled(ShowNextAbilityTooltip);
    $.DispatchEvent("DOTAHideAbilityTooltip");
}

// 在需要的时候调用这个函数开始轮播
StartTooltipCarousel();