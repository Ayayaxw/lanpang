function startCountdown() {
  const countdownText = $('#CountdownText');
  const BlurOverlayStyle = $('#blurOverlay');
  const countdownValues = ['3', '2', '1'];
  let index = 0;

  function updateCountdown() {
    // 重置样式
    BlurOverlayStyle.style.opacity = '1';
    countdownText.RemoveClass('AnimateIn');
    countdownText.RemoveClass('AnimateOut');
    countdownText.style.transitionDuration = '0s';
    countdownText.style.transform = 'scale3d(2, 2, 1)';
    countdownText.style.opacity = '1';

    // 设置新文本
    countdownText.text = countdownValues[index];

    // 开始动画，模拟弹跳效果
    let animationDuration = 0.9; // 动画持续时间
    let animationStep = 0.016; // 约每帧更新一次
    let baseScale = 1;  // 初始化基础缩放比例

    function animate(elapsed) {
      if (elapsed < animationDuration) {
        baseScale = 1 + Math.sin(elapsed * Math.PI * 6) * 5 / Math.exp(elapsed * 12);
        countdownText.style.transform = `scale3d(${baseScale}, ${baseScale}, 1)`;
        countdownText.style.opacity = 1 - elapsed / animationDuration;
        $.Schedule(animationStep, () => animate(elapsed + animationStep));
      } else {
        countdownText.style.opacity = '0';
        countdownText.style.transform = 'scale3d(1, 1, 1)';
        index++;
        if (index < countdownValues.length) {
          $.Schedule(animationStep, updateCountdown); // 延迟到下一次更新
        } else {
          $.Schedule(animationStep, startFighting); // 倒计时结束后显示"开始!"
        }
      }
    }

    // 立即启动动画
    animate(0);
  }

  updateCountdown();
}

function startFighting() {
  const countdownText = $('#CountdownText');
  const BlurOverlayStyle = $('#blurOverlay');

  // 重置样式
  BlurOverlayStyle.style.opacity = '1';
  countdownText.RemoveClass('AnimateIn');
  countdownText.RemoveClass('AnimateOut');
  countdownText.style.transitionDuration = '0s';
  countdownText.style.transform = 'scale3d(2, 2, 1)';
  countdownText.style.opacity = '1';

  // 设置文本为"开始!"
  countdownText.text = '开始!';

  // 动画参数
  let animationDuration = 0.9;
  let firstPhaseDuration = 0.2;
  let secondPhaseDuration = 0.2;
  let thirdPhaseDuration = 0.2;
  let animationStep = 0.016;
  let baseScale = 1;

  function animate(elapsed) {
    if (elapsed < animationDuration) {
      if (elapsed < firstPhaseDuration) {
        // 第一阶段动画
        baseScale = 1 + Math.sin(elapsed * Math.PI * 6) * 5 / Math.exp(elapsed * 12);
        countdownText.style.transform = `scale3d(${baseScale}, ${baseScale}, 1)`;
      } else if (elapsed < firstPhaseDuration + secondPhaseDuration) {
        // 第二阶段动画，保持状态
        countdownText.style.transform = `scale3d(${baseScale}, ${baseScale}, 1)`;
      } else {
        // 第三阶段动画
        BlurOverlayStyle.style.opacity = '0';
      }

      countdownText.style.opacity = 1 - elapsed / animationDuration;
      $.Schedule(animationStep, () => animate(elapsed + animationStep));
    } else {
      countdownText.style.opacity = '0';
      countdownText.style.transform = 'scale3d(1, 1, 1)';
    }
  }

  // 立即启动动画
  animate(0);
}
