# Swift、RX、RX+Swift

要先去读swift官方文档，如果有晦涩难懂的地方，可以去参考些优秀博客。

## swift

文档：

- https://www.cnswift.org

- 极客学院：https://wiki.jikexueyuan.com

- hangge 的 Swift 编程社区也不错
  Eg：
  - [Swift - 内联序列函数sequence介绍（附样例）](https://www.hangge.com/blog/cache/detail_1377.html)
  - [Swift - RxSwift的使用详解5（观察者1： AnyObserver、Binder）](https://www.hangge.com/blog/cache/detail_1941.html)

## RxSwift

- [RxSwift: ReactiveX for Swift](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/)


---

## 值得注意的小Tips

- ### Swift 与 OC 混编注意事项
   TODO

- ### `Class` & `Struct`
   - `Class` 引用类型， `Struct` 值类型。
   ```
   Class对象赋值，是指针指向同一块内存区域，当原对象值改变，新对象也跟随改变； 值类型会新开辟内存空间。
   引用类型存储在堆区域；值类型存储在栈区域
   ```
   - `Class` 可继承，`Struct` 不可继承

   文档参考: [classes-and-structures](https://www.cnswift.org/classes-and-structures)、[Value_and_Reference_Types](https://wiki.jikexueyuan.com/project/swift/chapter4/05_Value_and_Reference_Types.html)


- ### [Swift中的问号?和感叹号!](https://www.jianshu.com/p/eacd24f0adaf)

- ### [Swift iOS : 自动闭包autoclosure](https://juejin.cn/post/6844903491031269390)

- ### [Swift try try! try?使用和区别](https://www.cnblogs.com/Erma-king/p/6755969.html)


## 优秀博主

- ### 卓同学早年的Swift文章依然是经典
  Eg：
  - [Swift函数柯里化介绍及使用场景](https://www.jianshu.com/p/5b27fec8c616)
  - [Swift Collection 中的 lazy 作用](https://www.jianshu.com/p/fb3be4c70093)

- ### 靛青K的Swift玩的不错

- ### 喵神出过得书值得一看
