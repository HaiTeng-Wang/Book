
# iOS中的变量属性或修饰符

```
01. atomic                       // default
02. nonatomic
03. readonly
04. readwrite                    // default
05. strong  (iOS4 = retain)	 // default
06. retain
07. weak (iOS4 = unsafe_unretained)
08. unsafe_unretained
09. assign                       // default
10. copy
```


使用getter/setter方法访问属性。

如果你自己写 getter/setter，那 atomic/nonatomic/retain/assign/copy 这些关键字只起提示作用。写不写都一样。


## 01 `atomic`

- 默认行为；
- 为确保其原子性(可理解为：多个操作 不可被打乱或切割)，使用锁定机制给setter/getter上锁([@synchronized][@synchronized])，来使得变量值更具安全性；
- 但是性能低；
- 保证系统生成setter/getter操作完整性，不受其它线程影响。但是并不是真正的多线程访问安全。

    举例子：

    如果线程 A 调[self setName:@"A"]，线程 B 调[self setName:@"B"]，线程 C 调[self name]，那么所有这些不同线程上的操作都将依次顺序执行——也就是说，如果一个线程正在执行 getter/setter，其他线程就得等待。因此，属性 name 是读/写安全的。

    但是，如果有另一个线程 D 同时在调[name release]，那可能就会crash，因为 release 不受 getter/setter 操作的限制。

## 02 `nonatomic`
- 非默认行为，需要我们自行给属性添加关键字；
- 性能高；
- 在iOS开发中，你会发现，几乎所有属性都声明为 nonatomic。
在像iPhone这种内存较小的移动设备上，如果没有多线程间的通信，那么nonatomic就是一个非常好的选择；
- 不保证成setter/getter操作完整性，当多个线程在同一时间操作属性，会发生非预期结果。


## 03 `readonly`
- 这个属性是只读的；
- 声明readonly，告诉开发者这个属性没有setter方法，不可赋值；
- 如果你试图给一个实例的属性赋值，编译器会报错；
- @synthesize自动合成getter方法。

## 04 `readwrite`
- 可读可写；
- 默认行为；
- @synthesize自动合成setter/getter方法。


## 05 `strong`

iOS4 = retain

