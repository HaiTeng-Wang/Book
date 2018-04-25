
# @property内存语义修饰符Copy

#### 属性修饰符copy:
- copy一般用在修饰有可变对应类型的不可变对象上，如NSString, NSArray, NSDictionary。

- copy用来修饰block

#### 需知道:
当给copy修饰的属性赋值时，若赋值对象为不可变对象，只是指针指向这块内存区域，在这块区域上，引用计数加一（浅拷贝）。

若赋值对象为可变对象，要区分此对象是可变变量还是可变变量容器。
 - 可变变量：系统会新开辟一块内存空间，将数据拷贝过来，属性对象的指针指向这块新的内存空间。新的内存区域持有引用计数加一。（深拷贝）
 - 可变变量容器：系统会新开辟一块内存空间，新的内存区域持有引用计数加一，属性对象的指针指向这块新的内存空间。但是，容器内元素的内存地址还是老地址，没有改变。也就是说容器内的元素，和赋值对象内的元素对象是同一个。（不是真正意义上的深拷贝）

  对于copy修饰不可变变量容器做为属性，我们需要知道这几个概念`非真正意义深拷贝`、`单层深拷贝`、`真正意义的深拷贝`。在下面“例子”会详细介绍。（官方文档[Copying Collections](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Collections/Articles/Copying.html#//apple_ref/doc/uid/TP40010162-SW3)）


#### 需注意：
官方文档：[Encapsulating Data](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html#//apple_ref/doc/uid/TP40011210-CH5)

1、**如果在初始化的时候给copy修饰的实例变量赋值，别忘记调用copy方法**
```Objective-C
- (id)initWithSomeOriginalString:(NSString *)aString {
    self = [super init];
    if (self) {
        _instanceVariableForCopyProperty = [aString copy];
    }
    return self;
}

```

2、**使用下划线方式直接给实例变量赋值，其实只是实例变量的指针直接指向赋值对象，不会走setter方法，不会发送`copy`消息。**你会看到实例变量内存地址同引用对象地址一样。所以，一定要调用点语法给实例属性赋值。

```Objective-C
@interface ViewController ()
@property (nonatomic, copy) NSString *propertyString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableString *mutableString = [NSMutableString stringWithFormat:@"mutableData"];
    _propertyString = mutableString;

    NSLog(@"mutableString：%@ %p\n",mutableString,mutableString);
    NSLog(@"propertyString：%@ %p\n",self.propertyString,self.propertyString);
    /*
     打印结果：
     mutableString：mutableData 0x60400045e450
     propertyString：mutableData 0x60400045e450
     */
}

```

3、**若使用copy修饰可变对象**，在之后编码过程中对属性进行可变操作，**一定Crash**。所以你需要知道[`copy`、`mutableCopy`](https://www.zybuluo.com/MicroCai/note/50592)。

  >不管是集合类对象，还是非集合类对象，接收到copy和mutableCopy消息时，都遵循以下准则：
  > - copy返回immutable对象；
  > - mutableCopy返回mutable对象；

  崩溃原因:
  ```Objective-C
  [__NSArrayI removeObjectAtIndex:]: unrecognized selector sent to instance 0x7fcd1bc30460
  ```

4、**使用copy修饰属性，该对象一定要遵循`NSCopying`协议**，Foundation类默认实现了NSCopying协议。自定义的类需要自行实现，如果没实现该协议，对该实例属性进行操作时会Crash。

崩溃原因:
```Objective-C
reason: '-[CustomClass copyWithZone:]: unrecognized selector sent to instance 0x60400002ce60'
```


#### 例子：

##### 例子1、不可变变量用Strong，还是Copy修饰？

如下，使用Strong修饰一个不可变字符串NSString对象作为属性。在编码的过程中，指针指向一个可变变量字符串，当可变变量字符串的值发生了改变，那么Strong修饰的字符串属性的值也跟随发生了改变。因为strong修饰的是NSString，不可变字符转，所以这并不是我们想要的结果。

```Objective-C
@interface ViewController ()
@property (nonatomic, strong) NSString *propetyStr;
@end

NSMutableString *mutableString = [NSMutableString stringWithFormat:@"mutableString"];
self.propetyStr = mutableString;
[mutableString appendString:@"appendString"];

NSLog(@"mutableString：%@ %p\n",mutableString,mutableString);
NSLog(@"propetyStr：%@ %p\n",self.propetyStr,self.propetyStr);
/*
 打印结果：
 mutableString：mutableStringappendString 0x600000446960
 propetyStr：mutableStringappendString 0x600000446960
 */
```

在声明NSString属性时，一般我们将对象声明为NSString时，都不希望它改变。所以大多数情况下，我们建议用copy。以免和赋值对象共享一块内存空间，这块内存区域内的值改变了，从而导致的一些非预期问题。

```Objective-C
@property (nonatomic, copy) NSString *propetyStr;

NSLog(@"mutableString：%@ %p\n",mutableString,mutableString);
NSLog(@"propetyStr：%@ %p\n",self.propetyStr,self.propetyStr);
/*
 打印结果：
 mutableString：mutableStringappendString 0x600000440060
 propetyStr：mutableString 0x600000228260
 */
```

上面代码是我们想要的结果。但是，你还需要知道。如果，我们直接访问实例变量，会出现以下结果。

```Objective-C
_propetyStr = mutableString;

/*
 打印结果：
 mutableString：mutableStringappendString 0x60400025e0c0
 propetyStr：mutableStringappendString 0x60400025e0c0
 */
```
虽然我用copy修饰实例属性，但是，直接以下划线的形式给实例变量赋值，它们的内存地址居然一样。

请原谅我没有在官方文档上查阅到相关信息，但我查阅大量资料和通过上面实验证明，我想事实应该是这样的。官方要求我们使用setter和getter，也就是点语法访问属性。我们知道@property = ivar + setter + getter。那使用copy修饰属性时，setter方法究竟做了什么？

当使用copy修饰属性时，setter的方法实现：
```Objective-C
- (void)setPropetyStr:(NSString *)propetyStr{
    if (_propetyStr == propetyStr) {
        return;
    }

    NSString *oldValue = _propetyStr;
    _propetyStr = [propetyStr copy]; // 发送了copy消息
    [oldValue release];
}
```

**以上的实验，让我知道，为避免在编码过程中发生一些非预期的结果，当我们声明一个不可变变量（例如：NSString）属性时,我们选择用copy修饰（此时为深拷贝）。不要以下划线的形式给实例变量赋值。因为，我们知道在给copy修的属性赋值时，其实是调用了点语法(setter)方法发送copy消息。所以我们还需知道“使用Copy需要注意的四点事项”这里不错一一演示。**

**在下面这个例子，演示使用copy修饰的不可变变量NSString指针指向不可变变量NSString。其实，这种情况下只是指针指向这块内存区域，在这块区域上，引用计数加一（浅拷贝）。copy =  strong。**

```Objective-C
@property (nonatomic, copy) NSString *propetyStr;

NSString *testString = @"xxxxxxxxx";
self.propetyStr = testString;

NSLog(@"testString：%@ %p\n",testString,testString);
NSLog(@"propetyStr：%@ %p\n",self.propetyStr,self.propetyStr);
/*
 打印结果：
 testString：xxxxxxxxx 0x107a51210
 propetyStr：xxxxxxxxx 0x107a51210
 */
```

演示这个例子，我是想说明：在给copy修饰的属性赋值时，系统开辟新的内存空间是有针对性的。只针对，赋值对象为“可变变量”
。

还有一点我想你需要知道（虽然这和本文关联不大），我们在使用不可变变量的时候注意：**修改指针指向**带来的影响。

例子：
```Objective-C
// 更改指针指向地址
- (void)pointToAnotherMemoryAddress {
    // 1.指针a、b同时指向字符串pro
    NSString *a = @"pro";
    NSString *b = a;
    NSLog(@"Memory location of \n a = %p, \n b = %p", a, b);

    // 2.指针a指向字符串pro648
    a = @"pro648";
    NSLog(@"Memory location of \n a = %p, \n b = %p", a, b);

    /*
     打印结果：
     Memory location of
     a = 0x10b40b200,
     b = 0x10b40b200

     Memory location of
     a = 0x10b40b240,
     b = 0x10b40b200
     */
}
```

##### 例子2、不可变变量容器用Strong，还是Copy修饰？

先看这段代码

```Objective-C
@interface ViewController ()
@property (nonatomic, copy) NSArray *propertyArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableString *objectA = [NSMutableString stringWithFormat:@"objectA"];
    NSMutableString *objectB = [NSMutableString stringWithFormat:@"objectB"];
    NSMutableString *objectC = [NSMutableString stringWithFormat:@"objectC"];
    NSMutableArray *objectD = [NSMutableArray arrayWithObjects:[NSMutableString stringWithFormat:@"A"],@"B",@"C", nil];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithObjects:objectA,objectB,objectC,objectD, nil];

    self.propertyArray = mutableArray;

    NSLog(@"mutableArray：%@ %p\n",mutableArray,mutableArray);
    NSLog(@"propertyArray：%@ %p\n",self.propertyArray,self.propertyArray);
    /*
     打印结果：
     mutableArray：(
     objectA,
     objectB,
     objectC,
     (
     A,
     B,
     C
     )
     ) 0x604000259e00

     propertyArray：(
     objectA,
     objectB,
     objectC,
     (
     A,
     B,
     C
     )
     ) 0x604000259d10
     */
}

@end
```
上面的代码可以看到，使用copy修饰的不可变变量容器propertyArray，指针指向可变变量容器mutableArray。系统新开辟了块内存给propertyArray。

但是，这是真正意义上的“深拷贝”吗？我们往下看

```Objective-C
    self.propertyArray = mutableArray;
    // 在这里加三行代码
    [mutableArray addObject:@"objectE"];
    NSMutableString *tempMutableString = mutableArray.firstObject;
    [tempMutableString appendFormat:@" value is changed"];
    /*
     打印结果：
     mutableArray：(
     "objectA value is changed",
     objectB,
     objectC,
     (
     A,
     B,
     C
     ),
     objectE
     ) 0x6040002593b0

     propertyArray：(
     "objectA value is changed",
     objectB,
     objectC,
     (
     A,
     B,
     C
     )
     ) 0x6040002593e0
     */
}

@end
```
可以看到，我们对赋值对象mutableArray进行可变操作，并未影响propertyArray。这是因为使用copy修饰propertyArray，在给属性赋值时，调用了点语法（setter）发送了copy消息，系统新开辟块内存空间给propertyArray。但是，我们改变了mutableArray中的第一个元素的数据，propertyArray中的第一个元素数据也跟随改变。这说明：**使用copy修饰不可变变量作为属性，并非会达到真的意义上的深拷贝。因为，容器内元素的内存地址还是老地址，没有改变。**

若想实现深拷贝，怎么办呢？继续往下看
```Objective-C
    // self.propertyArray = mutableArray;
    self.propertyArray = [[NSArray alloc] initWithArray:mutableArray copyItems:YES];
    /*
     打印结果：
     mutableArray：(
     "objectA value is changed",
     objectB,
     objectC,
     (
     A,
     B,
     C
     ),
     objectE
     ) 0x60400025f140

     propertyArray：(
     objectA,
     objectB,
     objectC,
     (
     A,
     B,
     C
     )
     ) 0x60400025f050
     */
```
**使用`initWithArray:copyItems: `API实例化数组**，该API也适用于其它集合。

上面的代码是我们想要的结果，但是这是真正实现深拷贝的方式吗？其实这只是**单层的深拷贝**，继续往下看
```Objective-C
    // self.propertyArray = mutableArray;
    self.propertyArray = [[NSArray alloc] initWithArray:mutableArray copyItems:YES];
    // 我们将上面例子中的三行代码。替换为如下三行代码
    NSMutableArray *tempMutableArray = mutableArray[3];
    NSMutableString *tempMutableString = tempMutableArray.firstObject;
    [tempMutableString appendString:@" value is changed"];
    /*
     打印结果：
     mutableArray：(
     objectA,
     objectB,
     objectC,
     (
     "A value is changed",
     B,
     C
     )
     ) 0x6000002453d0

     propertyArray：(
     objectA,
     objectB,
     objectC,
     (
     "A value is changed",
     B,
     C
     )
     ) 0x600000244f80
     */
```
可以看到，我们修改了，容器内的元素（容器）的元素。这种容器嵌套的情况下，我们改变最里面的元素的值，被赋值对象的元素值也跟随变化。

**那对于一个集合类型的数据**，我们怎么才能**实现真正意义上的”深拷贝”**呢？答案是：**使用，归档、解档的方式**。
```Objective-C
//    self.propertyArray = mutableArray;
//    self.propertyArray = [[NSArray alloc] initWithArray:mutableArray copyItems:YES];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mutableArray];
    self.propertyArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    /*
     打印结果：
     mutableArray：(
     objectA,
     objectB,
     objectC,
     (
     "A value is changed",
     B,
     C
     )
     ) 0x60000044dec0

     propertyArray：(
     objectA,
     objectB,
     objectC,
     (
     A,
     B,
     C
     )
     ) 0x60000044e1f0
     */
```

##### 例子3、使用copy修饰自定义对象有意义吗？
其实不应该用这个标题，**如果你想得到一个自定义对象的克隆人，当然有意义**。但是，我从接触iOS开发到现在，还没有遇到需要copy自定义对象的时候。若你有遇到需要copy自定义对象的情况，请告知我。

copy自定义对象也是有许多注意点：**注意初始化方法的实现；注意copyWithZone方法的实现；注意自定义对象拥有可变集合元素的情况下是否想实现真正深拷贝。**

如下例子，思想源于[《招聘一个靠谱的iOS》面试题参考答案](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（上）.md#5-如何让自己的类用-copy-修饰符如何重写带-copy-关键字的-setter)
```Objective-C
#import "ViewController.h"

/**
 Person
 */
typedef NS_ENUM(NSInteger, PersonSex) {
    PersonSexMan,
    PersonSexWoman
};

@interface Person : NSObject<NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSUInteger age;
@property (nonatomic) PersonSex sex;

- (instancetype)initWithName:(NSString *)name age:(NSUInteger)age sex:(PersonSex)sex;
- (void)addFriend:(Person *)person;
- (void)removeFriend:(Person*)person;

@end


@implementation Person {
    NSMutableSet *_friends;
}

- (instancetype)initWithName:(NSString *)name
                         age:(NSUInteger)age
                         sex:(PersonSex)sex {
    if(self = [super init]) {
        _name = [name copy]; // 在初始化方法里，给copy修饰的属性赋值，别忘记调用copy方法。
        _age = age;
        _sex = sex;
        _friends = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addFriend:(Person *)person {
    [_friends addObject:person];
}

- (void)removeFriend:(Person *)person {
    [_friends removeObject:person];
}

- (id)copyWithZone:(NSZone *)zone {
    Person *copyPerson = [[[self class] allocWithZone:zone]
                     initWithName:_name
                     age:_age
                     sex:_sex];
    // 非真正意义深拷贝:
    copyPerson->_friends = [_friends mutableCopy];
    /*
     单层深拷贝:
     copyPerson->_friends = [[NSMutableSet alloc] initWithSet:_friends
     copyItems:YES];
     真正意义上的深拷贝:
     NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_friends];
     copyPerson->_friends = [NSKeyedUnarchiver unarchiveObjectWithData:data];
     */
    return copyPerson;
}

@end


/**
 ViewController
 */
@interface ViewController ()

@property (nonatomic, copy) NSArray *propertyArr;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    Person *tom = [[Person alloc] initWithName:@"Tom" age:27 sex:PersonSexMan];
    Person *marie = [[Person alloc] initWithName:@"Marie" age:27 sex:PersonSexWoman];
    Person *hunter = [[Person alloc] initWithName:@"Hunter" age:27 sex:PersonSexMan];
    [hunter addFriend:tom];
    Person *hunterCopy = [hunter copy];
    [hunter addFriend:marie];
    tom.name = @"PreeJ";
}

@end
```

如上代码看到：
Hunter有个朋友叫Tom；
造一个克隆人hunterCopy；
在这之后hunter又新增了一个朋友Marie；
最后Tom改名字了叫PreeJ。

真正意义上的“深拷贝”，Hunter生成一个克隆人之后，无论Hunter做什么操作其结果都应该和HunterCopy克隆人没关系。

我们在ViewDidLoad方法最后打个断点看最后结果
![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/CustomClassCopy.png)

NSCopint协议copyWithZone方法实现分析:

[copyWithZone:](https://developer.apple.com/documentation/foundation/nscopying/1410311-copywithzone)该方法返回一个实例对象给调用copy方法的接受者。参数zone是可以忽略不理的，OC不再使用的内存区域。

[allocWithZone:](https://developer.apple.com/documentation/objectivec/nsobject/1571945-allocwithzone)返回一个新的实例给类的接受者。Zone参数忽略即可。系统会新开辟一块内存空间出来来存储实例的数据，这块内存区域内其它实例变量为0。我们必须使用init...方法完成生成新的实例过程。这个方法的存在是历史遗留的原因。

[NSZone:](https://developer.apple.com/documentation/foundation/nszone?language=objc)被用来标识管理内存区域的一种类型。是一个结构体。在64-bit系统上运行忽略即可。我们平时开发过程中，不应该用它。

伙伴们的回答：

[What's the Point of Using [self class]
](https://stackoverflow.com/questions/5667312/whats-the-point-of-using-self-class)

[what is difference between alloc and allocWithZone:?
](https://stackoverflow.com/questions/4515293/what-is-difference-between-alloc-and-allocwithzone)

[从 Objective-C 里的 Alloc 和 AllocWithZone 谈起](https://justinyan.me/post/1306)

查看相关资料后，copyWithZone:内我是这样实现的
![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/CopyWithZone.png)


##### 例子4、[block作为属性，使用什么修饰？](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（上）.md#3-怎么用-copy-关键字)
