(function() {
    // 隐藏顶部栏
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false); 
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);

    // 隐藏小地图
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
    // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false);
    
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_QUICK_STATS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_KILLCAM, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FIGHT_RECAP, false);
    
    // 隐藏右下角商店栏
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);

    // 设置延时函数，2秒后执行
    (function () {
        // 打印脚本加载信息
        $.Msg("Script loaded and execution started.");
    
        // 获取Dota HUD面板的引用
        function GetHud() {
            var panel = $.GetContextPanel().GetParent();
            for (var i = 0; i < 100; i++) {
                if (panel.id != "Hud") {
                    panel = panel.GetParent();
                } else {
                    break;
                }
            }
            return panel;
        }
    
        // 隐藏不需要的Dota HUD元素
        function ConfigureDotaHud() {
            var hud = GetHud();
            var panelsToHide = [
                "quickstats", // 左上角的K/D显示
                "player_performance_container",
                "combat_events", // 左侧的死亡信息显示
                "SpectatorToastManager",//右侧的技能升级提醒
                "stackable_side_panels",
                "inventory_neutral_craft_holder",//中立装备栏
                "inventory_tpscroll_container",//TP栏
            ];
    
            for (var panel of panelsToHide) {
                var testPanel = hud.FindChildTraverse(panel);
                if (testPanel) { 
                    testPanel.visible = false;
                    $.Msg("Hiding panel: " + panel);
                } else {
                    $.Msg("Panel not found: " + panel);
                }
            }
        }
    
        // 设置延时执行隐藏面板函数
        $.Schedule(2.0, ConfigureDotaHud);


    
    })();


    function FindHeroFacetSnippetContainer() {
        // 获取初始面板
        var panel = $.GetContextPanel().GetParent();
        
        // 最大循环次数设为100以防止无限循环
        for (var i = 0; i < 100; i++) {
            // 如果找到目标面板，打印并返回
            if (panel.id === "HeroFacetSnippetContainer") {
                $.Msg("Found HeroFacetSnippetContainer panel!");
                return panel;
            }
            // 如果已经到达根节点还没找到，终止搜索
            if (!panel.GetParent()) {
                $.Msg("Could not find HeroFacetSnippetContainer - reached root panel");
                return null;
            }
            // 继续向上层寻找
            panel = panel.GetParent();
        }
        
        // 如果超过最大循环次数还没找到，返回null
        $.Msg("Could not find HeroFacetSnippetContainer - max iterations reached");
        return null;
    }
    
    // 使用示例：
    $.Schedule(2.0, function() {
        var facetPanel = FindHeroFacetSnippetContainer();
        if (facetPanel) {
            $.Msg("Panel ID: " + facetPanel.id);
            // 这里可以对找到的面板进行操作
        }
    });

})();
    

// (function() {
//     let isDisplayActive = false; // 控制变量
    
//     // 获取白板面板引用并设置样式
//     const whiteboardPanel = $("#WhiteboardRoot");
//     whiteboardPanel.visible = true; // 初始设置为隐藏
    
//     // 设置面板样式
//     whiteboardPanel.style.width = '100%';
//     whiteboardPanel.style.height = '100%';
//     whiteboardPanel.style.backgroundColor = '#FFFFFF';
//     whiteboardPanel.style.zIndex = '5';
//     whiteboardPanel.style.transitionProperty = 'opacity';
//     whiteboardPanel.style.transitionDuration = '0.3s';
//     whiteboardPanel.style.opacity = '1';

//     // 获取自定义UI根面板并设置zIndex
//     let customRoot = $.GetContextPanel();
//     while(customRoot.id != 'CustomUIRoot') customRoot = customRoot.GetParent();
//     customRoot.style.zIndex = -1;

//     // 获取Dota HUD面板的引用
//     function GetHud() {
//         var panel = $.GetContextPanel();
//         while (panel && panel.id !== "Hud") {
//             panel = panel.GetParent();
//         }
//         return panel;
//     }

//     // 隐藏Tooltip箭头的函数
//     function HideTooltipArrows() {
//         if (!isDisplayActive) return; // 如果控制变量为false，直接返回
    
//         const hud = GetHud();
//         if (!hud) {
//             $.Msg("HUD not found, retrying...");
//             $.Schedule(0.5, HideTooltipArrows);
//             return;
//         }
    
//         const tooltipPanels = [
//             "DOTAAbilityTooltip",
//             "DOTAHUDInnateStatusTooltip"
//         ];
    
//         const arrowsToHide = [
//             "TopArrow",
//             "LeftArrow",
//             "RightArrow",
//             "BottomArrow"
//         ];
    
