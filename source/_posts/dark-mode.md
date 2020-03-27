---
title: 日常笔记/Dark Mode
date: 2020-03-27 16:04:02
tags: 
categories: 日常笔记
---
没想到连傲娇不羁的微信，都已经屈服于 Apple 爸爸的霸权，开始支持`Dark Mode`。

<!-- more -->
# 识别 dark
在 html 页面中，识别 `Dark Mode` 的方式很多，比如

## `picture` 和 `source` 标签，用来设置不通的图片
```html
<picture>
    <source media="(prefers-color-scheme: dark)" srcset="dark-mode.jpg" />
    <img src="light-mode.jpg" />
</picture>
```

 ## 媒介查询可以支持：
```css
@media (prefers-color-scheme: dark) {
    :root {
        background: black;
        color: white;
    }
}
```
## js 中也可以获取：
```js
var darkMedia = window.matchMedia('(prefers-color-scheme: dark)')
function darkModeListener() {
  console.log(darkMedia.matches) // matches 说明已经匹配到 dark 模式
}
darkMedia.addListener(darkModeListener)
```

# 浏览器 dark

虽然页面中识别了 dark 模式，但是浏览器本身可能也有 dark 的机制。所以，你可以在 html 中使用 `meta` 和 `css` 通知浏览器，告诉他你支持哪些模式，用来触发浏览器的 dark 机制（具体的机制要看了浏览器了）。

## meta 中可以支持： 
```html
<meta name="color-scheme" content="light dark">
<meta name="color-scheme" content="dark">
<meta name="color-scheme" content="light">
```

## css 中可以支持：
```css
:root {
  color-scheme: light dark;
}
:root {
  color-scheme: dark;
}
:root {
  color-scheme: light;
}
```

# 实际应用
我在[博客](https://tyouzu1.github.io/blog)中加了个 switch 按钮，用来切换 `dark mode`。
```html
<div class="switch-box">
  <input id="checked_1" type="checkbox" class="switch"  value="0"0 />
  <label for="checked_1">
  <script>
  (function(){
    var dark = document.getElementById('checked_1')
    // 获取 dark 的 media
    var darkMedia = window.matchMedia('(prefers-color-scheme: dark)')
    function darkModeListener() {
      dark.checked = darkMedia.matches // darkMedia.matches true 表示为 dark 模式
    }
    // 监听系统的 dark 模式切换，自动改变主题
    darkMedia.addListener(darkModeListener)

     // 获取缓存的主题，如果有主题，就切换，没缓存就使用 matchMedia 获取的值
    var theme = window.localStorage.getItem('theme')
     if(theme==='dark'){
      dark.checked = true
    }else if(theme==='light'){
      dark.checked = false
    }else {
      darkModeListener()
    }
    // 用于缓存
    dark.onclick = (e)=>{window.localStorage.setItem('theme',e.target.checked ? 'dark' : 'light')}
  })()
  </script>
    <dark-bg></dark-bg>
    <dark-mode></dark-mode>
  </label>
</div>
```
有点无聊，用 checkbox 和 css变量 组合了一下，不用再写 js 啦～
```css
:root { 
  --dark: #dcdcdc;
  --light: transparent;
  --bg: var(--light);
  color-scheme: light dark;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: var(--dark);
  }
}
dark-mode, dark-bg {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  pointer-events: none;
}
/* 划重点 start */
dark-mode {
  background: var(--bg);
  /* 重中之最简单之 mix-blend-mode */
  mix-blend-mode: difference;
  /* 有zindex层级才会有效，没有 index 和谁去 mix 呢 */
  transition: all 0.5s ease;
}
dark-bg {
  /* 白色小底片，提供给 mix-blend-mode 进行混合 */
  background: #fff;
  z-index: -11;
}
/* 划重点 end */
.switch-box .switch~label {
  /* 正常的 --bg */
  --bg: var(--light);
}
.switch-box .switch:checked~label {
  /* 选中时 ，重写作用域内的 --bg */
  --bg: var(--dark);
}
.switch-box {
  position: absolute;
  top: 70px;
  right: 0;
}
.switch-box .switch {
  display:none;
}
.switch-box label {
  position:relative;
  display: block;
  padding: 1px;
  border-radius: 24px;
  height: 24px;
  width: 50px;
  background-color: #eee;
  cursor: pointer;
  vertical-align: top;
  user-select: none;
}
.switch-box label:before {
  content: '';
  display: block;
  border-radius: 24px;
  height: 100%;
  transition: all 0.3s ease;
}
.switch-box label:after {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 22px;
  height: 22px;
  box-sizing: border-box;
  border-radius: 50%;
  background-color: white;
  transform: translateX(0);
  transition: all 0.3s ease;
}
.switch-box .switch:checked~label:after {
  transform: translateX(26px);
}
```