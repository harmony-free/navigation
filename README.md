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

#### 插件明细

hello 各位同学，大家好！ 今天我们来讲讲关于鸿蒙里常用的Navigation容器导航组件。在开发的过程中，页面导航可谓是家常便饭，基本上一个应用有几十个甚至几百个页面，控制好页面导航是重中之重。

一、首先要了解Navigation容器导航组件的构成。NavPathStack、NavDestination这两个是核心，外加一个核心属性.navDestination()。官方文档写的眼花缭乱，但是其中的本质就这三个。

1、Navigation组件是主页面组件，在@Entry页面添加这个组件。

```arkts
@Entry
@Component
struct Index {
    build() {
        Navigation(){
            
        }
    }
}
```

2、NavPathStack是操控页面导航的关键控制器


```arkts
let navPathStack: NavPathStack = new NavPathStack();
```

3、NavDestination是被导航的组件，用@Component修饰的自定一组件，需要通过@Builder修饰的全局放发调用


```arkts
@Builder
export function testBuilder(o:object){
  NavDestination(){
    TestPage()
  }
}

@Component
export struct TestPage{
  build() {
    Text("TestPage")
  }
}
```

4、Navigation组件.navDestination()属性


```arkts
.navDestination((builderName: string, p: object) => {
  if (builderName == "testBuilder") {
    return wrapBuilder(testBuilder).builder(p)
  }
})

```

5、在此整体页面达到闭环，列出全部代码。


```arkts
const navPathStack: NavPathStack = new NavPathStack();

@Entry
@Component
struct Index {
    build() {
        Navigation(navPathStack){
            Text("testPage").onClick(()=>{
                navPathStack.pushPathByName("testPage",new Map)
            })
        }.navDestination((builderName: string, p: object) => {
            if (builderName == "testBuilder") {
            return wrapBuilder(testBuilder).builder(p)
            }
        })
    }
}

@Builder
export function testBuilder(o:object){
  NavDestination(){
    TestPage({o:o})
  }
}

@Component
export struct TestPage{
  o: object|undefined
  build() {
    Column(){
      Text("TestPage")
      Text("回到上个页面").onClick(()=>{
        navPathStack.pop()
      })
    }
  }
}
```

是不是有点惊讶，怎么才这么点，文档是那么多？对！没错！主要的核心就这么写，但是要应付日常繁琐的需求就要在这些代码进行封装了！

注意：完整代码我已提交到[鸿蒙三方库](https://ohpm.openharmony.cn/#/cn/home)中，使用一下命令安装


```
ohpm install @free/navigation
```


调用方式，按照上面编写子页面后需要requestBuilder注册一下子页面


```arkts
// 注册子页面
nav.requestBuilder('path',wrapBuilder(testBuilder))
// 跳转页面以及接收返回参数
nav.push("path",new Map).then((data)=>{
    if (data.data!=undefined) {
        // TODO: 处理返回参数
    }
})
// 返回页面传递返回参数
nav.pop(new Map);
```

喜欢本篇内容的话给个小爱心！


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
