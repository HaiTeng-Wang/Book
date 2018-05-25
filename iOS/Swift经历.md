
# 关于Swift的经历：


### 为什么迁移？

Swift将会是iOS的未来主流语言，毋庸置疑，苹果官方也极力推荐Swift编程，且Swift2.0进行开源，社区活跃度大家可晓而知。

但是Swift出现的时间并不久，14年横空问世，其API并不稳定，所以现在大部分公司也都只是尝试的接触Swift，16年的时候我们也是这样。

如今Swift版本已经升级到4.0其顶层API逐渐稳定，我相信Swift的接受者会越来越多。

那，Swift为什么这么受欢迎呢？这也就不得不说Swift的优点所在，在我以往使用Swift的过程中，对这门语言的**优点总结如下：**

- 更安全

- 更简洁

- 强大的特性

- 开源

#### 调研：大家对Swift的观点：

> [未来看好 Swift 的十个理由](https://www.ktanx.com/blog/p/2556)


> [Swift vs. Objective-C: Advantages of Swift Over Objective C](http://www.archer-soft.com/en/blog/swift-vs-objective-c-advantages-swift-over-objective-c)

##### Swift vs. Objective-C

| VS | Swift   | Objective-C  |
| --------   | --------   | -----  |
|01| Swift语法清晰简洁，因此它使得Swift中的API易于阅读和维护。   | Objective-C基于C，很难独立掌握。|
|02| Swift从Python，javaScript，Go，Ruby和其他编程语言中积累了所有的优点。| Objective-C的语法不同于任何其他编程语言，Objective-C操作起来非常困难，并不优雅。|
|03| 这很容易理解 - 它具有更合理的代码，从而缩短了代码的长度，从而缩短了开发时间。       | Objective-C实现的代码行数比Swift实现多两倍。 |
|04| Swift允许你交互式地开发你的应用程序。|Objective-C不允许您交互式开发应用程序。|
|05| swift对于程序员学习来说既简单又快速。 它使得创建iOS应用程序变得更容易。 不过，Swift开发人员现在是有限的。|    iOS 开发目前还是使用OC的较多，大部分公司还是以OC为基础|
|06| Swift旨在确保安全。 它的语法和语言结构排除了Objective-C潜在可能出现的几种类型的错误。 | OC没Swift安全。   |
|07| | |
|08| 它提供安全的内存管理，类型检测，泛型和可选项以及简单而严格的继承规则。| OC没有类型检测，泛型和其他伟大的事情（笔者补充：OC运行时还是很伟大的）|
|09| 你不能在OC中继承一个Swift类| OC中的类可以有子类|
|10| |在OC中没有这样的功能 |
|11| | |
|12| 元组允许您将多个元素分组为一个复合变量。| OC没有元祖|
|13| Swift智能编译动态库 | OC动态库，静态块都能编译|
|14| Swift是开源的。 最初是为Apple平台创建的，它正在逐渐扩展到构建在Linux上。 还有一个想法是让它与Android兼容。 | 不是开源的，局限于苹果设备|
|15|Swift还未完全稳定 | OC稳定|


### 怎么迁移？

1. 新功能用Swift来实现

2. 替换OC网络库，数据模型

3. 适用RxSwift

4. Swift代码规范

### 遇到哪些问题？

刚使用Swift时，不小心使用了强制解包符`!`，造成了Crash

Swift不支持OC中的宏

Swift的协议没有可选函数

OC无法调用，含有Swift特性的实例的方法或属性。如：OC访问一个Swift类中的枚举值变量，枚举元素非NSInteger类型。



### Swift与OC混编常见问题？

使用Swift原生类和Swift特有的属性，你会发现死活都永存不了。

Swift原生类或特有属性无法被编译进ProductName-Swift.h中，也就无法被OC代码调用。只有将Swift类继承NSObject，才可以被正常使用。

### 升级Xcode8后带来什么困扰？

---


#### `nil`

| `nil` | `Objective-C ` | `Swift`  |
| --------   | --------   | -----  |
| | nil是一个指向空对象的指针，只能赋值给对象 | nil不再是一个指针，是一个确定的值，表示缺失值。任何可选类型都可以赋值为nil(对象类型和基础类型)|


### [Swift是一门注重安全性的语言](http://swift.gg/2017/06/06/safety-in-swift/)
有些时候，我们会觉得Swift如此的强调安全性，确实让我们感觉它的语法太过苛刻，不过它带来的代码清晰，真的是利大于弊的。

#### `Optional`可选类型
在编码的过程中，我们要明确的知道，考虑哪个变量可以为`nil`哪些不能。需要**注意：**对于“可空”(nullable)的类型，如果使用强制解包符  `!`，来处理该类型，如果该类型变量的值真的为nil,直接会crash。


### Swift中的id、AnyObject、Any、AnyClass

### Swift初始化 VS Objective-C


### Swift动态性 VS Objective-C


### Swift的Class、Struct、Enum

   值类型与引用类型比较？
   Swift中将String、Array、Dictionary设计为值类型

### Swift是面向什么编程？ 对象、协议、还是函数（Swift中存在高阶函数）？


### Swift中访问控制符

### Swift具备哪些特性

### Swift中的内存面，怎么管理的？有何内存隐患？
