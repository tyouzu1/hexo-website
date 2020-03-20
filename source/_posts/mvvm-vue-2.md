---
title: 简易实现一个 Vue（2）
date: 2019-06-08 23:39:02
tags: Vue
categories: 简易实现一个 Vue
---
因为之前找工作换工作，找工作一个月，入职两个多月，一致在忙来忙去的，博客也搁置了一段时间，现在想想也蛮后悔的，不能总是半途而废，赶紧回来补课。把之前的东西写完，今后好好的继续学习吧，加油。

上一篇 [简易实现一个 Vue（1）【原理解析】](/blog/2019/06/08/mvvm-vue-2/) 讲完了大概的基本原理，现在照着Vue自己写一个。
说是自己写，思路一样的话，大概也就和照抄差不多，算个简易可拓展版的
具体代码在我的[github](https://github.com/tyouzu1/vue-mvvm)
<!-- more -->

# 目标用例
```html
<div id="app">
  <div>
    Vue
    <p class="add" @click="add" >点我点我number:{{number}}</p>
    <a href="https://tyouzu1.github.io">{{message}}</a>
    <!--这里是---注释 -->
  </div>
</div>
<script>
var app = new Vue({
  el: '#app',
  data: {
    number: 1,
    message: "tyouzu1.github.io"
  },
  methods: {
    add() {
      this.number = this.number+1
    }
  }
})  
</script>
```
# 基本结构

首先是整个代码的基本构成

```js
// 主体
class Vue {
  constructor(options={}){
    const vm = this
    vm.$options = {
      ...options
    }
    vm.data = vm.$options.data
    this._initData(vm.data);
    this._initMethods(vm.$options.methods)
    vm.$options.el = document.querySelector(vm.$options.el)
    vm.$mount(vm.$options.el)
  }
}
// 虚拟DOM
class VNode {
  constructor(tag, data, children,text, context){
  this.tag = tag;
  this.data = data;
  this.children = children;
  this.text = text;
  this.context = context;
  }
}
// 订阅数据
class Observer {
  constructor(value,vm){
    this.value = value;
    this.vm = vm
    this.walk(value);
    this.dep = new Dep();
  }
}
// 监听
class Watcher {
  constructor (vm, Fn) {
    this.vm = vm
    this.Fn = Fn
    this.depIds = new Set(); // 存储depId
    this.value = this.getThis()// 需要最后执行。第一次渲染
  }
}
// 订阅、触发指令
class Dep {
  constructor() {
    this.id = uuid ++ 
    this.subscribes = [];
  }
}
```

# 初始化Vue
```js
constructor(options={}){
  const vm = this
  vm.$options = {  //这里是传入的配置
    ...options
  }
  vm.data = vm.$options.data  // 这里是data 也就是this
  this._initData();   // 
  this._initMethods(vm.$options.methods)
  vm.$options.el = document.querySelector(vm.$options.el)
  vm.$mount(vm.$options.el)  // 挂在组件
}
```
首先初始化一下数据，最后进行第一次渲染
# 绑定数据
下面是`_initData`
```js
_initData() {
  const vm = this
  const data = vm.data;
  for (let key in data){
    //把data中的属性输出到this上
    Object.defineProperty(vm, key, {
      enumerable: true,
      configurable: true,
      get: function(){
        return this.data[key]
      },
      set: function(val){
        this.data[key] = val;
      },
    });
  }
  this._observer = new Observer(data,vm) //订阅数据
}
```
使用`Object.defineProperty`把**data**属性中的值输出到**this**上，现在可以使用`this.number`了
```js
_initMethods(methods) {
    for(let fn in methods){
      this[fn] = methods[fn]
    }
  }
```
把方法输出到this上，或者使用其他方法，只要实现`this.add`即可
# Observer 监听
然后创建**Observer**实例，检测数据的变动
这里直接使用**Proxy**来监听数据，在开始时`get`时订阅数据，`set`时触发依赖
```js
class Observer {
  constructor(value,vm){
    this.value = value;
    this.vm = vm
    this.walk(value);
    this.dep = new Dep();
  }
  walk (obj) {
    var dep = new Dep();
    const vm =  this.vm
    vm.data = new Proxy(obj, {
      get (target, key) {
        const data = target[key]
        if(Dep.target){// 第一次加载this.data时 Dep.target 有值，可以绑定依赖
          dep.depend();
        }
        return data
      },
      set(target,key,value){
        let res =  Reflect.set(target, key, value)
        dep.notify();
        return res
      }
    })
  }
}
```
# Dep 订阅、触发依赖
**Dep**用于订阅依赖和触发依赖
以下是**Dep**
```js
class Dep {
  constructor() {
    this.id = uuid ++ 
    this.subscribes = [];
  }
  depend() {
    Dep.target&&Dep.target.addDep(this); //Dep.target已经变成了Watcher，绑定依赖,把自己传到Watcher那边
  }
  addSubscribe(subscribe) {
    this.subscribes.push(subscribe);
  }
  notify() {
    const subscribes = this.subscribes;
    for (let i = 0;i < subscribes.length; i++) {
      subscribes[i].update(); //依次触发依赖
    }
  }
}
```
# mount  挂载
然后第一次挂载DOM，
```js
$mount() {
  const vm = this
  const options = vm.$options
  let template = options.template
  // 获取整个 innerHTML 包括节点本身
  if(!template||typeof template !== 'string'){
    const container = document.createElement('div')
    container.appendChild(el.cloneNode(true))
    template = container.innerHTML
  }
  const { render } = vm.compile(template)
  vm._renderProxy = new Proxy(vm, {
    has (target, key) {
      var has = key in target;
      var isAllowed = typeof key === 'string' && key.charAt(0) === '_' && !(key in target.data);
      return has || !isAllowed
    }
  });
  vm._c = function(tag,data,children){return new VNode(tag, data, children,undefined, vm); }
  vm._v = createTextVNode
  vm._e = createEmptyVNode
  vm._s = _s
  const renderFn = createFunction(render)
  vm.$options.render = renderFn
  vm._wachers = new Watcher(vm,()=>{
    const vnode = vm._render();
    vm.$el = this._patch(null,vnode);
    vm._vnode = vnode
  })
}
```

通过`compile`方法获取生成虚拟DOM的render方法，再传入this上的函数与数据，生成最终的 **vnode**
`_s _e _v`方法主要是生成文本
`_c`为生成Vnode实例，结构化数据

# compile 编译模版
这里是 `compile`
```js
compile(template){
  const ast = this._parse(template.trim()) //先转化为AST数据
  const code = this._generate(ast)  //再转化为生成虚拟DOM的代码
  return {
    ast,
    render: ("with(this){return " + code + "}"), //传入this变量  可以看下with的用法
  }
}
```
`_parse`函数中主要是把`template`使用正则，把**HTML**生成为**JSON**数据，网上有很多方法，我的实现在[github](https://github.com/tyouzu1/vue-mvvm)
数据格式基本为
```js
{
  type: 1, // parse 中会标记节点类型 1 标签 2 有模版js{{}}的文本 3 文本 
  tag: 'div',  // 相应节点是什么 
  attrs : {id: 'root'}, // 节点属性
  children: [  // 节点孩子属性
    {
      type: 1, // parse 中会标记节点类型
      tag: 'p', // 相应节点是什么 
      attrs: {},// 节点属性
      children: [ // 节点孩子属性
        {
          type: 2,  // parse 中会标记节点类型
          text: 'person的名字{{person.name}}', // 节点文本
          expression: '"person的名字" + _s(person.name)' // 节点的js
        }
      ]
    }
  ]
}
```
`_generate`函数把ast化的数据，再一次Vue化，比如一些`click` `v-if`等特性，都在这里处理，变成js代码，最终生成出 **可生成虚拟DOM的 js 代码** 的代码，供给`render`函数调用
最后使用`with`属性，使生成的code可以调用**Vue**实例上的`this`属性，即可使用函数和数据，`_s(person.name)`便可以生成出一个字符串文本。
# render
调用`_render`即可生成出虚拟DOM，将所有的模版数据都编译好，输出成最终的文本
```js
_render() {
  const vm = this
  return vm.$options.render.call(vm._renderProxy, vm.$createElement);
}
```
# patch 插入DOM
现在已经有了虚拟DOM，通过`patch`即可插入到真实DOM中
```js
_patch(oldVnode,newVnode) {
  const vm = this
  const parent = this.$options.el.parentNode
  createElement(parent,newVnode,true)
  return newVnode.elm
}
```
时间有限，没有写 diff，其实可以参照[snabbdom](https://github.com/snabbdom/snabbdom)
`createElement`可以创建节点，文本等，也可以绑定一些事件等
# Watcher 监听
最后，**Watcher**是监听器，收到**Dep**消息后，便会触发`_update`进行更新，重新计算虚拟DOM，再次进行`patch`，输出到真实DOM中
```js
class Watcher {
  constructor (vm, Fn) {
    this.vm = vm
    this.Fn = Fn
    this.depIds = new Set(); // 存储depId
    this.value = this.getThis()// 需要最后执行。第一次渲染
  }
  addDep(dep){
    if (!this.depIds.has(dep.id)) {
      dep.addSubscribe(this);//获取Dep实例，把自己的Watcher实例发送过去
      this.depIds.add(dep.id)
    }
  }
  update () {
    Promise.resolve().then(()=>{
      this.vm._update()
    })
  }
  getThis(){
    Dep.target = this
    this.Fn&&this.Fn() // 第一次渲染在这里 Dep.target 有值，绑定依赖
    Dep.target = null
  }
}
```

# 写在最后
到最后，和Vue的基本结构已经差不太多了，主要就是一些特性（v-if等指令），事件等，需要细心耐心的去写去做。
其实好好看看，已经是相对很简单了。