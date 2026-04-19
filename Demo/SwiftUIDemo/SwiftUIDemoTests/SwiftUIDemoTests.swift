//
//  SwiftUIDemoTests.swift
//  SwiftUIDemoTests
//
//  Created by Hunter on 2025/7/10.
//

import XCTest
@testable import SwiftUIDemo
// MARK: Tips
/*
Debug:
 [PO vs P vs V in LLDB of Xcode](https://dev.to/vinaykumar0339/po-vs-p-vs-v-in-lldb-of-xcode-3a7j)

 [【老司机精选】通过断点技巧让调试更高效](https://juejin.cn/post/7091848452614651941)
 Got it:
 Debug command: p po v e
 Breakpoint: exception, column, symbolic, runtime issue.
 Edit：condition ignore action(dubug common, script, etc) automatically continue after actions

 ----

 Testing:
 - XCTest
   - UITest, Unite Test, Performence test
 - SwiftTesting(Unite Test)

 ----

 Accessibility:
   - VoiceOver
   - dynamicFont

 ----

 SwiftLine:

 ----

 CI&CD:

 ----

 Performence optimization:

 ----
 */

// MARK: 测试查看 mutating 和 nomutating关键字
 struct Logger {
     var storedValue: Int

     var logValue: Int {
         get { storedValue }
         nonmutating set {
             /*
              "nonmutating：用于属性setter，表明操作不修改实例状态，支持常量(let)实例调用。"
              不修改存储属性，仅记录日志.
              如果这里不用nonmutating关键字标注，下方代码会报这个errorCannot assign to property: 'logger' is a 'let' constant, Change 'let' to 'var' to make it mutable
              let logger = Logger(storedValue: 5)
              */
             print("New value: \(newValue)")
         }
     }

     mutating func test()  {
         storedValue += 6
         /*
          "mutating：用于需要修改值类型自身状态的方法或属性setter。"
          如果不添加mutating关键字会报错 Left side of mutating operator isn't mutable: 'self' is immutable
          */
     }
}

// MARK: 测试查看swift copy的实现。对于类想要实现深拷贝，要么自己如下实现Copyable，要么遵循NSCoping协议去实现copy方法。

/* Swift 对象拷贝 https://juejin.cn/post/6844903464728788999
protocol Copyable {
    func copy()-> Self
}

class MyClass:Copyable{
    var des = " "

    func copy() -> Self{

       let obj = type(of: self).init(self.des)
        return obj

    }
    required init(_ des:String){
        self.des = des
    }
}

 let myClass = MyClass("my class")
 let yourClass = myClass.copy() as! MyClass
 yourClass.des = "your class"
 print(yourClass.des)//your class
 print(myClass.des)// my class

 class Son:MyClass{

 }
 let sonA = Son("sonA")
 let sonB = sonA.copy()
 sonB.des = "sonB"
 print(sonA.des)//sonA
 print(sonB.des)//sonB
 */

// MARK: 测试理解 some protocol不透明类型，和any protocol封装协议类型
/*
 any 和 some 的区别

 特性    any Container    some Container
 类型信息    擦除关联类型（动态分发）    保留关联类型（身份信息）（静态编译时确定）
 返回值    可以是任意符合的类型    必须是单一具体类型（编译器推断）
 性能    存在类型有运行时开销    无额外开销
 使用场景    需要隐藏具体(any 任意)类型    需要隐藏具体(some 某一个)类型
 */

protocol Shape {
    func draw() -> String
}

struct Triangle: Shape {
    var size: Int
    func draw() -> String {
       var result: [String] = []
       for length in 1...size {
           result.append(String(repeating: "*", count: length))
       }
       return result.joined(separator: "\n")
    }
}

struct FlippedShape<T: Shape>: Shape {
    var shape: T
    func draw() -> String {
        let lines = shape.draw().split(separator: "\n")
        return lines.reversed().joined(separator: "\n")
    }
}

struct JoinedShape<T: Shape, U: Shape>: Shape {
    var top: T
    var bottom: U
    func draw() -> String {
       return top.draw() + "\n" + bottom.draw()
    }
}

struct Square: Shape {
    var size: Int
    func draw() -> String {
        let line = String(repeating: "*", count: size)
        let result = Array<String>(repeating: line, count: size)
        return result.joined(separator: "\n")
    }
}

