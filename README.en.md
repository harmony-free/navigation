# navigation

#### Description [中文](README.md)

This is a library for routing encapsulation based on navigation in the Hongmeng version. It provides functions for pushing to the next page, replacing the current page for reloading, popping to return to the previous page, and going home to return to the home page.。

#### Software architecture

Container routing encapsulation based on system navigation

#### Installation Tutorial

`ohpm install @free/navigation`

#### Instruction Manual

example

```
// Go to Next Page
nav.push("name",new Object)

// Page reload
nav.replace("name",new Object)

// Back to previous page
nav.pop(new Object)

// Back to the home page
nav.home(new Object);
```

1、Include the header file

`import { nav, pageMap } from '@free/navigation';`

2、 `nav.navPathStack` add `Navigation`
`Navigation(router.navPathStack)`

3、 `Navigation` setting `.navDestination(pageMap)`
`Navigation(router.navPathStack){}.navDestination(pageMap)`

4、 `nav.push("name",new Object())` Perform a route jump. The first parameter is the component to be jumped to, and the second parameter is the data to be passed.

5、 `.then` Receive the data sent back from the next page

```
struct RootPage {
  @State message: string = 'Hello World';

  build() {
    Navigation(nav.navPathStack) {
      Text(this.message).onClick(() => {
        router.push("name",new Object()).then((o:object)=>{
            // o The data returned for the next page
        })
      })
    }.navDestination(pageMap)
  }
}
```

7、The component to be redirected `NamePage`，Go back to the previous page `nav.back(new Object())` The parameter is the parameter passed to the previous page.

```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage({o:o}) // The component to be redirected, where o represents the data to be passed. It can be omitted if not needed.
  }.hideTitleBar(true) // Hide default navigation
}

nav.requestBuilder("name", wrapBuilder(NameBuilder)) // Register the component to the route container

@Component
export struct NamePage {
  /// Receive data
  o: object | undefined 
  build() {
    Text("back")
    .onClick(() => {
       nav.back(new Object())
    })
  }
}
```
Note: Router navigation requires registration of the component.
```
@Builder
export function NameBuilder(o: object) {
  NavDestination() {
    NamePage()
  }.hideTitleBar(true)
}

nav.requestBuilder("name", wrapBuilder(NameBuilder)) 
```

#### Plugin Details

Hello, dear students! Good morning! Today, we are going to talk about the Navigation container navigation component commonly used in HONOR. During the development process, page navigation is quite common. Generally, an application has dozens or even hundreds of pages, so controlling page navigation is of utmost importance.

一、First, it is necessary to understand the composition of the Navigation container navigation component. NavPathStack and NavDestination are the core components, along with a core attribute: navDestination(). The official documentation is quite elaborate, but the essence of it boils down to these three elements.

1、The Navigation component is the main page component. Add this component to the @Entry page.

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

2、NavPathStack is the key controller for managing page navigation.


```arkts
let navPathStack: NavPathStack = new NavPathStack();
```

3、NNavDestination is the component being navigated. It is a custom component decorated with @Component and needs to be invoked through a global dispatch call decorated with @Builder.


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

4、The "navDestination()" attribute of the Navigation component


```arkts
.navDestination((builderName: string, p: object) => {
  if (builderName == "testBuilder") {
    return wrapBuilder(testBuilder).builder(p)
  }
})

```

5、At this point, the entire page has reached a closed loop, and all the codes are listed.


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
      Text("Go back to the previous page").onClick(()=>{
        navPathStack.pop()
      })
    }
  }
}
```

Are you a little surprised? Why is it only so little, when there are so many documents? Yes! Exactly! The main core is just written like this, but to handle the daily cumbersome requirements, these codes need to be encapsulated!

Note: The complete code has been submitted to [HarmonyOS Third-Party Library](https://ohpm.openharmony.cn/#/cn/home),Use the following command to install.


```
ohpm install @free/navigation
```


Calling method: After writing the sub-page as described above, you need to register the requestBuilder for the sub-page.


```arkts
// Registration sub-page
nav.requestBuilder('path',wrapBuilder(testBuilder))
// Redirecting the page and receiving the returned parameters
nav.push("path",new Map).then((data)=>{
    if (data.data!=undefined) {
        // TODO: Handle the return parameters
    }
})
// Return to the page and pass the return parameter
nav.pop(new Map);
```

If you like this content, please give a little heart!


#### Contribution

1.  Fork the repository
2.  Create Feat_xxx branch
3.  Commit your code
4.  Create Pull Request


#### Gitee Feature

1.  You can use Readme\_XXX.md to support different languages, such as Readme\_en.md, Readme\_zh.md
2.  Gitee blog [blog.gitee.com](https://blog.gitee.com)
3.  Explore open source project [https://gitee.com/explore](https://gitee.com/explore)
4.  The most valuable open source project [GVP](https://gitee.com/gvp)
5.  The manual of Gitee [https://gitee.com/help](https://gitee.com/help)
6.  The most popular members  [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
