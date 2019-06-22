---
title: 简易实现一个 Vue（1）【原理解析】
date: 2019-02-28 17:32:10
tags: Vue
categories: 简易实现一个 Vue
---
简单实现一个Vue，还原一些基本功能。当然，实现之前需要先了解它的实现原理。
其实 Vue 的源码确实很清楚了，这里可能讲的也就一知半解，也就是个大概思路。
<!-- more -->

要想实现一个 Vue，还是应该先来理解一下MVVM。（以下源码均为2.6版本，讲解较简单，大概思路）

# 什么是MVVM？

MVVM是`Model View ViewModel`的简写，与MVVM相似的还有MVC、MVP等，主要是为了分离视图（View）和模型（Model）。

主要优点是：低耦合、可重用性、独立开发、可测试。

在前端页面里，Model指的是纯JavaScript对象，View为视图界面，而ViewModel则负责将Model和View关联起来，把Model中的数据同步到View，View中的修改同步给Model。

在Vue中，也是为了View和Model分离之后的数据绑定，构建一个观察者模式，实现响应式，每当Model数据发生改变，自动的修改View，而不是像从前使用jQuery时，获取到数据，手动更新到DOM上。

想要详细的可以去了解一下。
[MVC，MVP 和 MVVM 的图示-阮一峰](http://www.ruanyifeng.com/blog/2015/02/mvcmvp_mvvm.html)、
[界面之下：还原真实的MV*模式](https://github.com/livoras/blog/issues/11)

# 实现Vue的主要要素
* 响应式：观察者模式动态更新View
* 模板解析：解析`.vue`文件中的html代码片段
* 虚拟 DOM：使用diff算法计算需要更新的DOM

# 响应式
想了解响应式可以先看看 Vue 文档中的介绍，[深入响应式原理](https://cn.vuejs.org/v2/guide/reactivity.html)。
## Object.defineProperty
当然，说到响应式，第一个应该说的便是 [**Object.defineProperty**](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty)，
因为目前的Vue依旧是通过数据绑定来实现的，利用**get** **set**来实现读写操作。
说实话，**defineProperty**简直就是老生常谈，我也面过不少求职者，大多都能说出来个1234。
```js
// Object.defineProperty(obj, prop, descriptor) obj: 要在其上定义属性的对象 prop: 要定义或修改的属性的名称。 descriptor: 将被定义或修改的属性描述符。
var person = { name: 'Razio' }
var age = 18
Object.defineProperty(person,'age',{
  enumerable : true, // 可枚举
  configurable : true, // 可配置
  get () {
    return age
  },
  set (next) {
    console.log(`我之前的年龄是${age}，我的新年龄是${next}`);
    age = next
  }
})
console.log(person.age) // 18
person.age = 22;           // 我之前的年龄是18，我的新年龄是22
console.log(person.age)  // 18
```
使用过上面的例子后大概能想到，在 Vue 中修改了model中的数据后，视图view也会进行相应变化，使用**defineProperty**也就是为了监听数据变化，当数据发生变化后收到通知，便能进行视图更新。

虽然说**defineProperty**可以监听数据变化，但是当我们实际使用时，会发现一个另外的问题。
如何监听数组的方法（push pop shift unshift ...）？。
那该怎么办呢？
Vue 的实现办法也比较简单，修改数据的原型方法。当然，并不是修改**Array.prototype**的方法，而是数组本身的方法。
```js
// 以下为基本原理，并不是源码实现
person.hobbies.__proto__ = {
    push(val) {
        console.log('push', val)
        return Array.prototype.push.call(person.hobbies, val)
    },
    pop() {
        console.log('pop')
        return Array.prototype.pop.call(person.hobbies)
    },
    unshift(val) {
        console.log('unshift', val)
        return Array.prototype.unshift.call(person.hobbies, val)
    },
    shift() {
        console.log('shift')
        return Array.prototype.shift.call(person.hobbies)
    }
}
// 这个时候再来执行 person.hobbies.push('美剧')
person.hobbies.push('美剧') //get    push 美剧   
// ...
// 此时 ，person.hobbies数组的方法 都已经被监听到了。同时也没有污染到全局的 Array.prototype
```
## Proxy
**defineProperty**虽然可行，但也并不是最优秀的实现，在ES的不断进化后，[**Proxy**](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Proxy)亦是一种可取代**defineProperty**的方法。当然尤大大自然也知道，所以在 Vue 3.0后的版本都会使用**Proxy**来替代**defineProperty**。
MDN上的解释其实也是言简意赅
`Proxy 对象用于定义基本操作的自定义行为（如属性查找，赋值，枚举，函数调用等）。`
`The Proxy object is used to define custom behavior for fundamental operations (e.g. property lookup, assignment, enumeration, function invocation, etc).`
所以说**Proxy**到底是啥呢，可以干嘛呢？
```js
var person = {
  name : 'Razio'
}
var proxyObj = new Proxy(person, {
  get(target, prop) {
    return prop in target ? target[prop] : '我还没有这个属性哦～'
  },
  set(target, prop, value) {
    console.log(`${value}是啥我不喜欢`)
    target[prop] = value;
  }
})

console.log(proxyObj.name);       // Razio
console.log(proxyObj.age);        // 我还没有这个属性哦～
proxyObj.age = 22;                // 22是啥我不喜欢
console.log(proxyObj.age)         // 22
// 我们在操作一下person
console.log(person.hobbies)         // undefined  
```
可见，在使用了 Proxy 后，通过 Proxy 的实例对象操作 person，可以达到预期的效果，但是操作原来的 person ，设置的拦截功能是无效的。
当然，其实 Proxy 对数组的方法也是可以监听的，这也是它的一大优点。
```js
var person = [{
  name: 'Razio'
}]
var handler = {
  set(target, prop, value) {
    console.log(`set`,target, prop, value)
    return Reflect.set(target, prop, value);
  }
}
var proxyObj = new Proxy(person, handler)
proxyObj.push({name: 'Tyouzu1'}) // set [{…}] 1 {name: "Tyouzu1"}
                                 // set [{…}, {…}] length 2
proxyObj.forEach((item) => {
  console.log(item.name); //  Razio Tyouzu1
});
```
可以看出，数组中的 push 方法已经被监听了。使用**Proxy**可以实现**defineProperty**能实现的功能，并且能更好的解决**defineProperty**不能解决的问题，更是能监听 **Set Map** 等

## 实现 Vue 的 Observer
现在已经知道了如何监听数据变化，可以做一些更多的事情了。
使用 Vue 时，需要这样定义示例。
```js
var vm = new Vue({
  data: {
    name: 'none'
  }
})
```
`Vue` 在接收到 `data（Model）` 后，便会使用`data`创建一个Observer实例。以下是 Observer 的部分[源码](https://github.com/vuejs/vue/blob/2.6/src/core/observer/index.js#L37)。
```js
export class Observer {
  value: any;
  dep: Dep;
  vmCount: number; // number of vms that have this object as root $data
  constructor (value: any) {
    this.value = value
    this.dep = new Dep()
    this.vmCount = 0
    def(value, '__ob__', this)
    if (Array.isArray(value)) { //可以看到 如果是数组 会特殊处理使用observeArray，非数组使用 walk
      if (hasProto) {
        protoAugment(value, arrayMethods)
      } else {
        copyAugment(value, arrayMethods, arrayKeys)
      }
      this.observeArray(value)
    } else {
      this.walk(value)
    }
  }
  walk (obj: Object) {
    const keys = Object.keys(obj)
    for (let i = 0; i < keys.length; i++) {
      defineReactive(obj, keys[i])
    }
  }
  observeArray (items: Array<any>) {
    for (let i = 0, l = items.length; i < l; i++) {
      observe(items[i])
    }
  }
}
```
### observeArray 与 walk
其实一看就明白，遍历所有的`value`，然后把数据交给`defineReactive`，其中 `walk` 用于对象，另一个用于数组。
其实大概想想也能理解，这里其实是为了注册 Model 数据，以便进行数据监听。

### defineReactive
那么就来看一下，在`walk`中调用的 [`defineReactive`](https://github.com/vuejs/vue/blob/2.6/src/core/observer/index.js#L135) 方法，到底有什么用。
```js
/**
 * Define a reactive property on an Object.
 */
export function defineReactive (
  obj: Object,
  key: string,
  val: any,
  customSetter?: ?Function,
  shallow?: boolean
) {
  const dep = new Dep()
  const property = Object.getOwnPropertyDescriptor(obj, key)
  if (property && property.configurable === false) {
    return
  }
  const getter = property && property.get
  const setter = property && property.set
  if ((!getter || setter) && arguments.length === 2) {
    val = obj[key]
  }
  let childOb = !shallow && observe(val)
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get: function reactiveGetter () {
      // 只有第一次会触发绑定依赖，之后就忽略了
      const value = getter ? getter.call(obj) : val
      if (Dep.target) {
        dep.depend()
        if (childOb) {
          childOb.dep.depend()
          if (Array.isArray(value)) {
            dependArray(value)
          }
        }
      }
      return value
    },
    set: function reactiveSetter (newVal) {
      const value = getter ? getter.call(obj) : val
      if (newVal === value || (newVal !== newVal && value !== value)) {
        return
      }
      if (getter && !setter) return
      if (setter) {
        setter.call(obj, newVal)
      } else {
        val = newVal
      }
      childOb = !shallow && observe(newVal)
      dep.notify()
    }
  })
}
```
可以看出，在2.6的版本里面，使用的是**Object.defineProperty**来进行监听非数组类型数据。注释也写到 `Define a reactive property on an Object.`
在 [文件110行](https://github.com/vuejs/vue/blob/2.6/src/core/observer/index.js#L110) 也能看出，`observe`方法其实也大同小异，只是遍历了数组的每个 item 继续使用 **Observer**
### Dep
在定义数据的**get set**时，前者调用了一个 `dep.depend()` 后者调用了一个`dep.notify()`，
在看之前的**Observer**代码，有一行 [`this.dep = new Dep()`](https://github.com/vuejs/vue/blob/2.6/src/core/observer/index.js#L44)

接下来可以追寻到 [Dep文件](https://github.com/vuejs/vue/blob/2.6/src/core/observer/dep.js) 中
```js
/**
 * A dep is an observable that can have multiple
 * directives subscribing to it.
 */
export default class Dep {
  static target: ?Watcher;
  id: number;
  subs: Array<Watcher>;
  constructor () {
    this.id = uid++
    this.subs = []
  }
  depend () {
    if (Dep.target) {
      Dep.target.addDep(this)
    }
  }
  notify () {
    const subs = this.subs.slice()
    for (let i = 0, l = subs.length; i < l; i++) {
      subs[i].update()
    }
  }
}
```
大家都知道，Vue 使用了观察者模式，其实 **Dep** 就是这个观察者模式的实践，`dep.depend()`用来订阅依赖，而`dep.notify()`用于触发依赖。
数据使用了 **set** 后便会订阅依赖，使用 **get** 便会触发依赖。当然，如果没有触发 **set**，也就代表了没有进行订阅依赖。其实这也是 MVVM 中 View 与 Model 之间的联系。
在进行 **get** 时，还有一行`childOb.dep.depend()`，其实对于对象数据类型，对其子属性也有处理（当然是万能的递归啦）。

也可以看一眼官网文档中的介绍图，数据通过 **getter setter** 来通知 **Watcher** 来进行组件重新渲染。
{% asset_img mv-data.png 深入响应式原理 %}

### Watcher

其实看到这里，还是会有很多东西不知道是干嘛的，比如 **Watcher**，`subs[i].update()` ` Dep.target.addDep(this)`,
这时候可以看一下 [**Watcher**的源码](https://github.com/vuejs/vue/blob/2.6/src/core/observer/watcher.js#L26)
也可以找一下在哪里用到过 **Watcher** [lifecycle.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/lifecycle.js#L197)
```js
import Dep, { pushTarget, popTarget } from './dep'
/**
 * A watcher parses an expression, collects dependencies,
 * and fires callback when the expression value changes.
 * This is used for both the $watch() api and directives.
 */
export default class Watcher {
  constructor (
    vm: Component,
    expOrFn: string | Function,
    cb: Function,
    isRenderWatcher?: boolean
  ) {
    this.vm = vm
    if (isRenderWatcher) {vm._watcher = this}
    vm._watchers.push(this)
    this.deep = this.user = false
    this.cb = cb
    this.active = true
    this.deps = []
    this.newDeps = []
    this.depIds = new Set()
    this.newDepIds = new Set()
    this.getter = expOrFn // 获取到了updateComponent
    this.value = this.get() // 执行 get()
  }
  /**
   * Evaluate the getter, and re-collect dependencies.
   */
  get () {
    pushTarget(this)  // 这里的骚操作 联系到了 Dep 中的 Dep.target，传递this， 便可以把当前编译时get的数据添加一个wather
    let value
    const vm = this.vm
    value = this.getter.call(vm, vm) //执行了 传入的expOrFn 即 updateComponent
    if (this.deep) {traverse(value)}
    popTarget()  // 用完就删了
    return value
  }
  /**
   * Add a dependency to this directive.
   */
  addDep (dep: Dep) {  // Dep 中 depend 会触发 addDep ，添加一些 id 以及 dep实例
    const id = dep.id
    if (!this.newDepIds.has(id)) {
      this.newDepIds.add(id)
      this.newDeps.push(dep)
      if (!this.depIds.has(id)) {dep.addSub(this)}
    }
  }
  /**
   * Subscriber interface.
   * Will be called when a dependency changes.
   */
  update () {   //在 Dep 中的 notify 会调用 update ，因为Dep 中的 subs 是 Array<Watcher>
    queueWatcher(this)  // queueWatcher 中使用了nextTick进行异步处理，调用flushSchedulerQueue函数 继续触发 watcher.run()
  }
  /**
   * Scheduler job interface.
   * Will be called by the scheduler.
   */
  run () { // 执行 get ，然后 this.getter.call(vm, vm) 再次触发 传入的expOrFn  即 updateComponent
    if (this.active) {
      const value = this.get()
      if (isObject(value) ||this.deep) {
        const oldValue = this.value
        this.value = value
        if (this.user) {this.cb.call(this.vm, value, oldValue)
        } else {this.cb.call(this.vm, value, oldValue)}
      }
    }
  }
}

new Watcher(vm, updateComponent, noop, {
  before () {
    if (vm._isMounted && !vm._isDestroyed) {
      callHook(vm, 'beforeUpdate')
    }
  }
}, true /* isRenderWatcher */)
```
最后结合上下文，`pushTarget(this)`控制了`Dep.target`的值，传递了 **Watcher** 的实例过去，在之前 `Object.defineProperty`中调用的`Dep.target`也就是有了值，也就是绑定了 **Watcher**，所以触发 **set** 时，才会触发 notify 之后的操作。其实也就是更新视图了。
之前的`dep.notify()`也知道是做什么了
```js
export default class Dep {
  subs: Array<Watcher>;
  notify () {
    const subs = this.subs.slice()
    for (let i = 0, l = subs.length; i < l; i++) {
      subs[i].update()  //subs其实也就是传入的 **Watcher**的实例，调用update()进行更新
    }
  }
}
```
总结一下，基本上流程就是：
1. 组件挂载时，会触发`new Wathcer`,从而触发`Wathcer`中的`this.get()`,使`Dep.target`获得`Watcher`的实例
2. 编译虚拟DOM时，遇到需要展示`this.data`上的数据时（`_s(person.name)`）,就会获取`this.data`上的数据从而触发`get`方法，从而触发`dep.depend()`，推入`Wathcer`
3. 更新时，触发`dep.notify()`,触发`Wathcer`,再触发新一次的计算、渲染

# 模板引擎
虽然说数据现在已经能够进行响应式了，数据响应式之后视图 View 又是如何更新呢？
## 模版
在 Vue 中的模版其实就是
```html
<div id="root">
  <p>person的名字{{person.name}}</p>
</div>
```
这段代码对于 Vue 来说，这就它他的模版语法，但是对于浏览器来说，只是一段 Html 代码。
而`{{person.name}}`对于Vue来说，其实是js的中的数据，而对于浏览器只是一个字符串。
Vue 所做的事情其实就是将模版转化为浏览器最终展示的 View 视图。

在 Vue 源码中其实也是有迹可循，在 [compiler](https://github.com/vuejs/vue/blob/2.6/src/compiler/index.js) 中有如下代码
```js
import { parse } from './parser/index'
import { optimize } from './optimizer'
import { generate } from './codegen/index'
import { createCompilerCreator } from './create-compiler'
export const createCompiler = createCompilerCreator(function baseCompile (
  template: string,
  options: CompilerOptions
): CompiledResult {
  const ast = parse(template.trim(), options) //解析器没毛病了 将 html ast 化
  // 根据模版生成 AST（`将非结构化的字符串处理成结构化的 JSON 数据`）。Vue 将模版中的 html 标签、标签的属性、以及 Vue 独特的指令语法（`v-if`、`v-for`等）转换为 JSON 数据。不了解 AST 的可以先去了解一下大概。

  if (options.optimize !== false) {
    // 优化上面生成的 AST 数据，将静态节点标记出来，以后进行 View 更新的时候便能忽略这些无需变化的静态节点，以便提升性能更新效率。
    optimize(ast, options)  // 文件中也有 optimize 的相应注释 ，实际上就是将静态数据标记，不需要改变的节点
  }
  const code = generate(ast, options) //生成 js 代码  生成 render 函数，以将 AST 转化为可执行的 js 函数。
  return {
    ast,
    render: code.render,
    staticRenderFns: code.staticRenderFns
  }
})
```
### 生成 AST
上面的模版通过 AST 语法生成出来的对象如下（使用创建一个 html 引入vue.js，修改源码10935行左右，console出来就可以了）
```js
{
  type: 1, // parse 中会标记节点类型
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
          expression: '"person的名字" + _s(person.name)' // 节点的js，调用_s(person.name)后会触发 get
        }
      ]
    }
  ]
}
```
对于实际的项目中，模版中会有很多不同的形式，各种各样的写法，在 [parser](https://github.com/vuejs/vue/blob/2.6/src/compiler/parser/index.js) 中都有做相应的处理。
Vue 中的 [html-parser](https://github.com/vuejs/vue/blob/2.6/src/compiler/parser/html-parser.js) 使用了 [simplehtmlparsers](http://erik.eae.net/simplehtmlparser/simplehtmlparser.js) 将 html 生成了结构化的数据，具体怎么处理的，其实就是分析出每个 tag 的头尾以及的类型和属性，然后生成一个 AST 的 JSON 对象。
使用 js 的大家一眼就能看出，`expression` 中的 `_s(person.name)`肯定是在执行一个 js 函数，虽然`expression`的属性其实只是一个字符串 `'"person的名字" + _s(person.name)'`， 但是使用 `new Function()`就能创建出一个函数用以调用。
如果你已经知道了 AST ，其实现在也能很好理解了，因为浏览器和 js 本身 都不能解析 Vue 模版，通过 AST ，便能将其转化为 js 可是别的数据，在处理成可渲染的数据发送给浏览器，浏览器便能渲染出来。

### optimize 优化
如果在上面的模版中在添加一些静态节点，具体实现可参看 [optimizer.js](https://github.com/vuejs/vue/blob/2.6/src/compiler/optimizer.js)
```html
<div id="root">
  <p>person的名字{{person.name}}</p>
  <p>这里是不需要改变的数据</p>
</div>
```
此时生成的 AST 数据为 
```js
{
  type: 1,
  tag: 'div',
  attrs: {id: 'root'},
  children: [
    {
      type: 1, // parse 中会标记节点类型
      tag: 'p',// 相应节点是什么 
      children: [
        {
          type: 3,  // parse 中会标记节点类型
          text: '这里是不需要改变的数据', // 节点文本
          static: true
        }
      ],
      static: true
    },
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
      ],
      static: false
    }
  ],
  static: false
}
```
标记 static 属性是为了告诉 Vue，这是一个后期不需要改变的静态节点，今后的 Model 变更导致的 View 更新，与这些 静态节点 不相干。也就是为了在后期进行 diff 的时候，节约成本提升效率。

### 生成 js 代码  生成 render 函数
以上代码会生成一个render字符串，利用`new Function`便能实例化出一个函数
```js
var data = {
  render:`with(this){return _c('div',{attrs:{"id":"root"}},[_c('p',[_v("person的名字"+_s(person.name))]),_c('p',[_v("这里是不需要改变的数据")]),_c('p')])}`,
  staticRenderFns: []
}

var render = new Function(data.render)
render.toString()
// 最终生成 => 
function anonymous() {
  with(this){
    return _c(
      'div',
      {attrs:{"id":"root"}},
      [
        _c(
          'p',
          [
            _v("person的名字"+_s(person.name))
          ]
        ),
        _c(
          'p',
          [
            _v("这里是不需要改变的数据")
          ]
        )
      ])
  }
}
```
Vue 通过这些操作，最终将模版转换成了一个 render 函数，函数中的`_c _v`等，其实在源码中也可以找到，其实就是创建节点的方法，每种类型的节点都会使用不同的函数。并且指令越多，编译出来的数据也会跟多更复杂。

其实在回想上文中，在render函数执行后，调用Model中的被Observe处理过属性时，也会触发 **set**，从而调用`dep.depend()`，进行第一次的订阅依赖。

# 虚拟 DOM
大家都知道，在 Vue 中有着虚拟 DOM 的概念，其实 Vue 中的虚拟 DOM 来源于 [snabbdom](https://github.com/snabbdom/snabbdom)，可见于 [patch.js](https://github.com/vuejs/vue/blob/2.6/src/core/vdom/patch.js)，大概也就是结合 AST 和 DOM，再增加一个 diff 算法，用于对比节点树。

Virtual DOM 其实就是 JS 和 DOM 之间的一个缓存。
**首先先用 JS 的对象结构表示出一个 DOM 树的结构（跟上文一样，标签、属性、文本等），并利用这个树形对象结构来创建一个真实的 DOM 结构，添加到文档中去。（初次构建）**
**当 Model 中的数据发生变化，需要影响到 View 时，构造一棵新的对象树，然后与旧的树进行对比，并且记录差异。（diff）**
**最后，把记录的差异实际变更到最开始构建的真实 DOM 树上，也就更新了视图 View。（数据变更）**

先来了解一下snabbdom
在 snabbdom 的 [Inline example](https://github.com/snabbdom/snabbdom#inline-example)中也可以看出是如何构建虚拟 DOM 的
```js
var snabbdom = require('snabbdom');
var patch = snabbdom.init([ // Init patch function with chosen modules
  require('snabbdom/modules/class').default, // makes it easy to toggle classes
  require('snabbdom/modules/props').default, // for setting properties on DOM elements
  require('snabbdom/modules/style').default, // handles styling on elements with support for animations
  require('snabbdom/modules/eventlisteners').default, // attaches event listeners
]);
var h = require('snabbdom/h').default; // helper function for creating vnodes

var container = document.getElementById('container');// 第一次创建时，获取容器节点

var vnode = h('div#container.two.classes', {on: {click: someFn}}, [// h 函数接收 js 对象结构的 DOM 树，创建出一个 vnode，并且绑定一些事件等。
  h('span', {style: {fontWeight: 'bold'}}, 'This is bold'),
  ' and this is just normal text',
  h('a', {props: {href: '/foo'}}, 'I\'ll take you places!')
]);
// Patch into empty DOM element – this modifies the DOM as a side effect
patch(container, vnode);// patch 函数将 vnode 输出到 container 容器中，也就能渲染出第一次的视图了

var newVnode = h('div#container.two.classes', {on: {click: anotherEventHandler}}, [  // 在向 h 函数传入新的 js 对象结构的 DOM 树，生成新的 vnode
  h('span', {style: {fontWeight: 'normal', fontStyle: 'italic'}}, 'This is now italic type'),
  ' and this is still just normal text',
  h('a', {props: {href: '/bar'}}, 'I\'ll take you places!')
]);
// Second `patch` invocation
// 再次调用 patch 函数 传入新的 vnode，在 patch 中其实会通过 diff 来进行对比，有区别的部分才会进行更新
patch(vnode, newVnode); // Snabbdom efficiently updates the old view to the new state 
```

了解了虚拟 DOM，在 Vue 中的应用其实也一目了然。
Vue 通过解析模版生成了 `render` 函数，调用 `render` 函数其实就可以生成 vnode，在 vnode 时会获取并调用 Model 中的数据，便会订阅依赖。之后通过`patch`创建到 html 中，渲染出真实的 DOM。
当 Model 中的数据发生变化后，便会触发依赖，重新执行 render 函数，生成新的 vnode，在`patch`中进行 diff，最后更新需要变更的部分。

在上文 [**Watcher**](#Watcher) 中介绍的 Watcher 时的 [lifecycle.js](https://github.com/vuejs/vue/blob/2.6/src/core/instance/lifecycle.js#L169) 中，也可以发现`vm._render() vm._update()`的影子，其实 Vue 就是在这里绑定的监听，用于调用 render 函数进行更新视图。
在想一下之前的 **Watcher** 与 **Dep** ，结合来看，也就大概了解Vue的运行顺序及其原理了，点到为止。

正式造 Vue 可见下篇 [简易实现一个 Vue（2）](/blog/2019/06/08/mvvm-vue-2/)
