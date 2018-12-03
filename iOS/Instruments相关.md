## Time Profiler(时间分析器)
检测应用CPU的使用情况.可以看到应用程序中各个方法正在消耗CPU时间

#### 注意：

1、使用真机测试

2、Xcode配置如下

```
2.1 Edit Scheme -> Build Configuration 选择Debug模式
2.2 Build Settings -> Debug Information Format -> Debug 选择 DWARF with dSYM File
```

---

## 检测内存泄露

### Analyze(静态分析工具)

#### 检测结果

警告120处

疑似泄露点238处

#### 疑似泄漏点

1、viewWillAppear、viewWillDisappear、viewDidDisappear等子类覆盖父类方法，没有调用父类的方法。

提示信息(eg):
```objective-c
The 'viewWillAppear:' instance method in UIViewController

subclass 'OpenPaymentViewController'

is missing a [super viewWillAppear:] call
```

此处，虽然没有发生内存泄露，但苹果官方提示需调用父类的方法。
查询文档、相关资料也并未有人回答出父类方法究竟做了些什么，只是有人踩过不调用父类方法的坑，尤其是NavigationController
子类中。所以按文档要求个人觉得最好还是要调用父类方法，虽然不调用也没发现什么错。

2、[Obj-C, Returning 'self' while it is not set to the result of '[(super or self) init…]'?
](https://stackoverflow.com/questions/8072385/obj-c-returning-self-while-it-is-not-set-to-the-result-of-super-or-self-i)

3、Dead store

 - 3.1 [Value stored to 'var' is never read](http://blog.csdn.net/duxinfeng2010/article/details/17840573)

 - 3.2 [Value stored to 'var' during its initialization is never read](https://stackoverflow.com/questions/12665081/value-stored-to-mykeyarray-during-its-initialization-is-never-read)

 - 3.3 [nil returned from a method that is expected to return a non-null value](https://stackoverflow.com/questions/39356369/null-is-returned-from-a-method-that-is-expected-to-return-a-non-null-value-wit)

4、Memory error

 - 报同上`3.3`一样的警告

5、Memory(Core Foundation/Objective-C)

 - 5.1 [Potential leak of an object stored into 'object'](https://stackoverflow.com/questions/19737851/potential-leak-of-object)

     注意：在ARC情况下，只有OC对象才能自动释放。

 - 5.2 Object leaked: allocated object is not referenced later in this execution path and has a retain count of +1

     注意：你是否还需要再次alloc?

 - 5.3 Incorrect decrement of the reference count of an object that is not owned at this point by the caller

6、Logic error（逻辑错误）

 - 6.1 [Property of mutable type 'NSMutableURLRequest' has 'copy' attribute; an immutable object will be stored instead](https://github.com/AFNetworking/AFNetworking/issues/3916)

 - 6.2 [Passed-by-value struct argument contains uninitialized data (e.g., via the field chain: 'size.width')](http://www.cnblogs.com/chaoyueME/p/5977320.html)

 - 6.3 [The left operand of '&' is a garbage value](http://blog.csdn.net/hamasn/article/details/7601592)

 - 6.4 [Undefined or garbage value returned to caller](https://stackoverflow.com/questions/8041556/logic-error-undefined-or-garbage-value-returned-to-caller)

7、Optimization（优化）

 - Instance variable '_verticalAlignment' in class 'VerticalAlignmentLable' is never used by the methods in its @implementation (although it may be used by category methods)

 多余的实例变量

8、API Misuse（滥用API）

 - Argument to 'NSMutableArray' method 'addObject:' cannot be nil

 NSMutableArray的方法addObject所需要的参数不能为nil

9、Coding Conventions

 - [Potential null dereference.  According to coding standards in 'Creating and Returning NSError Objects' the parameter may be null](http://www.cocoachina.com/ios/20150826/13080.html)


### Leeks(动态分析工具)



---

### 总结：

平时在编码过程中，一定不要欠下“技术债”。

编写一小模块，进行检测一次。在编写业务模块时，最好在VC里重写dealloc方法，打断点测试，写完后删除。
