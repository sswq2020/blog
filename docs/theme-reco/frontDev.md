---
title: 前端项目部署配置遇到的问题和一些思考
date: 2022-04-25
---


## 中文版主要目的记录项目开发过程中问题和想法

### 前端项目部署配置遇到的问题

- 起因:一般来说前端项目打包好的dist,如果直接放到服务器制定目录下,ngnix服务器配置一下，就可以直接访问启动。但是迪士尼因为特殊情况，需要前端自己写一个内置的node(这里采用**express**)服务来启动,因为一直配置不当,卡了很久。

- 优点
  
  1. 可以在node里获取动态的环境变量,动态的环境变量由**文件.env**提供,由npm包**dotenv**解析
  2. 前端在项目里启动了内置node,最后部署到生产环境,这样开发模式下可以保持一致的
  3. 前端可以控制访问的路由，返回结果可以控制，比如可以将`/config`路由返回需要的环境变量返回给angular作为初始化获取的数据

- 缺点
  1. 需要前端分配一定的精力写node服务
  2. 多写一些健康检查的接口,迪士尼的要求
  3. 掌握一些express的知识

- 解决express的过程
  1. 在server.js文件里express的配置静态资源的方法`express.static`,
  2. `express.static`只有配置`app.use`才能使用
  3. `app.use(express.static(root,options))`默认访问的根路由`'/'`,实际`app.use('/',express.static(root,options))`,express.static在配置正确的情况下，这样访问根路由+静态资源(例如`.css`,`.html`,`.js`),启动服务便能直接打开看到(`localhost:8080/runtime.232434.js`),在本地开发环境下并不是问题,但是线上真实环境往往更加复杂。
  4.SE分配的线上地址`https:// + hostName + /virtual-queue-admin-ui/`,并不是在根路由下`'/'`,千万不要`app.use(express.static(root,options))`配置路由中间件,这时应该配置`app.use('/virtual-queue-admin-ui', express.static(root,options))`,这样我们就能访问(`localhost:8080/virtual-queue-admin-ui/runtime.232434.js`),到此已经成功一半
  5. `express.static(root,options)`,我这里dist目录如下
   ```
    dist
      - static
        - server.js
      - virtual-queue-admin-ui(根据前端angular.json可配置)
        - index.html
        - xxxx.css
        - xxxx1.js
        - xxxx2.js
   ```
   因此根据层级关系在server.js里代码`app.use('/virtual-queue-admin-ui', express.static(__dirname + '/..' + '/virtual-queue-admin-ui'))`;
   6.利用express的全局中间件,将大部分接口都返回index.html
   ``` ts
    export const htmlMiddleware = async function(req:any, res:any, next: Function) {
    if (req.xhr) {
      return next();
    }
  
    const pattern = new Regex(/virtual-queue-admin-ui\/api/); // se定制路由接口
    const match = pattern.test(req.path);
    if (match) {
      return next();
    }
    const baseHref = '/virtual-queue-admin-ui/'
    const  htmlPath = '/virtual-queue-admin-ui/index.pro.html'
    const indexHtml = await ejs.renderFile(__dirname + '/..' + htmlPath, {
      baseHref
    });
    
    res.send(indexHtml);
  }


   ```

- Angular(Vue,React类似)
  angular.json文件配置如下
  ``` json
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/virtual-queue-admin-ui",
            "index": "src/index.html",
            .....
          },
          "configurations": {
            "production": {
              "index": "src/index.pro.html",
              "deployUrl": "/virtual-queue-admin-ui/",

              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.prod.ts"
                }
              ],
              "outputHashing": "all"
            },
          },
          "defaultConfiguration": "production"
        }
        .....
      }
  ```

   - 这里说明`"outputPath": "dist/virtual-queue-admin-ui"`,这里对应着打包后静态对应的目录,一般默认dist。我这里加了一个二级目录，为了区别明显。
   - `index.pro.html`与`index.html`区别只是一个 `<base href="<%= baseHref %>"/>`,其它保持一样,这里是为了express利用`ejs`把模版变量`{{baseHref}}`替换`/virtual-queue-admin-ui`。还有一种方案不用`ejs`和`index.pro.html`,用node.js文件读写配合正则替换
   - "deployUrl"指的是打包后index.html里,js里src,css里link添加前缀,
     例子中不添加deployUrl,打包后index.html里是这样
     ``` js
      <script src="runtime.b19001eba6033a19.js"></src>
     ```
     添加 `"deployUrl": "/virtual-queue-admin-ui/"`
     打包后index.html里是这样
     ``` js
      `<script src="/virtual-queue-admin-ui/runtime.b19001eba6033a19.js"></src>` // 这样静态资源寻找的路径从根路径下+"/virtual-queue-admin-ui/runtime.b19001eba6033a19.js" 去找,否则加载路径不正确
     ``` 
   - 最后如果线上可以配置cdn,可以给`"deployUrl": "https://cdn"`,打包后再用node.js替换制定cdn,用`ejs`也是一样的意思

  
       

  




