---
title: GitHub Page 博客
date: 2019-01-23 21:30:31
tags:
  - Hexo
---
使用 `hexo deploy` 上传了站点之后，发现 tyouzu1.github.io 中原有的文件都消失了，便开始寻找解决办法。
<!-- more -->
由于我 hexo 配置了
```yml
deploy:
  type: git
  repository: git@github.com:tyouzu1/tyouzu1.github.io.git
  branch: master

```

`hexo deploy` 之后虽然上传到了我的 tyouzu1.github.io 中，
但是 README.md 会被编译成 html ，CNAME 等文件也会丢失（可以使用 hexo-generator-cname ），
虽然放在 source 文件夹中可以解决一些问题，但是造成了更多的麻烦。

这时，可以选择新建一个 github 项目（blog），
修改 hexo 的站点配置
```yml
deploy:
  type: git
  repository: git@github.com:tyouzu1/blog.git
  branch: master

```
然后部署站点

打开项目的 Settings ，
找到 GitHub Pages 下的 Source ，选则 mastet 分支，点击 save
之后便可以打开 [https://tyouzu1.github.io/blog/](https://tyouzu1.github.io/blog/) 便可以看到已经成功部署到了 GitHub Pages 上

tyouzu1.github.io 下也就能做更多的事情了，只是之后需要要防止 url 路径的冲突