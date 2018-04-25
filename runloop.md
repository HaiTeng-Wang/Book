# Runloop

参考：

> [官方文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)
| [中文翻译](https://wenku.baidu.com/view/97d92788cc22bcd126ff0c3f.html)
|[开源地址](https://opensource.apple.com/source/CF/CF-1151.16/)

> [孙源的Runloop分享](https://pan.baidu.com/s/1o8dW0NS#list/path=%2F)

> [深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)

> [RunLoop 总结及应用](http://www.cnblogs.com/junhuawang/p/6437577.html)

阅读时间：15分钟

文章内容：

1. 什么是runloop?

  runloop与线程的关系

  runloop相关的5个类

  runloop的mode

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
