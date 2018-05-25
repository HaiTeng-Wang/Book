## 快速回顾Runtime

参考：
> [Objective-C Runtime Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048)

> [Objective-C Runtime](https://developer.apple.com/documentation/objectivec/objective_c_runtime)

> [Objective-C 消息发送与转发机制原理](http://yulingtianxia.com/blog/2016/06/15/Objective-C-Message-Sending-and-Forwarding/)

> [Runtime全方位装逼指南](http://ios.jobbole.com/85092/)


建议阅读时间： 15分钟

阅读完后需要明白：
1. 什么是runtime?

2. runtime是怎样进行消息发送，消息转发?

3. 我们可以通过runtime做些什么？


#### 前言：
之所以说OC是一门动态的语言，是因为OC会尽可能的将编译和链接时要做的事情放到运行时来做。也就是说，代码的运行只有编译器是不够的，还需要一个运行时系统（runtime system）来执行编译后的代码。

runtime好比OC的灵魂，很多东西都是在这个基础上实现的。大部分情况下我们只管编写OC代码，runtime系统自动在幕后辛勤劳作。runtime系统是由一系列数据结构和函数组成，具有公共接口的一个动态共享库。


运行时系统的主要功能是根据我们编写的OC代码发消息，消息只有到运行时，才会和函数实现绑定起来。


#### 消息发送
消息发送（Messaging）是 Runtime 通过 selector 快速查找 **IMP** 的过程，有了函数指针就可以执行对应的方法实现；（在查找 IMP 失败后会执行一系列转发流程俗称**消息转发**，文章之后会讲解。）


##### IMP
IMP在objc.h中的定义是：

```Objective-C
typedef void (*IMP)(void /* id, SEL, ... */ );
```

它就是一个函数指针，这是由编译器生成的。当你发起一个 ObjC 消息之后，最终它会执行的那段代码，就是由这个函数指针指定的。
IMP参数包含 id 和 SEL 类型。通过一组 id 和 SEL 参数就能确定唯一的方法实现地址。

**消息的执行**，会使用到一些函数和数据结构。OC中的类、方法、协议，等在runtime中都由一些数据结构来定义的。

如下的一个OC方法调用：
```Objective-C
[receiver message]
```

会被编译器转换为定义在message.h中的其中一个函数：
- objc_msgSend：像当前类对象发消息，返回值类型为id
- objc_msgSend_stret:返回值为结构体
- objc_msgSendSuper:向父类发消息，返回值类型为 id
- objc_msgSendSuper_stret:向父类发消息，返回值类型为结构体
- objc_msgSend_fpret:返回值类型为 floating-point，其中包含objc_msgSend_fp2ret 入口处理返回值类型为 long double 的情况

(这些函数的命名规律：带“Super”的是消息传递给超类；“stret”可分为“st”+“ret”两部分，分别代表“struct”和“return”；“fpret”就是“fp”+“ret”，分别代表“floating-point”和“return”。)

**消息发送步骤：**

首先，Runtime 系统会把方法调用转化为消息发送，即 objc_msgSend，并且把方法的调用者，和方法选择器，当做参数传递过去.

然后检测，检测这个 selector 是不是要忽略的；检测这个 target 是不是 nil 对象。ObjC 的特性是允许对一个 nil 对象执行任何一个方法不会 Crash，因为会被忽略掉。

如果上面两个都过了，那就开始查找这个类的 IMP。先获取到当前类，从当前类 cache 里面找，找得到就跳到对应的函数去执行；cache 找不到就找一下方法分发表（Class中的方法列表methodLists ）；如果分发表找不到就到超类的分发表去找，一直找，直到找到NSObject类为止。

如果还找不到就要开始进入动态方法解析了，后面会提到。

![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/Runtime_msgSend.png)
上图，展示了objc_msgSend：的两个必须参数id、SEL，顺根爬，找class的过程，找到当前类，也就找到了类内部的结构体成员，方法缓存cache、方法列表methodLists、元类meta、父类superClass等，找到当前类后，继而才能找IMP。

我们说 methodLists 指向该类的实例方法列表，实例方法即(-方法)；那么类方法（+方法）存储在哪儿呢？

一个 ObjC 类本身同时也是一个对象，为了处理类和对象的关系，runtime 库创建了一种叫做**元类 (Meta Class)** 的东西，它用来表述类对象本身所具备的元数据。类方法就定义于此处，因为这些方法可以理解成类对象的实例方法。当 [NSObject alloc] 这条消息发给类对象的时候，objc_msgSend() 会去它的元类里面去查找能够响应消息的方法，如果找到了，然后对这个类对象执行方法调用。

![](http://upload-images.jianshu.io/upload_images/1766530-3ca97555fbca34e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上图，根元类的超类是NSObject，而 isa 指向了自己。NSObject 的超类为 nil，也就是它没有超类。


#### 消息转发

![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/Runtime_forwardInvocation.png)

我们知道 Objc 不支持多继承的性质，了解了消息转之后，消息转发可以模拟多继承，当然实现多继承的方式还有很多种，比如利用Delegate或者Categroy都可以实现多继承的形式


#### 我们可以通过runtime做些什么？

我们可以通过runtime提供的接口做很多操作，操作objec、class、ivar、method、property、protocol、等等...，下面是一些常见的runtime使用场景：

- [通过消息转发机制，实现多继承](http://blog.ypli.xyz/ios/objective-c-runtimexiao-xi-zhuan-fa-shi-xian-duo-ji-cheng)

- 对象关联
   ```Objective-C
   void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
   ·object 是源对象.
   ·value 是被关联的对象.
   ·key 是关联的键，objc_getAssociatedObject 方法通过不同的 key 即可取出对应的被关联对象.
   ·policy 是一个枚举值，表示关联对象的行为，
   ```
   ```Objective-C
   id _Nullable objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key)
   ```
   1. 对象关联允许开发者对已经存在的类在 Category 中添加自定义的属性

   例子：UIButton 添加一个监听单击事件的 block 属性
   ```Objective-C
     #import "UIButton+ClickBlock.h"
     #import

    static const void *associatedKey = "associatedKey";

     //Category中的属性，只会生成setter和getter方法，不会生成成员变量

    -(void)setClick:(clickBlock)click {
        objc_setAssociatedObject(self, associatedKey, click, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self removeTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        if (click) {
            [self addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    -(clickBlock)click {
        return objc_getAssociatedObject(self, associatedKey);
    }

    -(void)buttonClick {
        if (self.click) {
            self.click();
        }
    }

    @end
   ```
   使用：
   ```Objective-C
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = self.view.bounds;
     [self.view addSubview:button];
     button.click = ^{
         NSLog(@"buttonClicked");
     };
   ```

   2. 使用类方法 初始化 添加手势回调
   ```Objective-C
    #import "UIGestureRecognizer+Block.h"
    #import <objc/runtime.h>

    static const int target_key;

    @implementation UIGestureRecognizer (Block)

    + (instancetype)ht_gestureRecognizerWithActionBlock:(HTGestureBlock)block {
        return [[self alloc] initWithActionBlock:block];
    }

    - (instancetype)initWithActionBlock:(HTGestureBlock)block {
        self = [self init];
        [self addActionBlock:block];
        [self addTarget:self action:@selector(invoke:)];
        return self;
    }

    - (void)addActionBlock:(HTGestureBlock)block {
        if (block) {
            objc_setAssociatedObject(self, &target_key, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }

    - (void)invoke:(id)sender {
        HTGestureBlock block = objc_getAssociatedObject(self, &target_key);
        if (block) {
            block(sender);
        }
    }

    @end
   ```
   使用：
   ```Objective-C
    [self addGestureRecognizer:[UITapGestureRecognizer ht_gestureRecognizerWithActionBlock:^(id gestureRecognizer) {

    }]];
   ```

- 自动归解档

    1.使用 class_copyIvarList 方法获取当前 Model 的所有成员变量.

    2.使用 ivar_getName 方法获取成员变量的名称.

    3.通过 KVC 来读取 Model 的属性值（encodeWithCoder:），以及给 Model 的属性赋值（initWithCoder:）.

- 字典与模型互转

  - 字典转模型
   1. 根据字典的 key 生成 setter 方法.
   2. 使用 objc_msgSend 调用 setter 方法为 Model 的属性赋值（或者 KVC）.

  - 模型转字典
   1. 调用 class_copyPropertyList 方法获取当前 Model 的所有属性.
   2. 调用 property_getName 获取属性名称.
   3. 根据属性名称生成 getter 方法.
   4. 使用 objc_msgSend 调用 getter 方法获取属性值（或者 KVC）.

- 交换方法

   我曾遇到这样的一个需求：我们的项目是支持iPad设备，但是iPad设备不支持转屏。

   ```Objective-C
    #import "ZFPlayerView+Category.h"
    #import <objc/runtime.h>

    @implementation ZFPlayerView (Category)

    + (void)load {
        if (isPad) {
            method_exchangeImplementations(class_getInstanceMethod([self class], @selector(onDeviceOrientationChange)),
                                           class_getInstanceMethod([self class], @selector(OrientationChangeNothing)));
        }
    }

    /// 如果是Pad 转屏不响应事件
    - (void)OrientationChangeNothing {
    }
    @end
   ```

- 动态添加方法
    ```Objective-C
    @implementation ViewController
    - (void)viewDidLoad {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.

        Person *p = [[Person alloc] init];

        // 默认person，没有实现eat方法，可以通过performSelector调用，但是会报错。
        // 动态添加方法就不会报错
        [p performSelector:@selector(eat)];
    }
    @end

    @implementation Person
    // void(*)()
    // 默认方法都有两个隐式参数，
    void eat(id self,SEL sel) {
        NSLog(@"%@ %@",self,NSStringFromSelector(sel));
    }

    // 当一个对象调用未实现的方法，会调用这个方法处理,并且会把对应的方法列表传过来.
    // 刚好可以用来判断，未实现的方法是不是我们想要动态添加的方法
    + (BOOL)resolveInstanceMethod:(SEL)sel {
        if (sel == @selector(eat)) {
            // 动态添加eat方法

            // 第一个参数：给哪个类添加方法
            // 第二个参数：添加方法的方法编号
            // 第三个参数：添加方法的函数实现（函数地址）
            // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
            class_addMethod(self, @selector(eat), eat, "v@:");
        }
        return [super resolveInstanceMethod:sel];
    }
    @end
    ```
