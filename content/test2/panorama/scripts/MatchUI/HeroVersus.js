
    // GameEvents.Subscribe("show_hero", function(event) {
    //     // 添加日志以查看接收到的数据
    //     $.Msg("Received event data: ", JSON.stringify(event, null, 2));
    //     showHeroVersus(selfHeroId, opponentHeroId, event.selfFacets, event.opponentFacets);
    // });
/*         function changeHeroToAxe() {
            $.Msg("准备更换英雄为Axe");
            $.Schedule(3, function() {
            var scene = $('#Greenpanel_1');  // 获取实际的DOTAScenePanel元素
        
            // 执行Lua脚本
            

            scene.SetScenePanelToLocalHero(131);



            //     $.Schedule(1, function() {
            //     scene.ReloadScene()
            // });
            $.Schedule(1, function() {

            scene.FireEntityInput("*",'StartGestureOverride',"ACT_DOTA_SPAWN")
            });
            // scene.FireEntityInput(
            //     "*",
            //     "RunScriptCode",
            //     `
            //     if thisEntity:GetClassname() == 'dota_item_wearable' then
            //         thisEntity:SetContextThink('delete',function() UTIL_Remove(thisEntity)  end,0)
            //     end
            // `)


            $.Msg("已尝试更换英雄为Axe");
            });
        }
        // 调用函数
        // changeHeroToAxe();*/
        // $.Schedule(0, function() {
        //     showHeroVersus(75, 106,leftHeroFacet,rightHeroFacet)
        //   }); 

// 在文件顶部添加这个辅助函数
function reverseString(str) {
  return str.split('').reverse().join('');
}

