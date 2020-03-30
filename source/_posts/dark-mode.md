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

写的时候突然脑洞大开，利用`mix-blend-mode`，做了一个反色的背景版。如果整体配色合适的话，用`mix-blend-mode`也许能够刚刚好配合出一个新的主题呢。当然，也一定要小心谨慎，因为`mix-blend-mode`会覆盖当前层级的所有展示，也许会影响你文中的图片展示。

回到主题，在知道如何判定dark模式之后，只需要根据不通模式，区分一下样式即可。

比如可以利用 `@media (prefers-color-scheme: dark)`来区分dark模式，修改需要改动的样式或者 css 变量。

但是由于是使用 media 来自动切换，如果需要支持手动修改主题，也就变得更麻烦。所以如果要支持手动切换主题的话，更适合使用动态修改标签类名等功能（如 body、body.dark等 ）来进行切换。

我在博客中使用了 media 来区分 dark 模式下的变量，使用 matchMedia 监听系统本身的主题，使用 localStorage 来存储用户已经选择的主题。

```html
<!-- 有点无聊，用 checkbox 和 css变量 组合了一下 ，写了个 switch 来切换主题。 -->
<div class="switch-box">
  <input id="checked_1" type="checkbox" class="switch"  value="0"0 />
  <label for="checked_1">
  <script>
  (function(){
    var dark = document.getElementById('checked_1')
    var body = document.body
    var theme = window.localStorage.getItem('theme')
    var darkMedia = window.matchMedia('(prefers-color-scheme: dark)')
    function darkModeListener() {
      console.log(darkMedia.matches)
      dark.checked = !!darkMedia.matches
    }
    darkMedia.addListener(darkModeListener)
    if(theme==='dark'){
      dark.checked = true
    }else if(theme==='light'){
      dark.checked = false
    }else {
      darkModeListener()
    }
    bodyDarkToggle(dark.checked)
    dark.onclick = (e)=>{
      window.localStorage.setItem('theme',e.target.checked ? 'dark' : 'light')
      bodyDarkToggle(e.target.checked)
    }
    function bodyDarkToggle(checked){
      // 切换body伤的dark样式
      if(checked){
        body.classList.add('dark') 
      }else {
       body.classList.remove('dark')
      }
    }
  })()
  </script>
    <dark-bg></dark-bg>
    <dark-mode></dark-mode>
  </label>
</div>
```
我使用`@media (prefers-color-scheme: dark)`来确定无缓存的默认情况下是否启用 dark 模式的样式，使用了动态的`body:not(.dark)`和`body.dark`来增加缓存下来的样式的优先级，防止被 media 中的样式覆盖。


```css
:root {
  --dark: #dcdcdc;
  --light: transparent;
  color-scheme: light dark;
}
:root body:not(.dark){ 
  --bg: var(--light);
  --linkHover: #222;
 --light: transparent;
}
:root body.dark{
  --bg: var(--dark);
  --linkHover: #fff;
}
@media (prefers-color-scheme: dark) {
  :root {
    /* 变量修改变量，集中颜色到一个地方处理 */
    --bg: var(--dark);
    /* 直接修改变量，分开处理颜色 */
    --linkHover: #fff;
  }
}
a:hover {
  /* dark */
  color: var(--linkHover);
}
dark-mode, dark-bg {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  pointer-events: none;
}
dark-mode {
  background: var(--bg);
  mix-blend-mode: difference;
  /* 有zindex层级才会有效，没有 index 和谁去 mix 呢 */
  transition: all 0.5s ease;
}
dark-bg {
  /* 白色小底片，提供给 mix-blend-mode 进行混合 */
  background: #fff;
  z-index: -11;
}
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