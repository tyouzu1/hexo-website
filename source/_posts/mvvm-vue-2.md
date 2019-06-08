---
title: 简易实现一个 Vue（2）【开始造轮子】
date: 2019-06-08 23:39:02
tags: Vue
---
因为之前找工作换工作，找工作一个月，入职两个多月，一致在忙来忙去的，博客也搁置了一段时间，现在想想也蛮后悔的，不能总是半途而废，赶紧回来补课。把之前的东西写完，今后好好的继续学习吧，最好能够保持每周一更。加油吧。

上一篇 [简易实现一个 Vue（1）【原理解析】](/blog/2019/06/08/mvvm-vue-2/) 讲完了大概的基本原理，现在正式开始造轮子啦，试着写一个简单的 Vue
<!-- more -->

<!-- # 整合Vue -->

<!-- ## constructor 初始化 -->
---待更新状态
<!-- ```js 
class Vue{
  constructor(options = {}){
    this.$el = document.querySelector(options.el);
    let data = this.data = options.data; 
    // 代理data，使其能直接this.xxx的方式访问data，正常的话需要this.data.xxx
    Object.keys(data).forEach((key)=> {
        this.proxyData(key);
    });
    this.methods = options.methods // 事件方法
    this.watcherTask = {}; // 需要监听的任务列表
    this.observer(data); // 初始化劫持监听所有数据
    this.compile(this.$el); // 解析dom
  }
}
``` -->