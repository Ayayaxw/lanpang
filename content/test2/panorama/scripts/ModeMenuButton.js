(function () {
    'use strict';

    let itemList = {
        NormalItems: [],
        NeutralItems: [],
        CustomItems: [],
        SpecialItems: []  // 新增特殊物品数组
    };
    let itemDataRequested = false;
    let strategyDataRequested = false;
    let globalStrategies = [];
    let heroStrategies = {};
    let currentTab = 'NormalItems';
    let itemSelectionDialogInitialized = false;
    let isAnimationEnabled = true;  // 默认开启动画


    function initializeItemSelectionDialog() {
        if (itemSelectionDialogInitialized) {
            return;  // 已经初始化，避免重复创建
        }
        itemSelectionDialogInitialized = true;
    
        const grids = ['NormalItemsGrid', 'NeutralItemsGrid', 'CustomItemsGrid', 'SpecialItemsGrid'];
        grids.forEach(gridId => {
            const grid = $(`#${gridId}`);
            if (!grid) {
                $.Msg(`Error: ${gridId} not found`);
                return;
            }
            // 创建物品条目
            const items = itemList[gridId.replace('Grid', '')];
            if (items) {
                items.forEach(item => createItemEntry(item, grid));
            }
        });
    }

    function onReceiveItemList(event) {
      let allItems = [];
  
      if (event && event.items) {
          if (typeof event.items === 'object' && !Array.isArray(event.items)) {
              allItems = Object.values(event.items);
          } else if (Array.isArray(event.items)) {
              allItems = event.items;
          }
      }
  
      if (allItems.length > 0) {
          itemList = {
              NeutralItems: [],
              NormalItems: [],
              CustomItems: [],
              SpecialItems: []
          };
  
          // 修改排序函数
          const sortItems = (items) => {
              return items.sort((a, b) => {
                  // 如果两个物品都有价格，按价格排序（从高到低）
                  if (a.cost && b.cost) {
                      return b.cost - a.cost;
                  }
                  // 如果只有一个物品有价格，有价格的排在前面
                  if (a.cost) return -1;
                  if (b.cost) return 1;
                  // 如果都没有价格，按名字排序
                  const nameA = a.name || '';
                  const nameB = b.name || '';
                  if (nameA < nameB) return -1;
                  if (nameA > nameB) return 1;
                  return 0;
              });
          };
  
          // 分类物品
          allItems.forEach(item => {
              if (item.isNeutralDrop) {
                  itemList.NeutralItems.push(item);
              } else if (item.isCustomItem) {
                  itemList.CustomItems.push(item);
              } else if (item.isSpecialItem) {
                  itemList.SpecialItems.push(item);
              } else {
                  itemList.NormalItems.push(item);
              }
          });
  
          // 对每个分类进行排序
          itemList.NeutralItems = sortItems(itemList.NeutralItems);
          itemList.NormalItems = sortItems(itemList.NormalItems);
          itemList.CustomItems = sortItems(itemList.CustomItems);
          itemList.SpecialItems = sortItems(itemList.SpecialItems);
  
          itemDataRequested = false;
      }
      initializeItemSelectionDialog();
  }

    GameEvents.Subscribe("send_item_list", onReceiveItemList);


    /*** 变量定义 ***/
  
    // 当前挑战类型代码
    let currentChallengeType = '';
  
    // 游戏模式选择相关
    let currentGameModeLabel = $('#CurrentGameModeLabel');
    let modifyButton = $('#ModifyGameModeButton');
    let selectionPanel = $('#GameModeSelectionPanel');
    let gameModes = [];
  
    // 英雄选择相关变量
    let selfHero = {
      heroId: -1,
      facetId: -1,
      aiEnabled: false,
      equipment: [], // 装备数组，例如：[{ name: 'ItemName', count: 数量 }]
    };
  
    let opponentHero = {
      heroId: -1,
      facetId: -1,
      aiEnabled: false,
      equipment: [], // 装备数组，例如：[{ name: 'ItemName', count: 数量 }]
    };
  
    // 面板元素
    const GameModeMainPanel = $("#GameModeMainPanel");
    const modeMenuButton = $("#ModeMenuButton");
    const fcHeroPickPanel = $('#FcHeroPickPanel');
    const changeHeroButton = $('#ChangeHeroButton');
    const hud = GetHud();
  
    // 初始化脚本
    init();
  
    /*** 初始化函数 ***/
    function init() {
      // 调试输出 GameModeMainPanel 信息
      $.Msg("GameModeMainPanel: ", GameModeMainPanel ? GameModeMainPanel.paneltype : "null");
  
      // 设置事件处理程序
      setupEventHandlers();
  
      // 初始化 GameEvents.GameSetup，如果尚未初始化
      if (!GameEvents.GameSetup) {
        GameEvents.GameSetup = {};
      }
      setupAnimationToggle();  // 添加这行
      // 订阅游戏事件
      GameEvents.Subscribe("initialize_game_modes", onInitializeGameModes);
      GameEvents.Subscribe("show_hero", onShowHero);
      GameEvents.Subscribe("show_left_hero", ReceiveLeftHeroData);
      
  
      
      // 初始化英雄装备数组
      selfHero.equipment = [];
      opponentHero.equipment = [];
  
      // 初始化 AI 状态
      selfHero.aiEnabled = false;
      opponentHero.aiEnabled = true;
    }
  



    /*** 设置事件处理程序 ***/
    function setupEventHandlers() {
      // 模式菜单按钮点击事件
      modeMenuButton.SetPanelEvent("onactivate", onModeMenuButtonClick);
  
      // 英雄选择事件（使用防抖函数）
      let debouncedOnHeroSelected = debounce(onHeroSelected, 0.3);
      $.RegisterEventHandler('DOTAUIHeroPickerHeroSelected', $('#HeroPicker'), debouncedOnHeroSelected);
  
      // 英雄修改按钮
      $('#ModifySelfHeroButton').SetPanelEvent('onactivate', () => toggleFcHeroPickPanel('ModifySelfHero'));
      $('#ModifyOpponentHeroButton').SetPanelEvent('onactivate', () => toggleFcHeroPickPanel('ModifyOpponentHero'));
      $('#CancelButton').SetPanelEvent('onactivate', onCancelButtonClick);
  
      // 自己英雄 AI 开关
      $('#SelfHeroAIToggle').SetPanelEvent('onactivate', onSelfHeroAIToggle);
  
      // 对手英雄 AI 开关
      $('#OpponentHeroAIToggle').SetPanelEvent('onactivate', onOpponentHeroAIToggle);
  
      // 更换英雄按钮
      changeHeroButton.SetPanelEvent('onactivate', onChangeHeroButtonClick);
  
      // 添加物品按钮事件
      $('#AddSelfItemButton').SetPanelEvent('onactivate', () => openItemSelectionDialog('Self'));
      $('#AddOpponentItemButton').SetPanelEvent('onactivate', () => openItemSelectionDialog('Opponent'));
      
  
      // 确认和取消按钮事件
      $('#ConfirmItemSelectionButton').SetPanelEvent('onactivate', onConfirmItemSelection);
      $('#CancelItemSelectionButton').SetPanelEvent('onactivate', closeItemSelectionDialog);
      $('#ClearAllItemsButton').SetPanelEvent('onactivate', clearAllItems);
    }

    let currentHeroType = ''; // 用于记录当前是为哪个英雄添加物品


    function closeAllPanels() {
      // 关闭游戏模式选择面板
      $('#GameModeSelectionPanel').SetHasClass('Visible', false);
      
      // 关闭物品选择对话框
      $('#ItemSelectionDialog').style.visibility = 'collapse';
      
      // 关闭策略选择面板
      $('#StrategySelectionPanel').AddClass('GameSetupPanelhidden');
      
      // 最小化英雄选择面板
      $('#FcHeroPickPanel').AddClass('minimized');
  }

    function clearAllItems() {
      $.Msg("清除所有物品");
      const grids = ['NormalItemsGrid', 'NeutralItemsGrid', 'CustomItemsGrid', 'SpecialItemsGrid'];
      
      grids.forEach(gridId => {
          const grid = $(`#${gridId}`);
          if (!grid) {
              $.Msg(`Error: ${gridId} not found`);
              return;
          }
  
          grid.Children().forEach(itemEntry => {
              const quantityEntry = itemEntry.quantityEntry;
              if (quantityEntry) {
                  quantityEntry.text = '0';
              }
          });
      });
  
      // // 自动触发确认选择
      // onConfirmItemSelection();
  }

    function createItemEntry(item, itemGrid) {
        if (!itemGrid) {
            $.Msg("Error: itemGrid is null in createItemEntry");
            return;
        }
    
        const itemEntry = $.CreatePanel('Panel', itemGrid, '');
        itemEntry.AddClass('ItemEntry');
    
        const itemIcon = $.CreatePanel('DOTAItemImage', itemEntry, '');
        itemIcon.AddClass('ItemIcon');
        itemIcon.itemname = item.name;
    
        const itemNameLabel = $.CreatePanel('Label', itemEntry, '');
        itemNameLabel.AddClass('ItemName');
        itemNameLabel.text = $.Localize(`#DOTA_Tooltip_ability_${item.name}`);
    
        // 添加价格标签（如果有价格）
        if (item.cost > 0) {
            const costLabel = $.CreatePanel('Label', itemEntry, '');
            costLabel.AddClass('ItemCost');
            costLabel.text = item.cost;
        }
    
        const quantityEntry = $.CreatePanel('TextEntry', itemEntry, '');
        quantityEntry.AddClass('ItemQuantityEntry');
        quantityEntry.SetAttributeString('itemName', item.name);
        quantityEntry.SetAttributeString('itemId', item.id);
        quantityEntry.text = '0';
    
        itemEntry.quantityEntry = quantityEntry;
    
        return itemEntry;
    }
      
    
    

    function openItemSelectionDialog(heroType) {
      currentHeroType = heroType;
      closeAllPanels();
      
      const dialogPanel = $('#ItemSelectionDialog');
      if (!dialogPanel) {
          $.Msg("Error: ItemSelectionDialog not found");
          return;
      }
    
        const equipment = heroType === 'Self' ? selfHero.equipment : opponentHero.equipment;
    
        // 更新数量输入框的值
        const grids = ['NormalItemsGrid', 'NeutralItemsGrid', 'CustomItemsGrid', 'SpecialItemsGrid'];
        grids.forEach(gridId => {
            const grid = $(`#${gridId}`);
            if (!grid) {
                $.Msg(`Error: ${gridId} not found`);
                return;
            }
    
            grid.Children().forEach(itemEntry => {
                const quantityEntry = itemEntry.quantityEntry;
                const itemName = quantityEntry.GetAttributeString('itemName', '');
    
                let quantity = '0';
                const existingItem = equipment.find(e => e.name === itemName);
                if (existingItem) {
                    quantity = existingItem.count.toString();
                }
                quantityEntry.text = quantity;
            });
        });
    
        showTab('NormalItems');
    
        dialogPanel.style.visibility = 'visible';
        $.Msg("Item selection dialog opened and quantities updated");
    }
    
    

    function showTab(tabName) {
        currentTab = tabName;
        $('#NormalItemsGrid').style.visibility = (tabName === 'NormalItems') ? 'visible' : 'collapse';
        $('#NeutralItemsGrid').style.visibility = (tabName === 'NeutralItems') ? 'visible' : 'collapse';
        $('#CustomItemsGrid').style.visibility = (tabName === 'CustomItems') ? 'visible' : 'collapse';
        $('#SpecialItemsGrid').style.visibility = (tabName === 'SpecialItems') ? 'visible' : 'collapse';  // 控制特殊物品网格的可见性
        $('#NormalItemsTab').SetHasClass('ActiveTab', tabName === 'NormalItems');
        $('#NeutralItemsTab').SetHasClass('ActiveTab', tabName === 'NeutralItems');
        $('#CustomItemsTab').SetHasClass('ActiveTab', tabName === 'CustomItems');
        $('#SpecialItemsTab').SetHasClass('ActiveTab', tabName === 'SpecialItems');  // 设置特殊物品标签页的激活状态
    }
    // 添加事件监听器
    $('#NormalItemsTab').SetPanelEvent('onactivate', () => showTab('NormalItems'));
    $('#NeutralItemsTab').SetPanelEvent('onactivate', () => showTab('NeutralItems'));
    $('#CustomItemsTab').SetPanelEvent('onactivate', () => showTab('CustomItems'));
    $('#SpecialItemsTab').SetPanelEvent('onactivate', () => showTab('SpecialItems'));  // 添加特殊物品标签页的事件监听器

    function closeItemSelectionDialog() {
        $('#ItemSelectionDialog').style.visibility = 'collapse';
    }
    /*** 事件处理程序 ***/
    
  
    // 取消按钮点击
    function onCancelButtonClick() {
      GameModeMainPanel.style.visibility = "collapse";
    }
  
    // 自己英雄 AI 开关变化
    function onSelfHeroAIToggle() {
      const aiToggle = $('#SelfHeroAIToggle');
      const strategyRow = $('#SelfHeroRow4');

      selfHero.aiEnabled = aiToggle.IsSelected();
      $.Msg("自己英雄 AI " + (selfHero.aiEnabled ? "已开启" : "已关闭"));

      if (strategyRow) {
        if (selfHero.aiEnabled) {
          strategyRow.RemoveClass('GameSetupPanelhidden');
        } else {
          strategyRow.AddClass('GameSetupPanelhidden');
        }
      }
    }
    // 对手英雄 AI 开关变化
    function onOpponentHeroAIToggle() {
      var aiToggle = $('#OpponentHeroAIToggle');
      var strategyRows = $('#OpponentHeroRow').FindChildrenWithClassTraverse('GameSetupPanelSettingsRow4');
      
      opponentHero.aiEnabled = aiToggle.checked;
      $.Msg("对手英雄 AI " + (opponentHero.aiEnabled ? "已开启" : "已关闭"));
      
      // 根据AI开关状态控制策略选项的显示
      strategyRows.forEach(function(row) {
        if (opponentHero.aiEnabled) {
          row.RemoveClass('GameSetupPanelhidden');
        } else {
          row.AddClass('GameSetupPanelhidden');
        }
      });
      
      // 在此处添加其他处理 AI 开启/关闭的逻辑
    }
  
      function onModeMenuButtonClick() {
        $.Msg("模式菜单按钮被点击");
        toggleVisibility(GameModeMainPanel);
        
        // 请求服务器发送游戏模式数据
        GameEvents.SendCustomGameEventToServer("fc_custom_event", { "SendGameModesData": "1" });
        
        // 检查是否已经有物品数据，如果没有且未请求过，则请求物品数据
        if (itemList.length === 0 && !itemDataRequested) {
            $.Msg("正在向服务器请求物品数据");
            GameEvents.SendCustomGameEventToServer("fc_custom_event", { "RequestItemData": "1" });
            itemDataRequested = true;  // 设置标志为已请求
        } else {
            $.Msg("物品数据已存在或之前已请求过");
        }
        
        // 检查是否已经有策略数据，如果没有且未请求过，则请求策略数据
        if (!strategyDataRequested) {
            $.Msg("正在向服务器请求策略数据");
            GameEvents.SendCustomGameEventToServer("fc_custom_event", { "RequestStrategyData": "1" });
            strategyDataRequested = true;  // 设置标志为已请求
        } else {
            $.Msg("策略数据已请求过");
        }
    }

    // 更换英雄按钮点击
    function onChangeHeroButtonClick() {
      if (checkAllSelectionsComplete()) {
        // 显示 HUD 元素
        showHUDElements();
  
        // 发送英雄数据到 Lua 后端
        sendHeroDataToLua();
  
        // 隐藏主要的游戏模式面板
        GameModeMainPanel.style.visibility = "collapse";
      }
    }
  
    // 接收到服务器发送的游戏模式数据
    function onInitializeGameModes(event) {
      gameModes = Object.values(event);
      updateGameModes();
      modifyButton.SetPanelEvent('onactivate', toggleGameModeSelection);
  }
  
  
  // 添加全局变量控制动画状态


  // 添加切换按钮事件处理
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

  // 更新按钮状态和文本
  function updateAnimationButtonState() {
      const toggleLabel = $('#ToggleAnimationButtonLabel');
      if (toggleLabel) {
          toggleLabel.text = isAnimationEnabled ? "关闭入场动画" : "开启入场动画";
      }
  }

  // 修改展示英雄的函数
  function onShowHero(event) {
      if (!isAnimationEnabled) {
          $.Msg("入场动画已关闭，跳过动画展示");
          return;
      }

      showHeroVersus(
          selfHero.heroId,
          opponentHero.heroId,
          event.selfFacets,
          event.opponentFacets,
          event.Time
      );
  }

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
    /*** 实用函数 ***/
  

    let selectedSelfOverallStrategy = { name: "默认策略", id: "default_strategy" };
    let selectedSelfHeroStrategy = { name: "默认策略", id: "default_strategy" };
    let selectedOpponentOverallStrategy = { name: "默认策略", id: "default_strategy" };
    let selectedOpponentHeroStrategy = { name: "默认策略", id: "default_strategy" };

    // 防抖函数，限制函数调用频率
    function debounce(func, wait) {
      let scheduleId = null;
      return function executedFunction(...args) {
        const later = () => {
          scheduleId = null;
          func(...args);
        };
        if (scheduleId !== null) {
          $.CancelScheduled(scheduleId);
        }
        scheduleId = $.Schedule(wait, later);
      };
    }
  
    // 切换面板的可见性
    function toggleVisibility(panel) {
      panel.style.visibility = panel.style.visibility === "visible" ? "collapse" : "visible";
    }
  
    // 显示之前隐藏的 HUD 元素
    function showHUDElements() {
      const panelsToToggle = ["ButtonBar", "lower_hud"];
      panelsToToggle.forEach(panelName => {
        const panel = hud.FindChildTraverse(panelName);
        if (panel) {
          panel.visible = true;
        }
      });
      $("#CustomHeroStatsRoot").AddClass("hidden");

      $("#HUDContainer").AddClass("hidden");
      var element = $("#CustomHeroStatsRoot");
      if (element && element.length > 0) {
          element.AddClass("hidden");
      } else {
          $.Msg("Element #CustomHeroStatsRoot not found");
      }
    }
  
    // 检查所有必需的选择是否已完成
    function checkAllSelectionsComplete() {
      const gameMode = currentGameModeLabel.text;
      const isSelfHeroSelected = selfHero.heroId !== -1 && selfHero.facetId !== -1;
      const isOpponentHeroSelected = opponentHero.heroId !== -1 && opponentHero.facetId !== -1;
      
      const modeData = gameModes.find(function(mode) {
          return mode.name === gameMode;
      });
      
      // 转换menuConfig为数组
      let requiredSelections = [];
      if (modeData && modeData.menuConfig) {
          requiredSelections = Object.values(modeData.menuConfig);
      }
      
      let allSelectionsComplete = gameMode !== '未选择';
      
      if (allSelectionsComplete && requiredSelections.length > 0) {
          for (let i = 0; i < requiredSelections.length; i++) {
              const item = requiredSelections[i];
              let isComplete = false;
              
              if (item === 'SelfHeroRow') {
                  isComplete = isSelfHeroSelected;
              } else if (item === 'OpponentHeroRow') {
                  isComplete = isOpponentHeroSelected;
              }
              
              if (!isComplete) {
                  allSelectionsComplete = false;
                  break;
              }
          }
      }
  
      changeHeroButton.enabled = allSelectionsComplete;
      changeHeroButton.SetHasClass('Disabled', !allSelectionsComplete);
  
      if (!allSelectionsComplete) {
          changeHeroButton.SetPanelEvent('onmouseover', function() {
              $.DispatchEvent('DOTAShowTextTooltip', changeHeroButton, '请选择英雄和游戏模式');
          });
          changeHeroButton.SetPanelEvent('onmouseout', function() {
              $.DispatchEvent('DOTAHideTextTooltip');
          });
      } else {
          changeHeroButton.ClearPanelEvent('onmouseover');
          changeHeroButton.ClearPanelEvent('onmouseout');
      }
  
      return allSelectionsComplete;
  }
  
    // 切换英雄选择面板
    function toggleFcHeroPickPanel(action) {
      const fcHeroPickPanel = $('#FcHeroPickPanel');
      
      if (fcHeroPickPanel.BHasClass('minimized')) {
          closeAllPanels();
          fcHeroPickPanel.RemoveClass('minimized');
          GameEvents.GameSetup.currentAction = action;
      } else {
          fcHeroPickPanel.AddClass('minimized');
      }
  }
  
    function onHeroSelected(heroId, facetId) {
      // $.Msg("接收到的英雄 ID：", heroId);
      // $.Msg("接收到的 Facet ID：", facetId);
    
      const action = GameEvents.GameSetup.currentAction;
      if (action === 'ModifySelfHero') {
        selfHero.heroId = heroId;
        selfHero.facetId = facetId;
        selectedSelfHeroStrategy = { name: "默认策略", id: "default_strategy" };
        lastSelectedSelfHeroStrategies = []; // 清空缓存选择
        updateHeroLabel($('#SelfHeroLabel'), heroId, facetId);
    
        // 显示 SelfHeroRow 及其子面板
        const selfHeroRow = $('#SelfHeroRow');
        if (selfHeroRow) {
          selfHeroRow.RemoveClass('GameSetupPanelhidden');
          // $.Msg("Removed GameSetupPanelhidden class from SelfHeroRow");
    
          // 显示 SelfHeroRow3
          const settingsRow3 = $('#SelfHeroRow3');
          if (settingsRow3) {
            settingsRow3.RemoveClass('GameSetupPanelhidden');
            // $.Msg("Removed GameSetupPanelhidden class from SelfHeroRow3");
          } else {
            // $.Msg("Warning: SelfHeroRow3 not found");
          }
        } else {
          // $.Msg("Error: SelfHeroRow not found");
        }
    
        // 更新英雄策略标签
        updateHeroStrategyLabel(heroId,"Self");
      } else if (action === 'ModifyOpponentHero') {
        opponentHero.heroId = heroId;
        opponentHero.facetId = facetId;
        selectedOpponentHeroStrategy = { name: "默认策略", id: "default_strategy" };
        lastSelectedOpponentHeroStrategies = []; // 清空缓存选择
        updateHeroLabel($('#OpponentHeroLabel'), heroId, facetId);
    
        // 显示 OpponentHeroRow 及其子面板
        const opponentHeroRow = $('#OpponentHeroRow');
        if (opponentHeroRow) {
          opponentHeroRow.RemoveClass('GameSetupPanelhidden');
          // $.Msg("Removed GameSetupPanelhidden class from OpponentHeroRow");
    
          // 显示 OpponentHeroRow3
          const opponentRow3 = $('#OpponentHeroRow3');
          const opponentRow4 = $('#OpponentHeroRow4');
          if (opponentRow3) {
            opponentRow3.RemoveClass('GameSetupPanelhidden');
            opponentRow4.RemoveClass('GameSetupPanelhidden');
            // $.Msg("Removed GameSetupPanelhidden class from OpponentHeroRow3");
          } else {
            // $.Msg("Warning: OpponentHeroRow3 not found");
          }
        } else {
          // $.Msg("Error: OpponentHeroRow not found");
        }
    
        // 更新对手英雄策略标签
        updateHeroStrategyLabel(heroId, 'opponent');
      }
    
      // 最小化英雄选择面板
      if (fcHeroPickPanel) {
        fcHeroPickPanel.AddClass('minimized');
      } else {
        $.Msg("Warning: fcHeroPickPanel not found");
      }
      checkAllSelectionsComplete();
    }
    
    // 更新英雄标签，显示选定的英雄和 Facet
    function updateHeroLabel(label, heroId, facetId) {
      const heroName = heroData[heroId] ? heroData[heroId].name : "未知英雄";
      const displayText = `${heroName} - ${facetId}`;
      label.text = displayText;
    }






          
      // 接收策略数据
      GameEvents.Subscribe("initialize_strategy_data", function(data) {
        // $.Msg("Received strategy data:");
        // $.Msg(JSON.stringify(data, null, 2));

        // 处理全局策略
        globalStrategies = Object.values(data.global_strategies || {});

        // 处理英雄策略
        heroStrategies = {};
        for (let heroId in data.hero_strategies) {
            heroStrategies[heroId] = Object.values(data.hero_strategies[heroId]);
        }

        // $.Msg("Processed Global Strategies:");
        // $.Msg(JSON.stringify(globalStrategies, null, 2));

        // $.Msg("Processed Hero Strategies:");
        // $.Msg(JSON.stringify(heroStrategies, null, 2));

        updateStrategyUI();

        // $.Msg("Strategy UI updated");
      });

    
      function updateStrategyUI() {
        // 更新自己的整体策略
        const selfOverallStrategyNames = Array.isArray(selectedSelfOverallStrategy)
            ? selectedSelfOverallStrategy.map(s => s.name).join(', ')
            : selectedSelfOverallStrategy.name;
        $('#SelfOverallStrategyLabel').text = selfOverallStrategyNames;
        
        // 更新对手的整体策略
        const opponentOverallStrategyNames = Array.isArray(selectedOpponentOverallStrategy)
            ? selectedOpponentOverallStrategy.map(s => s.name).join(', ')
            : selectedOpponentOverallStrategy.name;
        $('#OpponentOverallStrategyLabel').text = opponentOverallStrategyNames;
        
        // 更新自己的英雄策略
        if (selfHero.heroId) {
            const selfHeroStrategyNames = Array.isArray(selectedSelfHeroStrategy)
                ? selectedSelfHeroStrategy.map(s => s.name).join(', ')
                : selectedSelfHeroStrategy.name;
            $('#SelfHeroStrategyLabel').text = selfHeroStrategyNames;
        }
        
        // 更新对手的英雄策略
        if (opponentHero.heroId) {
            const opponentHeroStrategyNames = Array.isArray(selectedOpponentHeroStrategy)
                ? selectedOpponentHeroStrategy.map(s => s.name).join(', ')
                : selectedOpponentHeroStrategy.name;
            $('#OpponentHeroStrategyLabel').text = opponentHeroStrategyNames;
        }
    }
    
    
    function updateOverallStrategyLabel(player) {
      const defaultStrategy = { name: "默认策略", id: "default_strategy" };
      const labelId = player === 'Self' ? '#SelfOverallStrategyLabel' : '#OpponentOverallStrategyLabel';
      $(labelId).text = defaultStrategy.name;
  }
  
  
    
    function updateHeroStrategyLabel(heroId, player) {
      const defaultStrategy = { name: "默认策略", id: "default_strategy" };
      const labelId = player === 'Self' ? '#SelfHeroStrategyLabel' : '#OpponentHeroStrategyLabel';
      $(labelId).text = defaultStrategy.name;
  }


  


  let lastSelectedSelfOverallStrategies = [];
  let lastSelectedSelfHeroStrategies = [];
  let lastSelectedOpponentOverallStrategies = [];
  let lastSelectedOpponentHeroStrategies = [];
  

  function createStrategyToggle(strategy, strategyList, isSelected) {
      const strategyToggle = $.CreatePanel('ToggleButton', strategyList, '');
      strategyToggle.AddClass('StrategyToggle');
      strategyToggle.checked = isSelected;
  
      const strategyLabel = $.CreatePanel('Label', strategyToggle, '');
      strategyLabel.text = strategy.name;
  
      return strategyToggle;
  }
  
  function toggleStrategySelectionPanel(strategies, onStrategySelected, currentStrategy, lastSelectedStrategiesRef) {
    const strategyPanel = $('#StrategySelectionPanel');
    
    // 修改点：强制关闭所有其他面板
    closeAllPanels();
    
    if (strategyPanel.BHasClass('GameSetupPanelhidden')) {
        const strategyList = $('#StrategyList');
        strategyList.RemoveAndDeleteChildren();

        const selectedStrategies = Array.isArray(currentStrategy) ? currentStrategy : [currentStrategy];
        const selectedIds = selectedStrategies.map(s => s.id);

        for (let i = 0; i < strategies.length; i++) {
            const strategy = strategies[i];
            const isSelected = selectedIds.includes(strategy.id) || lastSelectedStrategiesRef.includes(strategy.id);
            createStrategyToggle(strategy, strategyList, isSelected);
        }

        // 获取确认按钮并添加事件监听
        const confirmButton = $('#ConfirmStrategySelection');
        confirmButton.SetPanelEvent('onactivate', function() {
            const selectedStrategies = strategies.filter((_, index) => 
                strategyList.GetChild(index).checked
            );
            lastSelectedStrategiesRef.length = 0;
            Array.prototype.push.apply(lastSelectedStrategiesRef, selectedStrategies.map(s => s.id));
            onStrategySelected(selectedStrategies.length === 1 ? selectedStrategies[0] : selectedStrategies);
            strategyPanel.AddClass('GameSetupPanelhidden');
        });
        
        // 修改点：始终先关闭再打开
        strategyPanel.RemoveClass('GameSetupPanelhidden');
    } else {
        strategyPanel.AddClass('GameSetupPanelhidden');
    }
}


    // 绑定按钮点击事件
    $('#ModifySelfOverallStrategyButton').SetPanelEvent('onactivate', onModifySelfOverallStrategy);
    $('#ModifySelfHeroStrategyButton').SetPanelEvent('onactivate', onModifySelfHeroStrategy);
    // 设置修改对手英雄策略按钮的事件处理程序
    $('#ModifyOpponentHeroStrategyButton').SetPanelEvent('onactivate', onModifyOpponentHeroStrategy);

    // 设置修改对手整体策略按钮的事件处理程序
    $('#ModifyOpponentOverallStrategyButton').SetPanelEvent('onactivate', onModifyOpponentOverallStrategy);


    function onModifyOpponentHeroStrategy() {
      if (!opponentHero.heroId) return;
  
      const heroSpecificStrategies = heroStrategies[opponentHero.heroId] || [];
      const strategies = [{ name: "默认策略", id: "default_strategy" }].concat(heroSpecificStrategies);
  
      toggleStrategySelectionPanel(strategies, function(strategies) {
          selectedOpponentHeroStrategy = Array.isArray(strategies) ? strategies : [strategies];
          $('#OpponentHeroStrategyLabel').text = selectedOpponentHeroStrategy.map(s => s.name).join(', ');
      }, selectedOpponentHeroStrategy, lastSelectedOpponentHeroStrategies);
  }
  
      // 修改英雄策略的功能
      function onModifySelfHeroStrategy() {
        if (!selfHero.heroId) return;
    
        const heroSpecificStrategies = heroStrategies[selfHero.heroId] || [];
        const strategies = [{ name: "默认策略", id: "default_strategy" }].concat(heroSpecificStrategies);
    
        toggleStrategySelectionPanel(strategies, function(strategies) {
            selectedSelfHeroStrategy = Array.isArray(strategies) ? strategies : [strategies];
            $('#SelfHeroStrategyLabel').text = selectedSelfHeroStrategy.map(s => s.name).join(', ');
        }, selectedSelfHeroStrategy, lastSelectedSelfHeroStrategies);
    }
  

    function onModifyOpponentOverallStrategy() {
      toggleStrategySelectionPanel(globalStrategies, function(strategies) {
          selectedOpponentOverallStrategy = Array.isArray(strategies) ? strategies : [strategies];
          $('#OpponentOverallStrategyLabel').text = selectedOpponentOverallStrategy.map(s => s.name).join(', ');
      }, selectedOpponentOverallStrategy, lastSelectedOpponentOverallStrategies);
  }


    // 修改整体策略的功能
    function onModifySelfOverallStrategy() {
      toggleStrategySelectionPanel(globalStrategies, function(strategies) {
          selectedSelfOverallStrategy = Array.isArray(strategies) ? strategies : [strategies];
          $('#SelfOverallStrategyLabel').text = selectedSelfOverallStrategy.map(s => s.name).join(', ');
      }, selectedSelfOverallStrategy, lastSelectedSelfOverallStrategies);
  }
  
  

  function sendHeroDataToLua() {
    $.Msg("开始发送英雄数据到 Lua 后端");
    $.Msg("当前挑战类型: " + currentChallengeType);

    if (currentChallengeType !== '') {
        // 转换自己的装备数据
        const simplifiedSelfEquipment = selfHero.equipment.map(item => ({
            name: item.name,
            count: item.count
        }));

        // 转换对手的装备数据
        const simplifiedOpponentEquipment = opponentHero.equipment.map(item => ({
            name: item.name,
            count: item.count
        }));

        // 处理策略数据
        const processStrategies = (strategies) => {
            if (!strategies || !Array.isArray(strategies)) {
                return ["默认策略"];
            }
            return strategies.map(s => s.name);
        };

        // 准备要发送的数据
        const eventData = {
            event: 'ChangeHeroRequest',
            selfHeroId: selfHero.heroId,
            selfFacetId: selfHero.facetId,
            opponentHeroId: opponentHero.heroId,
            opponentFacetId: opponentHero.facetId,
            challengeType: currentChallengeType,
            selfAIEnabled: Boolean(selfHero.aiEnabled),
            opponentAIEnabled: Boolean(opponentHero.aiEnabled),
            selfEquipment: simplifiedSelfEquipment,
            opponentEquipment: simplifiedOpponentEquipment,
            selfOverallStrategies: processStrategies(selectedSelfOverallStrategy),
            selfHeroStrategies: processStrategies(selectedSelfHeroStrategy),
            opponentOverallStrategies: processStrategies(selectedOpponentOverallStrategy),
            opponentHeroStrategies: processStrategies(selectedOpponentHeroStrategy)
        };

        // 发送数据到服务器
        GameEvents.SendCustomGameEventToServer("ChangeHeroRequest", eventData);

        $.Msg(JSON.stringify(eventData, null, 2));
    } else {
        $.Msg("警告: 挑战类型为空，无法发送数据");
    }
}
    function onConfirmItemSelection() {
      $.Msg("开始确认物品选择");
      const grids = ['NormalItemsGrid', 'NeutralItemsGrid', 'CustomItemsGrid', 'SpecialItemsGrid'];
      const items = [];
    
      grids.forEach(gridId => {
        const grid = $(`#${gridId}`);
        if (!grid) {
          $.Msg(`警告: ${gridId} 未找到`);
          return;
        }
    
        grid.Children().forEach(itemEntry => {
          const quantityEntry = itemEntry.quantityEntry;
    
          if (!quantityEntry) {
            $.Msg("警告: 未找到物品的数量条目");
            return;
          }
    
          const quantityText = quantityEntry.text;
          const quantity = parseInt(quantityText);
    
          if (quantity > 0) {
            const itemName = quantityEntry.GetAttributeString('itemName', '');
            const itemId = quantityEntry.GetAttributeString('itemId', '');
    
            items.push({
              name: itemName,
              id: itemId,
              count: quantity
            });
          }
        });
      });
    
      // 将选择的物品直接覆盖对应的英雄装备列表，防止重复添加
      if (currentHeroType === 'Self') {
        selfHero.equipment = items;
      } else if (currentHeroType === 'Opponent') {
        opponentHero.equipment = items;
      }

      // 关闭物品选择对话框
      closeItemSelectionDialog();

      // 更新UI，显示已选择的物品
      updateSelectedItemsUI(currentHeroType);

      // 打印调试信息
      $.Msg("物品选择确认完成，已选择 " + items.length + " 个物品");
      items.forEach(item => {
        $.Msg("  - " + item.name + " x " + item.count);
      });
    }
    
    
    function updateSelectedItemsUI(heroType) {
      $.Msg("开始更新 " + heroType + " 的物品 UI");
      const itemPanelId = heroType === 'Self' ? 'SelfHeroItemPanel' : 'OpponentHeroItemPanel';
      $.Msg("使用面板 ID: " + itemPanelId);
      const itemPanel = $('#' + itemPanelId);

      // 清空当前显示
      itemPanel.RemoveAndDeleteChildren();

      const equipment = heroType === 'Self' ? selfHero.equipment : opponentHero.equipment;

      equipment.forEach(item => {
        const itemEntry = $.CreatePanel('Panel', itemPanel, '');
        itemEntry.AddClass('HeroEquipmentItemEntry');

        // 物品图标
        const itemIcon = $.CreatePanel('DOTAItemImage', itemEntry, '');
        itemIcon.AddClass('HeroEquipmentItemIcon');
        itemIcon.itemname = item.name;

        // 物品数量
        if (item.count > 1) {
          const itemCountLabel = $.CreatePanel('Label', itemEntry, '');
          itemCountLabel.AddClass('HeroEquipmentItemCount');
          itemCountLabel.text = `x${item.count}`;
        }

        // // 物品名称
        // const itemNameLabel = $.CreatePanel('Label', itemEntry, '');
        // itemNameLabel.AddClass('HeroEquipmentItemName');
        // itemNameLabel.text = $.Localize(`#DOTA_Tooltip_ability_${item.name}`);
      });

      $.Msg("物品 UI 更新完成，总共显示 " + equipment.length + " 个物品");
    }
        


      // 更新游戏模式选择面板中的游戏模式
      function updateGameModes() {
        // 清除现有的按钮
        selectionPanel.RemoveAndDeleteChildren();
    
        // 按category对游戏模式进行分组
        const categorizedModes = {};
        gameModes.forEach(mode => {
            if (!categorizedModes[mode.category]) {
                categorizedModes[mode.category] = [];
            }
            categorizedModes[mode.category].push(mode);
        });
    
        // 定义category的显示顺序和显示名称
        const categoryOrder = {
            "test": { order: 1, name: "测试模式" },
            "creep": { order: 2, name: "刷兵模式" },
            "single": { order: 3, name: "单人模式" },
            "multiplayer": { order: 4, name: "多人模式" }
            // 可以根据需要添加更多类别
        };
    
        // 按照定义的顺序创建分类
        Object.entries(categorizedModes)
            .sort(([catA], [catB]) => {
                const orderA = categoryOrder[catA]?.order || 999;
                const orderB = categoryOrder[catB]?.order || 999;
                return orderA - orderB;
            })
            .forEach(([category, modes]) => {
                // 创建分类容器
                const categoryContainer = $.CreatePanel('Panel', selectionPanel, '');
                categoryContainer.AddClass('CategoryContainer');
    
                // 创建分类标题
                const categoryTitle = $.CreatePanel('Label', categoryContainer, '');
                categoryTitle.AddClass('CategoryTitle');
                categoryTitle.text = categoryOrder[category]?.name || category;
    
                // 创建一行用于放置模式按钮
                let currentRow = $.CreatePanel('Panel', categoryContainer, '');
                currentRow.AddClass('ModesRow');
                
                // 每行最多放置3个模式按钮
                const MODES_PER_ROW = 4;
                modes.forEach((mode, index) => {
                    if (index > 0 && index % MODES_PER_ROW === 0) {
                        currentRow = $.CreatePanel('Panel', categoryContainer, '');
                        currentRow.AddClass('ModesRow');
                    }
    
                    const button = $.CreatePanel('Button', currentRow, '');
                    button.AddClass('GameModeOption');
    
                    const label = $.CreatePanel('Label', button, '');
                    label.text = mode.name;
    
                    button.SetPanelEvent('onactivate', () => {
                        selectGameMode(mode.code, mode.name);
                    });
                });
            });
    }
  
    // 切换游戏模式选择面板的可见性
    function toggleGameModeSelection() {
      const selectionPanel = $('#GameModeSelectionPanel');
      const isVisible = selectionPanel.BHasClass('Visible');
      
      if (!isVisible) {
          closeAllPanels();
          selectionPanel.SetHasClass('Visible', true);
      } else {
          selectionPanel.SetHasClass('Visible', false);
      }
  }
  
    // 从选择面板中选择游戏模式
    function selectGameMode(code, name) {
      currentGameModeLabel.text = name;
      selectionPanel.SetHasClass('Visible', false);
      onGameModeChanged(code, name);
      checkAllSelectionsComplete();
    }
  
    // 当选择新的游戏模式时进行处理
    function onGameModeChanged(code, name) {
      $.Msg(`游戏模式已更改为：${name}（代码：${code}）`);
      currentChallengeType = code;
      $("#RoundCounter").text = name;
      updateGameModeUI(name);
    }
  
    // 根据选定的游戏模式更新 UI
    function updateGameModeUI(modeName) {
      const allMenuItems = ['SelfHeroRow', 'OpponentHeroRow'];
      
      $.Msg("Current mode name:", modeName);
      
      const modeData = gameModes.find(function(mode) {
          return mode.name === modeName;
      });
      
      $.Msg("Mode data:", JSON.stringify(modeData));
      
      // 将对象形式的menuConfig转换为数组
      let visibleItems = [];
      if (modeData && modeData.menuConfig) {
          if (modeData.menuConfigType === "array") {
              // 如果是带有类型标记的格式
              visibleItems = Object.values(modeData.menuConfig);
          } else {
              // 处理旧格式
              visibleItems = Object.values(modeData.menuConfig);
          }
      }
      
      $.Msg("Visible items after conversion:", JSON.stringify(visibleItems));
  
      allMenuItems.forEach(function(item) {
          const panel = $('#' + item);
          if (panel) {
              let isVisible = visibleItems.indexOf(item) !== -1;
              panel.style.visibility = isVisible ? 'visible' : 'collapse';
              $.Msg("Setting visibility for", item, "to", isVisible ? 'visible' : 'collapse');
          }
      });
  }
  
  })();
  