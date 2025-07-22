//
//  ViewController.swift
//  UIKitDemo
//
//  Created by Hunter on 2025/6/24.
//

import UIKit

class HTMLElement {
    var name: String = "HTML Name"
    let text: String?

    // MARK: 计算属性，通过闭包或函数设置属性的默认值，lazy，循环引用(weak, unowned)练习笔记。

    // 定义一个计算属性。计算属性和只读计算属性，只能用var定义。因为它们的值并非固定的。let 关键字只用于常量属性，表示它们的值在实例初始化时设置后就无法更改。
    var calculateProperty: String {
        set {
            self.name = newValue // 因为计算属性不存储值，而是提供一个 getter 和一个可选的 setter，来间接获取和设置其他属性或变量的值。所以表达式内可访问self。
        }
        get {
            return name // 可省略self，隐士访问self
        }
    }

    // 定义一个只读计算属性
    var readOnlyCalculateProperty: String {
        name
    }

    // 通过闭包或函数设置属性的默认值。
    /*
     如果某个存储型属性的默认值需要一些自定义或设置，你可以使用闭包或全局函数为其提供定制的默认值。每当某个属性所在类型的新实例被构造时，对应的闭包或函数会被调用，而它们的返回值会当做默认值赋值给这个属性。
     */
//    let someProperty: SomeType = {
//        // 在这个闭包中给 someProperty 创建一个默认值
//        // someValue 必须和 SomeType 类型相同
//        return someValue
//    }()

    // 定义懒加载存储属性，通过闭包设置属性的默认值 (在该属性被首次访问时闭包会被调用，返回值会当做默认值赋值给这个属性。)。
    // lazy修饰的属性必须用var定义。因为属性的初始值可能在实例构造完成之后才会得到。而常量属性在构造过程完成之前必须要有初始值，因此无法声明成延时加载。
    // 因为属性延迟加载，所以闭包体内可以访问到self。
    lazy var html: String = {

        return self.name
        // 因为该属性类型为值类型，而非闭包类型(闭包为引用类型)，所以self不会对该属性进行强引用，所以闭包体内接调用self（闭包体内没有弱引用或无主引用self）不会造成循环强引用。
    }() // 注意闭包结尾的花括号后面接了一对空的小括号。这用来告诉 Swift 立即执行此闭包。如果你忽略了这对括号，相当于将闭包本身作为值赋值给了属性，而不是将闭包的返回值赋值给属性。

