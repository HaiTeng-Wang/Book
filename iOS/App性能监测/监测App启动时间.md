
# App启动时间

参考：

> [iOS-Performance-Optimization][iOS-Performance-Optimization#启动优化]

## App启动分为两种方式

- 冷启动：App 不在内核缓冲存储器中。指的是当应用还没准备好运行时，我们必须加载和构建整个应用。
- 热启动：App 和数据已经在内存中。指的是应用已经运行但是在后台被挂起（比如用户点击了 home 健）

监测App启动时间，通常指监测冷启动时间。热启动，系统会直接从后台取当前程序，所以很快。

## 如何监测App启动时间

启动时间由 main 之前的启动时间和 main 之后的启动时间两部分组成

### pre-main （main函数之前）

下图是Apple 在 WWDC 上展示的 PPT，是对 main 之前启动所做事的一个简单总结

![AppPreMain]

Xcode 测量 pre-main 时间:

 Xcode -> Edit scheme -> Run -> Arguments 将环境变量 DYLD_PRINT_STATISTICS 设为 1

![DYLD_PRINT_STATISTICS]

再次Run就可以看到控制台输出：
```
Total pre-main time: 675.25 milliseconds (100.0%) // main函数之前共用了675.25毫秒（1秒=1000毫秒）
         dylib loading time: 258.05 milliseconds (38.2%) // 加载动态库用了258.05毫秒
        rebase/binding time: 206.68 milliseconds (30.6%) // 指针重定位使用了206.68毫秒
            ObjC setup time:  53.33 milliseconds (7.8%) // ObjC类初始化使用了53.33毫秒
           initializer time: 156.90 milliseconds (23.2%)
           slowest intializers  // 用时最多的这些初始化
               libSystem.dylib :  15.23 milliseconds (2.2%)
    libMainThreadChecker.dylib :  69.20 milliseconds (10.2%)
                    YangJinSuo :  42.98 milliseconds (6.3%)
```

**注意：如上测试是我在模拟器上的测试输出，所以输出值很大。测试要以真机为准。**

### main函数之后

有的人把 main 到 didFinishLaunching 结束的这一段时间作为指标，有的人把 main 到第一个 ViewController 的 viewDidAppear 作为考量指标。

如下两种方案监测main函数之后执行时间

#### 1、打点测试

代码示例：
```Objective-C
CFAbsoluteTime StartTime;

int main(int argc, char * argv[]) {
    @autoreleasepool {
        StartTime = CFAbsoluteTimeGetCurrent();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

extern CFAbsoluteTime StartTime;
 ...

// 在 applicationDidFinishLaunching:withOptions: 方法的最后统计
dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"Launched in %f sec", CFAbsoluteTimeGetCurrent() - StartTime);
});
```

我目前使用的是“贝聊科技”写的[BLStopwatch][BLStopwatch]。

![AfterMainFromIPhone.png]

#### [ 2、Time Profiler][Instrument-TimeProfiler]

可以查看多个线程中每个方法的耗时

##### 首先对Xcode进行设置

如果想要在TimeProfile中直观的查看方法耗时，需要对Xcode进行设置 在Xcode->Build Setting->Debug Information Format中设置选项为：DWARF with DSYM File。（ **不设置该选项，只能看到一堆栈**）

`dSYM`：dSYM 文件是保存 16 进制函数地址映射信息的中转文件。指具有调试信息的目标文件。

![Config-dSYM]

##### Xcode设置完之后就可以打开Time Profiler了

![TimeProfileTest.gif]

##### Call Tree:

- Separate By Thread：线程分离,只有这样才能在调用路径中能够清晰看到占用CPU最大的线程；

- Invert Call Tree：从上到下跟踪堆栈信息.这个选项可以快捷的看到方法调用路径最深方法占用CPU耗时,比如FuncA{FunB{FunC}},勾选后堆栈以C->B->A把调用层级最深的C显示最外面；

- Hide Missing Symbols：隐藏缺失符号。如果 dSYM 文件或其他系统架构缺失，列表中会出现很多奇怪的十六进制的数值，用此选项把这些干扰元素屏蔽掉，让列表回归清爽。

- Hide System Libraries：这个就更有用了,勾选后耗时调用路径只会显示app耗时的代码,性能分析普遍我们都比较关系自己代码的耗时而不是系统的.基本是必选项.注意有些代码耗时也会纳入系统层级，可以进行勾选前后前后对执行路径进行比对会非常有用。

- Flattern Recursion：拼合递归。将同一递归函数产生的多条堆栈（因为递归函数会调用自己）合并为一条。

- Top Functions：按耗时降序排列。

### 避免App启动时间过长（优化）

#### main函数启动之前的优化

- 减少动态库静态库的存在；必要的情况下，合并动态库。或者可以把代码注入到主程序。
- 减少 Class,selector 和 category 这些元数据的数量。
从编码原则和设计模式之类的理论都会鼓励大家多写精致短小的类和方法，并将每部分方法独立出一个类别，其实这会增加启动时间。
所以，合并一些在工程、架构上没有太大意义的扩展。（可以使用AppCode工具，检测项目中没有用到的类）
- 不要在load方法里面进行太多或耗时操作；

#### main函数启动之后的优化

- 不使用xib，直接使用代码加载首页视图；
- NSUserDefaults实际上是在Library文件夹下会生产一个plist文件，
如果文件太大的话一次能读取到内存中可能很耗时，这个影响需要评估，
如果耗时很大的话需要拆分(需考虑老版本覆盖安装兼容问题)；
- 先展示出UI，再刷新数据。给用户视觉上冲击感；
- 启动任务细分，不需要及时初始化，或不需要在主线程初始化的，选择异步或延后处理（网络请求，三方服务的注册，管理类的注册等）；

### 目标

苹果并没有硬性指标规定启动时间，以下两点是开发者们得调研总结：
> - 应该在400ms内完成main()函数之前的加载
> - 整体过程耗时不能超过20秒，否则系统会kill掉进程，App启动失败

目标，App启动时间越快越好。不要超过2秒。

[iOS-Performance-Optimization#启动优化]: https://github.com/skyming/iOS-Performance-Optimization#启动优化
[AppPreMain]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/AppPreMain.png
[DYLD_PRINT_STATISTICS]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/DYLD_PRINT_STATISTICS.png
[BLStopwatch]: https://github.com/beiliao-mobile/BLStopwatch
[AfterMainFromIPhone.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/AfterMainFromIPhone.png
[Config-dSYM]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/Config-dSYM.png
[Instrument-TimeProfiler]: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Instrument-TimeProfiler.html
[TimeProfileTest.gif]: https://github.com/HaiTeng-Wang/Book/blob/master/iOS/App%E6%80%A7%E8%83%BD%E7%9B%91%E6%B5%8B/TimeProfileTest.gif
