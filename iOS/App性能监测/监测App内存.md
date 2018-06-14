# 检测App内存

## [计算机存储单位][存储单位]

存储单位是一种计量单位。

基本单位为字节B，字节向上分别为KB、MB（兆Zhao）、GB、TB，每级为前一级的1024倍，比如:

1 Byte（B） = 8 bit

1 Kilo Byte（KB） = 1024B

1 Mega Byte（MB） = 1024 KB

1 Giga Byte （GB）= 1024 MB

1 Tera Byte（TB）= 1024 GB

......

**位 bit (比特)(Binary Digits)：** 存放一位二进制数，即 0 或 1，最小的存储单位。[英文缩写：b(固定小写)]

**字节byte：** 8个二进制位为一个字节(B)，最常用的单位。

## 内存空间的划分

[手机内存RAM、ROM简介][手机内存RAM、ROM简介]

[iOS 中内存分配与分区][iOS 中内存分配与分区]

[iOS程序APP运行中的内存分配][iOS程序APP运行中的内存分配]

[iOS程序中的内存分配分区][iOS程序中的内存分配分区]

[iOS内存分配与分区][iOS内存分配与分区]

[内存碎片][内存碎片]

通过上面的连接，对手机存储器RAM、ROM以及App运行中的内存分配有了一定的了解。

iPhone所有机型RAM，ROM（下表统计数据非官方，仅供参考）

| 手机型号        | RAM(运存)   |  ROM(容量)   |
| --------       | -----:     | :----:      |
| iPhone3G       | 128M       |   8G/16G    |
| iPhone3GS      |   256M     |  8G/16G/32G |
| iPhone4        |   512M	    |  8G/16G/32G |
| iPhone4S       |   512M     |  16G/32G/64G|
| iPhone5        |   1G       |  16G/32G/64G|
| iPhone5S       |   1G       |  16G/32G/64G|
| iPhone5C       |   1G       |  	8G/16G/32G|
| iPhone6        |   1G       |  16G/64G/128G|
| iPhone6P       |   1G       |  16G/64G/128G|
| iPhone6S       |   2G       | 16G/32G/64G/128G|
| iPhone6SP      |   2G       |  16G/64G/128G|
| iPhone7        |   2G       |  32G/128G/256G|
| iPhone7P       |   3G       |   	32G/128G/256G|
| iPhoneSE       |   2G       |   	16G/32G/64G/128G|
| iPhone8        |   2G       |   	64G/256G |
| iPhone8P       |   3G       |   	64G/256G |
| iPhone X       |   3G       |   	64G/256G |

1GB = 10 亿字节；实际可用容量会由于诸多因素而减少并有所差异。以iPhoneX为例，单击[此处][ht208119]了解实际可用容量详情。

### ROM

 查看手机内存使用情况：iPhone -> Setting(设置) -> General(通用) -> iPhone Storage(手机存储)

 ![iPhoneRom.png]

点击Cell，查看具体App Size 和 Documents Data 大小

 ![iPhoneAppRom.png]

### RAM

通过Xcode的Debug Navigator即可查看

![XcodeMemory.png]

#### 检测工具

##### 1. instruments

- #### Allocation
  可以用Allocation詳細分析App各模塊內存占用

  能監控到所有堆內存以及部分VM內存分配

- #### Leaks
  动态监测内存泄露

  当出现红色叉时，就监测到了内存泄露

  默认情况下会添加 Allocations 模板

##### 2. Analyze—静态分析

静态分析可疑的内存泄漏点

使用方法：打开Xcode，command + shift + B；或者Xcode - Product - Analyze；

##### 3. 除了Analyze—静态分析，和instruments动态分析之外，我们也可以使用一些优秀的开源库

比如：

- Facebook开源的內存分析工具[FBMemoryProfiler][FBMemoryProfiler]

- 腾讯开源的[OOMDetector][OOMDetector]（[博客][OOMDetectorBlog]）

## 苹果官方对于App的内存有没有硬性指标？

#### ROM

说是官方对App的ROM有无要求，不如说ipa上传app store的大小限制。

> [Maximum build file sizes][Maximum build file sizes]

iOS相关要求：

应用的未压缩总大小必须小于4GB