function showHeroVersus(leftHeroID, rightHeroID, leftHeroFacet, rightHeroFacet, time) {
  const leftFacet = Object.values(leftHeroFacet)[0];
  const rightFacet = Object.values(rightHeroFacet)[0];

  $("#TimeCountdown").text = time;

  // 获取面板和场景元素
  var mainButtonContainer = $("#MainButtonContainer");
  var hideDefaultButton = $("#HideMenuButton");
  var buttonLabel = hideDefaultButton.FindChildTraverse("HideMenuButtonLabel");
  var isHidden = mainButtonContainer.BHasClass("hidden");
  $("#HUDContainer").AddClass("hidden");
  $("#CustomHeroStatsRoot").AddClass("hidden");
  if (isHidden) {
  } else {
      mainButtonContainer.AddClass("hidden");
      $.Msg("添加hidden类");
  }
  if (buttonLabel.text === "隐藏菜单") {
      buttonLabel.text = "显示菜单";
  } else {
      buttonLabel.text = "隐藏菜单";
  }

  var container = $('#HeroVersusContainer');
  var leftScene = $('#leftHeroScene');
  var rightScene = $('#rightHeroScene');
  var leftHero = $('#leftHero');
  var rightHero = $('#rightHero');

  // 检查是否为"反转了"模式
  const isReversedMode = $('#CurrentGameModeLabel').text.includes('反转');
  $.Msg("当前游戏模式: " + $('#CurrentGameModeLabel').text);

  // 设置左侧英雄
  if (heroData[leftHeroID]) {
      $.Msg("左侧英雄存在");
      if (!heroData[leftHeroID].facingRight) {
          leftHero.AddClass('flip');
          $.Msg("左侧英雄已经翻转");
      } else {
          leftHero.RemoveClass('flip');
      }

      let scaleX = heroData[leftHeroID].avatarFacingRight ? 1 : -1;

      $('#HeroPortraitLeft').style.transform = `scaleX(${scaleX})`;

      if (scaleX === -1) {
          $.Msg("左侧英雄头像已经翻转");
      }

      // 设置左侧英雄名称和命石
      let heroNameElement = $('#LeftHeroNameEnglish');
      let heroNameChineseElement = $('#LeftHeroNameChinese');
      let heroFacetNameElement = $('#LeftHeroFacetName');
      let heroName1Element = $('#LeftHeroName1');

      if (isReversedMode) {
        // 在"反转了"模式下，对左侧英雄进行反转处理
        heroNameElement.text = reverseString(heroData[leftHeroID].englishName);
        heroNameChineseElement.text = reverseString(heroData[leftHeroID].name);
        $('#LeftHeroName').text = reverseString(heroData[leftHeroID].name);
    
        // 上下颠倒左侧英雄形象并向上移动一定的像素
        let adjustedHeight = heroData[leftHeroID].heightAdjust + 20;
        leftScene.style.transform = `translateY(${adjustedHeight}%) scaleY(-1)`;
    
        // 头像保持原样，不进行反转和移动
        $('#HeroPortraitLeft').style.transform = `scaleX(${scaleX})`;
    
        const facetToken = "#DOTA_Tooltip_Facet_" + leftFacet.name;
        const abilityToken = "#DOTA_Tooltip_Ability_" + leftFacet.abilityName;
        
        const facetLocalized = $.Localize(facetToken);
        if (facetLocalized !== facetToken) {
            // 如果Facet本地化存在
            heroFacetNameElement.text = reverseString(facetLocalized);
            heroName1Element.text = reverseString(facetLocalized);
        } else {
            // 如果Facet本地化不存在，尝试使用Ability本地化
            heroFacetNameElement.text = reverseString($.Localize(abilityToken));
            heroName1Element.text = reverseString($.Localize(abilityToken));
        }
    } else {
        // 正常模式下的逻辑
        heroNameElement.text = heroData[leftHeroID].englishName;
        heroNameChineseElement.text = heroData[leftHeroID].name;
        $('#LeftHeroName').text = heroData[leftHeroID].name;
    
        leftScene.style.transform = `translateY(${heroData[leftHeroID].heightAdjust}%)`;
        $('#HeroPortraitLeft').style.transform = `scaleX(${scaleX})`;
    
        const facetToken = "#DOTA_Tooltip_Facet_" + leftFacet.name;
        const abilityToken = "#DOTA_Tooltip_Ability_" + leftFacet.abilityName;
        
        const facetLocalized = $.Localize(facetToken);
        if (facetLocalized !== facetToken) {
            // 如果Facet本地化存在
            heroFacetNameElement.text = facetLocalized;
            heroName1Element.text = facetLocalized;
        } else {
            // 如果Facet本地化不存在，尝试使用Ability本地化
            heroFacetNameElement.text = $.Localize(abilityToken);
            heroName1Element.text = $.Localize(abilityToken);
        }
    }

      // 调整左侧英雄名字的字体大小
      let nameLength = heroData[leftHeroID].englishName.length;
      if (nameLength > 15) {
          heroNameElement.style.fontSize = '62px';
      } else if (nameLength > 10) {
          heroNameElement.style.fontSize = '72px';
      } else {
          heroNameElement.style.fontSize = '82px';
      }

      // 设置左侧英雄头像
      var leftHeroPortrait = $('#HeroPortraitLeft');
      if (leftHeroPortrait) {
          leftHeroPortrait.heroname = 'npc_dota_hero_' + heroData[leftHeroID].codeName;
      }

      // 设置左侧英雄属性图标
      let leftShieldIcon = $('#leftShieldIcon');
      if (leftShieldIcon) {
          let attribute = heroData[leftHeroID].heroAttribute;
          let attributeIconPath = '';

          switch (attribute) {
              case 1:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex';
                  break;
              case 2:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex';
                  break;
              case 4:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex';
                  break;
              case 8:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_all_psd.vtex';
                  break;
              default:
                  $.Msg("未知的英雄属性");
                  break;
          }

          if (attributeIconPath) {
              leftShieldIcon.SetImage(attributeIconPath);
          }
      }
  }

  // 设置右侧英雄
  if (heroData[rightHeroID]) {
      $.Msg("右侧英雄存在");
      if (heroData[rightHeroID].facingRight) {
          rightHero.AddClass('flip');
          $.Msg("右侧英雄已经翻转");
      } else {
          rightHero.RemoveClass('flip');
      }

      let scaleX = heroData[rightHeroID].avatarFacingRight ? -1 : 1;

      $('#HeroPortraitRight').style.transform = `scaleX(${scaleX})`;

      if (scaleX === -1) {
          $.Msg("右侧英雄头像已经翻转");
      }

      // 设置右侧英雄名称和命石
      let heroNameElement = $('#RightHeroNameEnglish');
      let heroNameChineseElement = $('#RightHeroNameChinese');
      let heroFacetNameElement = $('#RightHeroFacetName');
      let heroName1Element = $('#RightHeroName1');

      // 无论是否为"反转了"模式，右侧英雄都保持正常显示
      heroNameElement.text = heroData[rightHeroID].englishName;
      heroNameChineseElement.text = heroData[rightHeroID].name;
      $('#RightHeroName').text = heroData[rightHeroID].name;

      rightScene.style.transform = `translateY(${heroData[rightHeroID].heightAdjust}%)`;
      $('#HeroPortraitRight').style.transform = `scaleX(${scaleX})`;

      const facetToken = "#DOTA_Tooltip_Facet_" + rightFacet.name;
      const abilityToken = "#DOTA_Tooltip_Ability_" + rightFacet.abilityName;
      
      const facetLocalized = $.Localize(facetToken);
      if (facetLocalized !== facetToken) {
          // 如果Facet本地化存在
          heroFacetNameElement.text = facetLocalized;
          heroName1Element.text = facetLocalized;
      } else {
          // 如果Facet本地化不存在，尝试使用Ability本地化
          heroFacetNameElement.text = $.Localize(abilityToken);
          heroName1Element.text = $.Localize(abilityToken);
      }

      // 调整右侧英雄名字的字体大小
      let nameLength = heroData[rightHeroID].englishName.length;
      if (nameLength > 15) {
          heroNameElement.style.fontSize = '62px';
      } else if (nameLength > 10) {
          heroNameElement.style.fontSize = '72px';
      } else {
          heroNameElement.style.fontSize = '82px';
      }

      // 设置右侧英雄头像

      var rightHeroPortrait = $('#HeroPortraitRight');
      if (rightHeroPortrait) {
        rightHeroPortrait.heroname = 'npc_dota_hero_' + heroData[rightHeroID].codeName;
      }

      // 设置右侧英雄属性图标
      let rightShieldIcon = $('#rightShieldIcon');
      if (rightShieldIcon) {
          let attribute = heroData[rightHeroID].heroAttribute;
          let attributeIconPath = '';

          switch (attribute) {
              case 1:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex';
                  break;
              case 2:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex';
                  break;
              case 4:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex';
                  break;
              case 8:
                  attributeIconPath = 's2r://panorama/images/primary_attribute_icons/primary_attribute_icon_all_psd.vtex';
                  break;
              default:
                  $.Msg("未知的英雄属性");
                  break;
          }

          if (attributeIconPath) {
              rightShieldIcon.SetImage(attributeIconPath);
          }
      }
  }

  // 在设置场景面板后调用这个函数
  leftScene.SetScenePanelToLocalHero(leftHeroID);
  rightScene.SetScenePanelToLocalHero(rightHeroID);

  // 为左边的英雄应用特定装备
  applyHeroSpecificItems(leftScene, leftHeroID);

  // 为右边的英雄应用特定装备
  applyHeroSpecificItems(rightScene, rightHeroID);

  // 移除主容器的hidden类
  container.RemoveClass('hidden');

  // 0.5秒后移除其他所有元素的hidden类
  $.Schedule(1, function() {
      $.Schedule(0.1, function() {
          if (leftHeroID !== 126) {
              leftScene.FireEntityInput("*", 'StartGestureOverride', "ACT_DOTA_SPAWN");
          }

          if (rightHeroID !== 126) {
              rightScene.FireEntityInput("*", 'StartGestureOverride', "ACT_DOTA_SPAWN");
          }
      });
      $('#RightHeroNameContainer').RemoveClass('hidden');
      $('#LeftHeroNameContainer').RemoveClass('hidden');
      $('#HeroVersusTopBar').RemoveClass('hidden');
      $('#HeroVersusBottomBar').RemoveClass('hidden');
      $('#Left_Hero').RemoveClass('hidden');
      $('#Right_Hero').RemoveClass('hidden');
      $('#VersusSymbol').RemoveClass('hidden');
      $('#HeroVersusBackground').RemoveClass('hidden');
      var hud = GetHud();
      var panelToHide = "lower_hud";

      var lowerHudPanel = hud.FindChildTraverse(panelToHide);
      if (lowerHudPanel) {
          lowerHudPanel.visible = false;
          $.Msg("隐藏面板: " + panelToHide);
      } else {
          $.Msg("找不到面板: " + panelToHide);
      }
  });

  // 5秒后开始隐藏
  $.Schedule(5, function() {
      $('#RightHeroNameContainer').AddClass('hidden');
      $('#LeftHeroNameContainer').AddClass('hidden');
      $('#Left_Hero').AddClass('hidden');
      $('#Right_Hero').AddClass('hidden');
      $('#VersusSymbol').AddClass('hidden');
      $('#HeroVersusBackground').AddClass('hidden');

      var hud = GetHud();
      var panelToShow = "lower_hud";

      var lowerHudPanel = hud.FindChildTraverse(panelToShow);
      if (lowerHudPanel) {
          lowerHudPanel.visible = true;
          $.Msg("显示面板: " + panelToShow);
      } else {
          $.Msg("找不到面板: " + panelToShow);
      }
      $.Schedule(0.5, function() {
          $('#HeroVersusTopBar').AddClass('hidden');
          $('#HeroVersusBottomBar').AddClass('hidden');
          $("#HUDContainer").RemoveClass("hidden");
          $("#CustomHeroStatsRoot").RemoveClass("hidden");
      });
      // 3秒后隐藏主面板
      $.Schedule(3, function() {
          container.AddClass('hidden');
          leftHero.RemoveClass('flip');
          rightHero.RemoveClass('flip');
      });
  });
}


