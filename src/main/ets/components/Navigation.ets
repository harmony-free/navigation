/**
 * 使用的时候需要注册相关@Builder组件
 * 需要再容器组件中添加 router.navPathStack 和 routerMap
 * Navigation(router.navPathStack){}.navDestination(routerMap)
 */

import { AnimateCallback, CustomTransition } from './CustomNavigationUtils'

/**
 * Router回调用的参数
 */
interface NavCallBackFace {
  name: string
  resp: NavResp
  res: (value: NavRespFace | PromiseLike<NavRespFace>) => void
}

/**
 * Router回调用的参数
 */
class NavCallBack implements NavCallBackFace {
  name: string
  resp: NavResp = new NavResp()
  res: (value: NavRespFace | PromiseLike<NavRespFace>) => void =
    (value: NavRespFace | PromiseLike<NavRespFace>) => {
    }

  constructor(name: string, res: (value: NavRespFace | PromiseLike<NavRespFace>) => void) {
    this.name = name
    this.res = res
  }
}

/**
 * Router:返回数据
 */
interface NavRespFace {
  code: number
  message: string
  error: Error | undefined
  data: object | undefined
}

/**
 * Router:返回数据
 */
class NavResp implements NavRespFace {
  code: number = 0
  message: string = "跳转成功"
  error: Error | undefined = undefined
  data: object | undefined = undefined
}


/**
 * Router:系统Map数据
 */
interface NavInfoFace {
  name: string
  pageSourceFile: string
  buildFunction: string
  moduleName: string
}


/**
 * Router: 实体接口类
 */
interface NavFace {
  push(url: string, params?: object, animation?: boolean): Promise<NavRespFace>

  replace(url: string, params?: object, animation?: boolean): Promise<NavRespFace>

  pop(params: object, animation?: boolean): Promise<NavRespFace>

  // remove(id: number | string): Promise<RouterRespFace>
  //
  // clear(): Promise<RouterRespFace>
}

/**
 * Router: 实体类
 */
// Navigation
class Navigation implements NavFace {
  navPathStack: NavPathStack = new NavPathStack();
  routerMap: Map<string, NavInfoFace> = new Map();
  callBack: Array<NavCallBack> = new Array<NavCallBack>()
  builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();
  is404: boolean = true

  constructor() {
    /**
     * 路由拦截
     * willShow: 页面跳转前回调，允许操作栈，在当前跳转生效。
     * didShow: 页面跳转后回调，在该回调中操作栈会在下一次跳转生效。
     * modeChange: Navigation单双栏显示状态发生变更时触发该回调。
     */
    this.navPathStack.setInterception({
      willShow: (from: NavDestinationContext | NavBar) => {
      }
    })
  }

  /**
   * 生成随机UUID
   * @returns
   */
  generateUUID(): string {
    return 'xxxxyxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  animation(from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation):NavigationAnimatedTransition | undefined{
    if (from.mode == NavDestinationMode.DIALOG || to.mode == NavDestinationMode.DIALOG) {
      return undefined;
    }
    // 首页不进行自定义动画
    if (from.index === -1 || to.index === -1) {
      return undefined;
    }
    CustomTransition.getInstance().operation = operation;
    if (CustomTransition.getInstance().interactive) {
      let customAnimation: NavigationAnimatedTransition = {
        onTransitionEnd: (isSuccess: boolean) => {
          console.log("===== current transition is " + isSuccess);
          CustomTransition.getInstance().recoverState();
          CustomTransition.getInstance().proxy = undefined;
        },
        transition: (transitionProxy: NavigationTransitionProxy) => {
          CustomTransition.getInstance().proxy = transitionProxy;
          let targetIndex: string | undefined = operation == NavigationOperation.PUSH ?
            (to.navDestinationId) : (from.navDestinationId);
          if (targetIndex) {
            CustomTransition.getInstance().fireInteractiveAnimation(targetIndex, operation);
          }
        },
        isInteractive: CustomTransition.getInstance().interactive
      }
      return customAnimation;
    }
    let customAnimation: NavigationAnimatedTransition = {
      onTransitionEnd: (isSuccess: boolean) => {
        console.log(`current transition result is ${isSuccess}`)
      },
      // 转场开始时系统调用该方法，并传入转场上下文代理对象
      transition: (transitionProxy: NavigationTransitionProxy) => {
        if (!from.navDestinationId || !to.navDestinationId) {
          return;
        }
        // 从封装类CustomTransition中根据子页面的序列获取对应的转场动画回调
        let fromParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(from.navDestinationId);
        let toParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(to.navDestinationId);
        if (operation == NavigationOperation.PUSH) {
          if (toParam.start) {
            toParam.start(true, false);
          }
          animateTo({
            duration: 300, onFinish: () => {
              transitionProxy.finishTransition();
            }
          }, () => {
            if (toParam.finish) {
              toParam.finish(true, false);
            }
          })
        } else {
          if (fromParam.start) {
            fromParam.start(true, true);
          }
          animateTo({
            duration: 300, onFinish: () => {
              transitionProxy.finishTransition();
            }
          }, () => {
            if (fromParam.finish) {
              fromParam.finish(true, true);
            }
          })
        }
      }
    };
    return customAnimation;
  };



