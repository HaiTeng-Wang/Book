# Router

[路由][路由]

> - 路由（routing）就是通过互联的网络把信息从源地址传输到目的地址的活动；
> - 路由通常根据路由表（一个存储到各个目的地的最佳路径表）来引道分组传送；
> - 经过一些中间的节点后，到它们最后的目的地；
> - 作为硬件的话，则为路由器；
> - 通过路由寻址。

## github上几个热度不错的库

### [HHRouter][HHRouter]

##### HHRouter是一个单利对象

```Objective-c
+ (instancetype)shared;
```

##### map方法给controllerClass映射（注册）对应的自定义url

```Objective-C
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
```

##### matchController方法通过url匹配（获取）对应的controllerClass

```Objective-C
- (UIViewController *)matchController:(NSString *)route;
```

##### 提供个UIViewController的Category，用于控制器获取所需要的参数

```Objective-C
@interface UIViewController (HHRouter)

@property (nonatomic, strong) NSDictionary *params;

@end
```

##### Block相关API

```Objective-C
// 映射（注册）
- (void)map:(NSString *)route toBlock:(HHRouterBlock)block;
// 匹配（获取）
- (HHRouterBlock)matchBlock:(NSString *)route;
// 调用
- (id)callBlock:(NSString *)route;
```

##### 查询Router类型

```Objective-C
- (HHRouteType)canRoute:(NSString *)route;
```

#### 原理

##### 映射（注册）

```Objective-C
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
- (void)map:(NSString *)route toBlock:(HHRouterBlock)block;
```

第一个参数“router”字符串，第二个参数controllerClass/block

1、通过“router”字符串，获取pathComponents数组

把router字符串转换成url对象，遍历url.path.pathComponents，剔除“/”，然后将这些Component放到数组中。

比如url.path.pathComponents为：
```
<__NSArrayM 0x60400025c200>(
/,
Lgoin
)
```

剔除“/”得到pathComponents数组

```
<__NSArrayM 0x60000024bc70>(
Lgoin
)
```

2、获取到pathComponents数组，按顺序数组中每一个元素作为Key生成嵌套字典。

将这个嵌套字典放到HHRouter私有成员变量routes进行存储，routers是一个NSMutableDictionary。

3、将controllerClass/block存储到对应的字典中，key为“_”

HHRouter的routes结构例子：

```
{
    Lgoin =     {
        "_" = LoginViewController;
    };
}
```

##### 匹配（获取）

```Objective-C
- (UIViewController *)matchController:(NSString *)route;
- (HHRouterBlock)matchBlock:(NSString *)route;
```

参数route字符串，返回值UIViewController/HHRouterBlock

1、通过route字符串匹配生成新的参数字典

重新生成的这个参数字典示例：

```
{
   "controller_class" = LoginViewController;
   route = "XXXAPPScheme://User/Lgoin/?userId=888888";
   userId = 888888;
}
```

2、获取到对应的params（NSDictionary），即可获取到UIViewController/HHRouterBlock

3、初始化controllerClass/实现HHRouterBlock

4、将参数params赋值给viewController/block的参数params

（HHRouter提供个UIViewController的Category，用于获取控制器所需要的参数）

5、返回viewController/block调用

### [MGJRouter][MGJRouter]

蘑菇街开源的库，此库的README有详细介绍。

[蘑菇街 App 的组件化之路][蘑菇街 App 的组件化之路]实现组件之间通信工具。

作者描述：

> 已经有几款不错的 Router 了，如 JLRoutes, HHRouter, 但细看了下之后发现，还是不太满足需求。
JLRoutes 的问题主要在于查找 URL 的实现不够高效，通过遍历而不是匹配。还有就是功能偏多。
HHRouter 的 URL 查找是基于匹配，所以会更高效，MGJRouter 也是采用的这种方法，但它跟 ViewController 绑定地过于紧密，一定程度上降低了灵活性。
于是就有了 MGJRouter。


核心功能:

对一个回调（block）映射（注册）相应的地址（自定义url）,然后通过这个地址（自定义url）寻址，触发回调。


基本使用:

```Objective-C
[MGJRouter registerURLPattern:@"mgj://foo/bar" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameterUserInfo:%@", routerParameters[MGJRouterParameterUserInfo]);
}];

[MGJRouter openURL:@"mgj://foo/bar"];
```

如果想实现页面跳转，需要在Block回调中进行相关操作:

```Objective-C
[MGJRouter registerURLPattern:@"mgj://foo/bar" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameterUserInfo:%@", routerParameters[MGJRouterParameterUserInfo]);
    // create view controller with id
    // push view controller
}];
```

```Objective-C
[MGJRouter openURL:@"mgj://foo/bar"];
```

### [JLRoutes][JLRoutes]

JLRoutes基于Block相关API生成的URL路由库，支持ios、osx、tvos。版本最低兼容iOS7。

JLRoutes支持在特定的URL scheme中设置路由

支持使用通配符的方式生成路由

支持使用可选参数设置路由

可以查询Routes

可以让一个单独的类或对象成为处理者

可以设置优先级

等等.......

总的来说这个库，比较灵活，职责划分明确，生成一个比较全面的路由。

正因为JLRoutes功能齐全，所以JLRoutes会重一些。

##### JLRouter通过不同的类划分各自的职责：