function showSingleHero(heroID, heroFacet) {
    const facet = Object.values(heroFacet)[0];
    

    var mainButtonContainer = $("#MainButtonContainer");
    var hideDefaultButton = $("#HideMenuButton");
    var buttonLabel = hideDefaultButton.FindChildTraverse("HideMenuButtonLabel");
    var isHidden = mainButtonContainer.BHasClass("hidden");
    $("#HUDContainer").AddClass("hidden");
    $("#CustomHeroStatsRoot").AddClass("hidden");

    if (!isHidden) {
        mainButtonContainer.AddClass("hidden");
        $.Msg("添加hidden类");
    }
    if (buttonLabel.text === "隐藏菜单") {
        buttonLabel.text = "显示菜单";
    } else {
        buttonLabel.text = "隐藏菜单";
    }   
    
    var container = $('#HeroVersusContainer');
    var leftScene = $('#leftHeroScene');
    var leftHero = $('#leftHero');
  
    // 检查是否为"反转了"模式
    const isReversedMode = $('#CurrentGameModeLabel').text.includes('反转');
    $.Msg("当前游戏模式: " + $('#CurrentGameModeLabel').text);
  
    // 设置英雄 
    if (heroData[heroID]) {
        $.Msg("英雄存在");
        if (!heroData[heroID].facingRight) {
            leftHero.AddClass('flip');
            $.Msg("英雄已经翻转");
        } else {
            leftHero.RemoveClass('flip');
        }
  
        let scaleX = heroData[heroID].avatarFacingRight ? 1 : -1;
        
        $('#HeroPortraitLeft').style.transform = `scaleX(${scaleX})`;
        
        if (scaleX === -1) {
            $.Msg("英雄头像已经翻转");
        }
  
        leftScene.style.transform = `translateY(${heroData[heroID].heightAdjust}%)`;
  
        // 设置英雄名称和命石
        let heroNameElement = $('#LeftHeroNameEnglish');
        let heroNameChineseElement = $('#LeftHeroNameChinese');
        let heroFacetNameElement = $('#LeftHeroFacetName');
        let heroName1Element = $('#LeftHeroName1');
  
        if (isReversedMode) {
            heroNameElement.text = reverseString(heroData[heroID].englishName);
            heroNameChineseElement.text = reverseString(heroData[heroID].name);
            $('#LeftHeroName').text = reverseString(heroData[heroID].name);
        
            let adjustedHeight = heroData[heroID].heightAdjust + 20;
            leftScene.style.transform = `translateY(${adjustedHeight}%) scaleY(-1)`;
            
            $('#HeroPortraitLeft').style.transform = `scaleX(${scaleX})`;
        
            const facetToken = "#DOTA_Tooltip_Facet_" + facet.name;
            const abilityToken = "#DOTA_Tooltip_Ability_" + facet.abilityName;
            
            const facetLocalized = $.Localize(facetToken);
            if (facetLocalized !== facetToken) {
                heroFacetNameElement.text = reverseString(facetLocalized);
                heroName1Element.text = reverseString(facetLocalized);
            } else {
                heroFacetNameElement.text = reverseString($.Localize(abilityToken));
                heroName1Element.text = reverseString($.Localize(abilityToken));
            }
        } else {
            heroNameElement.text = heroData[heroID].englishName;
            heroNameChineseElement.text = heroData[heroID].name;
            $('#LeftHeroName').text = heroData[heroID].name;
        
            leftScene.style.transform = `translateY(${heroData[heroID].heightAdjust}%)`;
            $('#HeroPortraitLeft').style.transform = `scaleX(${scaleX})`;
        
            const facetToken = "#DOTA_Tooltip_Facet_" + facet.name;
            const abilityToken = "#DOTA_Tooltip_Ability_" + facet.abilityName;
            
            const facetLocalized = $.Localize(facetToken);
            if (facetLocalized !== facetToken) {
                heroFacetNameElement.text = facetLocalized;
                heroName1Element.text = facetLocalized;
            } else {
                heroFacetNameElement.text = $.Localize(abilityToken);
                heroName1Element.text = $.Localize(abilityToken);
            }
        }
  
        let nameLength = heroData[heroID].englishName.length;
        if (nameLength > 15) {
            heroNameElement.style.fontSize = '62px';
        } else if (nameLength > 10) {
            heroNameElement.style.fontSize = '72px';
        } else {
            heroNameElement.style.fontSize = '82px';
        }
  
        var leftHeroPortrait = $('#HeroPortraitLeft');
        if (leftHeroPortrait) {
            var heroPortraitUrl = 's2r://panorama/images/heroes/selection/npc_dota_hero_' + heroData[heroID].codeName + '.png';
            leftHeroPortrait.SetImage(heroPortraitUrl);
        }
    }
  
    // 设置场景面板
    leftScene.SetScenePanelToLocalHero(heroID);
    
    // 应用特定装备
    applyHeroSpecificItems(leftScene, heroID);
    
    // 移除主容器的hidden class
    container.RemoveClass('hidden');
    
    // 0.5秒后显示相关元素
    $.Schedule(1, function() {
      $.Schedule(0.1, function() { 
        if (heroID !== 126) {

          leftScene.FireEntityInput("*", 'StartGestureOverride', "ACT_DOTA_SPAWN");
        }
      });
      $('#LeftHeroNameContainer').RemoveClass('hidden');
      $('#HeroVersusTopBar').RemoveClass('hidden');
      $('#HeroVersusBottomBar').RemoveClass('hidden');
      $('#Left_Hero').RemoveClass('hidden');
  
      var hud = GetHud();
      var panelToHide = "lower_hud";
  
      var lowerHudPanel = hud.FindChildTraverse(panelToHide);
      if (lowerHudPanel) {
        lowerHudPanel.visible = false;
        $.Msg("隐藏面板: " + panelToHide);
      } else {
        $.Msg("找不到面板: " + panelToHide);
      }
    });
    
    // 3秒后开始隐藏
    $.Schedule(5, function() {
      $('#LeftHeroNameContainer').AddClass('hidden');
      $('#Left_Hero').AddClass('hidden');
      
      var hud = GetHud();
      var panelToShow = "lower_hud";
  
      var lowerHudPanel = hud.FindChildTraverse(panelToShow);
      if (lowerHudPanel) {
        lowerHudPanel.visible = true;
        $.Msg("显示面板: " + panelToShow);
      } else {
        $.Msg("找不到面板: " + panelToShow);
      }
      $.Schedule(0.5, function() {
        $('#HeroVersusTopBar').AddClass('hidden');
        $('#HeroVersusBottomBar').AddClass('hidden');
      });
      // 0.3秒后隐藏主面板
      $.Schedule(3, function() {
        container.AddClass('hidden');
        leftHero.RemoveClass('flip');
      });
    });
  }


