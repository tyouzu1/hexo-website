---
title: 日常笔记/19-7-15/antd使用问题/关闭浮层/dispatchEvent
date: 2019-07-15 18:29:20
tags: antd
categories: 日常笔记
---
碰见一个问题（后期有空补图）
使用 antd `Select、DatePiker` 等会弹出浮层的组件时，浮层会一直存在，在滚动屏幕时，不会自动关闭浮层。
#### 前提条件：
如果你的 `getPopupContainer`(也可以是类似的功能参数) 未填，默认渲染到body上，但是页面中的 滚动条 并不依赖于 body 而是页面中其他的元素，属于div中的内滚动条。这时，浮层由于是相对于body定位，无论怎么滚动div内滚动条，浮层便会依赖于body定位，永久处于屏幕中的某个位置不变。
如果浮层一直在这个位置，自然会影响我们滚动时看其他数据。
如果将滚动条所在的节点传入 `getPopupContainer` 便不会有这个问题，这是因为浮层会相对于滚动条所在的位置 absolute 定位。
但是当前的场景无法使用 `getPopupContainer`，这时可以用另外一种 hack 的办法。
#### hack
尝试后可知道，在点击出浮层后，点击页面中其他任意位置，便可以关闭浮层。所以可以利用这个方式，在滚动时来关闭浮层。
这时候便可以模拟一个事件来触发这个操作

```js
const input =  document.querySelector('input')
const event = document.createEvent('Events');
event.initEvent('touchstart',true,true);
input.dispatchEvent(event);
```
利用 dispatchEvent 来模拟点击事件，来触发antd的关闭浮层的操作。（至于为什么是touchstart，可以自己看看源码，或者直接点击测试）