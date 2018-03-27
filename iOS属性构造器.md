# iOS属性构造器

- `strong`： 强引用 （对指针指向的数据地址增加引用计数，称为强引用）

- `weak`： 弱引用 (对指针指向的数据地址不增加引用计数)。

   `weak`修饰的对象，指针指向的数据地址被释放，weak的值为`nil`，指针地址会被置为nil。

- `retain`： `ARC`之前属性构造器，功能同`strong`。

- `assign`： 修饰基本数据类型，不增加引用计数。

   `assign`其实也可以用来修饰对象，被`assign`修饰的对象在释放之后，指针的地址还是存在的，也就是说`assign`只是会对这片内存空间释放旧值，指针并没有被置为nil。如果在后续的内存分配中，刚好分到了这块地址，会出现野指针程序就会崩溃掉。

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

- `copy`（拷贝）
当`copy`修饰的属性，指针指向：
  - 可变变量：例如`NSMutableString`，为深拷贝。

  ```objective-c
  @interface ViewController ()
  @property (nonatomic, copy) NSString *str;
  @end

  @implementation ViewController
   - (void)viewDidLoad {
       NSMutableString *mutableStr = [NSMutableString stringWithFormat:@"mutableStr"];
       self.str = mutableStr; // copy修饰的str属性，指针指向mutableStr
       [mutableStr appendFormat:@" is chaged"]; // 原值已经被修改
       NSLog(@"str:%@,mutableStr:%@;\nstr内存地址:%p,mutableStr内存地址:%p",self.str,mutableStr,self.str,mutableStr);
/*
 打印：
 str:mutableStr,mutableStr:mutableStr is chaged;
 str内存地址:0x60400002a940,mutableStr内存地址:0x60400024a890

 结论：copy会重新开辟新的内存来保存一份相同的数据，被赋值对象和原值修改互不影响。
 */
}
  @end
  ```

  - 可变变量容器：例如`NSMutableArray`，容器本身为深拷贝，其中数据元素在拷贝的时候为浅拷贝。

  - 不可变变量：例如`NSString`，为浅拷贝。

  - 不可变变量容器：例如`NSArray`，容器本身及其中元素都为浅拷贝。

---

- `delegate`属性修饰符：

  `weak` or `strong` 先看一个例子：

  `TestClass`
  ```objective-c
  @protocol TestClassProtocol <NSObject>
  @optional
  - (void)justTest;
  @end

  @interface TestClass : NSObject
  @property (nonatomic, strong) id<TestClassProtocol>delegate;
  @end
  ```

  `ViewController`
  ```objective-c
  @interface ViewController ()
  @property (nonatomic, strong) TestClass *testClass;
  @end
  ```
  ```objective-c
  - (void)viewDidLoad {
    [super viewDidLoad];
    self.testClass = [[TestClass alloc] init];
    self.testClass.delegate = self;
  }
  ```

  结果：循环引用，造成内存泄露。`ViewController`没走`dealloc`方法。
  ![][1]
  - strong：该对象强引用`delegate`，外界不能销毁`delegate`对象，会导致循环引用(Retain Cycles)

  - weak：指明该对象并不负责保持delegate这个对象，delegate这个对象的销毁由外部控制

  因此，声明`delegate`属性，通常情况下我们用`weak`。

- `block`属性修饰符：`copy`。

---

##### 总结：
修饰`delegate`：`weak`

修饰`block`：`copy`

修饰`非OC对象`：`assign`

修饰`OC对象`需考虑：
1. 是否新开辟内存空间；
2. 在这块儿内存空间内的数据是否想持有引用计数。

##### 需注意：属性修饰符，在其修饰的对象被赋值的时候起作用。

##### 引用计数作用：保持指针指向的这块内存地址不被释放。

---
##### 疑问：
1、`NSCoping` & `NSMutableCopying`区别究竟在哪里？调用`copy`
或`mutableCopy`拷贝对象，为什么都为深拷贝？

2、`block`作为属性，究竟是使用`copy`还是`strong`修饰。`iOS5`之前的`MRC`时代`copy`是将`block`从栈区拷贝到堆区，`ARC`时代我们可用`strong`修饰吗？若可以，为什么？`stong`做了什么？


  [1]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/delegateRetainCycles.png
