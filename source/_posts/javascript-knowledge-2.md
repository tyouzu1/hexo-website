---
title: JavaScript 基础知识（2）—— 浅拷贝 与 深拷贝
date: 2019-02-16 18:15:40
tags: JavaScript
categories: JavaScript 基础知识
---
浅拷贝和深拷贝只针对于像Object，Array这样的复杂对象。之所以会出现深浅拷贝，实质上是因为在JavaScript当中基础类型和引用类型的不同存储方式，可见[上篇](/blog/2019/02/14/javascript-knowledge-1/)。由于对对象的操作实际上是在操作对象的引用，所以在复制一个引用类型时，复制的值并不是对象本身，其实也是对象的引用，即指向该对象的指针。

{% asset_img jk2.png 引用类型的复制 %}
<!-- more -->

```js
// 引用类型的复制
let me = { name: '张瑞', hobbies: ['游戏','旅游'] }
let myCopy = me
console.log(JSON.stringify(myCopy)) // {name:"张瑞",hobbies:["游戏","旅游"]}
me.hobbies.pop()
me.name = "张瑞瑞"
console.log(JSON.stringify(myCopy)) // {name:"张瑞瑞",hobbies:["游戏"]}
```
可以看出，复制的了我的人，复制不了我的心，由于me是个引用类型，在me改变内部属性时，myCopy中的属性也会也都会被改变。
### 浅拷贝
浅拷贝`只复制对象内的第一层属性`，结果对象可能会与源对象还保持着联系。
```js
let me = { name: '张瑞', hobbies: ['游戏','旅游'] }
function shallowCopy(obj) {
  let _obj = {};
  for (key in obj) {
    // 只复制第一层属性
    if (obj.hasOwnProperty(key)) {
      _obj[key] = obj[key];
    }
  }
  return _obj;
}
let myCopy = shallowCopy(me)
console.log(JSON.stringify(myCopy)) // {name:"张瑞",hobbies:["游戏","旅游"]}
me.hobbies.pop()
me.name = "张瑞瑞"
console.log(JSON.stringify(myCopy)) // {name:"张瑞",hobbies:["游戏"]}
```
由于只拷贝了第一层属性，在me改变name这个基本类型的属性时，并不会影响myCopy中的name属性。而改变hobbies这个引用类型的属性时，myCopy中的hobbies也被改变了，这就是浅拷贝：`只复制对象内的第一层属性`。

ES6中新增的Object.assign方法便是一个浅拷贝的实践。`用于对象的合并，将源对象（source）的所有可枚举属性，复制到目标对象（target）`。

通过浅拷贝得到的myCopy的hobbies属性和me的hobbies属性在内存中指向同一个地址，如果想完全的复制一个没有关联的我，这显然并不是期望得到的效果。所以，也就有了 深拷贝。

### 深拷贝
深拷贝可以对`对象内的属性`进行递归复制，拷贝后的新对象与源对象完全断开了联系。

