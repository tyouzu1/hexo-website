---
title: 日常笔记/创建一个可以返回 promise 的 action
date: 2020-02-25 23:32:15
tags: 
  - redux-saga
  - promise
categories: 日常笔记
---
在使用 saga 时，有时会有一种场景：

* 在页面中 dispatch 了一个 action，这个 action 在 saga 中也有注册。
* 在触发完 saga 中注册的 generator 函数后，需要触发回调，通知页面做一些操作。
* 但是由于场景限制必须在页面中触发回调，亦或是使用页面中的数据（放到 saga 的 generator 中看起来会异类）。

<!-- more -->

## 实现

最开始实现，往 saga 中传入 paload 参数的同时，增加了一个 callback 参数，虽然能用，单毕竟不优雅，并且每次使用都需要写很多的重复代码，这显然不符合程序员逻辑。

于是经过改良，模仿 dva ，写了一个回传 promise 的 action。
```js
// reducer.js
export const createPromiseAction = (key) => ((payload, resolve, reject) => ({
  type: key, payload, resolve, reject,
}));
actions = createPromiseAction('ACTION')

// saga.js
function* fetchDemoAsync({ payload, resolve, reject }) {
  try {
    const res = yield call(fetchAsync, payload );
    if (res && res.state === 'success') {
      resolve(res.result);
    } else {
      reject(res);
    }
  } catch (error) {
    reject();
  }
}

// 页面.js
function bindPromiseActionCreator(actionCreator, dispatch) {
  return function (payload, ...others) {
    if (others.length) {
      console.error('暂时只能传入一个 payload 参数，其他参数暂不支持');
    }
    return new Promise((resolve, reject) => {
      dispatch(actionCreator(payload, resolve, reject));
    });
  };
}
@connect(
  state => ({
    Store: state.demo,
  }),
  dispatch => ({
    Action: bindPromiseActionCreator(actions, dispatch),
  }),
)
class Demo extends React.Component {
...
  componentDidMount() {
   this.props.Action(data).then(res=>{
     console.log(res)
   })
  }
}

```
如此以来，把 action 的返回值 改为了 promise，这样便能在页面中直接使用 `.then` 的操作，或者直接使用 `async await` 来进行操作。

## 参考

[redux-saga issues](https://github.com/redux-saga/redux-saga/issues/161#issuecomment-229350795)