- 修饰对象类型，指针指向某个符合类型定义的内存区域，且在这块内存区域的引用计数+1

  MRC环境，测试示例：
  ![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/MRCTestStrong.png)

  提示：上方图片打印引用计数只是为了更直观的了解strong的作用。

  事实上，你应该永远不要使用`retainCount`来调试内存管理，其结果往往是误导性的。

  可看这里[When to use -retainCount?](https://stackoverflow.com/questions/4636146/when-to-use-retaincount)，以及官方解释[Practical Memory Management](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html)文档最下方，重要提示。

- 如果有多个对象同时引用一个属性，任一对象对该属性的修改都会影响其他对象获取的值；

- 如果需要保留一个对象，使用strong；

- 我们通常对于UIViewController的UI相关组件使用strong；

- 所有实例变量和局部变量默认都是强指针；

- strong只可以修饰对象类型：
  ```Objective-C
  Property with 'retain (or strong)' attribute must be of object type
  ```

## 06 `retain`
`ARC`之前属性构造器，功能同`strong`。


## 07 `weak`
iOS4 = unsafe_unretained

- 修饰对象类型，指针指向的数据地址不增加引用计数。所以，当weak修饰的属性指针，指向的内存区域内的数据（值）被释放（置空nil）时，指针也会被置空（nil）；

- 使用weak修饰的属性，并不会保留这块内存空间。如下：编译器会报警告。视图并没有显示：
![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/weakView.png)

- 不应该使用Strong修饰delegate对象：
![][1]
使用weak修饰delegate对象：
![][2]

- 使用weak避免类实例之间的循环强引用；

- IBOutlets对象通常使用weak修饰。因为控件他爹( view.superview )已经揪着它的小辫了( strong reference )，你( viewController )眼瞅着( weak reference )就好了。当然，如果你想在 view 从 superview 里面 remove 掉之后还继续持有的话，还是要用 strong 的( 你也揪着它的小辫， 这样如果他爹松手了它也跑不了 )；

- weak只可以修饰对象类型：
  ```Objective-C
  Property with 'weak' attribute must be of object type
  ```


## 08 `unsafe_unretained`
- 它作为属性的目的正如它的语义。是一个可怕的词，如果这个属性不安全，它应该看起来不安全；直白的翻译成中文为“不安全_不保留”，我们通常叫它“无主引用”；

- [4.1.1Property declarations](http://clang.llvm.org/docs/AutomaticReferenceCounting.html#property-declarations)中表明assign和unsafe_unretained都代表着__unsafe_unretained。所以我的理解是 unsafe_unretained = assign；

- [Use Unsafe Unretained References for Some Classes](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html#//apple_ref/doc/uid/TP40011210-CH5-SW33)

- iOS4之前，通常使用unsafe_unretained代替weak的功能，通常用来修饰不需要增加引用计数的对象类型；

- 出于安全性考虑，通常使用weak实现弱引用取代unsafe_unretained。现如今，属性声明很少会看到unsafe_unretained。

## 09 `assign`

- 修饰值类型，值类型是指primitive type，包括int, long, bool等非对象类型。不增加引用计数；

- 值类型，默认语义；

- `assign`其实也可以用来修饰对象，被`assign`修饰的对象在释放之后，指针的地址还是存在的，也就是说`assign`只是会对这片内存空间释放旧值，指针并没有被置为nil。如果在后续的内存分配中，刚好分到了这块地址，会出现野指针程序就会崩溃掉：

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


## 10. [copy](https://github.com/HaiTeng-Wang/Book/blob/master/iOS/%40property%E5%86%85%E5%AD%98%E8%AF%AD%E4%B9%89%E4%BF%AE%E9%A5%B0%E7%AC%A6Copy.md)

---

#### Topic:

##### Topic1: ARC之后出现四个[变量标识符：](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW4)

`__strong`:

- 是默认值。 只要有一个强指针，一个对象就保持“活着”。
  - 变量标识符的用法如下：
    ```Objective-C
    Number* __strong num = [[Number alloc] init];
    ```
  - 注意 __strong 的位置应该放到 * 和变量名中间，放到其他的位置严格意义上说是不正确的，只不过编译器不会报错。

`__weak`:

- 指定一个引用，该引用不会使引用的对象保持活着状态。 当没有强引用时，弱引用设置为零，指针置空nil。

`__unsafe_unretained`:

- 和weak相似，但是它所引用的对象被从内存中解除，指针就会悬空(出现了野指针)。

`__autoreleasing`：
- 用于标示使用引用传值的参数(id *)，在函数返回时会被自动释放掉；（文档原话翻译）
- 在ARC中__autoreleasing修饰的对象会自动注册到autoreleasepool中，使对象延迟释放，自动释放。

- 在ARC中，所有这种指针的指针 （NSError **）的函数参数如果不加修饰符，编译器会默认将他们认定为__autoreleasing类型；

- 某些类的方法会隐式地使用自己的autorelease pool，在这种时候使用__autoreleasing类型要特别小心。


##### Topic2: `__block`

- [Use Lifetime Qualifiers to Avoid Strong Reference Cycles](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW4):
  > MRC模式下，`__block`修饰的对象不会retain; 但是ARC模式下默认会retain；如果你不想让它retain，在前面加上 `__unsafe_unretained`, `变成__unsafe_unretained` `__block id x`; `为了防止使用修饰符__unsafe_unretained` 的指针指向object被释放掉，可以改为使用`__weak`。或者把`__block`变量指针设置为nil的方式来避免循环引用的问题。

- 也就是说`__block`在MRC时代有两个作用：
  - 说明修饰的变量可改；
  - 说明指针指向的对象不做这个隐式的retain操作；

- ARC后
  - 说明修饰的变量可改:
  - 说明指针指向的**对象（引用类型）**默认会retain操作；

    所以要注意一件事情：
    [Frequently Asked Questions - How do blocks work in ARC?](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW17)
    >`NSString * __block myString`在ARC中是被retained，并不是一个指针。要想获取以前的行为，使用`__block NSString * __unsafe_unretained myString`或者(最好使用)`__block NSString * __weak myString`。

- 当我们在block块中操作一个没有使用__block修饰的局部变量，编译器会爆error提示：

  ```Objective-C
  Variable is not assignable (missing __block type specifier)
  ```

- __block对申明block实现的影响：

  - 为什么使用__block修饰的变量，才可以在block被修改？

    通过clang工具可看到，block其实也是一个结构体block_impl_0。结构体block_impl_0 中引用的是 Block_byref_（__block修饰的变量）_0 的结构体指针，这样就可以达到修改外部变量的作用。

    没有使用__block修饰的变量，实际是在申明 block 时，是被复制到 block_impl_0 结构体中。因为这样，在 block 内部修改变量的内容，不会影响外部的实际变量。

    (对于这个问题，我参考的是唐巧大大的博文[谈Objective-C block的实现](https://blog.devtang.com/2013/07/28/a-look-inside-blocks/))


- 题外话：须知道static的变量和全局变量不需要加__block就可以在Block中修改。

##### Topic3: [ARC与Toll-Free Bridging](https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaEncyclopedia/Toll-FreeBridgin/Toll-FreeBridgin.html)

- 函数和方法也是可以互换的 - 我们可以将CFRelease与Cocoa对象一起使用，并通过Core Foundation对象进行释放和自动释放；

- 这页文档中，列出了免桥接对象；

- 并非所有数据类型都是免费桥接的。Core Foundation依然是之前的MRC机制，为了和谐Core Foundation类型的对象和Objective-C类型的对象出现一些“桥接修饰符”。


关于“桥接修饰符”，以及以上三个话题。部分参考这篇文章【[iOS开发ARC内存管理技术要点](https://www.cnblogs.com/flyFreeZn/p/4264220.html)】作者写于15年。

【[Objective-C 内存管理——你需要知道的一切](https://www.open-open.com/lib/view/open1460693431491.html)】这篇文章对OC内存管理方面总结的不错。

---
#### Reference：

**documentation:**
> - [Encapsulating Data](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html)
> - [Clang 7 documentation
OBJECTIVE-C AUTOMATIC REFERENCE COUNTING (ARC)](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#objective-c-automatic-reference-counting-arc)
> - [Transitioning to ARC Release Notes](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226)

**blog:**
> - [Variable property attributes or Modifiers in iOS](http://rdcworld-iphone.blogspot.ca/2012/12/variable-property-attributes-or.html)

**stackoverflow:**
> - [What's the difference between the atomic and nonatomic attributes?
](https://stackoverflow.com/questions/588866/whats-the-difference-between-the-atomic-and-nonatomic-attributes) | [[爆栈热门 iOS 问题] atomic 和 nonatomic 有什么区别？](https://www.jianshu.com/p/7288eacbb1a2)
> - [Objective-C ARC: strong vs retain and weak vs assign
](https://stackoverflow.com/questions/8927727/objective-c-arc-strong-vs-retain-and-weak-vs-assign/15541801#15541801)
> - [Explanation of strong and weak storage in iOS5
](https://stackoverflow.com/questions/9262535/explanation-of-strong-and-weak-storage-in-ios5)


[@synchronized]: https://github.com/HaiTeng-Wang/Book/blob/master/iOS中的锁.md#synchronized
[1]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/delegateRetainCycles.png
[2]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/delegateRetainCycles2.png

---

#### 补充：

#### 1. `Member variables`成员变量、`Instance variables`实例变量、`@property属性`、`@synthesize`、`@dynamic`
> 参考：

> [@property本质是什么？ivar、getter、setter 是如何生成并添加到这个类中的](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8A%EF%BC%89.md#6-property-%E7%9A%84%E6%9C%AC%E8%B4%A8%E6%98%AF%E4%BB%80%E4%B9%88ivargettersetter-%E6%98%AF%E5%A6%82%E4%BD%95%E7%94%9F%E6%88%90%E5%B9%B6%E6%B7%BB%E5%8A%A0%E5%88%B0%E8%BF%99%E4%B8%AA%E7%B1%BB%E4%B8%AD%E7%9A%84)

> [@synthesize究竟做什么？](https://codeday.me/bug/20170512/14768.html)

##### 1.1、实例变量(`instance variable`)：

由类定义的实例话的变量（不包括基本数据类型，如`int,double,float`)

##### 1.2、成员变量(`Member variable`)：

代码中的变量，包含实例变量和基本变量类型，无需与外界接触。成员变量默认是`protected`，一般情况下，非子类对象无法访问。（成员变量 = 实例变量 + 基本数据类型变量）

##### 1.3、`@property`：

编译器自动将变量的set和get方法的合成，可用点语法读取，可作为变量使用，可与外界接触。

简单地说：`@property = ivar(成员变量) + getter + setter`;

`property`在`runtime`中是`objc_property_t`定义如下:
```objective-c
typedef struct objc_property *objc_property_t;
```
而`objc_property`是一个结构体，包括`name`和`attributes`，定义如下：
```objective-c
struct property_t {
const char *name;
const char *attributes;
};
```
而`attributes`本质是`objc_property_attribute_t`，定义了`property`的一些属性，定义如下：
```objective-c
/// Defines a property attribute
typedef struct {
const char *name;           /**< The name of the attribute */
const char *value;          /**< The value of the attribute (usually empty) */
} objc_property_attribute_t;
```
而`attributes`的具体内容包括：类型、原子性、内存语义和对应的实例变量。

例如：定义一个`string`的属性
```objective-c
@property (nonatomic, copy) NSString *string;
```
通过`property_getAttributes(property)`获取到`attributes`并打印出来之后的结果为`T@”NSString”,C,N,V_string`。
其中`T`就代表`类型`，`C`就代表`Copy`，`N`代表`nonatomic`，`V`就代表对于的`实例变量`。

定义`property`时，编译器通过“自动合成”(`autosynthesis`)，生成`ivar`、`getter`、`setter`并添加到这个类中。

`@property`有两个对应的词，一个是`@synthesize`，一个是`@dynamic`。如果`@synthesize`和`@dynamic`都没写，那么默认的就是`@syntheszie var = _var`;

##### 1.4、 `@synthesize`

`@synthesize`作用：

若没有手动实现`setter`、`getter`编译器会自动帮我们实现这两个方法。


`@synthesize`合成成员变量规则：

- 如果指定了成员变量的名称,会生成一个指定的名称的成员变量
- 如果这个成员已经存在，就不在生成
- 如果`@synthesize foo`，会生成一个名字为`foo`的成员变量
- 如果是`@synthesize foo = _foo;`就不会生成成员变量了.

有了`property`自动合成属性之后，[`@synthesize`使用场景：](https://stackoverflow.com/questions/19784454/when-should-i-use-synthesize-explicitly)

- 指定成员变量名字
- 同时重写了`setter`和`getter`时
- 重写了只读属性的`getter`时
- 使用了`@dynamic`时
- 在`@protocol`中定义的所有属性
- 在`category`中定义的所有属性
- 重载的属性

##### 1.5、`@dynamic`

`@dynamic`作用：告诉编译器，属性的`setter`、`getter`由程序员手动生成，无需自动生成。

#### 2、修饰IBOutlet用Strong还是weak?
参考：
> [为什么 iOS 开发中，控件一般为 weak 而不是 strong？](https://www.zhihu.com/question/29927614)

> [修饰 outlet 用 Strong 还是 Weak?](http://sunshineyg888.github.io/2016/03/28/%E4%BF%AE%E9%A5%B0-outlet-%E7%94%A8-Strong-%E8%BF%98%E6%98%AFWeak/)

> [Should IBOutlets be strong or weak under ARC?](https://stackoverflow.com/questions/7678469/should-iboutlets-be-strong-or-weak-under-arc)

##### 一位知乎仁兄真理的回答：

因为控件他爹( view.superview )已经揪着它的小辫了( strong reference )，你( viewController )眼瞅着( weak reference )就好了。当然，如果你想在 view 从 superview 里面 remove 掉之后还继续持有的话，还是要用 strong 的( 你也揪着它的小辫， 这样如果他爹松手了它也跑不了 )。
