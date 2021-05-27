# 杂谈

这里放一些iOS开发者需要知道的技术点，及平时开发需要注意的小Tips。

记录来源：参考优秀的博客 + 文档 + 动手调试

---

## iOS响应者链:

UIApplication携带UITouch对象，通过`hittest`（探测器）`point` `event`属性找第一响应者。
```objective-c
 - (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event;
```
顺序：UIApplication(UITouch)->(UIWindow)->(VC)->(VC.View)->(SubView)

注意：alpha、hidden、userInteractionEnabled属性会阻断响应者链

(TODO: 需自行google调研、测试，待补充添加阅读链接)

---

## 动画

- 文顶顶 - [iOS开发UI篇—核心动画](https://www.cnblogs.com/wendingding/tag/IOS开发/default.html?page=5)

## 图形绘制

- 文顶顶 - [iOS开发UI篇—Quartz2D](https://www.cnblogs.com/wendingding/tag/IOS开发/default.html?page=5)

## 数据存储

- [iOS 存储方案从入门到精通](https://juejin.cn/post/6844903593913352206)

- 文顶顶的 - [数据库篇](https://www.cnblogs.com/wendingding/tag/%E6%95%B0%E6%8D%AE%E5%BA%93%E7%AF%87/)（包含SQLite和FMDB）


- ### 数据库对比（TODO）

## 网络

- [「HTTPS」如何通俗易懂的给你讲明白HTTPS？](https://juejin.cn/post/6955767063524671524)

- [如何给老婆解释什么是RESTful](https://zhuanlan.zhihu.com/p/30396391)

## 加密

- [iOS那几种加密解密常用算法](https://www.jianshu.com/p/3ec5ab0fed9b)

- [iOS 端 RSA 加密](https://cocoafei.top/2016/12/iOS-端-RSA-加密/)

## 编译速度优化

- [如何加快编译速度](https://www.zybuluo.com/qidiandasheng/note/587124)

---

## 依赖库管理工具

### `Carthage`与`CocoaPods`对比 (TODO)

### `Carthage` 相关 (TODO)

### `CocoaPods`相关
参考:
>[pod install vs. pod update](https://guides.cocoapods.org/using/pod-install-vs-update.html)
>[关于 Podfile.lock 带来的痛](http://www.samirchen.com/about-podfile-lock/)
> [iOS 中 Cocoapods 的 Bundle](https://juejin.im/entry/58abfab88fd9c50067fa2cf9)
> [cocoapods 管理图片资源和字体库](http://www.jianshu.com/p/2c7cf4fb0b30)

#### `pod install`   |  `pod update`
-  `pod install` 通常使用点
      - 安装cocoapods；
      - podfile中添加、删除，新依赖库；
      - 修改podfile中指定依赖库版本号;
每次执行`pod install`命令会先遵循`podfile`文件中的改动信息，然后再遵循podfile.lock文件而执行命令。

-  `pod update`通常使用点：
   - `pod update` 更新所有依赖库版本;
   - `pod update PODNAME` 更新指定依赖库版本;
`pod update`命令会遵循`podfile`文件指令下，从而更新依赖库。若未指定依赖库版本，则会默认更新到最新版本，然后会生成新的`podfile.lock`文件。

##### `Podfile.lock`
作用：跟踪，锁定，`podfile`文件中依赖库的`版本`。

第一次运行`pod install`命令时，会生成此文件，此文件会锁定你**此时**`podfile`文件中的版本。
之后每次修改`podfile`文件，或运行`pod update`命令时，会重新生成此文件。

##### `Manifest.lock`
Manifest.lock 是 Podfile.lock 的副本，每次只要生成 Podfile.lock 时就会生成一个一样的 Manifest.lock 存储在 Pods 文件夹下。在每次项目 Build 的时候，
会跑一下脚本检查一下 Podfile.lock 和 Manifest.lock 是否一致。

##### 如何加载`cocoapods`中的资源图片?
- 1、去`Pod`下`Bundle`中取获取资源图片

```objective-c
+ (UIImage *)ht_imageNamed:(NSString *)name ofType:(nullable NSString *)type {
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"SMPagerTabView.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if (bundle == nil) {
        bundlePath = [NSString stringWithFormat:@"%@/%@",mainBundlePath,@"Frameworks/CcfaxPagerTab.framework/SMPagerTabView.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:type]];
    }
}

```

- 2、真机获取不到`pod`中的资源`bundle`，所以图片显示不出来。可以这样取`cocoapods`中的`bundle`资源图片
[How to load resource in cocoapods resource_bundle](https://stackoverflow.com/questions/35692265/how-to-load-resource-in-cocoapods-resource-bundle)

```objective-c
    // fix：真机加载不到Bundle中资源图片。 date：20170816
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    NSURL *bundleURL = [[frameworkBundle resourceURL] URLByAppendingPathComponent:@"SMPagerTabView.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
    UIImage *image = [UIImage imageNamed:@"shadowImg" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    self.shadowImgView.image = image;
```

---

## webView

### webView & WKWebview

TODO

### iOS原生与H5交互
参考:
> [Objective-C与JavaScript交互的那些事](http://www.cocoachina.com/ios/20160127/15105.html)

> [OC调JS](http://blog.csdn.net/lwjok2007/article/details/47058101) | [JS调OC](http://blog.csdn.net/lwjok2007/article/details/47058795)

> [关于iOS7里的JavaScriptCore framework
](http://www.webryan.net/2013/10/about-ios7-javascriptcore-framework/)

- ##### JS给OC传消息

    1、拦截跳转的方式

   JS这边发请求，iOS把请求拦下来，再扒出请求url里的字符串，再各种截取得   到有用的数据

   ```objective-c
   UIWebView 用来监听请求触发也是通过 UIWebView 相关的 delegate
   method：web​View(_:​should​Start​Load​With:​navigation​Type:​)
   官方文档，方法中返回一个 Boolean，来判定是否让请求继续执行。
   ```

    2、JavaScriptCore
   JS调用OC函数（代码块），给OC值（参数），让OC做一些事情。传值、方法   命名都按web前端开发人员来定义。两端做适配。

- ##### OC给JS传消息
   OC调用JS函数给JS传值，JS函数接到此值（参数）做一些事情。

   即: Objective-C执行JavaScript代码：
   ```objective-c
   // 获取当前页面的title
   NSString *title = [webview    stringByEvaluatingJavaScriptFromString:@"document.title"];

   // 获取当前页面的url
   NSString *url = [webview    stringByEvaluatingJavaScriptFromString:@"document.location.href"];
   ```

   例子：弹窗
   - 第一种方式： `WebView`直接调用   `stringByEvaluatingJavaScriptFromString`属性

   ```objective-c
   [webView stringByEvaluatingJavaScriptFromString:@"alert('test js OC')"];
   ```

   - 第二种方式: `JavaScriptCore`
   ```objective-c
   JSContext *context=[webView    valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
   NSString *alertJS=@"alert('test js OC')"; //准备执行的js代码
   [context evaluateScript:alertJS];//通过oc方法调用js的alert
   ```

   - 第三种就是使用`WKWebview`

---

## TableView优化
参考：
> - [UITableView优化技巧](http://longxdragon.github.io/2015/05/26/UITableView%E4%BC%98%E5%8C%96%E6%8A%80%E5%B7%A7/)
> - [iOS-UITableView性能优化总结（附实例）](https://juejin.cn/post/6844903841163395080)

##### 复杂Cell(图文混排、高度自适应)
- 提前计算并缓存好高度（布局），因为heightForRowAtIndexPath:是调用最频繁的方法；
- 异步绘制，遇到复杂界面，遇到性能瓶颈时，可能就是突破口；
- 滑动时按需加载，这个在大量图片展示，网络加载的时候很管用！（SDWebImage已经实现异步加载，配合这条性能杠杠的）。

##### 需要注意的小Tips

- Cell的子视图imageView赋值，不要直接使用url转data转image对象方式进行赋值，若使用此方式一定要在子线程操作，且自己写缓存。推荐使用SDWebimage方式设置imageView。
- 正确使用reuseIdentifier来重用Cells，最核心的思想就是UITableViewCell的重用机制，极大的减少了内存的开销。自己不要在cellForRowAtIndexPath：回调中创建Cell。
```objective-c
// 不要这样自己创建
InfomationTableViewCell *cell = [[InfomationTableViewCell alloc] init];
```
- 尽量少用或不用透明图层，尽可能不不要切圆角，尽可能不要操作layer层。
- 减少subviews的数量。
- 尽量少用addView给Cell动态添加View，可以初始化时就添加，然后通过hide来控制是否显示。
- 在heightForRowAtIndexPath:中尽量不使用cellForRowAtIndexPath:，如果你需要用到它，只用一次然后缓存结果。
- xib中别忘记设置重用的标识，否则cell就不会发生重用

## 平时开发需要注意的小Tips
- imageNamed: 与 imageWithContentsOfFile:的差异(imageNamed: 适用于会重复加载的小图片，因为系统会自动缓存加载的图片，imageWithContentsOfFile: 仅加载图片)。

- [iOS之load与initialize详解和区别](https://www.jianshu.com/p/7b73be129d2b)

- [iOS - layoutSubviews总结（作用及调用机制）](https://www.jianshu.com/p/a2acc4c7dc4b)

- [应用程序生命周期] todo

- [iOS 视图生命周期](https://www.jianshu.com/p/e36a5d64ede2)

- 布局Tips
   [Cocoa-Swift-UIViewController布局Tips](http://study1234.com/cocoa-swift-uiviewcontrollerbu-ju-tips/)

  ##### topLayoutGuide & bottomLayoutGuide

  > - topLayoutGuide表示Y轴的最高点限制，表示不希望被Status Bar或Navigation Bar遮挡的视图最高位置。
  > - bottomLayoutGuide表示Y轴的最低点限制，表示不希望被UITabbarController遮挡的视图最低点距离supviewlayout的距离。

  ##### frame & bounds

  > - frame就是相对于父视图的布局位置与大小:
  > - bounds与frame最大的不同就是坐标系不同，bounds原点始终是(0,0)，而frame的原点则不一定，而是相对于其父视图的坐标。

---
