GameEvents.Subscribe("show_hero", onShowHero);

let isAnimationEnabled = true;  // 默认开启动画

setupAnimationToggle(); 

function onShowHero(event) {
    if (!isAnimationEnabled) {
        $.Msg("入场动画已关闭，跳过动画展示");
        return;
    }

    showHeroVersus(
        event.leftHeroID,
        event.rightHeroID,
        event.leftHeroFacets,
        event.rightHeroFacets,
        event.Time
    );
}

function setupAnimationToggle() {
    const toggleButton = $('#ToggleAnimationButton');
    const toggleLabel = $('#ToggleAnimationButtonLabel');

    if (!toggleButton || !toggleLabel) {
        $.Msg("Animation toggle button or label not found");
        return;
    }

    // 设置按钮初始状态
    updateAnimationButtonState();

    // 添加点击事件
    toggleButton.SetPanelEvent('onactivate', () => {
        isAnimationEnabled = !isAnimationEnabled;
        updateAnimationButtonState();
        $.Msg(`入场动画已${isAnimationEnabled ? '开启' : '关闭'}`);
    });
}

function updateAnimationButtonState() {
    const toggleLabel = $('#ToggleAnimationButtonLabel');
    if (toggleLabel) {
        toggleLabel.text = isAnimationEnabled ? "关闭入场动画" : "开启入场动画";
    }
}

