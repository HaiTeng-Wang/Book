
# iOS中的变量属性或修饰符

```
01. atomic                       //default		    
02. nonatomic
03. readonly
04. readwrite                    //default		  
05. strong  (iOS4 = retain)	  //default
06. retain
07. weak (iOS4 = unsafe_unretained)
08. unsafe_unretained
09. assign                       //default		    
10. copy
```


使用getter/setter方法访问属性

如果你自己写 getter/setter，那 atomic/nonatomic/retain/assign/copy 这些关键字只起提示作用。写不写都一样。


## 01 `atomic`

- 默认行为
- 给setter/getter上锁(@synchronized)，来确保变量值得安全性。
- 但是性能低
- 保证系统生成setter/getter操作完整性，不受其它线程影响。但是并不是真正的多线程访问安全。

    举例子：

    如果线程 A 调[self setName:@"A"]，线程 B 调[self setName:@"B"]，线程 C 调[self name]，那么所有这些不同线程上的操作都将依次顺序执行——也就是说，如果一个线程正在执行 getter/setter，其他线程就得等待。因此，属性 name 是读/写安全的。

    但是，如果有另一个线程 D 同时在调[name release]，那可能就会crash，因为 release 不受 getter/setter 操作的限制。

## 02 `nonatomic`
- 非默认行为，需要我们自行给属性添加关键字。
- 性能高
- 在iOS开发中，你会发现，几乎所有属性都声明为 nonatomic。
在像iPhone这种内存较小的移动设备上，如果没有多线程间的通信，那么nonatomic就是一个非常好的选择。
- 不保证成setter/getter操作完整性，当多个线程在同一时间操作属性，会发生非预期结果。


## 03 `readonly`
- 这个属性是只读的。
- 声明readonly，告诉开发者这个属性没有setter方法，不可赋值。
- 如果你试图给一个实例的属性赋值，编译器会报错。
- @synthesize自动合成getter方法

## 04 `readwrite`
- 可读可写
- 默认行为
- @synthesize自动合成setter/getter方法


## 05 `strong`

iOS4 = retain

- 修饰对象类型，指针指向某个符合类型定义的内存区域，且在这块内存区域的引用计数+1。

  MRC环境，测试示例：
  ![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/MRCTestStrong.png)

  提示：上方图片打印引用计数只是为了更直观的了解strong的作用。

  事实上，你应该永远不要使用`retainCount`来调试内存管理，其结果往往是误导性的。

  可看这里[When to use -retainCount?](https://stackoverflow.com/questions/4636146/when-to-use-retaincount)，以及官方解释[Practical Memory Management](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html)文档最下方，重要提示。

- 如果有多个对象同时引用一个属性，任一对象对该属性的修改都会影响其他对象获取的值

- 如果需要保留一个对象，使用strong

- 我们通常对于UIViewController的UI相关组件使用strong  

- 所有实例变量和局部变量默认都是强指针。

- strong只可以修饰对象类型：
```Objective-C
Property with 'retain (or strong)' attribute must be of object type
```

## 06 `retain`
 `ARC`之前属性构造器，功能同`strong`。


## 07 `weak`
iOS4 = unsafe_unretained

- 修饰对象类型，指针指向的数据地址不增加引用计数。所以，当weak修饰的属性指针，指向的内存区域内的数据（值）被释放（置空nil）时，指针也会被置空（nil）。

- 使用weak修饰的属性，并不会保留这块内存空间。如下：编译器会报警告。视图并没有显示。
![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/weakView.png)

- 不应该使用Strong修饰delegate对象
![][1]
使用weak修饰delegate对象
![][2]

- 使用weak避免类实例之间的循环强引用。

- IBOutlets对象通常使用weak修饰。因为控件他爹( view.superview )已经揪着它的小辫了( strong reference )，你( viewController )眼瞅着( weak reference )就好了。当然，如果你想在 view 从 superview 里面 remove 掉之后还继续持有的话，还是要用 strong 的( 你也揪着它的小辫， 这样如果他爹松手了它也跑不了 )。

- weak只可以修饰对象类型：
```Objective-C
Property with 'weak' attribute must be of object type
```


## 08 `unsafe_unretained`


## 09 `assign`

- 修饰值类型，值类型是指primitive type，包括int, long, bool等非对象类型。不增加引用计数。

- 值类型，默认语义。

- `assign`其实也可以用来修饰对象，被`assign`修饰的对象在释放之后，指针的地址还是存在的，也就是说`assign`只是会对这片内存空间释放旧值，指针并没有被置为nil。如果在后续的内存分配中，刚好分到了这块地址，会出现野指针程序就会崩溃掉。

  ```objective-c
  // 资源
  NSMutableString *originStr = [[NSMutableString alloc] initWithString:@"originStrValue"];
  // `assign`修饰的对象`assignMStr`，指针指向这块资源地址
  self.assignMStr = originStr;
  // 这块资源被置空
  originStr = nil;
  /*
  assign`修饰的对象的值已被释放，但`assign`修饰的对象指针并没有被置空，再访问这个对象会出现野指针，所以程序崩溃。如果修饰符为`weak`则不会崩溃。
  */
  NSLog(@"assignMStr输出:%p,%@",self.assignMStr, self.assignMStr);
  ```


## 10. copy

---


objective c - What is the difference between a __weak and a __block __strong

若引用和无主引用区别，形象例子

---

讨论：
1. 大量博客中说assign是默认关键字。但没给相关文档链接。原谅我并未查找到相关文档中有说明“assign是默认关键字”。但是在官方的大量.h文件中。assign修饰值类型，确实是省略没有写。

2. 原子性atomic作为iOS原子性语义，采用什么锁，来保证Setter/getter方法的完整性？

  有的人说：“使用同步锁@synchronized”；还有的人说：“使用自旋锁”；还有的人说：“如果属性具备atomic特质，同步锁，nonatomic使用的是自旋锁。

以上两个为题，如果有人知道相关文档说明，或可以证实相关事实，请一定要告知我，感谢万分。


---
本文参考：

documentation:
> - [Encapsulating Data](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html)
> - [Clang 7 documentation
OBJECTIVE-C AUTOMATIC REFERENCE COUNTING (ARC)](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#objective-c-automatic-reference-counting-arc)
> - [Transitioning to ARC Release Notes](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226)

blog:
> - [Objective-C ARC: strong vs retain and weak vs assign
](https://stackoverflow.com/questions/8927727/objective-c-arc-strong-vs-retain-and-weak-vs-assign/15541801#15541801)

stackoverflow:
> - [What's the difference between the atomic and nonatomic attributes?
](https://stackoverflow.com/questions/588866/whats-the-difference-between-the-atomic-and-nonatomic-attributes) | [[爆栈热门 iOS 问题] atomic 和 nonatomic 有什么区别？](https://www.jianshu.com/p/7288eacbb1a2)
> - [Variable property attributes or Modifiers in iOS](http://rdcworld-iphone.blogspot.ca/2012/12/variable-property-attributes-or.html)
> - [Explanation of strong and weak storage in iOS5
](https://stackoverflow.com/questions/9262535/explanation-of-strong-and-weak-storage-in-ios5)


[1]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/delegateRetainCycles.png
[2]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/delegateRetainCycles2.png
