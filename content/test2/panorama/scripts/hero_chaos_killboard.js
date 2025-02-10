(function() {
    let g_KillboardRoot = null;
    let g_KillboardFeed = null;
    const MAX_FEED_ITEMS = 8;
    
    function Initialize() {
        g_KillboardRoot = $('#hero_chaos_killboard_root');
        g_KillboardFeed = $('#hero_chaos_killboard_feed');
        
        if (!g_KillboardRoot || !g_KillboardFeed) {
            $.Msg("Error: Failed to initialize killboard panels!");
            return false;
        }

        // 添加事件监听器
        $.Msg("Registering hero_chaos_kill_feed event listener");
        GameEvents.Subscribe("hero_chaos_kill_feed", function(data) {
            $.Msg("Received kill feed event:");
            $.Msg(data);
            AddKillFeed(data);
        });

        // 确保父容器是右对齐的
        g_KillboardRoot.style.horizontalAlign = 'right';
        g_KillboardFeed.style.horizontalAlign = 'right';
        
        return true;
    }

    function AddKillFeed(data) {
        if (!g_KillboardFeed || !g_KillboardFeed.IsValid()) {
            $.Msg("Error: Kill feed panel is not initialized!");
            return;
        }

        // 检查击杀消息数量，如果超过最大值则删除最老的
        const children = g_KillboardFeed.Children();
        if (children && children.length >= MAX_FEED_ITEMS) {
            const oldestChild = children[0];
            if (oldestChild && oldestChild.IsValid()) {
                oldestChild.DeleteAsync(0.0);
            }
        }

        // 创建新的击杀信息面板
        const killItem = $.CreatePanel('Panel', g_KillboardFeed, '');
        if (!killItem) {
            $.Msg("Error: Failed to create kill item panel!");
            return;
        }

        killItem.AddClass('hero_chaos_killboard_item');
        killItem.style.horizontalAlign = 'right'; // 确保每个项目也是右对齐的
        
        // 击杀者英雄图标
        const killerIcon = $.CreatePanel('DOTAHeroImage', killItem, '');
        killerIcon.AddClass('hero_chaos_killboard_hero_icon');
        killerIcon.heroname = data.killer_hero;
        killerIcon.heroimagestyle = 'icon';
        
        // 击杀者名字
        const killerName = $.CreatePanel('Label', killItem, '');
        killerName.AddClass('hero_chaos_killboard_hero_name');
        killerName.AddClass('hero_chaos_killboard_hero_name_' + data.killer_type.toLowerCase());
        killerName.text = data.killer_name;
        
        // "击杀了" 文本
        const killText = $.CreatePanel('Label', killItem, '');
        killText.AddClass('hero_chaos_killboard_kill_text');
        killText.text = "击杀了";
        
        // 被击杀者英雄图标
        const victimIcon = $.CreatePanel('DOTAHeroImage', killItem, '');
        victimIcon.AddClass('hero_chaos_killboard_hero_icon');
        victimIcon.heroname = data.victim_hero;
        victimIcon.heroimagestyle = 'icon';
        
        // 被击杀者名字
        const victimName = $.CreatePanel('Label', killItem, '');
        victimName.AddClass('hero_chaos_killboard_hero_name');
        victimName.AddClass('hero_chaos_killboard_hero_name_' + data.victim_type.toLowerCase());
        victimName.text = data.victim_name;

        // 5秒后开始淡出动画
        $.Schedule(5.0, function() {
            if (killItem && killItem.IsValid()) {
                killItem.AddClass('hero_chaos_killboard_item_fadeout');
                
                // 动画结束后删除元素
                $.Schedule(0.3, function() {
                    if (killItem && killItem.IsValid()) {
                        killItem.DeleteAsync(0.0);
                    }
                });
            }
        });
    }

    // 测试函数保持不变
    function TestKillBoard() {
        if (!Initialize()) {
            $.Msg("Error: Cannot run test - initialization failed!");
            return;
        }

        const testKills = [
            {
                killer_hero: "npc_dota_hero_axe",
                killer_name: "斧王",
                killer_type: "1",
                victim_hero: "npc_dota_hero_lion",
                victim_name: "莱恩",
                victim_type: "4"
            },
            {
                killer_hero: "npc_dota_hero_phantom_assassin",
                killer_name: "幻影刺客",
                killer_type: "2",
                victim_hero: "npc_dota_hero_crystal_maiden",
                victim_name: "水晶室女",
                victim_type: "4"
            },
            {
                killer_hero: "npc_dota_hero_zuus",
                killer_name: "宙斯",
                killer_type: "4",
                victim_hero: "npc_dota_hero_juggernaut",
                victim_name: "主宰",
                victim_type: "2"
            },
            {
                killer_hero: "npc_dota_hero_invoker",
                killer_name: "祈求者",
                killer_type: "8",
                victim_hero: "npc_dota_hero_antimage",
                victim_name: "敌法师",
                victim_type: "4"
            }
        ];

        let index = 0;
        function showNextKill() {
            if (index < testKills.length) {
                AddKillFeed(testKills[index]);
                index++;
                $.Schedule(2.0, showNextKill);
            } else {
                index = 0;
                $.Schedule(2.0, showNextKill);
            }
        }

        showNextKill();
    }
    Initialize();
    //TestKillBoard();

})();