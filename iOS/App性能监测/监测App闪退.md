
在引入客户端**崩溃监控分析**工具之前，做了一番调研。

如今国内外已经有好些个第三方的崩溃监控分析的服务。正如【[移动开发之崩溃监控分析服务][移动开发之崩溃监控分析服务]】这篇文章中所说这样。

在这里我选择引入鹅厂的[Bugly][Bugly]来监测App崩溃，同时也可以很方便的监测线上App页面流畅度。也可以很方便的实现热更新功能。

经过我的使用及测试，Bugly确实简洁、方便、实时性，统计性很强。其带来的成本也是微乎其微。

Bugly主要提供以下服务：

- 异常上报
  - 崩溃分析
  - 卡顿分析
  - 错误分析
- 运营统计
- 应用升级（热更新）

在这里我并未集成热更新功能，如果文档未能满足你热更新功能集成，[这里][iOS接入Bugly的JSPatch热更新服务]有篇文章可参考。

[Bugly检查卡顿的依据和上报时机是什么?][Bugly检查卡顿原理]
> iOS 卡顿检查的依据是监控主线程 Runloop 的执行，观察执行耗时是否超过预定阀值(默认阀值为3000ms) 在监控到卡顿时会立即记录线程堆栈到本地，在App从后台切换到前台时，执行上报。


很遗憾的是，Bugly并非开源。其监听崩溃的原理**冯义力**(腾讯Bugly项目组高级工程师)前辈是这样回答的“**从系统的监听函数中获取当前的发生崩溃的异常信息，这个堆栈就在异常信息中**”。

我猜想也是通过```NSSetUncaughtExceptionHandler```函数的调用：

```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    return YES;
}
```

```Objective-C
void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
}
```

[Bugly]: https://bugly.qq.com/v2/index
[移动开发之崩溃监控分析服务]: https://mp.weixin.qq.com/s?__biz=MzIwMTQwNTA3Nw==&mid=402317533&idx=1&sn=37eefadfe316b8fc90864040fb5ca0b3&scene=1&srcid=0425oAcZTTkDUaHglFlqFtpQ&key=b28b03434249256b8137e5241f6eba74060807263aea8b493f5572765e6cb19c1d8bef0a6547ee98e5b437bee9555064&ascene=0&uin=MTIzNzM4NjQ2MQ%3D%3D&devicetype=iMac+MacB
[iOS接入Bugly的JSPatch热更新服务]: https://www.coder4.com/archives/5262
[Bugly检查卡顿原理]: https://bugly.qq.com/docs/user-guide/faq-ios/?v=20170912151050#2