- JLRoutes

  > JLRoutes类是JLRoutes框架的主要入口点。 用于访问schemes，管理路由和路由URL。

  依赖所有Class：
  ```
  #import "JLRRouteDefinition.h"
  #import "JLRRouteHandler.h"
  #import "JLRRouteRequest.h"
  #import "JLRRouteResponse.h"
  #import "JLRRouteDefinition.h"
  #import "JLRParsingUtilities.h"
  ```

- JLRRouteDefinition

  > JLRRouteDefinition是表示已注册路由的模型对象，包括URL scheme，路由pattern和priority；

  > 这个类的子类覆盖`-routeResponseForRequest`这个方法可以解析路由行为；

  > `callHandlerBlockWithParameters`也可以被子类重写来自定义传递给handlerBlock的参数。

  依赖：
  ```
  #import "JLRRouteRequest.h"
  #import "JLRRouteResponse.h"
  #import "JLRoutes.h"
  #import "JLRParsingUtilities.h"
  ```

- JLRRouteHandler

  > `JLRRouteHandler`是一个类，可以创建block处理者，通过 addRoute: call进行传递。
  这对于，如果您想让一个单独的类或对象成为处理者情况下特别有用。

  > 你的目标类需要遵守`JLRRouteHandlerTarget`协议。

  无依赖

- JLRRouteRequest

  > JLRRouteRequest是表示路由URL的请求的模型。

  > 它被分解成路径组件(path components )和查询参数(query parameters)，然后由JLRRouteDefinition使用它来尝试匹配。

  无依赖

- JLRRouteResponse

  > JLRRouteResponse尝试响应来自JLRRouteRequest类的请求。

  无依赖

- JLRParsingUtilities

  工具类

  无依赖

##### 路由实现的核心，都是一样的。注册 - 匹配  

JLRoutes内部这两个方法

注册
```objc
- (void)_registerRoute:(JLRRouteDefinition *)route
```

匹配，执行block
```objc

- (BOOL)_routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters executeRouteBlock:(BOOL)executeRouteBlock
```

##### 所有的route存储在一个内部字典中（这个字典可以理解为路由表）

内部字典:
```objc
static NSMutableDictionary *JLRGlobal_routeControllersMap = nil;
```

key：
```objc
@property (nonatomic, strong) NSString *scheme;
```

默认的key：
```objc
NSString *const JLRoutesGlobalRoutesScheme = @"JLRoutesGlobalRoutesScheme";
```

value：
```objc
@property (nonatomic, strong) NSMutableArray *mutableRoutes;
```

##### 关于JLRoutes的使用，我根据README翻译了一份中文文档，可以[这里][JLRoutes中文文档]查看。

---

**在移动端开发中，“Router”的原理和“路由器”的原理差不多**

#### 我使用Router的原因：

##### 1、解VC耦合

- Router作为中间站，对UIViewController/Activity进行解耦；
- 把每一个UIViewController/Activity映射为对应的自定义URL。一个地址对应一个页面；
- 通过这个URL匹配（获取）对应的UIViewController/Activity；
- UIViewController/Activity需要的参数通过URL传输；
- 所有的URL可以理解为路由表；

##### 2、当APP接收到消息时，可进入任意指定页面

- 其它App，可进入App中任意指定页面；
- 通过指定链接，可进入App中任意指定页面；
- App接受到远程消息，进入任意指定页面；


#### 使用Router也存在一定的弊端：

- 路由注册和获取，占用一定时间。

- 路由是一个单利对象，所有的Url以及参数被存储在这个单利的私有成员变量中。（这个私有变量是一个可变字典。）所以，会产生一定的内存开销。

   但是，影响不大。

#### 为了管理路由、路由表、以及路由与VC之间的关系，我抽象出一个中间层。如图：

![][AppRouter.png]


我使用Router的初衷就是为了方便的与VC进行绑定，而且我的App业务并不复杂，所以我选择HHRouter这个库作为URLRouter。

 - HHRouter较轻量级

 - 可以与VC进行绑定，VC也可方便的获取所需参数

 - HHRouter提供的API可以完全满足我的工程

抽象层的实现，我写了一份[Demo][Demo]。（仅供参考）


#### 对于抽象层的议论

安卓同学说：“这个抽象层，是完全没有必要存在的。这是过度设计”。

而我觉得，抽象层的必要性：

- 内聚，跳转关系。
- 方便管理路由表与各个VC对应；
- 提供简单的API，供业务代码使用；

这个还是因工程而议吧。凡事各有利弊。（欢迎提出你的观点）

#### 自定义URL（即：路由的路线）

移动端（iOS/Android）统一定义。


[路由]: https://zh.wikipedia.org/wiki/%E8%B7%AF%E7%94%B1
[HHRouter]: https://github.com/lightory/HHRouter
[MGJRouter]: https://github.com/meili/MGJRouter
[JLRoutes]: https://github.com/joeldev/JLRoutes/blob/master/JLRoutes/JLRoutes.m
[蘑菇街 App 的组件化之路]: http://limboy.me/tech/2016/03/10/mgj-components.html
[JLRoutes中文文档]: https://github.com/HaiTeng-Wang/Book/blob/master/iOS/JLRoutes中文文档.md

[Demo]: https://github.com/HaiTeng-Wang/iOSFrameworkDemo
[AppRouter.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/AppRouter.png