  /**
   * 注册builder
   * @param name builder 名称标识
   * @param builder 全局UI组件
   */
  requestBuilder(name: string, builder: WrappedBuilder<[object]>) {
    this.builderMap.set(name, builder)
  }

  /**
   * 路由跳转
   * @param name:string | WrappedBuilder 需要跳转的页面名称或者页面组件
   * @param params 跳转传入的参数
   * @param animation 跳转动画
   * @returns
   */
  push(name: string | WrappedBuilder<[object]>, params?: object,
    animation?: boolean | undefined): Promise<NavRespFace> {
    return new Promise<NavRespFace>((res, rej) => {
      let url = ""
      if (typeof name != 'string') {
        url = this.generateUUID()
        this.requestBuilder(url, name)
      } else {
        url = name
      }
      if (!this.builderMap.has(url) && !this.is404) {
        return;
      }
      this.callBack.push(new NavCallBack(url, res))
      this.navPathStack.pushPathByName(url, params, animation)
    })
  }

  /**
   * 路由重载
   * @param name:string | WrappedBuilder 需要重载的页面名称或者页面组件
   * @param params 跳转传入的参数
   * @param animation 跳转动画
   * @returns
   */
  replace(name: string | WrappedBuilder<[object]>, params?: object,
    animation?: boolean | undefined): Promise<NavRespFace> {
    return new Promise<NavRespFace>((res, rej) => {
      let url = ""
      if (typeof name != 'string') {
        url = this.generateUUID()
        this.requestBuilder(url, name)
      } else {
        url = name
      }
      if (!this.builderMap.has(url) && !this.is404) {
        return;
      }
      this.call()
      this.callBack.push(new NavCallBack(url, res))
      this.navPathStack.replacePathByName(url, params, animation)
    })
  }

  back(params?: object, animation?: boolean | undefined): Promise<NavRespFace> {
    return new Promise<NavRespFace>((res, rej) => {
      this.call(params)
      this.navPathStack.pop(params, animation)
    })
  }

  backName(name: string, params?: object,
    animation?: boolean | undefined): Promise<NavRespFace> {
    return new Promise<NavRespFace>((res, rej) => {
      if (!this.builderMap.has(name)) {
        if (this.is404) {
          this.push("")
        } else {
          return;
        }
      } else {
        this.callName(name, params)
        this.navPathStack.popToName(name, params, animation)
      }
    })
  }

  pop(params?: object, animation?: boolean | undefined): Promise<NavRespFace> {
    return new Promise<NavRespFace>((res, rej) => {
      this.call(params)
      this.navPathStack.pop(params, animation)
    })
  }

  home(params?: object, animation?: boolean | undefined): Promise<NavRespFace> {
    return new Promise<NavRespFace>((res, rej) => {
      this.call(params,0);
      this.navPathStack.popToIndex(0,params, animation)
    })
  }

  builder(url: string): WrappedBuilder<[object]> | undefined {
    return this.builderMap.get(url)
  }

  private callName(name: string, params?: object) {
    let url = this.call(params)
    if (url != undefined) {
      if (url != name) {
        this.call(params)
      }
    }
  }

  private call(params?: object,index?:number): string | undefined {
    let call:NavCallBack | undefined
    if (index == 0 && this.callBack.length > 0) {
      call = this.callBack[0];
      this.callBack = [];
    }else{
      call = this.callBack.pop()
    }
    if (call) {
      call.resp.data = params
      call.res(call.resp)
      return call.name
    }
    return undefined
  }

  size(): number {
    return this.navPathStack.size()
  }

  // remove(id: string | number): Promise<RouterRespFace> {
  //   return new Promise<RouterRespFace>((res, rej) => {
  //     let resp = new RouterResp()
  //     res(resp)
  //   })
  // }
  //
  // clear(): Promise<RouterRespFace> {
  //   return new Promise<RouterRespFace>((res, rej) => {
  //
  //   })
  // }
}

/**
 * 在Navigation 页面 navDestination 注册 routerMap方法
 * @param builderName
 * @param p
 */

@Builder
export function routerMap(builderName: string, p: object) {
  if (nav.builderMap.has(builderName)) {
    nav.builder(builderName)!.builder(p)
  } else {
    wrapBuilder(page404).builder({ name: builderName, state: 404 })
  }
}

/**
 * 系统默认页面参数
 */
interface PageState {
  name?: string
  state?: number
  msg?: string
}

/**
 * 系统默认404页面
 * @param o:PageState 传参对象
 */
@Builder
export function page404(o: PageState) {
  NavDestination() {
    Text() {
      Span('404\n').fontSize(30)
      Span(`很抱歉，您所访问的页面${o.name}不存在\n，请联系系统管理员~`)
    }.textAlign(TextAlign.Center).margin({ top: 50 })
  }.title("页面未找到")
}

/**
 * 系统默认500页面
 * @param o:PageState 传参对象
 */
@Builder
export function page500(o: PageState) {
  NavDestination() {
    Text() {
      Span('500\n').fontSize(30)
      Span(`很抱歉，您所访问的页面数据有误\n，请联系系统管理员~`)
    }.textAlign(TextAlign.Center).margin({ top: 50 })
  }.title("页面数据出错")
}

export const nav = new Navigation()
