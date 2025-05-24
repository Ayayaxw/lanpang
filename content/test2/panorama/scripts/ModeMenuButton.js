(function () {
    'use strict';

    // 技能等级默认值常量定义
    const DEFAULT_SKILL_LEVELS = {
        BASIC_SKILLS: 0,      // 技能1-3的默认等级
        ULTIMATE_SKILL: 0,    // 终极技能（技能6）的默认等级
        OTHER_SKILLS: 0       // 其他技能（技能4-5）的默认等级
    };
    
    // 技能等级最大值常量定义
    const MAX_SKILL_LEVELS = {
        BASIC_SKILLS: 4,      // 技能1-3的最大等级
        ULTIMATE_SKILL: 3,    // 终极技能（技能6）的最大等级
        OTHER_SKILLS: 0       // 其他技能（技能4-5）的最大等级
    };
    
    // 判断技能是否为终极技能
    function isUltimateSkill(skillIndex) {
        return skillIndex === 6;
    }
    
    // 获取技能的默认等级
    function getDefaultSkillLevel(skillIndex) {
        if (isUltimateSkill(skillIndex)) {
            return DEFAULT_SKILL_LEVELS.ULTIMATE_SKILL;
        } else if (skillIndex <= 3) {
            return DEFAULT_SKILL_LEVELS.BASIC_SKILLS;
        } else {
            return DEFAULT_SKILL_LEVELS.OTHER_SKILLS;
        }
    }
    
    // 获取技能的最大等级
    function getMaxSkillLevel(skillIndex) {
        if (isUltimateSkill(skillIndex)) {
            return MAX_SKILL_LEVELS.ULTIMATE_SKILL;
        } else if (skillIndex <= 3) {
            return MAX_SKILL_LEVELS.BASIC_SKILLS;
        } else {
            return MAX_SKILL_LEVELS.OTHER_SKILLS;
        }
    }

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


    let currentPanelType = 'Default';  // 添加面板类型判断
    // 添加存储自定义英雄装备的对象
    let customHeroEquipment = {};
    // 添加存储自定义英雄策略的对象
    let customHeroStrategies = {};
    // 添加存储自定义英雄的对象
    let customHeroes = {};


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

        

    GameEvents.Subscribe("initialize_game_modes", onInitializeGameModes);

    GameEvents.Subscribe("initialize_strategy_data", function(data) {
        globalStrategies = Object.values(data.global_strategies || {});

        heroStrategies = {};
        for (let heroId in data.hero_strategies) {
            heroStrategies[heroId] = Object.values(data.hero_strategies[heroId]);
        }
        //updateStrategyUI();

      });


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

      // 初始化英雄装备数组
      if (!customHeroEquipment['SelfHero']) {
          customHeroEquipment['SelfHero'] = [];
      }
      if (!customHeroEquipment['OpponentHero']) {
          customHeroEquipment['OpponentHero'] = [];
      }
  
      // 初始化 AI 状态 - 使用customHeroes对象统一管理
      if (!customHeroes['SelfHero']) {
          customHeroes['SelfHero'] = {
              heroId: '',
              facetId: -1,
              heroName: '未选择英雄',
              aiEnabled: false
          };
      }
      
      if (!customHeroes['OpponentHero']) {
          customHeroes['OpponentHero'] = {
              heroId: '',
              facetId: -1,
              heroName: '未选择英雄',
              aiEnabled: true  // 对手默认开启AI
          };
      }
      
      // 初始化策略数据
      if (!customHeroStrategies['SelfHero']) {
          customHeroStrategies['SelfHero'] = {
              overall: { name: "默认策略", id: "default_strategy" },
              hero: { name: "默认策略", id: "default_strategy" }
          };
      }
      
      if (!customHeroStrategies['OpponentHero']) {
          customHeroStrategies['OpponentHero'] = {
              overall: { name: "默认策略", id: "default_strategy" },
              hero: { name: "默认策略", id: "default_strategy" }
          };
      }
    }
  

    /*** 设置事件处理程序 ***/
    function setupEventHandlers() {
      // 模式菜单按钮点击事件
      modeMenuButton.SetPanelEvent("onactivate", onModeMenuButtonClick);
  
      // 定义防抖处理函数
      let debouncedOnHeroSelected = debounce(onHeroSelected, 0.1);
      
      // 移除任何现有的事件处理器，确保不会重复
      try {
        $.UnregisterForUnhandledEvent('DOTAUIHeroPickerHeroSelected', $('#HeroPicker'));
      } catch (e) {
        // 忽略错误，如果事件未注册
        $.Msg("初始化时移除事件处理器出错:", e);
      }

  

      $('#CancelButton').SetPanelEvent('onactivate', onCancelButtonClick);
  
      changeHeroButton.SetPanelEvent('onactivate', onChangeHeroButtonClick);
  
      // 确认和取消按钮事件
      $('#ConfirmItemSelectionButton').SetPanelEvent('onactivate', onConfirmItemSelection);
      $('#CancelItemSelectionButton').SetPanelEvent('onactivate', closeItemSelectionDialog);
      $('#ClearAllItemsButton').SetPanelEvent('onactivate', clearAllItems);

      // 新增测试按钮事件
      //$('#AddNewHeroButton').SetPanelEvent('onactivate', addNewHeroPanel);
    }

    let currentHeroType = ''; // 用于记录当前是为哪个英雄添加物品


    function closeAllPanels(excludeHeroId) {
      // 关闭游戏模式选择面板
      $('#GameModeSelectionPanel').SetHasClass('Visible', false);
      
      // 关闭物品选择对话框
      $('#ItemSelectionDialog').style.visibility = 'collapse';
      
      // 关闭策略选择面板
      $('#StrategySelectionPanel').AddClass('GameSetupPanelhidden');
      
      // 最小化英雄选择面板
      $('#FcHeroPickPanel').AddClass('minimized');
      
      // 关闭所有技能阈值面板，排除指定的英雄ID
      const allHeroes = Object.keys(customHeroes);
      allHeroes.forEach(heroId => {
        // 如果当前英雄ID是要排除的，则跳过
        if (excludeHeroId && heroId === excludeHeroId) {
          return;
        }
        
        const skillThresholdPanel = $(`#${heroId}SkillThresholdPanel`);
        if (skillThresholdPanel && !skillThresholdPanel.BHasClass('GameSetupPanelhidden')) {
          skillThresholdPanel.AddClass('GameSetupPanelhidden');
        }
      });
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


      
    
    

    function openItemSelectionDialog(heroType, panelType) {
      currentHeroType = heroType;
      currentPanelType = panelType || 'Default';  // 添加面板类型判断
      closeAllPanels();
      
      const dialogPanel = $('#ItemSelectionDialog');
      if (!dialogPanel) {
          $.Msg("Error: ItemSelectionDialog not found");
          return;
      }
    
      // 根据面板类型确定要使用的装备数据
      let equipment = [];
      if (panelType === 'Custom') {
          // 处理自定义英雄面板
          if (!customHeroEquipment[heroType]) {
              customHeroEquipment[heroType] = [];
          }
          equipment = customHeroEquipment[heroType];
          $.Msg(`使用自定义英雄 ${heroType} 的装备数据，共 ${equipment.length} 件物品`);
      } else {
          // 处理默认面板
          equipment = heroType === 'Self' ? selfHero.equipment : opponentHero.equipment;
      }
    
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


    function onModeMenuButtonClick() {
        $.Msg("模式菜单按钮被点击");
        
        if (GameModeMainPanel.style.visibility === "collapse") {
        // 检查并确保固定面板已经被创建
        if (!$('#SelfHeroRow') || !$('#OpponentHeroRow')) {

        }
        
        // 更新英雄标签和装备显示
        updateSelectedItemsUI('SelfHero', 'Player');
        updateSelectedItemsUI('OpponentHero', 'Player');
        
        // 请求服务器发送游戏模式数据
        GameEvents.SendCustomGameEventToServer("fc_custom_event", { "SendGameModesData": "1" });
        
        // 检查是否已经有物品数据，如果没有且未请求过，则请求物品数据
        if (Object.values(itemList).every(arr => arr.length === 0) && !itemDataRequested) {
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
        
        // 显示面板
        GameModeMainPanel.style.visibility = "visible";
        
        // 如果已有游戏模式，显示根据模式需要的面板
        updateGameModes();
        } else {
        // 直接隐藏面板
        GameModeMainPanel.style.visibility = "collapse";
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
        
        // 检查游戏模式是否已选择
        const gameModeSelected = gameMode && gameMode !== '未选择';
        if (!gameModeSelected) {
            changeHeroButton.SetHasClass('Disabled', true);
            return false;
        }
        
        // 查找当前游戏模式的配置
        const modeData = gameModes.find(function(mode) {
            return mode.name === gameMode;
        });
        
        // 获取当前模式需要的英雄类型
        const requiredHeroes = modeData && modeData.menuConfig ? Object.values(modeData.menuConfig) : [];
        
        // 检查需要的英雄是否都已选择
        let allRequiredHeroesSelected = true;
        
        // 只有当需要SelfHero时才检查
        if (requiredHeroes.includes('SelfHeroRow')) {
            const selfHeroSelected = customHeroes['SelfHero'] && customHeroes['SelfHero'].heroId && customHeroes['SelfHero'].heroId !== '';
            if (!selfHeroSelected) allRequiredHeroesSelected = false;
        }
        
        // 只有当需要OpponentHero时才检查
        if (requiredHeroes.includes('OpponentHeroRow')) {
            const opponentHeroSelected = customHeroes['OpponentHero'] && customHeroes['OpponentHero'].heroId && customHeroes['OpponentHero'].heroId !== '';
            if (!opponentHeroSelected) allRequiredHeroesSelected = false;
        }
        
        // 检查自定义英雄是否都已选择
        let allCustomHeroesSelected = true;
        Object.keys(customHeroes).forEach(heroId => {
            // 跳过SelfHero和OpponentHero，已单独检查
            if (heroId !== 'SelfHero' && heroId !== 'OpponentHero') {
                // 只检查当前模式需要的自定义英雄
                const customRowId = `${heroId}Row`;
                if (requiredHeroes.includes(customRowId)) {
                    if (!customHeroes[heroId].heroId || customHeroes[heroId].heroId === '') {
                        allCustomHeroesSelected = false;
                    }
                }
            }
        });
        
        // 综合判断所有选择是否完成
        const allSelectionsComplete = gameModeSelected && allRequiredHeroesSelected && allCustomHeroesSelected;
        
        $.Msg(`检查选择状态: 游戏模式=${gameModeSelected}, 需要的英雄都已选择=${allRequiredHeroesSelected}, 自定义英雄=${allCustomHeroesSelected}, 总体=${allSelectionsComplete}`);
        
        // 更新开始游戏按钮状态
        changeHeroButton.SetHasClass('Disabled', !allSelectionsComplete);

        return allSelectionsComplete;
    }
  
    // 切换英雄选择面板
    function toggleFcHeroPickPanel(action, heroId) {
      const fcHeroPickPanel = $('#FcHeroPickPanel');
      
      if (fcHeroPickPanel.BHasClass('minimized')) {
          closeAllPanels();
          fcHeroPickPanel.RemoveClass('minimized');
          if (!GameEvents.GameSetup) {
              GameEvents.GameSetup = {};
          }
          

          try {
              // 尝试获取所有注册到HeroPicker的处理函数并移除它们
              const heroPicker = $('#HeroPicker');
              if (heroPicker) {
                  // 移除所有DOTAUIHeroPickerHeroSelected事件处理器
                  $.UnregisterForUnhandledEvent('DOTAUIHeroPickerHeroSelected', heroPicker);
              }
          } catch (e) {
              $.Msg("移除事件处理器时出错:", e);
              // 错误处理，继续执行不中断
          }
          
          // 设置当前动作
          GameEvents.GameSetup.currentAction = action;
          
          // 判断是修改自定义英雄还是固定面板英雄
          if (action === 'ModifyCustomHero') {
              // 自定义英雄，记录当前操作的自定义英雄ID
              GameEvents.GameSetup.currentCustomHeroId = heroId;
              
              // 确保在自定义英雄对象中存在该英雄的记录
              if (!customHeroes[heroId]) {
                  customHeroes[heroId] = {
                      heroId: '',
                      facetId: -1,
                      heroName: '未选择英雄',
                      aiEnabled: false
                  };
              }
              
              // 注册新的事件处理器，确保只处理当前选中的自定义英雄面板
              $.RegisterEventHandler('DOTAUIHeroPickerHeroSelected', $('#HeroPicker'), (heroId, facetidraw) => {
                  // 只处理当前动作为ModifyCustomHero的情况
                  let facetId = facetidraw & 0xFFFFFFFF;
                  if (GameEvents.GameSetup.currentAction === 'ModifyCustomHero') {
                      // 获取当前操作的自定义英雄ID
                      const customHeroId = GameEvents.GameSetup.currentCustomHeroId;
                      $.Msg(`处理英雄选择事件：heroId=${heroId}, facetId=${facetId}, 当前自定义英雄ID=${customHeroId}`);
                      
                      if (customHeroId) {
                          // 获取当前英雄ID以检查是否发生更改
                          const currentHeroId = customHeroes[customHeroId]?.heroId || '';
                          const isHeroChanged = currentHeroId !== heroId && heroId !== '';
                          
                          // 获取当前AI状态（如果存在）
                          const currentAiState = customHeroes[customHeroId]?.aiEnabled;
                          
                          // 判断是否需要默认开启AI (只有在第一次选择英雄时才使用默认值)
                          const shouldEnableAI = currentAiState !== undefined ? currentAiState : (customHeroId !== 'SelfHero');
                          
                          // 更新自定义英雄数据 - 只更新当前选择的自定义英雄
                          if (!customHeroes[customHeroId]) {
                              customHeroes[customHeroId] = {
                                  heroId: heroId,
                                  facetId: facetId,
                                  heroName: getHeroName(heroId),
                                  aiEnabled: shouldEnableAI  // 使用确定的AI状态
                              };
                          } else {
                              customHeroes[customHeroId].heroId = heroId;
                              customHeroes[customHeroId].facetId = facetId;
                              customHeroes[customHeroId].heroName = getHeroName(heroId);
                              // 只有在首次选择英雄且AI状态未设置时才设置默认AI状态
                              if (currentHeroId === '' && currentAiState === undefined) {
                                  customHeroes[customHeroId].aiEnabled = shouldEnableAI;
                              }
                              // 其他情况保持原来的AI状态不变
                          }
                          
                          // 更新UI - 只更新对应面板的UI
                          const heroLabel = $(`#${customHeroId}Label`);
                          if (heroLabel) {
                              // 使用updateHeroLabel函数统一更新标签，确保显示命石信息
                              updateHeroLabel(heroLabel, heroId, facetId);
                              $.Msg(`更新面板 ${customHeroId} 的英雄标签，英雄ID=${heroId}, 命石ID=${facetId}`);
                          } else {
                              $.Msg(`错误：找不到英雄标签 #${customHeroId}Label`);
                          }
                          
                          // 显示物品行和AI开关
                          const heroRow3 = $(`#${customHeroId}Row3`);
                          if (heroRow3) {
                              heroRow3.RemoveClass('GameSetupPanelhidden');
                          }
                          
                          // 设置AI开关的状态
                          const aiToggle = $(`#${customHeroId}AIToggle`);
                          if (aiToggle) {
                              aiToggle.checked = customHeroes[customHeroId].aiEnabled;
                          }
                          
                          // 如果AI已开启或应该开启，显示策略行
                          if (customHeroes[customHeroId].aiEnabled) {
                              const heroRow4 = $(`#${customHeroId}Row4`);
                              if (heroRow4) {
                                  heroRow4.RemoveClass('GameSetupPanelhidden');
                              }
                          } else {
                              // 如果AI未开启，确保策略行隐藏
                              const heroRow4 = $(`#${customHeroId}Row4`);
                              if (heroRow4) {
                                  heroRow4.AddClass('GameSetupPanelhidden');
                              }
                          }
                          
                          // 无论AI是否开启，都调用updateStrategyRowVisibility来更新技能阈值按钮
                          updateStrategyRowVisibility(customHeroId);
                          
                          // 如果英雄已更改，重置英雄特定策略
                          if (isHeroChanged) {
                              if (customHeroStrategies[customHeroId]) {
                                  customHeroStrategies[customHeroId].hero = { name: "默认策略", id: "default_strategy" };
                              } else {
                                  customHeroStrategies[customHeroId] = {
                                    overall: { name: "默认策略", id: "default_strategy" },
                                    hero: { name: "默认策略", id: "default_strategy" }
                                  };
                              }
                              
                              // 清空缓存的英雄策略选择
                              if (customHeroLastSelectedStrategies[customHeroId]) {
                                  customHeroLastSelectedStrategies[customHeroId].hero = [];
                              }
                              
                              // 更新英雄策略标签
                              const heroStrategyLabel = $(`#${customHeroId}StrategyLabel`);
                              if (heroStrategyLabel) {
                                  heroStrategyLabel.text = "默认策略";
                              }
                              
                              // 重置技能阈值设置
                              if (customHeroes[customHeroId].skillThresholds) {
                                  // 重置所有技能阈值为默认值
                                  for (let i = 1; i <= 6; i++) {
                                      customHeroes[customHeroId].skillThresholds[`skill${i}`] = {
                                          hpThreshold: 100,
                                          distThreshold: 0,
                                          level: getDefaultSkillLevel(i)
                                      };
                                  }
                                  
                                  // 更新技能阈值按钮状态
                                  updateSkillThresholdButtonState(customHeroId);
                              }
                              
                              $.Msg(`已清空自定义英雄 ${customHeroId} 的策略和技能阈值设置，因为更换了英雄`);
                          }
                          
                          // 自动确认英雄选择 - 这里只关闭面板而不调用onHeroSelected防止交叉影响
                          fcHeroPickPanel.AddClass('minimized');
                      }
                  }
              });
          } 
      } else {
          fcHeroPickPanel.AddClass('minimized');
      }
    }

    function onHeroSelected(heroId, facetId) {
        // 防止无效调用
        if (!GameEvents.GameSetup || !GameEvents.GameSetup.currentAction) {
            $.Msg("警告: onHeroSelected被调用，但GameEvents.GameSetup未初始化或currentAction未设置");
            return;
        }
        
        // 沙盒模式特殊处理
        if (GameEvents.GameSetup.currentAction === 'SandboxHeroSelect') {
            return; // 沙盒模式有自己的处理逻辑
        }
        
        // 记录调用信息便于调试
        $.Msg(`执行onHeroSelected: heroId=${heroId}, facetId=${facetId}, currentAction=${GameEvents.GameSetup.currentAction}`);
        
        const action = GameEvents.GameSetup.currentAction;
        

        // 定义用于映射操作类型到相应对象和UI元素的配置
        const actionConfigs = {
            'ModifySelfHero': {
                hero: selfHero, 
                heroPrefix: 'Self',
                rows: ['SelfHeroRow', 'SelfHeroRow3'],
                strategyVars: {
                    hero: 'selectedSelfHeroStrategy',
                    overall: 'selectedSelfOverallStrategy',
                    lastSelected: 'lastSelectedSelfHeroStrategies'
                }
            },
            'ModifyOpponentHero': {
                hero: opponentHero,
                heroPrefix: 'Opponent',
                rows: ['OpponentHeroRow', 'OpponentHeroRow3', 'OpponentHeroRow4'],
                strategyVars: {
                    hero: 'selectedOpponentHeroStrategy',
                    overall: 'selectedOpponentOverallStrategy',
                    lastSelected: 'lastSelectedOpponentHeroStrategies'
                }
            }
        };
        
        // 获取当前操作的配置
        const config = actionConfigs[action];
        if (!config) {
            $.Msg(`错误：未知的操作类型 ${action}`);
            return;
        }
        
        const { hero, heroPrefix, rows, strategyVars } = config;
        
        // 检查是否首次选择英雄
        const isFirstSelection = hero.heroId === -1;
        
        // 检查是否更换了英雄
        if (hero.heroId !== heroId) {
            // 清空英雄策略，因为换了新英雄
            window[strategyVars.hero] = { name: "默认策略", id: "default_strategy" };
            
            // 彻底清空缓存的策略选择
            const lastSelectedStrategies = window[strategyVars.lastSelected];
            if (Array.isArray(lastSelectedStrategies)) {
                lastSelectedStrategies.length = 0;
            } else {
                window[strategyVars.lastSelected] = [];
            }
            
            // 更新英雄策略标签
            $(`#${heroPrefix}HeroStrategyLabel`).text = "默认策略";
            
            // 重置技能阈值设置
            const heroFullId = heroPrefix + "Hero";
            if (customHeroes[heroFullId] && customHeroes[heroFullId].skillThresholds) {
                // 重置所有技能阈值为默认值
                for (let i = 1; i <= 6; i++) {
                    customHeroes[heroFullId].skillThresholds[`skill${i}`] = {
                        hpThreshold: 100,
                        distThreshold: 0,
                        level: getDefaultSkillLevel(i)
                    };
                }
                
                // 更新技能阈值按钮状态
                updateSkillThresholdButtonState(heroFullId);
            }
            
            $.Msg(`已清空${heroPrefix === 'Self' ? '自己' : '对手'}英雄的策略和技能阈值设置，因为更换了英雄`);
        }
        
        // 首次选择英雄时，确保整体策略设置为默认值
        if (isFirstSelection) {
            window[strategyVars.overall] = { name: "默认策略", id: "default_strategy" };
            $(`#${heroPrefix}OverallStrategyLabel`).text = "默认策略";
            $.Msg(`首次选择${heroPrefix === 'Self' ? '' : '对手'}英雄，设置整体策略为默认策略`);
        }
        
        // 更新英雄数据
        hero.heroId = heroId;
        hero.facetId = facetId;
        
        // 更新英雄标签
        updateHeroLabel($(`#${heroPrefix}HeroLabel`), heroId, facetId);
        
        // 显示相关面板
        rows.forEach(rowId => {
            const row = $(`#${rowId}`);
            if (row) {
                row.RemoveClass('GameSetupPanelhidden');
            }
        });
        
        // 如果是非SelfHero（即不是自己的英雄），则自动勾选AI开关
        if (heroPrefix !== 'Self' && isFirstSelection) {
            // 更新对应的customHeroes数据
            if (customHeroes[heroPrefix + 'Hero']) {
                customHeroes[heroPrefix + 'Hero'].aiEnabled = true;
            }
            
            // 设置AI开关的UI状态
            const aiToggle = $(`#${heroPrefix}HeroAIToggle`);
            if (aiToggle) {
                aiToggle.checked = true;
                $.Msg(`自动开启 ${heroPrefix}Hero 的AI`);
            }
            
            // 显示策略行
            const strategyRow = $(`#${heroPrefix}HeroRow4`);
            if (strategyRow) {
                strategyRow.RemoveClass('GameSetupPanelhidden');
                $.Msg(`显示 ${heroPrefix}Hero 的策略行`);
            }
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
        if (!heroId || heroId === '') {
            label.text = "未选择英雄";
            return;
        }
        
        // 确保facetId是数字类型
        const facetIdNum = typeof facetId === 'number' ? facetId : parseInt(facetId);
        $.Msg(`updateHeroLabel: heroId=${heroId}, facetId原始值=${facetId}, 类型=${typeof facetId}, 转换后=${facetIdNum}`);
        
        const heroName = getHeroName(heroId);
        const displayText = facetIdNum > 0 ? `${heroName} - ${facetIdNum}` : heroName;
        $.Msg(`updateHeroLabel: 设置标签文本为：${displayText}`);
        label.text = displayText;
    }

  // 为自定义英雄添加策略缓存
  let customHeroLastSelectedStrategies = {};

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
    
    // 先检查当前面板是否已经可见
    if (!strategyPanel.BHasClass('GameSetupPanelhidden')) {
        // 如果已经可见，直接关闭并返回
        strategyPanel.AddClass('GameSetupPanelhidden');
        return;
    }
    
    // 关闭其他所有面板
    closeAllPanels();
    
    // 初始化策略列表
    const strategyList = $('#StrategyList');
    strategyList.RemoveAndDeleteChildren();

    // 处理当前策略，确保它是数组形式，方便后面比较
    const selectedStrategies = Array.isArray(currentStrategy) ? currentStrategy : [currentStrategy];
    
    // 如果当前策略是默认策略但ID为空，则确保使用正确的ID
    if (selectedStrategies.length === 1 && selectedStrategies[0].name === "默认策略" && !selectedStrategies[0].id) {
        selectedStrategies[0].id = "default_strategy";
    }
    
    // 获取所有选中策略的ID
    const selectedIds = selectedStrategies.map(s => s.id);
    
    $.Msg(`当前选中的策略：${JSON.stringify(selectedIds)}`);

    // 创建策略选项
    for (let i = 0; i < strategies.length; i++) {
        const strategy = strategies[i];
        // 检查该策略是否应该被选中
        const isSelected = selectedIds.includes(strategy.id);
        $.Msg(`创建策略选项: ${strategy.name}, ID=${strategy.id}, 是否选中=${isSelected}`);
        const strategyToggle = createStrategyToggle(strategy, strategyList, isSelected);
    }

    // 确认按钮事件
    const confirmButton = $('#ConfirmStrategySelection');
    confirmButton.SetPanelEvent('onactivate', function() {
        const selectedStrategies = strategies.filter((_, index) => 
            strategyList.GetChild(index).checked
        );
        
        // 确保至少选择了一个策略，如果没有选择，默认使用"默认策略"
        if (selectedStrategies.length === 0) {
            const defaultStrategy = strategies.find(s => s.id === "default_strategy") || 
                                   { name: "默认策略", id: "default_strategy" };
            selectedStrategies.push(defaultStrategy);
            $.Msg(`没有选择策略，默认使用: ${defaultStrategy.name}`);
        }
        
        // 确保lastSelectedStrategiesRef是数组
        if (!Array.isArray(lastSelectedStrategiesRef)) {
            lastSelectedStrategiesRef = [];
        }
        
        // 清空并更新lastSelectedStrategiesRef
        lastSelectedStrategiesRef.length = 0;
        selectedStrategies.forEach(s => lastSelectedStrategiesRef.push(s.id));
        
        onStrategySelected(selectedStrategies.length === 1 ? selectedStrategies[0] : selectedStrategies);
        strategyPanel.AddClass('GameSetupPanelhidden');
    });
    
    // 显示面板
    strategyPanel.RemoveClass('GameSetupPanelhidden');
}


  function sendHeroDataToLua() {
    $.Msg("开始发送英雄数据到 Lua 后端");
    $.Msg("当前挑战类型: " + currentChallengeType);

    if (currentChallengeType !== '') {
        // 从自定义英雄对象中获取数据
        const selfHeroData = customHeroes['SelfHero'];
        const opponentHeroData = customHeroes['OpponentHero'];
        
        // 检查数据是否存在
        if (!selfHeroData || !opponentHeroData) {
            $.Msg("错误: 未找到英雄数据", selfHeroData, opponentHeroData);
            return;
        }
        
        $.Msg("从统一管理的customHeroes获取数据:");
        $.Msg("自己英雄数据: ", JSON.stringify(selfHeroData));
        $.Msg("对手英雄数据: ", JSON.stringify(opponentHeroData));
        
        // 获取装备数据
        const selfEquipment = customHeroEquipment['SelfHero'] || [];
        const opponentEquipment = customHeroEquipment['OpponentHero'] || [];
        
        // 转换装备数据
        const simplifiedSelfEquipment = selfEquipment.map(item => ({
            name: item.name,
            count: item.count
        }));

        const simplifiedOpponentEquipment = opponentEquipment.map(item => ({
            name: item.name,
            count: item.count
        }));

        // 获取策略数据
        const selfOverallStrategy = customHeroStrategies['SelfHero']?.overall || { name: "默认策略", id: "default_strategy" };
        const selfHeroStrategy = customHeroStrategies['SelfHero']?.hero || { name: "默认策略", id: "default_strategy" };
        const opponentOverallStrategy = customHeroStrategies['OpponentHero']?.overall || { name: "默认策略", id: "default_strategy" };
        const opponentHeroStrategy = customHeroStrategies['OpponentHero']?.hero || { name: "默认策略", id: "default_strategy" };

        // 处理策略数据
        const processStrategies = (strategies) => {
            if (!strategies || !Array.isArray(strategies)) {
                if (strategies && strategies.name) {
                    return [strategies.name];
                }
                return ["默认策略"];
            }
            return strategies.map(s => s.name);
        };

        // 准备要发送的数据
        const eventData = {
            event: 'ChangeHeroRequest',
            selfHeroId: selfHeroData.heroId,
            selfFacetId: selfHeroData.facetId,
            opponentHeroId: opponentHeroData.heroId,
            opponentFacetId: opponentHeroData.facetId,
            challengeType: currentChallengeType,
            selfAIEnabled: Boolean(selfHeroData.aiEnabled),
            opponentAIEnabled: Boolean(opponentHeroData.aiEnabled),
            selfEquipment: simplifiedSelfEquipment,
            opponentEquipment: simplifiedOpponentEquipment,
            selfOverallStrategies: processStrategies(selfOverallStrategy),
            selfHeroStrategies: processStrategies(selfHeroStrategy),
            opponentOverallStrategies: processStrategies(opponentOverallStrategy),
            opponentHeroStrategies: processStrategies(opponentHeroStrategy)
        };

        // 添加技能阈值数据
        if (selfHeroData.skillThresholds) {
            eventData.selfSkillThresholds = selfHeroData.skillThresholds;
        }
        
        if (opponentHeroData.skillThresholds) {
            eventData.opponentSkillThresholds = opponentHeroData.skillThresholds;
        }
        
        // 添加技能权重数据
        if (selfHeroData.teamMode && selfHeroData.teamMode.enabled && selfHeroData.skillWeights) {
            eventData.selfSkillWeights = selfHeroData.skillWeights;
            $.Msg("添加自己英雄的技能权重数据: ", JSON.stringify(selfHeroData.skillWeights));
        }
        
        if (opponentHeroData.teamMode && opponentHeroData.teamMode.enabled && opponentHeroData.skillWeights) {
            eventData.opponentSkillWeights = opponentHeroData.skillWeights;
            $.Msg("添加对手英雄的技能权重数据: ", JSON.stringify(opponentHeroData.skillWeights));
        }
        
        // 添加自定义英雄的技能阈值数据
        const customHeroIds = Object.keys(customHeroes).filter(id => id !== 'SelfHero' && id !== 'OpponentHero');
        if (customHeroIds.length > 0) {
            eventData.customHeroData = {};
            customHeroIds.forEach(heroId => {
                eventData.customHeroData[heroId] = {
                    heroId: customHeroes[heroId].heroId,
                    facetId: customHeroes[heroId].facetId,
                    aiEnabled: Boolean(customHeroes[heroId].aiEnabled),
                    skillThresholds: customHeroes[heroId].skillThresholds || {}
                };
                
                // 添加团队模式和技能权重数据
                if (customHeroes[heroId].teamMode && customHeroes[heroId].teamMode.enabled && customHeroes[heroId].skillWeights) {
                    eventData.customHeroData[heroId].teamMode = customHeroes[heroId].teamMode;
                    eventData.customHeroData[heroId].skillWeights = customHeroes[heroId].skillWeights;
                    $.Msg(`添加自定义英雄 ${heroId} 的技能权重数据: `, JSON.stringify(customHeroes[heroId].skillWeights));
                }
                
                // 添加装备和策略数据
                if (customHeroEquipment[heroId]) {
                    eventData.customHeroData[heroId].equipment = customHeroEquipment[heroId].map(item => ({
                        name: item.name,
                        count: item.count
                    }));
                }
                
                if (customHeroStrategies[heroId]) {
                    eventData.customHeroData[heroId].overallStrategies = processStrategies(customHeroStrategies[heroId].overall);
                    eventData.customHeroData[heroId].heroStrategies = processStrategies(customHeroStrategies[heroId].hero);
                }
            });
        }

        // 发送数据到服务器
        GameEvents.SendCustomGameEventToServer("ChangeHeroRequest", eventData);

        $.Msg("发送到服务器的数据: ", JSON.stringify(eventData, null, 2));
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
    
      // 根据面板类型更新对应的装备列表
      if (currentPanelType === 'Custom') {
        // 处理自定义英雄面板
        customHeroEquipment[currentHeroType] = items;
        $.Msg(`已更新自定义英雄 ${currentHeroType} 的装备，共 ${items.length} 件物品`);
      } else {
        // 处理默认面板
        if (currentHeroType === 'Self') {
          selfHero.equipment = items;
        } else if (currentHeroType === 'Opponent') {
          opponentHero.equipment = items;
        }
      }

      // 关闭物品选择对话框
      closeItemSelectionDialog();

      // 更新UI，显示已选择的物品
      updateSelectedItemsUI(currentHeroType, currentPanelType);

      // 打印调试信息
      $.Msg("物品选择确认完成，已选择 " + items.length + " 个物品");
      items.forEach(item => {
        $.Msg("  - " + item.name + " x " + item.count);
      });
    }
    
    
    function updateSelectedItemsUI(heroType, panelType) {
      $.Msg(`开始更新 ${heroType} 的物品 UI，面板类型: ${panelType}`);
      
      let itemPanelId;
      let equipment;
      
      if (panelType === 'Custom') {
        // 处理自定义英雄面板
        itemPanelId = `${heroType}ItemPanel`;
        equipment = customHeroEquipment[heroType] || [];
      } else {
        // 处理默认面板
        itemPanelId = heroType === 'Self' ? 'SelfHeroItemPanel' : 'OpponentHeroItemPanel';
        equipment = heroType === 'Self' ? selfHero.equipment : opponentHero.equipment;
      }
      
      $.Msg("使用面板 ID: " + itemPanelId + "，装备数量: " + (equipment ? equipment.length : 0));
      const itemPanel = $('#' + itemPanelId);
      
      if (!itemPanel) {
        $.Msg(`错误: 未找到面板 ${itemPanelId}`);
        return;
      }

      // 清空当前显示
      itemPanel.RemoveAndDeleteChildren();

      if (!equipment || equipment.length === 0) {
        $.Msg("没有装备可显示");
        return;
      }

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
      
      $.Msg("Found mode data:", JSON.stringify(modeData));
      
       if (modeData && modeData.menuConfig) {
          const enabledItems = Object.values(modeData.menuConfig);
          
          $.Msg("Enabled menu items:", JSON.stringify(enabledItems));
          
          // 对于所有的菜单项目，先检查是否需要启用或删除
          for (const item of allMenuItems) {
              // 检查是否需要启用此项
              const shouldEnable = enabledItems.includes(item);
              $.Msg(`需要启用 ${item}?: ${shouldEnable}`);
              
              // 确定面板ID和标签
              let panelId, panelLabel, playerType;
              if (item === 'SelfHeroRow') {
                  panelId = 'SelfHero';
                  panelLabel = '英雄（自己）';
                  playerType = 'Self';
              } else if (item === 'OpponentHeroRow') {
                  panelId = 'OpponentHero';
                  panelLabel = '英雄（对手）';
                  playerType = 'Opponent';
              }
              
              if (panelId) {
                  // 检查面板是否已存在
                  const existingPanel = $(`#${panelId}Row`);
                  
                  if (shouldEnable) {
                      // 如果需要启用但面板不存在，则创建它
                      if (!existingPanel) {
                          $.Msg(`创建新英雄面板: ${panelId}`);
                          addNewHeroPanel(panelId, panelLabel, playerType);
                      } else {
                          // 如果已存在，显示面板
                          $.Msg(`显示已存在的面板: ${panelId}`);
                          existingPanel.style.visibility = 'visible';
                      }
                  } else {
                      // 如果不需要启用且面板存在，则删除它
                      if (existingPanel) {
                          $.Msg(`删除不需要的面板: ${panelId}`);
                          
                          // 清理相关数据
                          if (panelId === 'SelfHero' || panelId === 'OpponentHero') {
                              // 重置英雄数据
                              if (customHeroes[panelId]) {
                                  customHeroes[panelId] = {
                                      heroId: '',
                                      facetId: -1,
                                      heroName: '未选择英雄',
                                      aiEnabled: false
                                  };
                              }
                              
                              // 重置装备数据
                              if (customHeroEquipment[panelId]) {
                                  customHeroEquipment[panelId] = [];
                              }
                              
                              // 重置策略数据
                              if (customHeroStrategies[panelId]) {
                                  customHeroStrategies[panelId] = {
                                      overall: { name: "默认策略", id: "default_strategy" },
                                      hero: { name: "默认策略", id: "default_strategy" }
                                  };
                              }
                          }
                          
                          // 删除面板
                          existingPanel.DeleteAsync(0.0);
                      }
                  }
              }
          }
      } else {
          // 如果没有找到模式数据或菜单配置，删除所有面板
          $.Msg("No mode data or menu config found. Removing all panels.");
          for (const item of allMenuItems) {
              // 获取与菜单项对应的面板ID
              let panelId;
              if (item === 'SelfHeroRow') {
                  panelId = 'SelfHero';
              } else if (item === 'OpponentHeroRow') {
                  panelId = 'OpponentHero';
              }
              
              if (panelId) {
                  const panel = $(`#${panelId}Row`);
                  if (panel) {
                      // 清理相关数据
                      if (customHeroes[panelId]) {
                          customHeroes[panelId] = {
                              heroId: '',
                              facetId: -1,
                              heroName: '未选择英雄',
                              aiEnabled: false
                          };
                      }
                      
                      if (customHeroEquipment[panelId]) {
                          customHeroEquipment[panelId] = [];
                      }
                      
                      if (customHeroStrategies[panelId]) {
                          customHeroStrategies[panelId] = {
                              overall: { name: "默认策略", id: "default_strategy" },
                              hero: { name: "默认策略", id: "default_strategy" }
                          };
                      }
                      
                      // 删除面板
                      panel.DeleteAsync(0.0);
                  }
              }
          }
      } 
      
      // 检查所有选择完成状态
      checkAllSelectionsComplete();
    }
  
  // 新增：添加新英雄设置面板的功能
  let heroCounter = 1; // 用于生成唯一ID
  
  function addNewHeroPanel(customId, customLabel, playerType) {

    $.Msg("添加新英雄面板");
    const heroIndex = heroCounter++;
    // 使用自定义ID，如果提供的话
    const heroId = customId || `CustomHero_${heroIndex}`;
    
    // 获取GameSetupPanel
    const gameSetupPanel = $('#GameSetupPanel');
    
    // 检查面板是否已存在
    const existingPanel = $(`#${heroId}Row`);
    if (existingPanel) {
      existingPanel.style.visibility = 'visible';
      return heroId; // 如果面板已存在，直接返回ID
    }
    
    // 直接找到添加按钮所在的行
    const addButtonRow = $('#ChangeHeroButton').GetParent();
    
    // 创建英雄行面板
    const heroRow = $.CreatePanel('Panel', gameSetupPanel, `${heroId}Row`);
    
    // 将新面板放在添加按钮行的前面
    if (addButtonRow) {
      gameSetupPanel.MoveChildBefore(heroRow, addButtonRow);
    }
    
    heroRow.AddClass('GameSetupPanelSettingsRow2');
    heroRow.style.visibility = 'visible';
    
    // 创建主要行
    const mainRow = $.CreatePanel('Panel', heroRow, '');
    mainRow.AddClass('HeroSelectionMainRow');
    
    // 创建标签 - 使用自定义标签，如果提供的话
    const label = $.CreatePanel('Label', mainRow, '');
    label.AddClass('GameSetupPanelSettingLabel1');
    label.text = customLabel || `英雄 ${heroIndex}`;
    
    // 创建右侧内容
    const rightContent = $.CreatePanel('Panel', mainRow, '');
    rightContent.AddClass('HeroSelectionRightContent');
    
    const labelContainer = $.CreatePanel('Panel', rightContent, '');
    labelContainer.AddClass('HeroLabelContainer');
    
    const heroLabel = $.CreatePanel('Label', labelContainer, `${heroId}Label`);
    heroLabel.AddClass('HeroLabel');
    heroLabel.text = '未选择英雄';
    
    const modifyButton = $.CreatePanel('Button', labelContainer, `Modify${heroId}Button`);
    modifyButton.AddClass('ModifyButton');
    
    const modifyButtonLabel = $.CreatePanel('Label', modifyButton, '');
    modifyButtonLabel.text = '修改';
    
    // 创建第三行（物品行） - 初始隐藏
    const heroRow3 = $.CreatePanel('Panel', heroRow, `${heroId}Row3`);
    heroRow3.AddClass('GameSetupPanelSettingsRow3');
    heroRow3.AddClass('GameSetupPanelhidden'); // 初始隐藏
    
    const heroSelectionSubRow = $.CreatePanel('Panel', heroRow3, '');
    heroSelectionSubRow.AddClass('HeroSelectionSubRow');
    
    const heroItemPanel = $.CreatePanel('Panel', heroSelectionSubRow, `${heroId}ItemPanel`);
    heroItemPanel.AddClass('HeroItemPanel');
    
    const heroControlContainer = $.CreatePanel('Panel', heroRow3, '');
    heroControlContainer.AddClass('HeroControlContainer');
    
    const addItemButton = $.CreatePanel('Button', heroControlContainer, `Add${heroId}ItemButton`);
    addItemButton.AddClass('AddItemButton');
    
    const addItemButtonLabel = $.CreatePanel('Label', addItemButton, '');
    addItemButtonLabel.text = '添加物品';
    
    // 创建AI开关
    const aiToggle = $.CreatePanel('ToggleButton', heroControlContainer, `${heroId}AIToggle`);
    aiToggle.AddClass('HeroAIToggle');
    
    // 判断是否是第一个面板（SelfHero是自己的英雄，默认AI关闭）
    const isFirstPanel = (heroId === 'SelfHero');
    
    // 非第一个面板，默认开启AI
    let aiEnabled = !isFirstPanel;
    
    // 设置AI开关的默认状态
    if (aiEnabled) {
      aiToggle.checked = true;
    }
    
    const aiToggleLabel = $.CreatePanel('Label', aiToggle, '');
    aiToggleLabel.AddClass('HeroAIToggleLabel');
    aiToggleLabel.text = '开启AI';
    
    // 添加技能阈值按钮
    const skillThresholdButton = $.CreatePanel('Button', heroControlContainer, `${heroId}SkillThresholdButton`);
    skillThresholdButton.AddClass('AddItemButton');
    
    const skillThresholdButtonLabel = $.CreatePanel('Label', skillThresholdButton, '');
    skillThresholdButtonLabel.text = '技能阈值';
    
    // 创建技能阈值面板 - 初始隐藏
    const skillThresholdPanel = $.CreatePanel('Panel', $.GetContextPanel(), `${heroId}SkillThresholdPanel`);
    skillThresholdPanel.AddClass('SkillThresholdPanel');
    skillThresholdPanel.AddClass('GameSetupPanelhidden'); // 初始隐藏
    
    // 创建标题栏
    const titleBar = $.CreatePanel('Panel', skillThresholdPanel, `${heroId}SkillThresholdTitleBar`);
    titleBar.AddClass('SkillThresholdTitleBar');
    
    // 创建技能阈值面板标题
    const skillThresholdTitle = $.CreatePanel('Label', titleBar, '');
    skillThresholdTitle.AddClass('SkillThresholdTitle');
    skillThresholdTitle.text = '技能施放阈值设置';
    
    // 创建关闭按钮
    const closeButton = $.CreatePanel('Button', titleBar, '');
    closeButton.AddClass('SkillThresholdCloseButton');
    const closeButtonLabel = $.CreatePanel('Label', closeButton, '');
    closeButtonLabel.text = 'X';
    
    // 设置关闭按钮事件
    closeButton.SetPanelEvent('onactivate', function() {
        $.Msg("关闭技能阈值面板");
        skillThresholdPanel.AddClass('GameSetupPanelhidden');
    });
    
    // 创建技能等级设置区域
    const skillLevelSettingPanel = $.CreatePanel('Panel', skillThresholdPanel, `${heroId}SkillLevelSettingPanel`);
    skillLevelSettingPanel.AddClass('SkillLevelSettingPanel');
    
    // 添加技能等级设置标题和团队模式勾选框的容器
    const skillLevelHeaderRow = $.CreatePanel('Panel', skillLevelSettingPanel, '');
    skillLevelHeaderRow.AddClass('SkillLevelHeaderRow');
    
    // 添加技能等级设置标题
    const skillLevelTitle = $.CreatePanel('Label', skillLevelHeaderRow, '');
    skillLevelTitle.AddClass('SkillLevelTitle');
    skillLevelTitle.text = '技能等级设置';
    
    // 添加团队模式勾选框
    const teamModeContainer = $.CreatePanel('Panel', skillLevelHeaderRow, '');
    teamModeContainer.AddClass('TeamModeContainer');
    
    const teamModeToggle = $.CreatePanel('ToggleButton', teamModeContainer, `${heroId}TeamModeToggle`);
    teamModeToggle.AddClass('TeamModeToggle');
    
    const teamModeLabel = $.CreatePanel('Label', teamModeContainer, '');
    teamModeLabel.AddClass('TeamModeLabel');
    teamModeLabel.text = '团队模式';
    
    // 设置团队模式勾选框的点击事件
    teamModeToggle.SetPanelEvent('onactivate', function() {
        // 获取当前勾选状态
        const isTeamMode = teamModeToggle.IsSelected();
        
        // 更新customHeroes中的团队模式状态
        if (!customHeroes[heroId].teamMode) {
            customHeroes[heroId].teamMode = {};
        }
        customHeroes[heroId].teamMode.enabled = isTeamMode;
        
        // 显示或隐藏所有技能的权重输入框
        toggleTeamModeInputs(heroId, isTeamMode);
        
        // 如果开启团队模式，初始化权重值
        if (isTeamMode && (!customHeroes[heroId].skillWeights || Object.keys(customHeroes[heroId].skillWeights).length === 0)) {
            initializeSkillWeights(heroId);
        }
        
        $.Msg(`${heroId} 团队模式 ${isTeamMode ? "已开启" : "已关闭"}`);
    });
    
    // 添加技能1、2、3和大招的等级设置
    const skillsToSet = [
      { index: 1, name: '技能1', maxLevel: MAX_SKILL_LEVELS.BASIC_SKILLS },
      { index: 2, name: '技能2', maxLevel: MAX_SKILL_LEVELS.BASIC_SKILLS },
      { index: 3, name: '技能3', maxLevel: MAX_SKILL_LEVELS.BASIC_SKILLS },
      { index: 6, name: '终极技能', maxLevel: MAX_SKILL_LEVELS.ULTIMATE_SKILL }
    ];
    
    // 为每个需要设置等级的技能创建一行
    skillsToSet.forEach(skill => {
      const skillLevelRow = $.CreatePanel('Panel', skillLevelSettingPanel, `${heroId}Skill${skill.index}LevelRow`);
      skillLevelRow.AddClass('SkillLevelRow');
      
      // 技能名称标签
      const skillLevelLabel = $.CreatePanel('Label', skillLevelRow, '');
      skillLevelLabel.AddClass('SkillLevelLabel');
      skillLevelLabel.text = skill.name + ':';
      
      // 创建等级选择器面板
      const levelSelectorPanel = $.CreatePanel('Panel', skillLevelRow, `${heroId}Skill${skill.index}LevelSelector`);
      levelSelectorPanel.AddClass('LevelSelectorPanel');
      
      // 首先创建0级按钮
      const zeroLevelButton = $.CreatePanel('Button', levelSelectorPanel, `${heroId}Skill${skill.index}Level0`);
      zeroLevelButton.AddClass('LevelButton');
      
      const zeroLevelLabel = $.CreatePanel('Label', zeroLevelButton, '');
      zeroLevelLabel.text = '0';
      
      // 设置0级按钮点击事件
      zeroLevelButton.SetPanelEvent('onactivate', function() {
        // 移除所有按钮的选中状态
        for (let l = 0; l <= skill.maxLevel; l++) {
          const btn = $(`#${heroId}Skill${skill.index}Level${l}`);
          if (btn) {
            btn.RemoveClass('SelectedLevel');
          }
        }
        
        // 添加当前按钮的选中状态
        zeroLevelButton.AddClass('SelectedLevel');
        
        // 记录选中的等级到按钮的父面板上
        levelSelectorPanel.selectedLevel = 0;
        
        $.Msg(`设置${heroId}${skill.name}等级为0`);
      });
      
      // 为每个可能的等级创建一个按钮
      for (let level = 1; level <= skill.maxLevel; level++) {
        const levelButton = $.CreatePanel('Button', levelSelectorPanel, `${heroId}Skill${skill.index}Level${level}`);
        levelButton.AddClass('LevelButton');
        
        const levelLabel = $.CreatePanel('Label', levelButton, '');
        levelLabel.text = level.toString();
        
        // 默认选中的等级
        const defaultLevel = getDefaultSkillLevel(skill.index);
        if (level === defaultLevel) {
          levelButton.AddClass('SelectedLevel');
        }
        
        // 设置点击事件
        levelButton.SetPanelEvent('onactivate', function() {
          // 移除所有按钮的选中状态
          for (let l = 0; l <= skill.maxLevel; l++) {
            const btn = $(`#${heroId}Skill${skill.index}Level${l}`);
            if (btn) {
              btn.RemoveClass('SelectedLevel');
            }
          }
          
          // 添加当前按钮的选中状态
          levelButton.AddClass('SelectedLevel');
          
          // 记录选中的等级到按钮的父面板上，方便之后获取
          levelSelectorPanel.selectedLevel = level;
          
          $.Msg(`设置${heroId}${skill.name}等级为${level}`);
        });
      }
      
      // 初始化选中的等级
      levelSelectorPanel.selectedLevel = getDefaultSkillLevel(skill.index);
      
      // 添加权重输入框
      const weightContainer = $.CreatePanel('Panel', skillLevelRow, `${heroId}Skill${skill.index}WeightContainer`);
      weightContainer.AddClass('WeightContainer');
      weightContainer.style.visibility = 'collapse'; // 初始隐藏
      
      const weightLabel = $.CreatePanel('Label', weightContainer, '');
      weightLabel.AddClass('WeightLabel');
      weightLabel.text = '权重:';
      
      const weightInput = $.CreatePanel('TextEntry', weightContainer, `${heroId}Skill${skill.index}Weight`);
      weightInput.AddClass('WeightInput');
      weightInput.text = 0; // 初始默认值: 大招40，普通技能15
      

    });
    
    // 创建6个技能的阈值设置
    for (let i = 1; i <= 6; i++) {
      const skillRow = $.CreatePanel('Panel', skillThresholdPanel, `${heroId}Skill${i}Row`);
      skillRow.AddClass('SkillThresholdRow');
      
      // 技能名称
      const skillNameLabel = $.CreatePanel('Label', skillRow, '');
      skillNameLabel.AddClass('SkillNameLabel');
      skillNameLabel.text = i === 6 ? '终极技能' : `技能${i}`;
      
      // 生命值阈值设置
      const hpThresholdContainer = $.CreatePanel('Panel', skillRow, '');
      hpThresholdContainer.AddClass('ThresholdContainer');
      
      const hpThresholdLabel = $.CreatePanel('Label', hpThresholdContainer, '');
      hpThresholdLabel.AddClass('ThresholdLabel');
      hpThresholdLabel.text = '生命值阈值:';
      
      const hpThresholdInput = $.CreatePanel('TextEntry', hpThresholdContainer, `${heroId}Skill${i}HpThreshold`);
      hpThresholdInput.AddClass('ThresholdInput');
      hpThresholdInput.text = '100';
      
      // 距离阈值设置
      const distThresholdContainer = $.CreatePanel('Panel', skillRow, '');
      distThresholdContainer.AddClass('ThresholdContainer');
      
      const distThresholdLabel = $.CreatePanel('Label', distThresholdContainer, '');
      distThresholdLabel.AddClass('ThresholdLabel');
      distThresholdLabel.text = '距离阈值:';
      
      const distThresholdInput = $.CreatePanel('TextEntry', distThresholdContainer, `${heroId}Skill${i}DistThreshold`);
      distThresholdInput.AddClass('ThresholdInput');
      distThresholdInput.text = '0';
    }
    
    // 添加确认按钮
    const skillThresholdButtonsRow = $.CreatePanel('Panel', skillThresholdPanel, '');
    skillThresholdButtonsRow.AddClass('SkillThresholdButtonsRow');
    
    // 添加重置按钮
    const resetSkillThresholdButton = $.CreatePanel('Button', skillThresholdButtonsRow, `${heroId}ResetSkillThresholdButton`);
    resetSkillThresholdButton.AddClass('ResetButton');
    
    const resetSkillThresholdButtonLabel = $.CreatePanel('Label', resetSkillThresholdButton, '');
    resetSkillThresholdButtonLabel.text = '重置';
    
    const confirmSkillThresholdButton = $.CreatePanel('Button', skillThresholdButtonsRow, `${heroId}ConfirmSkillThresholdButton`);
    confirmSkillThresholdButton.AddClass('ConfirmButton');
    
    const confirmSkillThresholdButtonLabel = $.CreatePanel('Label', confirmSkillThresholdButton, '');
    confirmSkillThresholdButtonLabel.text = '确认';
    
    // 设置重置按钮点击事件
    resetSkillThresholdButton.SetPanelEvent('onactivate', function() {
      // 重置所有技能阈值为初始值
      for (let i = 1; i <= 6; i++) {
        const hpThresholdInput = $(`#${heroId}Skill${i}HpThreshold`);
        const distThresholdInput = $(`#${heroId}Skill${i}DistThreshold`);
        const weightInput = $(`#${heroId}Skill${i}Weight`);
        
        if (hpThresholdInput && distThresholdInput) {
          // 重置为初始值
          hpThresholdInput.text = '100';
          distThresholdInput.text = '0';
          
          // 重置权重值
          if (weightInput) {
              weightInput.text = 0
          }
          
          // 重置技能等级
          if (i <= 3 || i === 6) {
            const levelSelector = $(`#${heroId}Skill${i}LevelSelector`);
            if (levelSelector) {
              const defaultLevel = getDefaultSkillLevel(i);
              
              // 更新选中状态
              const maxLevel = getMaxSkillLevel(i);
              for (let l = 0; l <= maxLevel; l++) {
                const btn = $(`#${heroId}Skill${i}Level${l}`);
                if (btn) {
                  if (l === defaultLevel) {
                    btn.AddClass('SelectedLevel');
                  } else {
                    btn.RemoveClass('SelectedLevel');
                  }
                }
              }
              
              // 保存当前选中的等级
              levelSelector.selectedLevel = defaultLevel;
            }
          }
          
          $.Msg(`重置 ${heroId} 技能${i} 阈值: HP=100, 距离=0, 等级=${getDefaultSkillLevel(i)}`);
        }
      }
      
      // 如果处于团队模式，重新初始化权重值
      const teamModeToggle = $(`#${heroId}TeamModeToggle`);
      if (teamModeToggle && teamModeToggle.IsSelected()) {
          initializeSkillWeights(heroId);
      }
      
      // 更新技能阈值按钮状态
      updateSkillThresholdButtonState(heroId);
    });
    
    // 设置技能阈值按钮点击事件
    skillThresholdButton.SetPanelEvent('onactivate', function() {
      // 先关闭其他所有面板，但排除当前英雄的技能阈值面板
      closeAllPanels(heroId);
      
      // 加载技能阈值数据
      loadSkillThresholdData(heroId);
      
      // 切换当前技能阈值面板的可见性
      if (skillThresholdPanel.BHasClass('GameSetupPanelhidden')) {
        // 确保面板在最上层显示
        skillThresholdPanel.RemoveClass('GameSetupPanelhidden');
        // 移至最上层
        $.GetContextPanel().MoveChildAfter(skillThresholdPanel, $.GetContextPanel().GetChild($.GetContextPanel().GetChildCount() - 1));
      } else {
        skillThresholdPanel.AddClass('GameSetupPanelhidden');
      }
    });
    
    // 设置确认按钮点击事件
    confirmSkillThresholdButton.SetPanelEvent('onactivate', function() {
      // 保存技能阈值设置
      // 确保customHeroes[heroId].skillThresholds存在
      if (!customHeroes[heroId].skillThresholds) {
        customHeroes[heroId].skillThresholds = {};
      }
      
      // 获取团队模式状态
      const teamModeToggle = $(`#${heroId}TeamModeToggle`);
      const isTeamMode = teamModeToggle && teamModeToggle.IsSelected();
      
      // 确保teamMode对象存在
      if (!customHeroes[heroId].teamMode) {
        customHeroes[heroId].teamMode = {};
      }
      
      // 保存团队模式状态
      customHeroes[heroId].teamMode.enabled = isTeamMode;
      
      // 确保skillWeights对象存在
      if (!customHeroes[heroId].skillWeights) {
        customHeroes[heroId].skillWeights = {};
      }
      
      // 遍历所有技能，读取并保存阈值设置
      for (let i = 1; i <= 6; i++) {
        const hpThresholdInput = $(`#${heroId}Skill${i}HpThreshold`);
        const distThresholdInput = $(`#${heroId}Skill${i}DistThreshold`);
        
        if (hpThresholdInput && distThresholdInput) {
          // 读取输入框的值并转换为数字
          const hpThreshold = parseInt(hpThresholdInput.text) || 100;
          const distThreshold = parseInt(distThresholdInput.text) || 0;
          
          // 读取技能等级
          let level = getDefaultSkillLevel(i); // 默认值
          if (i <= 3 || i === 6) {
            const levelSelector = $(`#${heroId}Skill${i}LevelSelector`);
            if (levelSelector) {
              level = typeof levelSelector.selectedLevel === 'number' ? levelSelector.selectedLevel : getDefaultSkillLevel(i);
            }
          }
          
          // 保存到customHeroes对象中
          customHeroes[heroId].skillThresholds[`skill${i}`] = {
            hpThreshold: hpThreshold,
            distThreshold: distThreshold,
            level: level
          };
          
          // 如果开启了团队模式，保存权重
          if (isTeamMode) {
            const weightInput = $(`#${heroId}Skill${i}Weight`);
            if (weightInput) {
              const weight = parseInt(weightInput.text) || 0;
              customHeroes[heroId].skillWeights[`skill${i}`] = weight;
            }
          }
          
          $.Msg(`保存 ${heroId} 技能${i} 阈值: HP=${hpThreshold}, 距离=${distThreshold}, 等级=${level}${isTeamMode ? `, 权重=${customHeroes[heroId].skillWeights[`skill${i}`]}` : ''}`);
        }
      }
      
      // 更新技能阈值按钮状态
      updateSkillThresholdButtonState(heroId);
      
      // 隐藏技能阈值面板
      skillThresholdPanel.AddClass('GameSetupPanelhidden');
    });
    
    // 创建第四行（策略行）- 默认隐藏
    const heroRow4 = $.CreatePanel('Panel', heroRow, `${heroId}Row4`);
    heroRow4.AddClass('GameSetupPanelSettingsRow4');
    heroRow4.AddClass('GameSetupPanelhidden'); // 初始隐藏
    
    // 策略行始终保持隐藏状态，直到同时满足了选择了英雄且开启了AI
    // 不再在此处基于aiEnabled显示策略行，而是等待英雄选择后再处理
    
    // 整体策略
    const overallStrategyRow = $.CreatePanel('Panel', heroRow4, '');
    overallStrategyRow.AddClass('StrategySelectionRow');
    
    const overallStrategyLabel = $.CreatePanel('Label', overallStrategyRow, '');
    overallStrategyLabel.AddClass('StrategyLabel');
    overallStrategyLabel.text = '整体策略(AI):';
    
    const overallStrategyValue = $.CreatePanel('Label', overallStrategyRow, `${heroId}OverallStrategyLabel`);
    overallStrategyValue.AddClass('StrategyValue');
    overallStrategyValue.text = '默认策略';
    
    const modifyOverallStrategyButton = $.CreatePanel('Button', overallStrategyRow, `Modify${heroId}OverallStrategyButton`);
    modifyOverallStrategyButton.AddClass('ModifyButton');
    
    const modifyOverallStrategyButtonLabel = $.CreatePanel('Label', modifyOverallStrategyButton, '');
    modifyOverallStrategyButtonLabel.text = '修改';
    
    // 英雄策略
    const heroStrategyRow = $.CreatePanel('Panel', heroRow4, '');
    heroStrategyRow.AddClass('StrategySelectionRow');
    
    const heroStrategyLabel = $.CreatePanel('Label', heroStrategyRow, '');
    heroStrategyLabel.AddClass('StrategyLabel');
    heroStrategyLabel.text = '英雄策略(AI):';
    
    const heroStrategyValue = $.CreatePanel('Label', heroStrategyRow, `${heroId}StrategyLabel`);
    heroStrategyValue.AddClass('StrategyValue');
    heroStrategyValue.text = '未选择';
    
    const modifyHeroStrategyButton = $.CreatePanel('Button', heroStrategyRow, `Modify${heroId}StrategyButton`);
    modifyHeroStrategyButton.AddClass('ModifyButton');
    
    const modifyHeroStrategyButtonLabel = $.CreatePanel('Label', modifyHeroStrategyButton, '');
    modifyHeroStrategyButtonLabel.text = '修改';
    
    // 初始化自定义英雄数据和策略
    if (!customHeroes[heroId]) {
      customHeroes[heroId] = {
        heroId: '',
        facetId: -1,
        heroName: '未选择英雄',
        aiEnabled: aiEnabled,  // 使用前面决定的AI状态
        skillThresholds: {}, // 添加技能阈值数据存储
        teamMode: { enabled: false }, // 添加团队模式状态
        skillWeights: {} // 添加技能权重数据存储
      };
      
      // 初始化技能阈值数据
      for (let i = 1; i <= 6; i++) {
        customHeroes[heroId].skillThresholds[`skill${i}`] = {
          hpThreshold: 100,
          distThreshold: 0,
          level: getDefaultSkillLevel(i)
        };
        
        // 初始化权重值
        customHeroes[heroId].skillWeights[`skill${i}`] = 0
      }
    }
    
    // 确保初始化策略为默认策略
    if (!customHeroStrategies[heroId]) {
      customHeroStrategies[heroId] = {
        overall: { name: "默认策略", id: "default_strategy" },
        hero: { name: "默认策略", id: "default_strategy" }
      };
      
      // 设置策略标签
      const overallStrategyValue = $(`#${heroId}OverallStrategyLabel`);
      if (overallStrategyValue) {
        overallStrategyValue.text = '默认策略';
      }
      
      const heroStrategyValue = $(`#${heroId}StrategyLabel`);
      if (heroStrategyValue) {
        heroStrategyValue.text = '默认策略';
      }
    }
    
    // 设置按钮事件
    modifyButton.SetPanelEvent('onactivate', function() {
      toggleFcHeroPickPanel('ModifyCustomHero', heroId);
    });
    
    addItemButton.SetPanelEvent('onactivate', function() {
      openItemSelectionDialog(heroId, 'Custom');
    });
    
    // 添加AI开关事件
    aiToggle.SetPanelEvent('onactivate', function() {
      // 更新AI状态
      customHeroes[heroId].aiEnabled = aiToggle.IsSelected();
      
      // 根据AI状态显示或隐藏策略行和技能阈值按钮
      updateStrategyRowVisibility(heroId);
      
      $.Msg(`${heroId} AI ${customHeroes[heroId].aiEnabled ? "已开启" : "已关闭"}`);
    });
    
    modifyOverallStrategyButton.SetPanelEvent('onactivate', function() {
      const strategies = globalStrategies || [];
      
      // 获取之前保存的策略
      if (!customHeroStrategies[heroId]) {
        customHeroStrategies[heroId] = {
          overall: { name: "默认策略", id: "default_strategy" },
          hero: { name: "默认策略", id: "default_strategy" }
        };
      }
      const currentStrategy = customHeroStrategies[heroId].overall;
      
      // 获取或初始化最后选择的策略ID数组
      if (!customHeroLastSelectedStrategies[heroId]) {
        customHeroLastSelectedStrategies[heroId] = {
          overall: [],
          hero: []
        };
      }
      const lastSelectedRef = customHeroLastSelectedStrategies[heroId].overall;
      
      toggleStrategySelectionPanel(strategies, function(strategy) {
        // 处理返回的策略，确保显示名称而不是对象
        const selectedStrategies = Array.isArray(strategy) ? strategy : [strategy];
        customHeroStrategies[heroId].overall = selectedStrategies.length === 1 ? selectedStrategies[0] : selectedStrategies;
        overallStrategyValue.text = selectedStrategies.map(s => s.name).join(', ');
        $.Msg(`为 ${heroId} 设置整体策略: ${overallStrategyValue.text}`);
      }, currentStrategy, lastSelectedRef);
    });
    
    modifyHeroStrategyButton.SetPanelEvent('onactivate', function() {
      // 获取选择的英雄ID，直接从customHeroes对象获取并确保它存在且不为空
      if (!customHeroes[heroId] || !customHeroes[heroId].heroId) {
        $.Msg(`警告: ${heroId} 尚未选择英雄，无法设置英雄特定策略`);
        return;
      }
      
      const selectedHeroId = customHeroes[heroId].heroId;
      
      // 打印当前英雄ID以便调试
      $.Msg(`正在为 ${heroId} 设置英雄特定策略，英雄ID: ${selectedHeroId}`);
      
      // 根据选择的英雄动态获取对应的策略
      const heroSpecificStrategies = heroStrategies[selectedHeroId] || [];
      $.Msg(`找到该英雄的特定策略数量: ${heroSpecificStrategies.length}`);
      
      const strategies = [{ name: "默认策略", id: "default_strategy" }].concat(heroSpecificStrategies);
      
      // 获取之前保存的策略
      if (!customHeroStrategies[heroId]) {
        customHeroStrategies[heroId] = {
          overall: { name: "默认策略", id: "default_strategy" },
          hero: { name: "默认策略", id: "default_strategy" }
        };
      }
      const currentStrategy = customHeroStrategies[heroId].hero;
      
      // 获取或初始化最后选择的策略ID数组
      if (!customHeroLastSelectedStrategies[heroId]) {
        customHeroLastSelectedStrategies[heroId] = {
          overall: [],
          hero: []
        };
      }
      const lastSelectedRef = customHeroLastSelectedStrategies[heroId].hero;
      
      toggleStrategySelectionPanel(strategies, function(strategy) {
        // 处理返回的策略，确保显示名称而不是对象
        const selectedStrategies = Array.isArray(strategy) ? strategy : [strategy];
        customHeroStrategies[heroId].hero = selectedStrategies.length === 1 ? selectedStrategies[0] : selectedStrategies;
        heroStrategyValue.text = selectedStrategies.map(s => s.name).join(', ');
        $.Msg(`为 ${heroId} 设置英雄策略: ${heroStrategyValue.text}`);
      }, currentStrategy, lastSelectedRef);
    });
    
    return heroId;
  }

  // 添加一个新的辅助函数来获取英雄名称
  function getHeroName(heroId) {
    if (!heroId) return "未选择英雄";
    return heroData && heroData[heroId] ? heroData[heroId].name : (heroId || "未知英雄");
  }



  // 添加一个用于更新策略行可见性的辅助函数
  function updateStrategyRowVisibility(heroId) {
    // 检查是否选择了英雄且开启了AI
    const hero = customHeroes[heroId];
    const hasSelectedHero = hero && hero.heroId && hero.heroId !== '';
    const isAIEnabled = hero && hero.aiEnabled;
    
    $.Msg(`检查 ${heroId} 策略行显示条件: 已选择英雄=${hasSelectedHero}, AI已开启=${isAIEnabled}`);
    
    // 获取策略行面板
    const strategyRow = $(`#${heroId}Row4`);
    if (!strategyRow) {
      $.Msg(`警告: 找不到 ${heroId} 的策略行面板`);
      return;
    }
    
    // 同时获取技能阈值按钮
    const skillThresholdButton = $(`#${heroId}SkillThresholdButton`);
    
    // 只有同时满足两个条件才显示策略行和技能阈值按钮
    if (hasSelectedHero && isAIEnabled) {
      // 显示策略行
      strategyRow.RemoveClass('GameSetupPanelhidden');
      $.Msg(`显示 ${heroId} 的策略行`);
      
      // 显示技能阈值按钮
      if (skillThresholdButton) {
        skillThresholdButton.style.visibility = 'visible';
        $.Msg(`显示 ${heroId} 的技能阈值按钮`);
      }
    } else {
      // 隐藏策略行
      strategyRow.AddClass('GameSetupPanelhidden');
      $.Msg(`隐藏 ${heroId} 的策略行`);
      
      // 隐藏技能阈值按钮
      if (skillThresholdButton) {
        skillThresholdButton.style.visibility = 'collapse';
        $.Msg(`隐藏 ${heroId} 的技能阈值按钮`);
      }
    }
  }

  // 添加函数：加载英雄技能阈值数据到输入框中
  function loadSkillThresholdData(heroId) {
    $.Msg(`加载 ${heroId} 的技能阈值数据`);
    
    // 确保customHeroes[heroId]存在
    if (!customHeroes[heroId]) {
      $.Msg(`警告: ${heroId} 数据不存在`);
      return;
    }
    
    // 确保skillThresholds对象存在
    if (!customHeroes[heroId].skillThresholds) {
      customHeroes[heroId].skillThresholds = {};
      
      // 初始化技能阈值数据
      for (let i = 1; i <= 6; i++) {
        customHeroes[heroId].skillThresholds[`skill${i}`] = {
          hpThreshold: 100,
          distThreshold: 0,
          level: getDefaultSkillLevel(i)
        };
      }
    }
    
    // 确保teamMode对象存在
    if (!customHeroes[heroId].teamMode) {
      customHeroes[heroId].teamMode = { enabled: false };
    }
    
    // 确保skillWeights对象存在
    if (!customHeroes[heroId].skillWeights) {
      customHeroes[heroId].skillWeights = {};
      // 初始化权重值
      for (let i = 1; i <= 6; i++) {
        customHeroes[heroId].skillWeights[`skill${i}`] = 0
      }
    }
    
    // 设置团队模式勾选框状态
    const teamModeToggle = $(`#${heroId}TeamModeToggle`);
    if (teamModeToggle) {
      teamModeToggle.checked = customHeroes[heroId].teamMode.enabled;
      // 显示或隐藏权重输入框
      toggleTeamModeInputs(heroId, customHeroes[heroId].teamMode.enabled);
    }
    
    // 遍历所有技能，加载阈值数据到输入框
    for (let i = 1; i <= 6; i++) {
      const skillData = customHeroes[heroId].skillThresholds[`skill${i}`] || { 
        hpThreshold: 100, 
        distThreshold: 0, 
        level: getDefaultSkillLevel(i)
      };
      
      const hpThresholdInput = $(`#${heroId}Skill${i}HpThreshold`);
      const distThresholdInput = $(`#${heroId}Skill${i}DistThreshold`);
      
      if (hpThresholdInput && distThresholdInput) {
        hpThresholdInput.text = skillData.hpThreshold.toString();
        distThresholdInput.text = skillData.distThreshold.toString();
        
        // 加载技能等级 - 仅针对技能1-3和大招
        if (i <= 3 || i === 6) {
          const levelSelector = $(`#${heroId}Skill${i}LevelSelector`);
          if (levelSelector) {
            const level = typeof skillData.level === 'number' ? skillData.level : getDefaultSkillLevel(i);
            
            // 更新选中状态
            const maxLevel = getMaxSkillLevel(i);
            for (let l = 0; l <= maxLevel; l++) {
              const btn = $(`#${heroId}Skill${i}Level${l}`);
              if (btn) {
                if (l === level) {
                  btn.AddClass('SelectedLevel');
                } else {
                  btn.RemoveClass('SelectedLevel');
                }
              }
            }
            
            // 保存当前选中的等级
            levelSelector.selectedLevel = level;
          }
        }
        
        // 加载权重数据 - 对所有技能
        const weightInput = $(`#${heroId}Skill${i}Weight`);
        if (weightInput) {
          const weight = customHeroes[heroId].skillWeights[`skill${i}`] || 0;
          weightInput.text = weight.toString();
        }
        
        $.Msg(`已加载技能${i}的阈值: HP=${skillData.hpThreshold}, 距离=${skillData.distThreshold}, 等级=${skillData.level !== undefined ? skillData.level : '未设置'}, 权重=${customHeroes[heroId].skillWeights[`skill${i}`] || '未设置'}`);
      } else {
        $.Msg(`警告: 无法找到技能${i}的输入框`);
      }
    }
    
    // 更新技能阈值按钮状态
    updateSkillThresholdButtonState(heroId);
  }

  // 添加新函数：检查并更新技能阈值按钮状态
  function updateSkillThresholdButtonState(heroId) {
    // 确保英雄数据存在
    if (!customHeroes[heroId] || !customHeroes[heroId].skillThresholds) {
        return;
    }
    
    // 检查是否有任何技能阈值被修改过
    let isModified = false;
    for (let i = 1; i <= 6; i++) {
        const skillData = customHeroes[heroId].skillThresholds[`skill${i}`];
        
        // 检查生命值阈值和距离阈值是否被修改
        if (skillData && (skillData.hpThreshold !== 100 || skillData.distThreshold !== 0)) {
            isModified = true;
            break;
        }
        
        // 检查技能等级是否被修改（针对技能1-3和大招）
        if ((i <= 3 || i === 6) && skillData) {
            const defaultLevel = getDefaultSkillLevel(i);
            if (skillData.level !== defaultLevel) {
                isModified = true;
                break;
            }
        }
    }
    
    // 获取技能阈值按钮
    const skillThresholdButton = $(`#${heroId}SkillThresholdButton`);
    if (skillThresholdButton) {
        // 根据是否修改过设置按钮样式
        if (isModified) {
            skillThresholdButton.AddClass('ModifiedThresholdButton');
            $.Msg(`${heroId} 的技能阈值已修改，添加高亮样式`);
        } else {
            skillThresholdButton.RemoveClass('ModifiedThresholdButton');
            $.Msg(`${heroId} 的技能阈值是默认值，移除高亮样式`);
        }
    }
  }

  // 添加新函数：显示或隐藏团队模式下的权重输入框
  function toggleTeamModeInputs(heroId, show) {
      // 只针对有等级设置的技能（技能1、2、3和终极技能/技能6）
      const skillsWithLevel = [1, 2, 3, 6];
      
      // 遍历这些技能，显示或隐藏权重输入框
      skillsWithLevel.forEach(skillIndex => {
          const weightContainer = $(`#${heroId}Skill${skillIndex}WeightContainer`);
          if (weightContainer) {
              weightContainer.style.visibility = show ? 'visible' : 'collapse';
          }
      });
  }

  // 添加新函数：初始化技能权重值
  function initializeSkillWeights(heroId) {
      // 只针对有等级设置的技能（技能1、2、3和终极技能/技能6）
      const skillsWithLevel = [1, 2, 3, 6];
      
      // 默认权重设置：大招40，其他技能每个20
      const defaultWeights = {};
      let totalWeight = 0;
      
      // 为每个技能设置默认权重
      skillsWithLevel.forEach(skillIndex => {
          const weight = skillIndex === 6 ? 0 : 0; // 大招40，普通技能20
          defaultWeights[`skill${skillIndex}`] = weight;
          totalWeight += weight;
          
          // 更新UI
          const weightInput = $(`#${heroId}Skill${skillIndex}Weight`);
          if (weightInput) {
              weightInput.text = weight.toString();
          }
      });
      
      // 保存权重值
      if (!customHeroes[heroId].skillWeights) {
          customHeroes[heroId].skillWeights = {};
      }
      
      // 将权重保存到customHeroes对象中
      skillsWithLevel.forEach(skillIndex => {
          customHeroes[heroId].skillWeights[`skill${skillIndex}`] = defaultWeights[`skill${skillIndex}`];
      });
      
      // 为技能4和5设置默认权重为0（因为它们没有等级设置）
      customHeroes[heroId].skillWeights[`skill4`] = 0;
      customHeroes[heroId].skillWeights[`skill5`] = 0;
      
      $.Msg(`已初始化 ${heroId} 的技能权重值: ${JSON.stringify(defaultWeights)}`);
  }

})();
  