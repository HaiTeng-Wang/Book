# KVO

### KVO初探



> Key-value observing is a mechanism that allows objects to be notified of changes to specified properties of other objects.
键值观察是一种机制，它允许将其他对象的指定属性的更改通知给对象。

KVO是Key-Value Observing的缩写，即：健值观察。先查看NSKeyValueObserving.h文件

![kvo](/assets/kvo.png)


可知平时编码中常用的相关方法都是NSObject和集合类的分类。

同时，这也验证了[KVO文档](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html#//apple_ref/doc/uid/10000177-BCICJDHA)中如下这句话：
> Typically, if your objects inherit from NSObject and you create properties in the usual way, your objects and their properties will automatically be KVO Compliant.
通常，如果您的对象继承自NSObject并以通常的方式创建属性，则您的对象及其属性将自动符合KVO标准。

#### 使用方式三步曲：

1. `addObserver:forKeyPath:options:context:`

2. `observeValueForKeyPath:ofObject:change:context:`

3. `removeObserver:forKeyPath:`

![KVOGlance](/assets/KVOGlance.png)

#### 注意：

##### 1. `context`参数

- > 消息中的 context 指针包含任意数据，这些数据将在相应的更改通知中传递回观察者。你可以指定 NULL 并完全依靠key Path键路径字符串来确定变更通知的来源，但是这种方法可能会导致对象的super class父类由于不同的原因而观察到相同的键路径，因此可能会引起问题。

  > 一种更安全、更可扩展的方法是使用context确保你收到的通知时发给观察者的，而不是super class。

  - 主要用于区别监听对象，尤其是相同path的不同对象的观察，比如一个父类的实例对象和子类的实例对象都是一个对象的观察者。


##### 2. 移除观察者

  KVO的`addObserver`和`removeObserver`需要是成对的，如果重复remove则会导致NSRangeException类型的Crash，如果忘记remove则会在观察者释放后再次接收到KVO回调时Crash。苹果官方推荐的方式是，在init的时候进行addObserver，在dealloc时removeObserver，这样可以保证add和remove是成对出现的，是一种比较理想的使用方式。


##### 3. KVO的触发模式（手动和自动）

  KVO在属性发生改变的时候默认是自动调用的，如果需要手动的控制这个调用时机，或者自己来实现KVO属性的调用，可以通过KVO提供的方法来调用。
  在所要观察的对象.m文件中加入
  ```Objective-c
  +(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return YES; // 默认，自动模式
    return NO; // 手动模式
  }
  ```
  同时在属性变化之前，调用：
  ```Objective-c
  - (void)willChangeValueForKey:(NSString *)key;
  ```
  在属性变化之后，调用：
  ```Objective-c
  - (void)didChangeValueForKey:(NSString *)key;
  ```
  其实无论属性的值是否发生改变，是否调用Setter方法，只要调用了`willChangeValueForKey:`和`didChangeValueForKey:`就会触发回调。

  一般我们在开发的时候，需要用到KVO监听属性值得变化，一般不会将所有的值得监听都是手动的触发，同时我们也看到`automaticallyNotifiesObserversForKey:`传入了一个参数key, 就是为了让我们根据key来决定是否手动开启KVO.
  ```Objective-c
  +(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    if ([key isEqualToString:@"name"]) {
        return NO; //手动模式
    }
    return YES; //默认，自动模式
  }
  ```

##### 4. 注册依赖
  - 适用情况：一个属性的值取决于另一对象中一个或多个其他属性的值。如果一个属性的值发生更改，则派生属性的值也应标记为更改。
  - 示例：
   - 下载的进度 = 已下载 / 总下载
   - 人的全名取决于名字和姓氏

  第一种方法是我们通过重写`keyPathsForValuesAffectingValueForKey:`

  eg：
  ```objective-c
  // 下载进度 -- writtenData/totalData
    + (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key{

        NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
        if ([key isEqualToString:@"downloadProgress"]) {
            NSArray *affectingKeys = @[@"totalData", @"writtenData"];
            keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
        }
        return keyPaths;
    }
  ```

  第二种方法是通过实现遵循命名约定的类方法`keyPathsForValuesAffecting<Key>`来实现相同的结果，其中<Key>是依赖值的属性名称（首字母大写）。实现代码如下：

  ```objective-c
    + (NSSet *)keyPathsForValuesAffectingFullName {
        return [NSSet setWithObjects:@"lastName", @"firstName", nil];
    }
  ```
   **对于分类我们只能以第二种方法进行实现。因为我们不能在分类中重写`keyPathsForValuesAffectingValueForKey:`的实现。**

  (以上是官方文档中的一对一关系To-One Relationships，对于一对多To-Many Relationships的情况不适用，可以[查看官方中的示例](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVODependentKeys.html#//apple_ref/doc/uid/20002179-SW5)。)

##### 5. 数组观察

- KVO可以监听单个属性的变化，也可以监听集合对象的变化。
- 如果被观察的对象为array类型，需要注意在修改该array对象时需要通过KVC的`mutableArrayValueForKey:`方法获得该对象。因为KVO监听的是set方法，而对array进行操作却不是set方法，所以，如果通过点语法直接访问，无法改变该属性。

  Eg：`[self.person mutableArrayValueForKey:@"dateArray"]` 去获取person的dateArray属性，该属性为NSMutableArray类型。

### KVO原理探讨

> KVO 是通过 isa-swizzling 实现的。

基本的流程是编译器自动为被观察者对象创造一个派生类（此派生类的父类是被观察者对象所属类），并将被观察者对象的 isa 指向这个派生类。

例如：当person 被观察后，person 对象的 isa 指针被指向了一个新建的 Person 的子类 NSKVONotifying_Person
```objective-c
self.person = [[Person alloc] init];
[self.person addObserver:self forKeyPath:@"nickName" options:(NSKeyValueObservingOptionNew) context:NULL];
```

此时，派生类NSKVONotifying_Person重写了**被观察值**的 `setter`方法(eg：setNickName:)，和NSObject的`class`、`dealloc`以及新增`_isKVO`方法。并在`setter`中添加进行通知的代码。

所以，Objective-C 在发送消息的时候，会通过 isa 指针找到当前派生类NSKVONotifying_Person，实际上是发送到了派生类对象的方法。

当修改了isa指向后，因为同时重写了class方法，所以class的返回值不会变，所以也验证了KVO官方文档有描述
> 通过 isa 获取类的类型是不可靠的，通过 class 方法才能得到正确的类

```objective-c
NSLog(@"%@", [self.person class]);
// object_getClass方法返回 isa 指向
NSLog(@" %@", object_getClass(self.person));

控制台打印:
Person
NSKVONotifying_Person
```

因此，当被观察值被修改了，会触发NSKVONotifying_Person的setter方法

```objective-c
self.nickName = @"被观察值被修改";
```

- 在 setter 中，会添加以下两个方法的调用
  - `(void)willChangeValueForKey:(NSString *)key`;
  - `(void)didChangeValueForKey:(NSString *)key`;

  在willChange和didChange之间会回调父类的setter方法进行赋值，

  然后在`didChangeValueForKey:`中，去调用：

  ```objective-c
  - (void)observeValueForKeyPath:(nullable NSString *)keyPath
                        ofObject:(nullable id)object
                          change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                         context:(nullable void *)context;
  ```               
  于是实现了属性值修改的通知，复制代码包含了新值和旧值。所以，KVO的原理是修改 setter 方法，因此使用 KVO 必须调用 setter，若直接访问属性对象则没有效果。

最后在调用移除观察者方法时，此时isa会指回原始类Person。但是中间类NSKVONotifying_Person没有被销毁，仍在内存中。
```objective-c
[self.person removeObserver:self forKeyPath:@"nickName"];
```

---

官方文档：https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html#//apple_ref/doc/uid/10000177-BCICJDHA

写的不错的文章：
- [iOS KVO 官方文档《Key-Value Observing Programming Guide》中文翻译](https://www.mdeditor.tw/pl/grHm)

- [iOS Objective-C KVO 详解](https://www.jianshu.com/p/3e12f28baaff)
