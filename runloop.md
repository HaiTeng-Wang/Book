# Runloop

参考：

> [官方文档][官方文档] | [中文翻译][中文翻译] |[开源地址][开源地址]

> [孙源的Runloop分享][孙源的Runloop分享]

> [深入理解RunLoop][深入理解RunLoop]

> [RunLoop 总结及应用][RunLoop 总结及应用]

## 什么是runloop?

##### 字面上看运行循环

[Event loop][Event loop]

跑圈

##### 基本作用

保持程序的持续运行(主运行循环)，并接受用户输入

其实它内部就是do-while循环,在这个循环内部不断的处理各种任务(比如Source、Timer、Observer)（比如苹果利用 RunLoop 实现自动释放池、延迟回调、触摸事件、屏幕刷新等功能）决定程序在何时应处理哪些Event

节省CPU资源，提高程序性能：该做事时做事，该休息时休息

##### 存在主要价值

UIApplicationMain函数一直没有返回，就是因为函数内部就启动了一个RunLoop
所以，保持了程序的持续运行

这个默认启动的RunLoop是跟主线程相关联的

##### runloop与线程的关系

每条线程都有唯一的一个与之对应的RunLoop对象，其关系是保存在一个全局的 Dictionary 里。

线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。RunLoop在第一次获取时创建，在线程结束时销毁

主线程的RunLoop已经自动创建好了，子线程的RunLoop需要主动创建

苹果不允许直接创建 RunLoop，它只提供了两个自动获取的函数：CFRunLoopGetMain() 和 CFRunLoopGetCurrent()。

在NSRunLoop中这两个函数转化的API为currentRunLoop 和 mainRunLoop

```Objective-C
/// 全局的Dictionary，key 是 pthread_t， value 是 CFRunLoopRef
static CFMutableDictionaryRef loopsDic;
/// 访问 loopsDic 时的锁
static CFSpinLock_t loopsLock;

/// 获取一个 pthread 对应的 RunLoop。
CFRunLoopRef _CFRunLoopGet(pthread_t thread) {
    OSSpinLockLock(&loopsLock);

    if (!loopsDic) {
        // 第一次进入时，初始化全局Dic，并先为主线程创建一个 RunLoop。
        loopsDic = CFDictionaryCreateMutable();
        CFRunLoopRef mainLoop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, pthread_main_thread_np(), mainLoop);
    }

    /// 直接从 Dictionary 里获取。
    CFRunLoopRef loop = CFDictionaryGetValue(loopsDic, thread));

    if (!loop) {
        /// 取不到时，创建一个
        loop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, thread, loop);
        /// 注册一个回调，当线程销毁时，顺便也销毁其对应的 RunLoop。
        _CFSetTSD(..., thread, loop, __CFFinalizeRunLoop);
    }

    OSSpinLockUnLock(&loopsLock);
    return loop;
}

CFRunLoopRef CFRunLoopGetMain() {
    return _CFRunLoopGet(pthread_main_thread_np());
}

CFRunLoopRef CFRunLoopGetCurrent() {
    return _CFRunLoopGet(pthread_self());
}
```

##### runloop实际上是一个对象

iOS中有2套API来访问和使用RunLoop

Foundation - NSRunloop

Core Foundation - CFRunloop

NSRunLoop是基于CFRunLoopRef的一层OC包装

## 剖析runloop

 ![a run loop and its sources结构图][RunloopStructurePNG]

 从图中可得知，一条线程，从开始到结束，一直在跑圈从而处理两大事件源；

- 输入源（input source）
  - Port
  - Custom
  - performSelector
- 定时源（timer source）

除了处理事件，runloop也生成相关行为的notification。

注册runloop观察者可以收到这些notification，并做相应处理。（Core Foundation提供的相关API，在下文“RunLoop实际应用场景”中可以看到使用示例）

下面会从runloop的组成说起，然后逐个解释Mode、Input Sources、Timer Sources、Run Loop Observers。从而来看runloop源码分析，来说内部实现逻辑。

### runloop的组成
![RunLoop_0][RunLoop_0.png]
![Runloop构成元素][Runloop构成元素]

runloop与线程是一一对应

一个runloop中至少存在一个Mode

每个Mode的存在必须至少有一个Source或Timer或Observer

每次RunLoop启动时，只能指定其中一个 Mode，这个Mode被称作 CurrentMode

如果需要切换Mode，只能退出Loop，再重新指定一个Mode进入。这样做主要是为了分隔开不同组的Source/Timer/Observer，让其互不影响

#### Runloop Modes 模式

#### Input Sources 输入源

#### Timer Sources 定时源

#### Run Loop Observers 观察者

#### The Run Loop Sequence of Events runloop内部逻辑

## 什么时候使用runloop

官方解释......

### 使用runloop对象

#### Getting a Run Loop Object

#### Configuring the Run Loop

#### Starting the Run Loop

#### Exiting the Run Loop

#### Thread Safety and Run Loop Objects

### RinLoop in Cocoa -  苹果用 RunLoop 实现的功能

### RunLoop 的实际应用场景

3. runloop内部怎么实现的？

   看内部实现得知，苹果通过runloop做了些什么（实现了哪些功能）？(可以说在`do {} while (...)`中做了些什么更恰当)

4. 实际开发中，我们可以通过runloop做些什么？遇到哪些问题？

    #### 可以做什么

    可以添加Observer监听RunLoop的状态,比如监听点击事件的处理(在所有点击事件之前做一些事情)

    开启一个常驻线程(让一个子线程不进入消亡状态,等待其他线程发来消息,处理其他事件)

     - 在子线程中开启一个定时器

     - 在子线程中进行一些长期监控

       实际应用举例：AFNetworking开启了一条常住线程，用于网络请求

   可以让某些事件(行为、任务)在特定模式下执行。列如：当用户在拖拽ScrollView时(UI交互时)不显示图片,拖拽完成时显示图片

   可以控制定时器在特定模式下执行

   处理Crash，手机崩溃日志

    #### Topic

    Runloop与定时器。iOS的几种定时器，定时器准不准？

    Runloop与NSURLConnection

    Runloop与自动释放池

    Runloop与GCD

    #### 遇到问题

    在一个子线程里启动一个timer，但是这个timer一次也不会被调用

    在一个子线程里发起一个NSURLConnection网络数据请求，但是NSURLConnection的delegate没有回调

    在主线程环境下，方法体第一行调用performSelector:withObject:afterDelay:这种带afterDelay的方法簇时，这一次调用的实际执行时机往往是在方法体的最后执行，如下代码示例：


[Runloop构成元素]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/Runloop构成元素.png
[RunLoop_0.png]: https://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_0.png
[RunloopStructurePNG]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/RunloopStructure.png
[Event loop]: https://en.wikipedia.org/wiki/Event_loop
[官方文档]: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html
[中文翻译]: https://wenku.baidu.com/view/97d92788cc22bcd126ff0c3f.html
[开源地址]: https://opensource.apple.com/source/CF/CF-1151.16/
[孙源的Runloop分享]: https://pan.baidu.com/s/1o8dW0NS#list/path=%2F
[深入理解RunLoop]: https://blog.ibireme.com/2015/05/18/runloop/
[RunLoop 总结及应用]: http://www.cnblogs.com/junhuawang/p/6437577.html
