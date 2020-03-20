---
title: 日常笔记/tree shaking
date: 2020-03-08 22:25:56
tags: 
  - webpack
  - tree shaking
categories: 日常笔记
---

`tree shaking` 是一个术语，简而言之就是为了减少代码的体积。在 rollup 、webpack中均有实现， 推荐在个人库文件中使用 rollup 进行 tree shaking。

<!-- more -->

# 先说要素

* Use ES2015 module syntax (i.e. import and export).
* Ensure no compilers transform your ES2015 module syntax into CommonJS modules (this is the default behavior of the popular Babel preset @babel/preset-env - see the [documentation](https://babel.docschina.org/docs/en/babel-preset-env#modules) for more details).
* Add a "sideEffects" property to your project's package.json file.
* Use the production mode configuration option to enable various optimizations including minification and tree shaking.

* 使用 ES2015 模块语法（即 import 和 export）。
* 确保没有 compiler 将 ES2015 模块语法转换为 CommonJS 模块（这也是流行的 Babel preset 中 @babel/preset-env 的默认行为 - 更多详细信息请查看 [文档](https://babel.docschina.org/docs/en/babel-preset-env#modules)）。
* 在项目 package.json 文件中，添加一个 "sideEffects" 属性。
* 通过将 mode 选项设置为 production，启用 minification(代码压缩) 和 tree shaking。

# 实际使用

## 标记无用代码

在实际使用中，可以发现，如果使用的 webpack 版本为 3 或 4 ，无需修改 @babel/preset-env 的配置。而 webpack v2 需要修改 preset-env 的 modules 属性。

而对于 sideEffects 属性 ，实际有两个配置的地方，一个是`package.json`中，一个是 **webpack 的配置文件**中的`optimization`中。

`package.json`中的 sideEffects 属性表示库文件中有无副作。

 webpack 配置文件中则表示的是：**是否识别第三方库文件中的 `package.json` 中的 sideEffects  属性**，当然，webpack是默认开启这个配置的

在使用了 sideEffects 属性后，在**未压缩的 build 出的文件**中会发现有 `unused harmony export` 的注释，代表着该变量是未使用的变量。当然，如果你的 sideEffects 没有配置正确，没有忽略掉一些具有副作用的文件，会导致这个注释不准确，会错误的标记一些变量。

所以一般应该这样使用
```json
{
  "sideEffects": [
    "*.css"  //由于css中可以引入css， @import './style.css';  但是 import 进来后并没有赋值变量并且使用，所以一般需要忽略 css 文件
  ]
}
```
亦或是文件中有一些影响或者使用全局变量的代码，比如：polyfill等， 都是有副作用的代码，都需要在 sideEffects 中进行忽略。

## 剔除无用代码

在 webpack 进行标记 unused 后，并没有结束，还需要你使用一些工具才能将这些未使用的代码进行剔除。

如：TerserPlugin，或者 UglifyJsPlugin（不支持es6+的代码），利用这些压缩代码的插件，来进行最后的剔除无用代码的工作。

当然，如果 sideEffects 没有配置好，有用的代码也可能被意外剔除，影响整个程序的使用。

如果代码中有使用 require ，一样会影响 `tree shaking` 的发挥，因为 `tree shaking` 基于 ES6 的 import 、 export，并不能识别 require 进来的代码，即使被 require 进来的代码中含有 import 、 export 也没有作用。

# 参考文献
[webpack tree-shaking](https://webpack.js.org/guides/tree-shaking)

