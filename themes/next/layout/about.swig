{% extends '_layout.swig' %}
{% import '_macro/post-collapse.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %}{{ __('title.about') }}: {{ page.about }} | {{ title }}{% endblock %}

{% block content %}

  {######################}
  {### ABOUT BLOCK ###}
  {######################}
  <div class="about">
    <h4 class="about-title">关于我</h4>
    <div class="about-container">
      <p>Hi，我是Razio，性别男，爱好女。95年出生于新疆塔城地区，毕业于大连民族大学，程序员。实习和毕业没有去投大厂，错过了最好的时机，恩，好忧伤，后悔也来不及了。</p>
      <a href="https://tyouzu1.github.io/resume/">这里是简历</a>
      <h4>生活：</h4>
      <p>喜欢钻研钻研技术，提升自己，希望有朝一日我也能独当一面。</p>
      <p>喜欢打游戏，和小伙伴们开黑，玩玩LOL、吃鸡、炉石传说啥的。当然最喜欢的还是主机游戏，上古卷轴一类的大作。</p>
      <p>平日里也喜欢运动，经常去跑跑步啥的，希望 9102 年能学会游泳。</p>
      <h4>工作：</h4>
      <p>做事情会有强迫症，要做到最快最好。</p>
      <p>用抽象工厂模式写过 Phaser 的游戏。</p>
      <p>React、Vue 都有过实际的开发经验。大部分时间都去研究了 React，因为它的性能取决于你自己，目前使用 umi + dva 的解决方案。一般普通小项目都会去用 Vue ，额，虽然我研究得少，但至少我现在能保证完成任务。</p>
      <p>其实，我还是喜欢原生 JS 多一点，能用 CSS 的，一定要研究出来。</p>
      <p>小程序写得不要太累，目前正在抽空做一个小程序组件库，虽然用处不大，练练手嘛。</p>
      <p>java 和 Node.js 也都有过尝试。</p>
      <p>打包工具的话，最开始一直用的 webpack，目前正在学着使用 gulp。</p>
    </div>
  </div>
  {##########################}
  {### END ABOUT BLOCK ###}
  {##########################}

  {% include '_partials/pagination.swig' %}

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
