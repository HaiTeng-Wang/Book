# 监测App界面流畅度

### 参考：
> [iOS-Performance-Optimization][iOS-Performance-Optimization]

### 检测页面卡顿的方式（不限于如下三种）：

- #### [FPS][FPS]

  经过开发者们的测试度量，**iOS系统中正常的屏幕刷新率为60Hz（60次每秒）。**为了证实这一点，我开启了一个新工程使用CADisplayLink进行测试，确实如此。

  帧率越高意味着界面越流畅。

  网络上流传的最多的关于测量 FPS 的方法，GitHub 上有关计算 FPS 的仓库基本都是通过以下方式实现的：

  ```Objective-C
  @implementation YYFPSLabel {
      CADisplayLink *_link;
      NSUInteger _count;
      NSTimeInterval _lastTime;    
  }

  - (id)init {
      self = [super init];
      if( self ){        
      _link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
      [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

      }
      return self;
  }

  - (void)dealloc {
      [_link invalidate];
  }

  - (void)tick:(CADisplayLink *)link {
      if (_lastTime == 0) {
          _lastTime = link.timestamp;
          return;
      }

      _count++;
      NSTimeInterval delta = link.timestamp - _lastTime;
      if (delta < 1) return;
      float fps = _count / delta;
      NSLog(@"%f",fps);
      _lastTime = link.timestamp;
      _count = 0;    
  }
  ```

  [CADisplayLink：][cadisplaylink]代表绑定到显示器vsync（vertical synchronization垂直同步信号）的计时器的类。默认情况下，当屏幕更新时调用@selector(tick:)，从而可获得1秒内屏幕刷新率。

  关于屏幕显示图像的原理，[这里][屏幕显示图像的原理]有篇文章可参考。

- #### Instruments (Time Profile)

  主线程为了达到接近60fps的绘制效率，不能在UI(主)线程有单个超过（1/60s≈16ms）的计算任务。通过Instrument设置16ms的采样率可以检测出大部分这种费时的任务。

- #### RunloopObserver

  开辟一个子线程来监控主线程的 RunLoop，当两个状态(BeforeSources和AfterWaiting)区域之间的耗时大于阈值时，就记为发生一次卡顿。此时获取调用堆栈。

### 我的方案

“过早的优化是万恶之源”，在需求未定，性能问题不明显时，没必要尝试做优化，而要尽量正确的实现功能。

在考虑投入产出比之后，生产环境未实现监测。

在DUBG模式下，我采用一个明确的 FPS 指示器来监测页面卡顿，使用Time Profile找出耗时方法。

FPS 指示器，我使用的是[PFPSStatus][PFPSStatus]。


[iOS-Performance-Optimization]: https://github.com/skyming/iOS-Performance-Optimization#卡顿优化
[FPS]: https://baike.baidu.com/item/fps/3227416
[cadisplaylink]: https://developer.apple.com/documentation/quartzcore/cadisplaylink?changes=_8
[屏幕显示图像的原理]: https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/
[PFPSStatus]: https://github.com/joggerplus/JPFPSStatus
