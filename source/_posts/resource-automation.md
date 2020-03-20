---
title: 日常笔记/前端资源文件自动化加载
date: 2020-03-01 23:12:32
tags: 
  - webpack
  - redux-saga
  - redux
categories: 日常笔记
---
在开发中遇到了这样的问题：（使用 redux 和 saga）

* 每建一个新的页面，需要增加一个 reducer 和 saga 文件。
* 每个 reducer 中需要定义一个独立的 namespace 。
* 每个 reducer 和 saga 文件都需要在入口文件中引入，不然等于无效。
<!-- more -->

## reducer 入口文件

于是在 reducer 的 index 入口文件中，写了这样的代码：
```js
// 利用 require.context 引入当前目录下的所有一级文件，筛选出需要的 js 文件
const files = require.context('./', false, /\.js$/);
const modules = {};
const exclude = ['./', './index.js'];
files.keys().forEach(key => {
  // 排除以下目录
  if (exclude.includes(key)) return;
  // 兼容 macos 和 windows 的路径 \ /
  modules[key.replace(/(\.\/|\.js)/g, '')] = files(key).default;
});
// console.log('自动导入 Reducers ',Object.keys(modules));
export default combineReducers({
  // 文件夹名称即为reducer名称
  ...modules,
});

```
之后，只要在文件加中新增一个新的 reducer 文件，文件便会被自动引入，文件名便是 reducer 的名称。

在 reducer 文件中也可以使用 webpack 中的 `__filename`来自动创建不同的 namespace，防止 action 重复

```js
// [reducer name].js
// 兼容 macos 和 windows 的路径 \ /
const filename = __filename.split(/[\/\\]/).pop().split('.')[0];
// webpack.config.js
node: {
  __filename: true,
},
```

## saga 入口文件

saga入口文件中使用如下代码：
```js
const files = require.context('./', false, /\.js$/);
const modules = {};
const exclude = ['./sagas.js'];
files.keys().forEach(key => {
  // 以下文件例外，不属于saga文件
  if (exclude.includes(key)) return;
  // 兼容 macos 和 windows 的路径 \ /
  modules[key.replace(/(\.\/|\.js)/g, '')] = files(key).default;
});
// console.log('自动导入 Saga ',Object.keys(modules));
let modulesList = [];
Object.keys(modules).forEach(key => {
  modulesList = modulesList.concat(modules[key]);
});

export default function* rootSaga() {
  yield all([
    ...modulesList,
    takeEvery('*', logger),
  ]);
}
```

之后，每次新建一个 saga 文件，都会被自动引入。

## 注意事项

由于使用了 `require.context`, 所以 `tree shaking`会失效。

当然，如果使用的动态加载的 reducer ，可能还需要一些改动，有空来补。