    // 定义懒加载的的闭包`() -> String` 属性。
    lazy var asHTML: () -> String = {
        [unowned self] in // 注意这里是捕获列表，用unowned捕获self，以防止循环引用，因为 `asHTML`，是当前类型的属性，所以self一**定不会**先于属性释放，所以这里用unowned去弱引用self。（但是，一旦self**先释放**了，这时候再调用闭包会crash，因为闭包内使用了unowned self。例如：5s后调用这个闭包，但是在这之前self被释放了。这时候这里就会crash。这种情况就要注意了，要用weak了。）
        /*
         unowend vs weak
         都是为了避免所修饰的引用类型造成循环引用，其互相持有，导致引用计数都不为0，而没有被释放。产生内存泄露。
         不同之处在于:
         1. weak 会相当于将所修饰的类型转换为可选类型。访问的时候需要可选访问，或对其进行可选绑定。当其修饰的示例可能先被释放，或者说，生命周期更短，且需要打破引用循环时，使用弱引用。
         2. unowned 会相当于将所修饰的类型转换为一定不为空的可选类型，访问的时候无需解包，但如果所修饰的类型为一但为nil，对其访问会crash！无主引用是在另一个实例具有相同或更长的生命周期时使用的，也就是说，当确定自己所引用类型实例生命周期一定比自己长，且需要打破引用循环时使用。
         官方例子：
         unowned
         1. 闭包作为类的实例属性，且闭包内访问了self。(闭包是引用类型，self->clouser clouser->self) (也就是这里的asHTML例子。闭包内可用unowned捕获self, 因为self和其属性**生命周期相同，同时释放**)
         2. 信用卡和人（两个类实例属性互相引用）：人也许会有一张信用卡(strong修饰可选信用卡)，每张信用卡**必然**有它的主人(unowend修饰比较适合)。
         3. Country和City（两个类实例属性互相引用，且始终都应该有值）无主引用和隐士解包可选引用。国家**必须始终有**一个首都(strong修饰隐士解包可选引用)，每个城市**必须始终属性**一个国家(无主引用)。
         4. 无主可选引用示例（Department和Course）：一个系（department）拥有它的课程([Course])（保持强引用），每门课程(Course)都属于某个系的一部分（department 属性不是可选的，所以用unowned修饰），有些课程没有推荐的后续可nextCourse（所以用无主可选引用修饰 unowned var nextCourse: Course?）
         (实际code过程中，3. 4. 例子情况没遇到过，可不必深入，了解就好。主要掌握什么情况下会导致循环引用，weak vs unowend即可）

         weak
         1. 租户和公寓（两个类实例属性互相引用）：租户可能住在公寓里(strong修饰可选公寓)，公寓里也可能住着租户，同时公寓在其生命周期的某个时刻**可能没有**租户(weak修饰比较适合)。
         2. 逃逸闭包（可能先被释放）
         3. 代理（可能先被释放）


         unowned(unsafe) 代表不安全的无主引用，会禁用运行时安全检查。
         运行时都会crash。xcode中报错不一样。unowned(unsafe) 程序将尝试访问该实例曾经所在的内存位置，这是一个不安全的操作。
         // Fatal error: Attempted to read an unowned reference but object 0x60000282ae50 was already deallocated
         // Thread 1: EXC_BAD_ACCESS (code=1, address=0x67fc3c2f2660)
         */
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    } // 这里没有`()`，所以意味着将闭包本身作为值赋值给了属性。


    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }


    deinit {
        print("\(name) is being deinitialized")
    }


}

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    lazy var clouser: () = {
        [weak self] in

        if let this = self {
            this.label.text = "dfsd"
        }

    }()

    var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")

    override func viewDidLoad() {
        super.viewDidLoad()
//        label.layer.masksToBounds = true // button label，等view，切圆角时候，如果调用了masksToBounds 会造成离屏渲染 (无需调用)。同时需知道，ImageView 设置了 cornerRadius 即使没有调用 masksToBounds，也会造成离屏渲染。（可以让UI直接切好图，或者自己进行异步绘制。）
        label.layer.cornerRadius = 20
        label.layer.backgroundColor = UIColor.red.cgColor

    }

    @IBAction func clickbutton(_ sender: UIButton) {
        let homeVC = HomeViewController.init(nibName: "HomeViewController", bundle: Bundle.main)
//        homeVC.delegate = self // 代理练习。如果homeVC先被释放，homeVD的delegate就可以用strong修饰，不存在强引用环。
        navigationController?.pushViewController(homeVC, animated: true)
    }

    @IBAction func goRetainCycleVC(_ sender: UIButton) {
        present(RetainCycleVC(), animated: true)
    }

    @IBAction func goConbineTestVC() {
        present(CombineTestViewController(), animated: true)
    }
}


public class RetainCycleVC: UIViewController {
    var myView: MyView?

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        myView = MyView(self)
        打印()
    }

    func 打印() {
        for i in 0...1000000 {
            print(i)
        }
    }

    deinit {

    }
}

class MyView: UIView {
    let name = "ChildrenVC"
    var retainCycleVC: UIViewController?
    init(_ vc: UIViewController) {
        retainCycleVC = vc
        super.init(frame: vc.view.frame)
        backgroundColor = .orange
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {

    }
}


@objc public protocol ViewControlDelegate: AnyObject {
    @objc optional func increment(forCount count: Int) -> Int
}

extension ViewController: ViewControlDelegate {
    func increment(forCount count: Int) -> Int {
        print(count)
        return 20
    }
}