每个Mach-O可执行文件（例如，app_name.app/app_name）都不得超过这些最大文件大小

| iOS版本        | 最大可执行文件大小   |  注意  |
| --------   | -----:  | :----:  |
| iOS9.0 以上   | 500M |   对于二进制文件中所有__TEXT段的总和  |
| iOS 7.X 至 OS 8.X   |60 MB |   对于每个体系结构slice_中的__TEXT部分  |
| 早于iOS 7.0   | 80M |   对于二进制文件中所有__TEXT段的总和  |

如果没看懂，[这里][ipa上传app store的大小限制]有篇文章。

我的App可执行文件__TEXT总大小为 （6553600 + 7208960）% 1024 % 1024 ≈ 13 MB (App最低支持iOS8.0)
![AppTextSize.png]

#### RAM

iOS单个应用程序的最大可用运存是多少？官方虽然没有公布，但是在[stackoverflow][ios-app-maximum-memory-budget]上有人对此做了些测试。

所有机型下，iOS单个应用程序的最大可用运存大概占手机总可用运作的50%以上。

虽然运存很充足，但是如果运存太大也是会被KO掉。小应用程序还好，如果程序太大，好比游戏类，那么就要格外的注意了。可以获取应用程序运存/手机运存的值，提前做运存处理。

在开发中也是要注意内存泄露和暴内存问题。以及野指针造成程序崩溃。

### 我的方案(目标)

#### ROM

App的大小超过苹果硬性要求，上传App Store肯定被拒。

如果App包太大，会影响用户在App Store下载应用的时间，会占用用户手机更多内存空间。

Appstore安装包是由资源和可执行文件两部分组成，安装包瘦身也是从这两部分进行。

不要遗留沉余文件，沉余代码。关于App的体积优化可看[这里][体积优化]

#### RAM

App 的运存占用率不要太大。

不要出现**爆內存問題**和**內存泄漏**。

三方库的导入，本身就是在增加成本。在有必要的情况下使用三方库。

Xcode-Analyze静态分析和instruments动态分析配合使用，可以很好地检测出App的运存使用情况。


## 相关文章及参考

> - [Memory Usage Performance Guidelines][Memory Usage Performance Guidelines]
> - [探索iOS内存分配][探索iOS内存分配]


[存储单位]: https://baike.baidu.com/item/%E5%AD%98%E5%82%A8%E5%8D%95%E4%BD%8D
[手机内存RAM、ROM简介]: https://blog.csdn.net/fengbingchun/article/details/78996319
[iOS程序APP运行中的内存分配]: http://www.qingpingshan.com/rjbc/ios/285054.html
[iOS程序中的内存分配分区]: http://www.code4app.com/blog-873055-3429.html
[iOS 中内存分配与分区]: https://www.cnblogs.com/mddblog/p/4405165.html
[iOS内存分配与分区]: https://cnbin.github.io/blog/2016/02/25/iosnei-cun-fen-pei-yu-fen-qu/
[内存碎片]: https://baike.baidu.com/item/%E5%86%85%E5%AD%98%E7%A2%8E%E7%89%87
[Maximum build file sizes]: https://help.apple.com/app-store-connect/#/dev611e0a21f
[ipa上传app store的大小限制]: https://blog.csdn.net/qq_19411159/article/details/75045114
[AppTextSize.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/AppTextSize.png
[ios-app-maximum-memory-budget]: https://stackoverflow.com/questions/5887248/ios-app-maximum-memory-budget
[iPhoneRom.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/iPhoneRom.png
[iPhoneAppRom.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/iPhoneAppRom.png
[XcodeMemory.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/XcodeMemory.png
[ht208119]: https://support.apple.com/zh-cn/ht208119
[OOMDetector]: https://github.com/Tencent/OOMDetector
[OOMDetectorBlog]: https://com-it.tech/archives/2149
[FBMemoryProfiler]: https://github.com/facebook/FBMemoryProfiler
[体积优化]: https://github.com/skyming/iOS-Performance-Optimization#体积优化
[Memory Usage Performance Guidelines]: https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/ManagingMemory.html#//apple_ref/doc/uid/10000160i
[探索iOS内存分配]: https://juejin.im/post/5a5e13c45188257327399e19
