---
title: JavaScript 基础知识（1）—— 基础类型 和 引用类型
date: 2019-02-14 18:21:30
tags: JavaScript
categories: JavaScript 基础知识
---
说到 JavaScript 的基础知识，那肯定首当其冲的就是 基础类型 和 引用类型 了。
<!-- more -->
### 两种类型
JavaScript 中变量有两种不同类型的值：基本类型、引用类型。

基础类型保存在 栈内存 中，在按值访问，操作的是他们实际保存的值。

引用类型保存在 堆内存 中，但js不允许直接访问内存，所以在操作的时候，实际操作的是 对象的引用。

{% asset_img jk1.png 栈内存与堆内存 %}

基础类型 主要有：字符串`string`、数值`number`、布尔值`boolean`、`null`、`undefined`以及ES6中的`symbol`（独一无二的值），加上现在最新的 [`BigInt`](https://tc39.es/ecma262/)

引用类型 主要有：对象`object`、数组`array`、正则 `regExp`、函数`function`、日期`date` 以及 特殊的基本包装类型(`String、Number、Boolean`)、单体内置对象（`Math`）等。

```js
// 基础类型
var str = 'string'
var num = 123
var bool = false
var Null = null
var Undefined = undefined
var symbol = Symbol()
// 时过境迁，bigint也成为了基础类型的一份子
var bigint = 11n

//引用类型
var obj = {}
var arr = []
var reg = new RegExp()
var fn = function (){}
var date = new Date()
var string = new String('string')
```

### 两种类型的复制

#### 基本类型的复制
复制时，会在栈内存中创建一个新的值，然后把值复制到新分配的位置。

{% asset_img jk3.png 基本类型的复制 %}

```js
// 基本类型的复制
var str1 = 'abc'
var str2 = str1
console.log('str1:',str1,',str2:',str2) // str1: abc ,str2: abc
str1 = 'test'
console.log('str1:',str1,',str2:',str2) // str1: test ,str2: abc
```


#### 引用类型的复制
复制的是存储在栈内存中的 指针，将 指针 复制到栈中新分配的位置，这个 指针副本 与 原指针 都指向存储在堆中的 同一个对象。由于同指向一个对象，所以当其中一个变量改变时，也将会影响另一个变量。

{% asset_img jk2.png 引用类型的复制 %}

```js
// 引用类型的复制
var obj1 = { name: 'obj1' }
var obj2 = obj1
console.log('obj1:',obj1,',obj2:',obj2) // obj1: {name: "obj1"} ,obj2: {name: "obj1"}
obj1.name = 'name'
console.log('obj1:',obj1,',obj2:',obj2) // obj1: {name: "name"} ,obj2: {name: "name"}
```

#### tip
* `new String('abc')` 属于引用类型，不等于 `'abc'`
```js
console.log(new String('abc')=== 'abc') // false
```
这是因为 `String` 只是一个 `string` 的对象封装类型，经过 `new` 操作符得出来的属于对象的实例。

* 使用 `const` 声明的对象，可以修改其属性
```js
const a = {}
a.b = 123  // 不报错
```
这是因为 [const对象对应的堆内存指向是不变的，但是堆内存中的数据本身的大小或者属性是可变的。而对于const定义的基础变量而言，这个值就相当于const对象的指针，是不可变。](https://www.cnblogs.com/heioray/p/9487093.html)

### 如何判断类型

#### typeof
`typeof`操作符是检测基本类型的最佳工具。

```js
console.log('字符串:',typeof 'abc')         // 字符串: string
console.log('数值:',typeof 123)             // 数值: number
console.log('BigInt:',typeof 123n)         // BigInt: bigint
console.log('布尔值:',typeof false)         // 布尔值: boolean
console.log('null:',typeof null)           // null: object
console.log('undefined:',typeof undefined) // undefined: undefined
console.log('Symbol:',typeof Symbol())     // Symbol: symbol
console.log('对象:',typeof {})              // 对象: object
console.log('数组:',typeof [])              // 数组: object
console.log('正则:',typeof new RegExp())    // 正则: object
console.log('函数:',typeof function (){})   // 函数: function
console.log('日期:',typeof new Date())      // 日期: object
console.log('String封装类型:',typeof new String('string'))      // String封装类型: string
```
可以发现，`typeof` 并不能完全区分出 `null、object、array、regexp、date`等，得到的值都是 `object`。
在 Javascript 语言中，`typeof null === 'object'`。这样就会错误的认为 `null` 是一个对象。实际上这只是一个无法修复的bug。[可以看这里](http://2ality.com/2013/10/typeof-null.html)
在《JavaScript高级程序设计》中这样解释：“因为特殊值null被认为是一个空对象的引用”。
而经过 `typeof` 测试，`object、array、regexp、date`等 也都得出了 `object`，这是因为所有的引用类型，在堆中都是对象，其实都是基于`Object`实例进行的一种扩展。

至于 `typeof function (){}` 为什么是 `function`， 在《JavaScript权威指南》中`function`被看做是`object`基本数据类型的一种特殊对象，《JavaScript高级程序设计》也把函数视为对象，而不是一种基本数据类型。
```js
var fn = function () { };
console.log(fn instanceof Object);  // true
```

#### instanceof
`instanceof`检测值是不是一个构造函数的实例。
```js
// 常规用法
var stringObj = new String("abc") 
console.log(stringObj instanceof String) // true
console.log("" instanceof String)    // false
console.log("" instanceof Object)        // false

function Foo(){} 
var foo = new Foo() 
console.log(foo instanceof Foo)          // true
// 继承中关系中的用法
function Aoo(){} 
function Foo(){} 
Foo.prototype = new Aoo()
var foo = new Foo() 
console.log(foo instanceof Foo)          // true 
console.log(foo instanceof Aoo)          // true
...
```
经过实验，也可以得出，当使用 `instanceof` 检测基本类型时候，只会返回`false`。
但是当使用 `instanceof` 检测frame的数组时，会出现问题。所以 `Array.isArray()` 应运而生。
```html
<html>
<head>
  <script>
    function test(arr) {
      var iframeWin = frames[0]
      console.log(arr instanceof Array) // false
      console.log(arr instanceof iframeWin.Array) // true
      console.log(Array.isArray(arr)) // true
    }
  </script>
</head>
<body>
  <iframe></iframe>
  <script>
    var iframeWin = frames[0]
    iframeWin.document.write('<script>window.parent.test([])</'+'script>')
  </script>
</body>
</html>
```
[参考1](https://www.ibm.com/developerworks/cn/web/1306_jiangjj_jsinstanceof/index.html) [参考2](http://www.cnblogs.com/xiaoheimiaoer/p/4575002.html)

#### constructor
如下：
```js
var a = 123
console.log(a.constructor == Number) //true
```
（...待更新）

#### toString
其实是使用`Object.prototype.toString()`方法来检测数据类型。这个方法非常通用。
当然，也可以使用`Reflect`，更加简洁。
```js
console.log(Object.prototype.toString.call(new Boolean(1)))        // "[object Boolean]"
console.log(Object.prototype.toString.call(true))                  // "[object Boolean]"
console.log(Object.prototype.toString.call(new Number(1)))         // "[object Number]"
console.log(Object.prototype.toString.call(100))                   // "[object Number]"
console.log(Object.prototype.toString.call(BigInt(11)))            // "[object BigInt]"
console.log(Object.prototype.toString.call(11n))                   // "[object BigInt]"
console.log(Object.prototype.toString.call(new String("sssssss"))) // "[object String]"
console.log(Object.prototype.toString.call("sssssss"))             // "[object String]"
console.log(Object.prototype.toString.call(function(){return 1}))  // "[object Function]"
console.log(Object.prototype.toString.call(new Array(1,2,3,4,5)))  // "[object Array]"
console.log(Object.prototype.toString.call([1,2,3,4,5]))           // "[object Array]"
console.log(Object.prototype.toString.call(new Date()))            // "[object Date]"
console.log(Object.prototype.toString.call(new RegExp('sssssss'))) // "[object RegExp]"
console.log(Object.prototype.toString.call(/sssssss/))             // "[object RegExp]"

console.log(Reflect.toString === Object.prototype.toString)        // true
```