function applyHeroSpecificItems(scene, heroID) {
    switch (heroID) {
        case 75: // 沉默术士的ID
            scene.ReplaceEconItemSlot(0, 12414, 0);
            scene.ReplaceEconItemSlot(1, 12826, 0);
            scene.ReplaceEconItemSlot(5, 13921, 0);
            scene.ReplaceEconItemSlot(4, 13923, 0);
            scene.ReplaceEconItemSlot(8, 13924, 0);
            break;
        case 13: // 沉默术士的ID
            scene.ReplaceEconItemSlot(1, 6709, 0);
            scene.ReplaceEconItemSlot(2, 6671, 0);
            scene.ReplaceEconItemSlot(3, 6709, 0);
            scene.ReplaceEconItemSlot(4, 6709, 0);
            scene.ReplaceEconItemSlot(5, 6709, 0);
            scene.ReplaceEconItemSlot(6, 6671, 0);
            scene.ReplaceEconItemSlot(7, 6671, 0);
            scene.ReplaceEconItemSlot(8, 6671, 0);
            scene.ReplaceEconItemSlot(9, 6671, 0);
            scene.ReplaceEconItemSlot(10, 13767, 0);
            $.Msg("为帕克更换冠军服饰");

            break;
        // 可以在这里添加其他英雄的case
        // case 76:
        //     // 为ID为76的英雄设置装备
        //     break;
    }
}




  // 辅助函数，用于打印 Facet 数据
  function PrintFacets(facets) {
    for (var id in facets) {
      var facet = facets[id];
      $.Msg("  Facet ID " + id + ":");
      $.Msg("    名称: " + facet.name);
      $.Msg("    颜色: " + facet.color);
      $.Msg("    渐变ID: " + facet.gradientId);
      $.Msg("    图标: " + facet.icon);
    }
  }
