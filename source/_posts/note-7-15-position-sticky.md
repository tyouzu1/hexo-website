---
title: 日常笔记/19-7-15/position-sticky使用问题
date: 2019-07-15 18:29:35
tags: 
  - sticky
  - css
categories: 日常笔记
---
css中 `position:sticky` 这个属性的兼容性也在慢慢提升，我在项目中也有了实际应用，比如固定表头、页头等。
首先，sticky会根据附近的父节点的 `overflow` 属性来定位，如果 `overflow` 是 `hidden`，那么便不会有滚动条，与`position:sticky`的功能也想违背，也不会进行相应的定位了，等于无效，只有滚动条存在时才会生效。
总的来说，就是如果没有高度，是看不出来 sticky 的效果的。

当想对 table 中的表头进行定位时，在 chrome 中 thead 是无法使用`position:sticky`的，但是 th 标签可以。
```css
thead th{
  position: sticky;
  top: 0;
}
```