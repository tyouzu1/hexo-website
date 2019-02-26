---
title: 记录一些解决方案（链接）- 持续更新
date: 2019-02-19 16:22:09
tags:
---
rem适配  ParseUrl dva live2d-widget 等
<!-- more -->

# rem适配 
一般js版本链接[http://caibaojian.com/simple-flexible.html](http://caibaojian.com/simple-flexible.html)
```js
//designWidth:设计稿的实际宽度值，需要根据实际设置
//maxWidth:制作稿的最大宽度值，需要根据实际设置
//这段js的最后面有两个参数记得要设置，一个为设计稿实际宽度，一个为制作稿最大宽度，例如设计稿为750，最大宽度为750，则为(750,750)
;(function(designWidth, maxWidth) {
	var doc = document,
	win = window,
	docEl = doc.documentElement,
	remStyle = document.createElement("style"),
	tid;

	function refreshRem() {
		var width = docEl.getBoundingClientRect().width;
		maxWidth = maxWidth || 540;
		width>maxWidth && (width=maxWidth);
		var rem = width * 100 / designWidth;
		remStyle.innerHTML = 'html{font-size:' + rem + 'px;}';
	}

	if (docEl.firstElementChild) {
		docEl.firstElementChild.appendChild(remStyle);
	} else {
		var wrap = doc.createElement("div");
		wrap.appendChild(remStyle);
		doc.write(wrap.innerHTML);
		wrap = null;
	}
	//要等 wiewport 设置好后才能执行 refreshRem，不然 refreshRem 会执行2次；
	refreshRem();

	win.addEventListener("resize", function() {
		clearTimeout(tid); //防止执行两次
		tid = setTimeout(refreshRem, 300);
	}, false);

	win.addEventListener("pageshow", function(e) {
		if (e.persisted) { // 浏览器后退的时候重新计算
			clearTimeout(tid);
			tid = setTimeout(refreshRem, 300);
		}
	}, false);

	if (doc.readyState === "complete") {
		doc.body.style.fontSize = "16px";
	} else {
		doc.addEventListener("DOMContentLoaded", function(e) {
			doc.body.style.fontSize = "16px";
		}, false);
	}
})(750, 750);
```
张鑫旭老师 vw rem 版本 [https://www.zhangxinxu.com/wordpress/2016/08/vw-viewport-responsive-layout-typography/](https://www.zhangxinxu.com/wordpress/2016/08/vw-viewport-responsive-layout-typography/)
```css
html {
    font-size: 16px;
}

@media screen and (min-width: 375px) {
    html {
        /* iPhone6的375px尺寸作为16px基准，414px正好18px大小, 600 20px */
        font-size: calc(100% + 2 * (100vw - 375px) / 39);
        font-size: calc(16px + 2 * (100vw - 375px) / 39);
    }
}
@media screen and (min-width: 414px) {
    html {
        /* 414px-1000px每100像素宽字体增加1px(18px-22px) */
        font-size: calc(112.5% + 4 * (100vw - 414px) / 586);
        font-size: calc(18px + 4 * (100vw - 414px) / 586);
    }
}
@media screen and (min-width: 600px) {
    html {
        /* 600px-1000px每100像素宽字体增加1px(20px-24px) */
        font-size: calc(125% + 4 * (100vw - 600px) / 400);
        font-size: calc(20px + 4 * (100vw - 600px) / 400);
    }
}
@media screen and (min-width: 1000px) {
    html {
        /* 1000px往后是每100像素0.5px增加 */
        font-size: calc(137.5% + 6 * (100vw - 1000px) / 1000);
        font-size: calc(22px + 6 * (100vw - 1000px) / 1000);
    }
}

```

# Parse Url
用于格式化Url [https://j11y.io/javascript/parsing-urls-with-the-dom/](https://j11y.io/javascript/parsing-urls-with-the-dom/)
## parseURL
```js
// This function creates a new anchor element and uses location
// properties (inherent) to get the desired URL data. Some String
// operations are used (to normalize results across browsers).
 
function parseURL(url) {
    var a =  document.createElement('a');
    a.href = url;
    return {
        source: url,
        protocol: a.protocol.replace(':',''),
        host: a.hostname,
        port: a.port,
        query: a.search,
        params: (function(){
            var ret = {},
                seg = a.search.replace(/^?/,'').split('&'),
                len = seg.length, i = 0, s;
            for (;i<len;i++) {
                if (!seg[i]) { continue; }
                s = seg[i].split('=');
                ret[s[0]] = s[1];
            }
            return ret;
        })(),
        file: (a.pathname.match(//([^/?#]+)$/i) || [,''])[1],
        hash: a.hash.replace('#',''),
        path: a.pathname.replace(/^([^/])/,'/$1'),
        relative: (a.href.match(/tps?://[^/]+(.+)/) || [,''])[1],
        segments: a.pathname.replace(/^//,'').split('/')
    };
}

```
## Usage
```js
var myURL = parseURL('http://abc.com:8080/dir/index.html?id=255&m=hello#top');
 
myURL.file;     // = 'index.html'
myURL.hash;     // = 'top'
myURL.host;     // = 'abc.com'
myURL.query;    // = '?id=255&m=hello'
myURL.params;   // = Object = { id: 255, m: hello }
myURL.path;     // = '/dir/index.html'
myURL.segments; // = Array = ['dir', 'index.html']
myURL.port;     // = '8080'
myURL.protocol; // = 'http'
myURL.source;   // = 'http://abc.com:8080/dir/index.html?id=255&m=hello#top'
```
<!-- ## React+Redux 究极进化体

[Dva](https://dvajs.com/)
[Umi](https://umijs.org/guide/with-dva.html)

再多说一句，React 官网的教程，已经足够详尽、足够学习了。 -->

# live2d-widget canvas交互 
live2d-widget 可快速支持hexo [https://github.com/xiazeyu/live2d-widget.js](https://github.com/xiazeyu/live2d-widget.js)

