GameEvents.Subscribe("ShowHorrorMessage", function() {   
    ShowHorrorMessage()
});

//ShowHorrorMessage()
function ShowHorrorMessage() {
    // 获取面板元素
    var container = $('#HorrorMessageContainer');
    var messageText = $('#HorrorMessageText');
    var vignette = $('#vignette');
    var blurOverlay = $('#blurOverlay');
    

    // 重置状态
    messageText.RemoveClass("AnimateIn");
    messageText.RemoveClass("AnimateOut");
    //messageText.text = "他们来了...";
    
    messageText.style.opacity = '0'; // 允许动画从可见开始
    messageText.style.transform = 'scale3d(1,1,1)'; // 缩放初始状态
    
    // 显示容器
    container.style.visibility = 'visible';
    
    // 显示背景效果
    blurOverlay.style.opacity = '0.7';
    
    // 稍后显示暗角效果
    $.Schedule(0.2, function() {
      vignette.style.opacity = '1.0';
    });
    
    // 显示恐怖文本（在顶部）- 明显的出现效果
    $.Schedule(0.4, function() {

      messageText.style.opacity = '1'; // 允许动画从可见开始
      messageText.AddClass("AnimateIn");
      
      // 更明显的文本抖动效果
      var shakeCount = 0;
      var maxShake = 8;
      var shakeInterval = $.Schedule(0.15, function() {
        var xOffset = Math.random() * 6 - 3;
        var yOffset = Math.random() * 6 - 3;
        
        messageText.style.transform = 'translateX(' + xOffset + 'px) translateY(' + yOffset + 'px) scale3d(1.3, 1.3, 1.0)';
        
        shakeCount++;
        if (shakeCount < maxShake) {
          return 0.15;
        } else {
          messageText.style.transform = 'scale3d(1.3, 1.3, 1.0)';
        }
      });
      
      // 文字闪烁效果
      var flashCount = 0;
      var flashInterval = $.Schedule(0.3, function() {
        var flashColor;
        if (flashCount % 2 === 0) {
          flashColor = '#ff4444';
          messageText.style.textShadow = '0px 0px 40px #ff0000, 0px 0px 50px #dd0000, 0px 0px 60px #aa0000';
        } else {
          flashColor = '#ff0000';
          messageText.style.textShadow = '0px 0px 30px #ff0000, 0px 0px 40px #dd0000, 0px 0px 50px #aa0000';
        }
        
        messageText.style.color = flashColor;
        
        flashCount++;
        if (flashCount < 5) {
          return 0.3;
        }
      });
      
      // 一段时间后开始淡出所有元素（缓慢）
      $.Schedule(1.5, function() {
        // 同时开始所有元素的淡出
        messageText.RemoveClass("AnimateIn");
        messageText.AddClass("AnimateOut");
        messageText.style.opacity = '0';
        vignette.style.opacity = '0';
        blurOverlay.style.opacity = '0';
      
        // 动画完全结束后隐藏容器
        $.Schedule(1.5, function() { // 增加等待时间，确保所有过渡效果完成
          container.style.visibility = 'collapse';
        });
      });
    });
  }