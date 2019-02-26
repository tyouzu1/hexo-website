---
title: 函数防抖 和 函数节流 （debounce and throttle）
date: 2019-02-25 17:34:58
tags: 函数
---
在前端开发过程中，我们经常会绑定一些事件，例如click、resize、scroll事件，但是这些事件无法控制触发频率，甚至如果用户不停的点击按钮，click事件也会频繁的触发，事件的触发频率变高之后，响应速度也会下降，更可能出现出现页面卡顿，假死现象。
针对这种问题，有两种解决策略，也就是 函数防抖 和 函数节流 （debounce and throttle）
<!-- more -->
# debounce
debounce: 去抖动,防止误动作,防抖动。
其主要思想是：当一个事件触发时，为其设置一个周期用来延期执行动作，如果周期内再次触发则重新设定周期，循环往复直到周期结束之后才执行 要执行的动作。
比如又一个按钮，如果用户点击了多次，会触发多次事件，但是使用了debounce处理之后，事件只会在**周期内用户点击的最后一次**才执行。
这里有三种办法，可以根据实际情况使用。
## 第一种 n秒后执行
每触发一次事件，生成一个定时器，清空之前的定时器，定时器到达时间才会执行函数。
```js
function debounce(fn, time) {
  let timer; // 通过闭包保存定时器变量
  return function () {
    let that = this;
    let args = arguments;
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      fn.apply(that, args)
    }, time);
  }
}

```

## 第二种 立即执行
触发事件后函数立即执行并禁用函数不允许再次调用，在周期结束后解除禁用允许下一次调用函数。
```js
function debounce(fn,time) {
  let timer;
  return function () {
    let that = this;
    let args = arguments;
    if (timer) clearTimeout(timer);
    let allow = !timer;  // 这里做一个限制
    timer = setTimeout(() => {
      timer = null;
    }, time)
    if (allow) fn.apply(that, args) // 这里做一个限制
  }
}
```

## 第三种 合体版
以上方法也可以加入一个参数，用于控制是否立即执行
```js
function debounce(fn,time,immediate) {
  let timer;
  return function () {
    let that = this;
    let args = arguments;
    if (timer) clearTimeout(timer);
    if (immediate) { // 这里设置是否启用立即执行
      let able = !timer;
      timer = setTimeout(() => {
        timer = null;
      }, time)
      if (able) fn.apply(that, args)
    } else {
      timer = setTimeout(()=>{
        fn.apply(that, args)
      }, time);
    }
  }
}
```

# throttle
throttle: 节流阀,节流阀,节流。
其主要思想是：**使连续触发的事件在一个周期内只执行一次**，在周期内如果有新事件触发不予执行，周期结束后有事件则触发一次并开始新的周期。实际上就是稀释了执行频率。
主要用于处理事件高频触发的情况，使动作定期执行。
## 第一种 使用定时器
与debounce第一种的区别是，debounce需要清空并重新生成定时器。throttle是等待定时器执行完，然后在生成定时器。
```js
function throttle(fn, time) {
  let timer;
  return function() {
    let that = this;
    let args = arguments;
    if (!timer) {
      timer = setTimeout(() => {
        timer = null;
        fn.apply(that, args)
      }, time)
    }
  }
}
```

## 第二种 立即执行 + 开关
与debounce第一种的区别是，debounce需要清空并重新生成定时器。throttle是等待定时器执行完，然后在生成定时器。
```js
function throttle(fn, time, immediate) {
  let timer;
  return function() {
    let that = this;
    let args = arguments;
    if (!timer) {
      if(immediate){
        fn.apply(that, args)
        timer = setTimeout(() => {
          timer = null;
        }, time)
      }else {
        timer = setTimeout(() => {
          timer = null;
          fn.apply(that, args)
        }, time)
      }
    }
  }
}
```

## 第三种 使用时间戳
使用时间戳可以避免生成定时器，利用时间来判定事件是否可以执行。
```js
function throttle(fn, time) {
    let prev = 0;
    return function() {
        let now = Date.now();
        let that = this;
        let args = arguments;
        if (now - prev > time) { // 对比时间差
            fn.apply(that, args);
            prev = now;
        }
    }
}
```

还有很多种方法，这里只是简单的介绍一下思路。具体可以参考lodash的[`_.debounce`](https://lodash.com/docs/#debounce) 、[`_.throttle`](https://lodash.com/docs/#throttle) 等。

使用方法如下：
```js
function handleClick(){
  console.log('click')
}
function handleMove(){
  console.log('move')
}
window.onclick = debounce(handleClick,800)
window.onmousemove = throttle(handleMove,800)
```