var leftNumber = 80;  // 左边的初始数字
var rightNumber = leftNumber+1;  // 右边的初始数字
// 设置每隔 8 秒执行一次
function scheduleNext() {
    if (leftNumber <= 150 && rightNumber <= 150) {
        showHeroVersus(leftNumber, rightNumber);
        leftNumber += 2;  // 左边数字每次增加 2
        rightNumber += 2;  // 右边数字每次增加 2

        // 8秒后调度下一次调用
        $.Schedule(10.0, scheduleNext);
    }
}

var leftHeroFacet = {
    2: {
      name: "nevermore_shadowmire",
      color: "Red",
      gradientId: 0,
      icon: "slow"
    }
  };
  
  var rightHeroFacet = {
    2: {
      name: "hoodwink_treebounce_trickshot",
      color: "Green",
      gradientId: 0,
      icon: "tree"
    }
  };




  function showHeroVersus_demo(leftHeroID, rightHeroID, leftHeroFacet, rightHeroFacet) {
    const leftFacet = Object.values(leftHeroFacet)[0];
    const rightFacet = Object.values(rightHeroFacet)[0];
    
      // 获取面板和场景元素
      var mainButtonContainer = $("#MainButtonContainer");
      var hideDefaultButton = $("#HideMenuButton");
      var buttonLabel = hideDefaultButton.FindChildTraverse("HideMenuButtonLabel");
      var isHidden = mainButtonContainer.BHasClass("hidden");
      if (isHidden) {
      } else {
          mainButtonContainer.AddClass("hidden");
          $.Msg("添加hidden类");
      }
      if (buttonLabel.text === "隐藏菜单") {
          buttonLabel.text = "显示菜单";
      } 
      else {
          buttonLabel.text = "隐藏菜单";
      }   
    
      var container = $('#HeroVersusContainer');
      var leftScene = $('#leftHeroScene');
      var rightScene = $('#rightHeroScene');
      var leftHero = $('#leftHero');
      var rightHero = $('#rightHero');
  
      $('#RightHeroNameContainer').AddClass('hidden');
      $('#LeftHeroNameContainer').AddClass('hidden');
      $('#Left_Hero').AddClass('hidden');
      $('#Right_Hero').AddClass('hidden');
      $('#VersusSymbol').AddClass('hidden');
      $('#HeroVersusBackground').AddClass('hidden');
    
      // 设置英雄 
      if (heroData[leftHeroID]) {
          $.Msg("左侧英雄存在");
          if (!heroData[leftHeroID].facingRight) {
              leftHero.AddClass('flip');
              $.Msg("左侧英雄已经翻转");
          } else {
              leftHero.RemoveClass('flip');
          }
          leftScene.style.transform = `translateY(${heroData[leftHeroID].heightAdjust}%)`;
  
          // 设置左侧（自己）英雄名称
          let heroNameElement = $('#LeftHeroNameEnglish');
          heroNameElement.text = heroData[leftHeroID].englishName;
          
          let nameLength = heroData[leftHeroID].englishName.length;
          if (nameLength > 15) {
              heroNameElement.style.fontSize = '62px';
          } else if (nameLength > 10) {
              heroNameElement.style.fontSize = '72px';
          } else {
              heroNameElement.style.fontSize = '82px'; // 重置为默认大小
          }
          $('#LeftHeroNameChinese').text = heroData[leftHeroID].name;
          // 获取 Facet 名称并本地化
            if (leftFacet.abilityName && leftFacet.abilityName !== "" && leftFacet.abilityName !== leftFacet.name ) {
              $('#LeftHeroFacetName').text = $.Localize("#DOTA_Tooltip_Ability_" + leftFacet.abilityName);
          } else {
              $('#LeftHeroFacetName').text = $.Localize("#DOTA_Tooltip_Facet_" + leftFacet.name);
          }
      }
      if (heroData[rightHeroID]) {
          $.Msg("右侧英雄存在");
          if (heroData[rightHeroID].facingRight) {
              rightHero.AddClass('flip');
              $.Msg("右侧英雄已经翻转");
          } else {
              rightHero.RemoveClass('flip');
          }
          rightScene.style.transform = `translateY(${heroData[rightHeroID].heightAdjust}%)`;
  
          // 设置右侧（敌人）英雄名称
          let heroNameElement = $('#RightHeroNameEnglish');
          heroNameElement.text = heroData[rightHeroID].englishName;
          
          let nameLength = heroData[rightHeroID].englishName.length;
          if (nameLength > 15) {
              heroNameElement.style.fontSize = '62px';
          } else if (nameLength > 10) {
              heroNameElement.style.fontSize = '72px';
          } else {
              heroNameElement.style.fontSize = '82px'; // 重置为默认大小
          }
  
          $('#RightHeroNameChinese').text = heroData[rightHeroID].name; 
          
            if (rightFacet.abilityName && rightFacet.abilityName !== "" && rightFacet.abilityName !== rightFacet.name ) {
              $('#RightHeroFacetName').text = $.Localize("#DOTA_Tooltip_Ability_" + rightFacet.abilityName);
          } else {
              $('#RightHeroFacetName').text = $.Localize("#DOTA_Tooltip_Facet_" + rightFacet.name);
          }
  
      }
      leftScene.SetScenePanelToLocalHero(leftHeroID);
      rightScene.SetScenePanelToLocalHero(rightHeroID);
    
      // 移除主容器的hidden class
      container.RemoveClass('hidden');
    
      // 0.5秒后移除其他所有元素的hidden class
      $.Schedule(0, function() {
          $.Schedule(0.1, function() {
            leftScene.ReplaceEconItemSlot(0, 12414, 0)
            leftScene.ReplaceEconItemSlot(1, 12826, 0)
            leftScene.ReplaceEconItemSlot(5, 13921, 0)
            leftScene.ReplaceEconItemSlot(4, 13923, 0)
            leftScene.ReplaceEconItemSlot(8, 13924, 0)

        });
            $.Schedule(0.5, function() {
          leftScene.FireEntityInput("*",'StartGestureOverride',"ACT_DOTA_ATTACK")



          
      });
          $('#Left_Hero').RemoveClass('hidden');

          var hud = GetHud();
          var panelToHide = "lower_hud";
      
          var lowerHudPanel = hud.FindChildTraverse(panelToHide);
          if (lowerHudPanel) {
              lowerHudPanel.visible = false;
              $.Msg("隐藏面板: " + panelToHide);
          } else {
              $.Msg("找不到面板: " + panelToHide);
          }
      });
    
      $.Schedule(100, function() {
        $.Schedule(0.1, function() {
        rightScene.FireEntityInput("*",'StartGestureOverride',"ACT_DOTA_VICTORY")
     
    });
        $('#Right_Hero').RemoveClass('hidden');
});
    
  }