func makeTrapezoid() -> some Shape {
    let top = Triangle(size: 2)
    let middle = Square(size: 2)
    let bottom = FlippedShape(shape: top)
    let trapezoid = JoinedShape(
        top: top,
        bottom: JoinedShape(top: middle, bottom: bottom)
    )
    return trapezoid
}

func flip<T: Shape>(_ shape: T) -> some Shape {
    return FlippedShape(shape: shape)
}
func join<T: Shape, U: Shape>(_ top: T, _ bottom: U) -> some Shape {
    JoinedShape(top: top, bottom: bottom)
}

/*
 let trapezoid = makeTrapezoid()
 print(trapezoid.draw())

 let smallTriangle = Triangle(size: 3)
 let opaqueJoinedTriangles = join(smallTriangle, flip(smallTriangle))
 print(opaqueJoinedTriangles.draw())
 */

// 测试不透明类型和封装协议类型文档中的关于”具有一个关联类型的装协议类型不能作为返回类型测试“。答案是：旧版确实禁止直接返回 Container，但 Swift 5.7+ 的 any 关键字放宽了这一限制。any Container 是存在类型（运行时擦除），而 Container 是协议（编译时需要完整类型信息）。

protocol Container {
    associatedtype Item
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}
extension Array: Container { }

func makeProtocolContainer<T>(item: T) -> any Container {
    return [item]
}

// MARK: 初始化器练习
// 关于访问级别：构造器和函数一样，遵循访问级别指导原则。初始化器访问级别：本类Public, open -> internal, 本类fileprivate->fileprivate，本类private->private。结构体中如果成员为 private或fileprivate，默认的成员逐一初始化器也为private或fileprivate。如果本类为Public, open internal 默认成员逐一初始化器访问级别则为 internal。
public class InitClass { // 类的初始化器遵循两段式构造过程：1. 类中每个存储属性都有一个初始值 2. 新实例准备使用之前可以自定义他们的存储属性。4种有效的安全检查：1. 保证所在类的所有属性都初始化完->构造任务向上代理给父类构造器——>2.继承属性设置新值。3.便利构造器为任意属性赋值之前需代理调用其它构造器。4.构造器在第一阶段（每个属性都要有初始值）构造未完成之前不能读取任何实例属性的值，不能引用self作为一个值（eg:函数闭包作为一个属性成员的实现内不能用self访问其它成员和self本值）
    var name: String?
    var age: Int // swift要求所有存储属性必须有初始值，如果所有存储属性都有初始值会自动提供一个默认的初始化器eg:InitClass()。默认初始化器即为指定初始化器，每个类必须至少有一个指定初始化器。
    private init(age: Int) {
        self.age = age
    }
    init(_ age: Int = 0) {
        self.age = age
    }
    required init(age: Int, name: String?) { // 必要初始化器 指定初始化器 便利初始化器 默认构造器 可失败构造器 区别 去查看deepseek（我之前搜索的，回答的我很满意，必须看一眼）。必要初始化器和便利初始化器只有class才有。
        self.age = age
        self.name = name
    }
    convenience init() { // 构造器中的代理调用规则：指定初始化器遵循纵向代理调用，只可以调用父类的指定初始化器（向上代理）。 便利初始化器遵循横向代理调用, 只可以调用本类的便利初始化器和指定初始化器（横向代理）。
        self.init(age: 10, name: "")
    }
}
public class superClass {
   fileprivate func superFileprivateFun() {
   }
}
// 子类的访问级别不得高于父类的访问级别
class sonClass: superClass {
    override func superFileprivateFun() {
        // 子类重写父类成员可提升父类成员的访问级别，这里子类从写后的superFileprivateFun的访问级别为internal。
        // 同一个上下文中，子类可访问父类的方法
        super.superFileprivateFun()
    }
}


struct InitStruct {
//    private var name: String?
    var age: Int /* 结构体中所有存储属性也是都要有初始值，定义的时候可以不给初始值，但是必须初始化中必须给值。
                  InitStruct.init(age: 0, name: "", sex: 0)
                  InitStruct.init(age: 0, name: "")
                  InitStruct.init(name: "") 否则会报error "Missing argument for parameter 'age' in call"
                   */
    var name: String
    var sex: Int = 0
//    init(age: Int) { // 如果你在结构体类型中定一个自定义构造器，你将无法访问到默认构造器和逐一成员构造器。但是将自定义构造器写在extension中，就没关系。但是要注意结构体内是否有private或fileprivate访问修饰符修饰的存储属性，这会导致结构体的逐一成员构造器也是相对应的访问级别，从而没失去意义。
//        self.age = age
//    }
}
//
//extension InitStruct {
//    init(age: Int) {
//        self.age = age
//        self.name = "" // 如果把这行注释掉，会报erro: Return from initializer without initializing all stored properties
//    }
//}


