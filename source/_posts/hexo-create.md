---
title: 创建属于你的博客
comments: true
tags:
  - Hexo
# categories: 
#   - Hexo
#   - 2112
---
主要使用 Node.js + Hexo + Next + Github ，其实都很简单，在此只是为了记录一下
<!-- more -->

## 开始

### 安装Hexo
需要先安装 Node.js
为了使用 npm 安装 Hexo
打开 bash

`npm install -g hexo-cli`

### 创建项目 

`hexo init <folder>`
`cd <folder>`
`npm install`

### 启动项目
`hexo server`

浏览器输入[localhost:4000](localhost:4000)查看

### 发布、部署项目

需要先确认站点配置文件配置正确

```yml
deploy:
  type: git
  repository: https://github.com:username/username.github.io.git
  branch: master
```

### 发布

`hexo clean && hexo generate && hexo deploy`

如果 deploy 不成功 需要
`npm install hexo-deployer-git --save`

每次修改配置文件  都需要在博客所在目录下 `hexo generate` 才能保存。

## 发布文章

使用
`hexo new "博客文章文件名"`
或
  新建md文件放到 /source/_posts 文件夹或其子文件夹中，并且文章要按照规定格式书写

如： 
```yml
---
title: # 标题
tags:   # 标签
  - 标签名称1
  - 标签名称2
categorys:  # 分类
  - 分类1
  - 分类2
---
```

### 预览文章

清除缓存
`hexo clean`
生成静态网页
`hexo generate`
预览
`hexo server`

### 设置404页面

`hexo new page "404"`
编辑 `source/404.md`

或
在 `themes/source` 中写入 `404.html`

如腾讯公益404页面
```html

<!DOCTYPE HTML>
<html>
<head>
  <meta http-equiv="content-type" content="text/html;charset=utf-8;"/>
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
  <meta name="robots" content="all" />
  <meta name="robots" content="index,follow"/>
  <link rel="stylesheet" type="text/css" href="https://qzone.qq.com/gy/404/style/404style.css">
</head>
<body>
  <script type="text/plain" src="http://www.qq.com/404/search_children.js"
          charset="utf-8" homePageUrl="/"
          homePageName="回到我的主页">
  </script>
  <script src="https://qzone.qq.com/gy/404/data.js" charset="utf-8"></script>
  <script src="https://qzone.qq.com/gy/404/page.js" charset="utf-8"></script>
</body>
</html>

```

## 创建标签、分类

### 标签 
`hexo new page "tags"`
打开站点目录中的 `source/tags/index.md`
配置
```yml
---
title: tags
date: 2019-01-23 14:31:20
type: "tags" # 设置tags名
comments: false # 设置评论功能
---
```

### 分类
`hexo new page "categories"`
打开站点目录中的 `source/tags/index.md`
配置
```yml
---
title: tags
date: 2019-01-23 14:32:14
type: "categories" # 设置tags名
comments: false
---
```

## 主题

这里主要使用 [Next](https://theme-next.org/)

先
`git clone https://github.com/iissnan/hexo-theme-next themes/next`
或新路径
`git clone https://github.com/theme-next/hexo-theme-next themes/next`

将主题放在 `themes/` 目录下即可

### 更换主题

找到站点配置项 `_config.yml` 
修改
```yml
theme: next
```

### 配置主题

找到主题配置项 `themes/next/_config.yml` 
修改
```yml
# ---------------------------------------------------------------
# Scheme Settings
# ---------------------------------------------------------------

# Schemes
scheme: Muse
#scheme: Mist
#scheme: Pisces
#scheme: Gemini
```
任选一项即可 更多样式可以参照 https://github.com/iissnan/hexo-theme-next/issues/119


### Hexo 命令

```bash

hexo init <文件名>#生成站点

hexo new page "xxx" #生成页面

hexo new "" #生成文章

hexo server  #启动本地服务

hexo generate  #保存修改，生成文件

hexo clean #清缓存

hexo deploy  #发布到远程

```

具体的 命令行 输入 `hexo` 

## 注意事项

真的很简单，多看文档就好啦，都写的很清楚 [Hexo](https://hexo.io/) [Next](https://theme-next.org/) 