```js
let me = { name: '张瑞', hobbies: { game:['LOL','吃鸡'], other:[] },like:{} }
function deepCopy(obj) {
  let _obj = Array.isArray(obj) ? [] : {};
  for (key in obj) {
    // 还有 typeof obj[key] === 'function',例子暂不需要
    if(typeof obj[key] === 'object'){
      _obj[key] =  deepCopy(obj[key])
    }else {
      _obj[key] = obj[key];
    }
  }
  return _obj;
}
let myCopy = deepCopy(me)
console.log(JSON.stringify(myCopy)) // {"name":"张瑞","hobbies":{"game":["LOL","吃鸡"],"other":[]},"like":{}}
me.hobbies.game.pop()
me.name = "张瑞瑞"
console.log(JSON.stringify(me))     // {"name":"张瑞瑞","hobbies":{"game":["LOL"],"other":[]},"like":{}}
console.log(JSON.stringify(myCopy)) // {"name":"张瑞","hobbies":{"game":["LOL","吃鸡"],"other":[]},"like":{}}
```
不难看出，经过递归后，deepCopy完全的复制了另一个我。
在真正投入使用的时候，由于递归的特性，也会造成很多副作用，如对象环的问题（对象的某个属性值是对象本身），当递归调用次数足够大，就会造成栈溢出。[下面有解决办法](#对象环问题)

其实还有更多的方法，如下
#### Reflect
Reflect 其实类似于 上文中的 `for in` 写法。使用[Reflect.ownKeys](http://es6.ruanyifeng.com/?search=setPrototypeOf&x=8&y=3#docs/reflect#Reflect-ownKeys-target)
```js
// 判断目标是否是对象
function isObject(val) {
  return val != null && typeof val === 'object' && Array.isArray(val) === false;
};
function deepCopy(obj) {
  if (!isObject(obj)) {
    throw new Error('obj 不是一个对象！')
  }
  let copy = Array.isArray(obj) ? [...obj] : { ...obj }
  Reflect.ownKeys(copy).forEach(key => {
    copy[key] = isObject(obj[key]) ? deepCopy(obj[key]) : obj[key]
  })
  return copy
}
```
#### lodash jQuery.extend
lodash 中的 `cloneDeep` 等api更加完善，具体可以参考lodash的[baseClone](https://github.com/lodash/lodash/blob/master/.internal/baseClone.js)等方法
```js
let copy = _.cloneDeep(me)
```
`jQuery.extend`也是非常经典的一个方法，用法多样。可以查看源码[jQuery.extend](https://github.com/jquery/jquery/blob/master/src/core.js)
```js
let object1 = {
  apple: 0,
  banana: {weight: 52, price: 100},
  cherry: 97
};
let object2 = {
  banana: {price: 200},
  durian: 100
};
/* object2 合并到 object1 中 */
$.extend(object1, object2);
```

#### JSON 序列化反序列化
这可能也是最简单也是最好理解的方法了，但是在实际日常使用中也会出现一些问题，那是因为JSON语言中并没有`undefined,function`等数据类型，在拷贝具有这些类型的对象时，也必然会报错。
```js
function deepCopy(obj) {
  return JSON.parse(JSON.stringify(obj))
}
```

### 特殊情况
#### 对象环问题
```js
let obj1 = {}
obj1.self=obj1
let obj2 = deepCopy(obj1)//Uncaught RangeError: Maximum call stack size exceeded
```
对于这种问题，我们可以创建一个变量，在递归时把每个要拷贝的属性都缓存进来，下一轮递归的时候，如果缓存中有存在相同的对象，就可以直接使用这个对象并停止递归。这样改造之后，便不会在进入递归死循环，也就不会发生栈溢出了。
```js
function deepCopy(obj) {
  let cache = []
  cache.push(obj);
  let _obj = Array.isArray(obj) ? [] : {};
  for (key in obj) {
    if(typeof obj[key] === 'object'){
      // 使用indexOf可以检测数组中是否存在相同的对象
      let index = cache.indexOf(obj[key]);
      if (index > -1) {
        _obj[key] = cache[index];
      }else {
        _obj[key] =  deepCopy(obj[key])
      }
    }else {
      _obj[key] = obj[key];
    }
  }
  return _obj;
}
let obj1 = {}
obj1.self=obj1
let obj2 = deepCopy(obj1)// {self: {…}}
```
经过改造，没有再报栈溢出的错误，也得到了我们想要的结果。

当然，我们也可是使用WeakMap的方式创建一个更有趣的方法。

```js
function deepCopy(obj, map=new WeakMap()){
  if (!isObject(obj)) return obj;
  if (map.has(obj)) return map.get(obj); // 有则返回
  let copy = Array.isArray(obj) ? [] : {}
  map.set(obj, copy)                      // 无则设置
  return Object.assign(copy, Object.keys(obj).map(key => ({[key]:deepCopy(obj[key], map)})))
}
let me = {name:'张瑞'}
me.like=me
let he = deepCopy(me)
console.log(he)                            // {name: "张瑞", like: {…}}
```
[`WeakMap的键名所指向的对象，不计入垃圾回收机制。WeakMap的设计目的在于，有时我们想在某个对象上面存放一些数据，但是这会形成对于这个对象的引用。`](http://es6.ruanyifeng.com/?search=setPrototypeOf&x=8&y=3#docs/set-map#WeakMap)
由于WeakMap的特性，它的键是弱引用的，正好符合现在的需求。

lodash也能处理对象环问题，具体可参见源码[baseClone#L198](https://github.com/lodash/lodash/blob/master/.internal/baseClone.js#L198)。
#### 拷贝原型上的属性
由于在`JavaScript`中，对象是基于原型链设计的，所以`某个属性查找不到时会沿着它的原型链向上查找`。
```js
function deepCopy(obj) {
  if (!isObject(obj)) throw new Error(obj+'不是一个对象！')
  let copy = Array.isArray(obj) ? [] : {}
  for (let key in obj) {
    copy[key] = isObject(obj[key]) ? deepCopy(obj[key]) : obj[key]
  }
  return copy
}
let me = { name: '张瑞', hobbies: { game:['LOL','吃鸡'], other:[] },like:{} }
let create = Object.create(me)
console.log('create:',create)  //如下图
let copy = deepCopy(create)
console.log('copy',copy)  //如下图
```
{% asset_img jk2_1.png 栈内存与堆内存 %} 

经过测试，使用[`Object.create`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/create)生成出来的`create`对象，使用`for...in`方法的拷贝，已经拷贝成功。
因为[`原形链上的属性也不会被追踪以及复制`](https://developer.mozilla.org/zh-CN/docs/Web/Guide/API/DOM/The_structured_clone_algorithm#%E7%BB%93%E6%9E%84%E5%8C%96%E5%85%8B%E9%9A%86%E6%89%80%E4%B8%8D%E8%83%BD%E5%81%9A%E5%88%B0%E7%9A%84)，`Object.keys、Reflect.ownKeys、JSON`方法本身也不会追踪原型链上的属性，所以使用这些方法并不能拷贝到原型上的属性.

#### 拷贝 Symbol
因为`Symbol`是一种特殊的数据类型，由于它的特点便是独一无二，所以此时，使用浅拷贝等于深拷贝。
但是此时，如果使用上文中使用`for...in`的方法来拷贝时，是无法拷贝的，因为现在还没有对`Symbol`类型做处理。
更多信息可参见阮大的教程[Symbol-属性名的遍历](http://es6.ruanyifeng.com/?search=setPrototypeOf&x=8&y=3#docs/symbol#%E5%B1%9E%E6%80%A7%E5%90%8D%E7%9A%84%E9%81%8D%E5%8E%86)
```js
function deepCopy(obj) {
  let cache = []
  cache.push(obj);
  let _obj = Array.isArray(obj) ? [] : {};
  let symbols = Object.getOwnPropertySymbols(obj)
  if (symbols.length > 0) {
    symbols.forEach(key => {
      _obj[key] =  isObject(obj[key]) ? deepCopy(obj[key]) : obj[key]
    })
  }
  for (key in obj) {
    if(typeof obj[key] === 'object'){
      // 使用indexOf可以检测数组中是否存在相同的对象
      let index = cache.indexOf(obj[key]);
      if (index > -1) {
        _obj[key] = cache[index];
      }else {
        _obj[key] =  deepCopy(obj[key])
      }
    }else {
      _obj[key] = obj[key];
    }
  }
  return _obj;
}
let obj1 = {}
let sym = Symbol('Symbollllllll')
obj1[sym] = {
  a:1
}
let obj2 = deepCopy(obj1)
console.log(obj2) //{Symbol(Symbollllllll): {a: 1}}
```
由于Reflect.ownKeys可以直接获取`Symbol`值，所以Reflect的方法可以直接拷贝。

#### 不可枚举的属性
当拷贝一些描述符属性、getter/setter一类不可枚举的属性时，就需要进一步的处理了。因为上面所写的种种方法，都无法拷贝这些属性（枚举不出来，臣妾做不到啊）。
我们现设置一个不可枚举的对象
```js
let me = { name: '张瑞', hobbies: { game:['LOL','吃鸡'], other:[] },like:{} }

Object.defineProperties(me, {
    'hobbies': {
        writable: false,
        enumerable: false,
        configurable: false
    },
    'name': {
        get() {
          return '就不告诉你'
        },
        set(val) {
          console.log('不可以，我就叫张瑞')
        }
    }
})
```
该实现方法了，恩。。。
不可枚举的属性那可咱办呢。
好吧，还是要看阮大的教程。
[对象的扩展-属性的可枚举性和遍历](http://es6.ruanyifeng.com/?search=setPrototypeOf&x=8&y=3#docs/object#%E5%B1%9E%E6%80%A7%E7%9A%84%E5%8F%AF%E6%9E%9A%E4%B8%BE%E6%80%A7%E5%92%8C%E9%81%8D%E5%8E%86)
[Object.getOwnPropertyDescriptors](http://es6.ruanyifeng.com/?search=setPrototypeOf&x=8&y=3#docs/object-methods#Object-getOwnPropertyDescriptors)
`ES5 的Object.getOwnPropertyDescriptor()方法会返回某个对象属性的描述对象（descriptor）。ES2017 引入了Object.getOwnPropertyDescriptors()方法，返回指定对象所有自身属性（非继承属性）的描述对象。`

好了开写，这次来个究极版本的
```js
function isObject(val) {
  return val != null && typeof val === 'object' && Array.isArray(val) === false;
};
function deepCopy(obj, map = new WeakMap()) {
  if (!isObject(obj)) return obj
  if (map.has(obj)) return map.get(obj)
  let _obj = Array.isArray(obj) ? [] : {}
  map.set(obj, _obj)
  let symbols = Object.getOwnPropertySymbols(obj)
  if (symbols.length > 0) {
    symbols.forEach(key => {
      _obj[key] =  isObject(obj[key]) ? deepCopy(obj[key]) : obj[key]
    })
  }
  // 拷贝 描述对象
  _obj = Object.create(
    Object.getPrototypeOf(_obj),
    Object.getOwnPropertyDescriptors(obj)
  )
  for (let key in obj) {
    _obj[key] = isObject(obj[key]) ? deepCopy(obj[key], map) : obj[key];
  }

  return _obj
}
```
好啦，快试试。
```js
let myCopy = deepCopy(me)
myCopy.name = '换个名字'   // 不可以，我就叫张瑞
console.log(myCopy.name)  // 就不告诉你
```