// var localizedAbilityName = $.Localize("#DOTA_Tooltip_Ability_dark_seer_vacuum");
// $.Msg("Localized Ability Name: " + localizedAbilityName);

// var abilityList = [
//   "dragon_knight_dragon_tail",
//   "juggernaut_blade_fury",
//   "lina_dragon_slave",
//   "crystal_maiden_crystal_nova",
//   "sven_storm_bolt"
// ];

// var tooltipCount = 0;

// function AddTooltip() {
//   if (tooltipCount >= abilityList.length) {
//       $.Msg("已经显示了所有可用的技能介绍");
//       return;
//   }

//   var tooltipContainer = $("#TooltipContainer");
//   var newTooltipPanel = $.CreatePanel("Panel", tooltipContainer, "Tooltip_" + tooltipCount);
//   newTooltipPanel.AddClass("TooltipPanel");

//   var abilityImage = $.CreatePanel("DOTAAbilityImage", newTooltipPanel, "");
//   abilityImage.abilityname = abilityList[tooltipCount];

//   var tooltipAnchor = $.CreatePanel("Panel", newTooltipPanel, "");
//   tooltipAnchor.AddClass("TooltipAnchor");

//   var TooltipAnchor1 = $.CreatePanel("Panel", newTooltipPanel, "");
//   TooltipAnchor1.AddClass("TooltipAnchor1");


//   $.Schedule(0.1, function() {
//       $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", 
//           tooltipAnchor,
//           abilityList[tooltipCount],
//           -1
//       );
//       $.DispatchEvent("DOTAShowAbilityTooltip", TooltipAnchor1, "item_blink");

//       // 隐藏左箭头
//       $.Schedule(0.1, function() {
//           var tooltipContent = tooltipAnchor.FindChildTraverse("DOTAAbilityTooltip");
//           if (tooltipContent) {
//               tooltipContent.AddClass("HideLeftArrow");
//           }
//       });
//   });

//   tooltipCount++;
// }

// (function() {
//   $("#AddTooltipButton").SetPanelEvent("onactivate", AddTooltip);
// })();
