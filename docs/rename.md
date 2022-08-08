---
title: 记一次用Node批量修改文件名
date: 2022-8-8
---

## 由于需求是将一些系列13数字命名的图片批量重命名

### 目录结构如下
```
pages
  - jpg
    - xxxxxxxxxxxx.jpg
    - xxxxxxxxxxxx.png
  - index.js
  - copy   
```

## 分析需求

 - 读取文件名api`readdirSync`
 - 正则匹配过滤
 - 修改文件名api`renameSync`

## 这里为什么使用同步的方式，因为本地不需要异步的交互，按顺序等待即可


### 脚本编写，代码写在index.js里

``` js
const fs = require('fs')
fs.readdirSync(__dirname + '/jpg')
.filter(fileName => {
    console.log('fileName===' + fileName)
    return /^(\d{6})(\d{4})(\d{3})(\.jpg|\.png)$/g.test(fileName)
})
.forEach(fileName => {
    console.log('fileName===' + fileName)
    let newName = fileName.replace(/^(\d{6})(\d{4})(\d{3})(\.jpg|\.png)$/g, function (match, $1, $2, $3, $4) {
        console.log('$1',$1)
        return $1 + '-' + $2 + '-' + $3 + $4
    })
    fs.renameSync(__dirname + '/jpg/' + fileName, __dirname + '/copy/' + newName, (err) => {
        if (err) {
            return
        }
        console.log('rename')
    })
});
```

## 最后执行`node index即可`
