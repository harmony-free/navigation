# navigation

#### 介绍 [English](README.en.md)

这是鸿蒙版本基于navigation进行路由封装的库，push 前往 下一页、replace 页面重载、pop 返回 上一页、home 回到首页。

#### 软件架构

基于系统navigation进行容器路由封装

#### 安装教程

`ohpm install @free/navigation`

#### 使用说明

简单例子

```
// 前往 下一页
nav.push("name",new Object)

// 页面重载
nav.replace("name",new Object)

// 返回 上一页
nav.pop(new Object)

// 回到首页
nav.home(new Object);
```

1、引入头文件

`import { nav, pageMap } from '@free/navigation';`

2、将 `nav.navPathStack` 添加到 `Navigation`
`Navigation(router.navPathStack)`

3、再 `Navigation` 设置 `.navDestination(pageMap)`
`Navigation(router.navPathStack){}.navDestination(pageMap)`

4、通过 `nav.push("name",new Object())` 进行路由跳转,第一个参数是待跳转组件，第二个参数为传递数据

5、通过 `then` 接受下个页面回传过来的数据

```
struct RootPage {
  @State message: string = 'Hello World';

  build() {
    Navigation(nav.navPathStack) {
      Text(this.message).onClick(() => {
        router.push("name",new Object()).then((o:object)=>{
            // o 为下个页面传回的数据
        })
      })
    }.navDestination(pageMap)
  }
}
```

7、待跳转的组件 `NamePage`，返回上个页面 `nav.back(new Object())` 参数是传到上个页面的参数

```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage({o:o}) // 待跳转的组件,o为传递数据 可以不传
  }.hideTitleBar(true) // 隐藏默认导航
}

nav.requestBuilder("name", wrapBuilder(NameBuilder)) // 注册组件到路由容器中

@Component
export struct NamePage {
  /// 接收数据
  o: object | undefined 
  build() {
    Text("返回")
    .onClick(() => {
       nav.back(new Object())
    })
  }
}
```
注意：router 跳转 需要注册组件
```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage() // 待跳转的组件
  }.hideTitleBar(true) // 隐藏默认导航
}

nav.requestBuilder("name", wrapBuilder(NameBuilder)) // 注册组件到路由容器中
```

#### 参与贡献

1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

#### 特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5. Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6. Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