// Test of Access Control For Protocol
// 不可以为协议的要求声明访问控制级别。协议的继承也遵循访问控制原则(实体的访问控制级别不能高于依赖的访问控制级别)。
public protocol PrivateProtocol {
    func privateFunc()
}

// Test of Access Control For extension
// open public, internel -> internel, fileprivate->fileprivate, private->private。
// 可显示为extension设置访问级别，extension内的实体也可覆盖显示声明的访问级别。
// 在同一文件内为extension显示声明private没有实际意义。 例如一个文件内有 Struc A{}，同时有Class B{}，以及 private extension A{}。private extension A 内的实体可已被文件内的任意作用域所访问到，但在其他文件访问不了extention A内声明的实体。
extension PrivateProtocol {

}

final class SwiftUIDemoTests: XCTestCase {

    func test_the_use_of_sequence_operators() {
        /*
         Tips:
         - We need always use the `guard` to do the pre condition.
         - For the String, mayby we can convert to Array to operation that due to the string subscript is the type of Index.
         - We can use the Tuple type to swap two value.
         eg1:
         var (a, b) = (0, 1)
         for _ in 2 ... n { (a, b) = (b, a + b)}
         eg2:
         func _swap<T>(_ chars: inout [T], _ p: Int, _ q: Int) {
         (chars[p], chars[q]) = (chars[q], chars[p])
         }
         - Iteration: for _ in 0 ..< array.count  |  while left < right { left ++; right--} | recursion
         */

        // The commens mean: "// return type // prints or Tip"
        // Declaring the part of belows as `var` means that the corresponding example operation can only be used on the variable

        _ = "AEIOU".lowercased() // String
        _ = "aeiou".uppercased() // String

        var append = ""; append.append("") // String // Tip: The type of Set needs to using insert(element)
        var appendSequence = [1]; appendSequence.append(contentsOf: [2]) // [Int]

        var removeFirst = "1"; _ = removeFirst.removeLast(); // String.Element
        var removeAt = "1"; _ = removeAt.remove(at: removeAt.startIndex) // Character
        var removeLast = "1"; _ = removeLast.removeLast() // String.Element

        _ = "split,separater".split(separator: ",") // [String.SubSequence]

        _ = "reversed".reversed() // ReversedCollection<String>

        _ = "abcde".sorted() // Array // prints ["a", "b", "c", "d", "e"]
        _ = [("Alim", 30), ("Jeff", 39), ("Hunter", 32)].sorted { $0.1 > $1.1 }
        var sort = [1, 2, 4, 3, 0]; sort.sort() // Array [0, 1, 2, 3, 4]

        _ = [1, 2, 3].contains(1) // Bool
        _ = [-1, 0, 1, 2, 3].contains(where: {$0 > 0}) // Bool
        _ = "".contains(where: { $0.isNumber || $0.isLetter || $0.isUppercase || $0.isSymbol || $0.isWhitespace }) // Bool

        _ = max(10, 100) // T : Comparable
        _ = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156].max{ $0.value < $1.value } // Self.Element? // Prints "Optional((key: "Heliotrope", value: 296))"

        _ = [1, 3, 5, 100].enumerated().max(by: { $0.element < $1.element })?.offset  // Tip: 1. $0 is let $0: (offset: Int, element: Int); 2. This operator will get the max element index for array, that will return Optional(3)

        _ = [["a"], ["b"], ["c"]].reduce([String](), +) // [String]
        _ = "aabbc".reduce(into: [:]) { $0[$1, default: 0] += 1 } // Dic // prints ["a":2, "b": 2, c: 1]
        _ = "reduceInto".reduce(into: "") { if !"aeiouAEIOU".contains($1) {$0.append($1)} } // String
        _ = "".filter { $0 != "1" } // Tip: Use the same about `map` `flatMap` `compatMap`

        _ = Array(repeating: String(repeating: "", count: 10), count: 10) // [String]
        _ = String(Set(String(Array(String("aabbc"))))) // String // prints "abc" // Tip: init with sequences

    }


}
