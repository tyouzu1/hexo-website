---
title: 本地（localhost）开发 PWA，使用 https
date: 2019-08-09 13:24:30
tags: 
  - PWA 
  - https
  - Service Worker
---
最近有新任务，把当前的项目加个 **PWA** 进来。于是乎，又发现了技术的星辰大海。
测试项目在 项目在 [github](https://github.com/tyouzu1/tyouzu1.github.io) 也可以直接访问 [tyouzu1.github.io](https://tyouzu1.github.io)

<!-- more -->
# PWA 简介
先来介绍下 **PWA** 
`Progressive Web App, 简称 PWA，是提升 Web App 的体验的一种新方法，能给用户原生应用的体验。`

## PWA 的特点
* 可靠 - 即使在不稳定的网络环境下，也能瞬间加载并展现
* 体验 - 快速响应，并且有平滑的动画响应用户的操作
* 粘性 - 像设备上的原生应用，具有沉浸式的用户体验，用户可以添加到桌面

## PWA 表现形式
可以访问下 [微博](http://m.weibo.cn/) 的 m 站，现在已经支持了 **PWA**。可以添加到桌面。

~~如果不能添加，可能是浏览器没有启用相应功能。
可以打开 Chrome浏览器的 `chrome://flags/` 页面。搜索 `progressive` 打开 `Desktop PWAs` 功能~~

搜不到的话，那应该就肯定能用。现在 Chrome 基本上都是默认支持了。

由于我打开后搜索不到了，就不截图了。

macOs 上可以添加到启动台

{% asset_img install_weibo.png macOs上安装 %}

{% asset_img install_weibo2.png macOs上安装 %}

{% asset_img mac_weibo.png macOs上安装 %}

{% asset_img mac_weibo2.png macOs上安装 %}

打开后如下图，去掉了很多无关的功能，显得非常专业

{% asset_img mac_weibo3.png macOs上安装 %}

具体的 **PWA** 表现形式本文不再赘述。

具体可以参见 [lavas](https://lavas.baidu.com/pwa/README)

# 如何使用 PWA
## 添加到桌面功能
**PWA** 可以让你的应用能够添加到桌面，并获得更好的用户体验，而且并不仅仅是一个网页快捷方式

那么如何启用这个功能呢？

有三要素
>* 正常的 manifest.json
>* 正常的 Service Worker
>* 可访问的 HTTPS

只要你的网站添加了这三样，你的应用就能正常使用 **PWA** 的特性了

### manifest.json
下面是一个 `manifest.json` 样例
具体文档可参见 [MDN](https://developer.mozilla.org/zh-CN/docs/Web/Manifest)
```json
{
  "short_name": "Razio",  // 简短易读的名称
  "name": "这是 Razio 的博客",  // 为应用程序提供一个可读的名称
  "display": "standalone",    //  fullscreen占满整个屏幕。 standalone	浏览器相关UI隐藏 等
  "icons": [  // 指定可在各种环境中用作应用程序图标的图像对象数组
    {
      "src": "https://tyouzu1.github.io/icon_48.png", // 路径
      "type": "image/png", //类型
      "sizes": "48x48"  // 尺寸
    },
    {
      "src": "https://tyouzu1.github.io/icon_144.png",
      "type": "image/png",
      "sizes": "144x144"
    },
    {
      "sizes": "192x192",
      "src": "https://tyouzu1.github.io/icon_192.png",
      "type": "image/png"
    },
    {
      "sizes": "512x512",
      "src": "https://tyouzu1.github.io/icon_512.png",
      "type": "image/png"
    }
  ],
  "start_url": "/" // 加载的URL
}
```

最后，在你的 html 中引入
```html
<link rel="manifest" href="/manifest.json">
```

使用 webpack
```js
var WebpackPwaManifest = require('webpack-pwa-manifest')
plugins: [
  new WebpackPwaManifest({
    name: '这是 Razio 的博客',
    short_name: 'Razio',
    description: 'My name is Razio',
    background_color: '#ffffff',
    start_url: "/",
    display: "standalone",
    icons: [
      {
        src: path.resolve('src/assets/icon.png'),
        sizes: [48, 144, 192, 512] // multiple sizes
      }
    ]
  })
]
```
引入 `webpack` 插件后，会生成 `manifest.json` 文件，自动打包到 html 中。


### Service Worker

#### 什么是 Service Worker?
没啥好说的，[MDN](https://developer.mozilla.org/zh-CN/docs/Web/API/Service_Worker_API)，自学吧
#### 如何建一个简单的 Service Worker

`sw.js`
```js
var cacheName = 'test-sw-0-1';
var cacheFiles = [
    '/',
    './index.html',
    // './index.js',
    // './style.css',
    // './img/banner.png',
    // 在这里可以选择缓存文件
];
// 监听 install 事件，安装完成后，进行文件缓存
self.addEventListener('install', function (e) {
    console.log('Service Worker 状态： install');
    var cacheOpenPromise = caches.open(cacheName).then(function (cache) {
        // 把要缓存的 cacheFiles 列表传入
        return cache.addAll(cacheFiles);
    });
    e.waitUntil(cacheOpenPromise);
});
// 监听 fetch 事件，安装完成后，进行文件缓存
self.addEventListener('fetch', function (e) {
    console.log('Service Worker 状态： fetch');
    var cacheMatchPromise = caches.match(e.request).then(function (cache) {
            // 如果有cache则直接返回，否则通过fetch请求
            return cache || fetch(e.request);
        }).catch(function (err) {
            console.log(err);
            return fetch(e.request);
        })
    e.respondWith(cacheMatchPromise);
});
// 监听 activate 事件，清除缓存
self.addEventListener('activate', function (e) {
    console.log('Service Worker 状态： activate');
    var cachePromise = caches.keys().then(function (keys) {
        return Promise.all(keys.map(function (key) {
            if (key !== cacheName) {
                return caches.delete(key);
            }
        }));
    })
    e.waitUntil(cachePromise);
    return self.clients.claim();
});
```
在 html 中调用 `sw.js`
```js
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
        navigator.serviceWorker.register('/sw.js', {scope: '/'})
            .then(function (registration) {
                // 注册成功
                console.log('ServiceWorker registration successful with scope: ', registration.scope);
            })
            .catch(function (err) {
                // 注册失败:
                console.log('ServiceWorker registration failed: ', err);
            });
    });
}
```

当然，这里也可以使用 webpack 的 [`offline-plugin`](https://github.com/NekR/offline-plugin) 插件来解决
webpack
```js
var OfflinePlugin = require('offline-plugin');
plugins: [
  new OfflinePlugin()
]
```
功能很强大，细节有空再补，具体行为可以参见 [`offline-plugin`](https://github.com/NekR/offline-plugin) 文档

### HTTPS 服务
在本地调试时，可以利用 `webpack` 或者 `http-server` 来启动 https 服务。

webpack-dev-server
```js
devServer: {
    https: true
}
```
http-server 命令行方式
```js
http-server -S
```
之后便可以用 https 的方式访问项目，如 `https://localhost:8080`

可是进来后发现，浏览器认为是不安全的，这也就会导致浏览器不会启用 PWA 的添加应用功能
{% asset_img https_error.png 不安全的HTTPS %}

解决的方法有很多，总的来说就是让本地浏览器忽略当前这个地址从而不检测 https证书，或是伪造成一个安全的证书让浏览器认为它是安全的

这里采用 [mkcert](https://github.com/FiloSottile/mkcert) 来伪造证书。

使用起来也很方便

先安装 
```
brew install mkcert
```
其他系统可参照文档 [mkcert](https://github.com/FiloSottile/mkcert)

然后使用 mkcert 创建一个证书，mkcert 会自动将其插入到证书库中并信任。
在 MACOS 中是在钥匙串中
{% asset_img mkcert.png 钥匙串 %}

然后使用 mkcert + [输入需要证书的地址] 生成 key 和 cert
```
mkcert localhost 127.0.0.1 
```

然后通过 webpack 启动
```js
 devServer: {
    https: {
        key: fs.readFileSync('path/to/localhost+1-key.pem'),
        cert: fs.readFileSync('path/to/localhost+1.pem'),
        ca: fs.readFileSync('/Users/YOUR/Library/Application Support/mkcert/rootCA.pem'),
    }
}
```
或者使用 http-server
```
http-server -S -C localhost+1.pem -K localhost+1-key.pem
```

接下来 访问你本地的地址，浏览器就能正确识别到HTTPS了。

再来看一下三要素

>* 正常的 manifest.json
>* 正常的 Service Worker
>* 可访问的 HTTPS

现在三要素已经完成，你的应用应该也能正常使用 PWA 的特性了。

现在可以打开最新的 Chrome 浏览器，进入项目地址，打开控制台 Application 。

{% asset_img PWA.png pwa %}

有时会会有一些错误信息，这大概率都是因为你的 `manifest.json` 信息填写不正确，或是图片资源有问题等。进行相应修改即可

{% asset_img PWA_error.png pwa报错 %}

在满足三要素，一切正常后，url输入栏 也会相应多出来一个按钮，这时，你的 PWA 应用基本上就可以正常添加到主屏幕了。

{% asset_img PWA_add.png 安装pwa %}

然后就可以向上文中的微博一样添加到主屏幕啦，使用 Service Worker 缓存的功能有机会再写

项目在 [github](https://github.com/tyouzu1/tyouzu1.github.io) 也可以直接访问 [tyouzu1.github.io](https://tyouzu1.github.io)