//         for (const tooltipId of tooltipPanels) {
//             const tooltip = hud.FindChildTraverse(tooltipId);
//             if (!tooltip) {
//                 $.Msg(`${tooltipId} panel not found, retrying...`);
//                 $.Schedule(0.5, HideTooltipArrows);
//                 return;
//             }
    
//             for (const arrowId of arrowsToHide) {
//                 const arrow = tooltip.FindChildTraverse(arrowId);
//                 if (arrow) {
//                     arrow.visible = false;
//                     $.Msg(`Successfully hidden ${arrowId} in ${tooltipId}`);
//                 }
//             }
//         }
//     }
//     $.Schedule(2.0, HideTooltipArrows);


//     // 设置显示状态的函数
//     function SetDisplayState(state) {
//         isDisplayActive = state;
//         whiteboardPanel.visible = state;
        
//         if (state) {
//             whiteboardPanel.style.opacity = '1';
//             // 如果激活，执行隐藏箭头
//             $.Schedule(2.0, HideTooltipArrows);
//         } else {
//             whiteboardPanel.style.opacity = '0';
//         }
//     }

//     // 注册游戏事件监听器
//     GameEvents.Subscribe('SetDisplayState', (data) => {
//         SetDisplayState(data.state);
//     });

//     $.Msg("Tooltip arrows hiding script loaded.");
// })();





// (function() {
//     $.Msg("=== Full UI Hierarchy Search ===");

//     function PrintAllLevels() {
//         let currentPanel = $.GetContextPanel();
//         let level = 0;

//         while (currentPanel !== null) {
//             $.Msg(`\n=== Level ${level} ===`);
//             $.Msg(`Current Panel: [${currentPanel.id}] (Class: ${currentPanel.paneltype})`);
            
//             // 打印当前层级的所有子面板
//             $.Msg("Children at this level:");
//             let children = currentPanel.Children();
//             for (let child of children) {
//                 $.Msg(`- [${child.id}] (Class: ${child.paneltype}, Visible: ${child.visible})`);
//             }

//             // 移动到父级
//             currentPanel = currentPanel.GetParent();
//             level++;
//         }
//     }

//     // 初始化延迟执行
//     $.Schedule(2.0, PrintAllLevels);
// })();

//查找面板的好方法

// (function() {
//     $.Msg("=== HUD Structure Debugger ===");

//     // 增强版HUD获取方法
//     function GetHudRoot() {
//         let panel = $.GetContextPanel();
//         while (panel && panel.id !== "Hud") {
//             panel = panel.GetParent();
//         }
//         return panel || $.GetContextPanel();
//     }

//     // 递归打印面板结构
//     function PrintPanelStructure(panel, depth = 0) {
//         if (!panel) return;

//         // 构建缩进前缀
//         let prefix = "|".repeat(depth) + (depth > 0 ? "─ " : "");
        
//         // 打印当前面板信息
//         let info = `${prefix}[${panel.id}]`;
//         if (panel.style) {
//             info += ` (Class: ${panel.paneltype}, Visible: ${panel.visible})`;
//         }
//         $.Msg(info);

//         // 特别关注目标容器
//         if (panel.id === "DOTATooltipManager") {
//             $.Msg(`${prefix}★ Found Tooltip Manager!`);
//             // 立即检查其子元素
//             let tooltip = panel.FindChildTraverse("dotaTooltipAbility");
//             if (tooltip) {
//                 $.Msg(`${prefix}  ★ Found dotaTooltipAbility!`);
//                 let coreDetails = tooltip.FindChildTraverse("AbilityCoreDetails");
//                 $.Msg(`${prefix}    ${coreDetails ? "★ Found AbilityCoreDetails!" : "× Missing AbilityCoreDetails"}`);
//             }
//         }

//         // 递归遍历子元素
//         let children = panel.Children();
//         for (let child of children) {
//             PrintPanelStructure(child, depth + 1);
//         }
//     }

//     // 带重试机制的调试方法
//     function DebugHudStructure() {
//         let hud = GetHudRoot();
//         if (!hud) {
//             $.Msg("HUD root not found, retrying...");
//             $.Schedule(0.5, DebugHudStructure);
//             return;
//         }

//         $.Msg("=== Full HUD Structure ===");
//         PrintPanelStructure(hud);

//         // 特别检查工具提示系统
//         let tooltipManager = hud.FindChildTraverse("DOTAAbilityTooltip");
//         if (tooltipManager) {
//             $.Msg("=== Tooltip Manager Structure ===");
//             PrintPanelStructure(tooltipManager, 1);

//         } else {
//             $.Msg("× DOTATooltipManager not found!");
//         }
//     }

//     // 初始化延迟执行
//     $.Schedule(2.0, () => {
//         DebugHudStructure();
//         // 持续监控（每5秒更新一次）
//         $.Schedule(5.0, DebugHudStructure);
//     });
// })();