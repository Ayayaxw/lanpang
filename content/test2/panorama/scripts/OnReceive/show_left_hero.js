
GameEvents.Subscribe("show_left_hero", ReceiveLeftHeroData);


function ReceiveLeftHeroData(data) {
    if (!isAnimationEnabled) {
        $.Msg("入场动画已关闭，跳过动画展示");
        return;
    }

    console.log("接收到左侧英雄数据:", data);

    if (data && data.heroID && data.facets) {
        const heroID = data.heroID;
        const heroFacet = data.facets;
        showSingleHero(heroID, heroFacet);
    } else {
        console.error("接收到的数据格式不正确");
    }
}