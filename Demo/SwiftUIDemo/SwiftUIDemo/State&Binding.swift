//
//  State&Binding.swift
//  CoreDataDemo
//
//  Created by Hunter on 2025/7/10.
//

import SwiftUI
/*

 SwiftUI 中的 @State 和 @Binding 是状态管理的核心工具，它们的内部实现基于 Swift 的属性包装器和响应式设计模式

 一、@State 和 @Binding 的内部实现
 1. @State 的底层机制

 存储位置：
 @State 的值实际由 SwiftUI 的框架层托管，存储在视图外部的某个独立内存区域（非视图结构体内部）。
 视图重建时，框架通过内部标识符（如 _Location）找回状态，确保数据不丢失。 // 关于这句话的理解，这里有个例子 [Swift 5.9 新 @Observable 对象在 SwiftUI 使用中的陷阱与解决](https://zhuanlan.zhihu.com/p/1919696366772424862)

 依赖追踪：
 SwiftUI 在渲染时构建一个 依赖图，记录哪些视图依赖哪些状态。
 当 @State 的值变化时，框架标记依赖它的视图为“脏”状态，触发 body 重新计算。
 - SwiftUI 的响应式更新机制:
   - 依赖图（Dependency Graph）
     SwiftUI 内部维护一个依赖图，跟踪所有状态（ @State、 @ObservedObject 等）与视图的关系。
     当状态变化时，依赖图中标记相关视图为“需要更新”。
  - 差异化比较（Diffing）
     视图的 body 重新计算后，SwiftUI 会比较新旧视图树，仅更新实际发生变化的部分。
     例如，只有 Text("Count: \(count)") 中的 count 变化时，仅该文本节点会刷新。

 线程安全：
 状态更新必须在主线程完成，确保 UI 操作的线程安全。

 伪代码实现：
 @propertyWrapper
 struct State<Value> {
     private var _value: Value
     private var _location: AnyLocation<Value>? // 指向框架托管的存储

     var wrappedValue: Value {
         get { _location?.value ?? _value }
         nonmutating set {
             _location?.value = newValue
             // 通知框架更新依赖此状态的视图
         }
     }

     init(wrappedValue: Value) {
         self._value = wrappedValue
         // 框架在此处将 _value 绑定到托管存储
     }
 }


 2. @Binding 的底层机制
  - 双向绑定：Binding 封装了“读”和“写”两个闭包，分别对应父视图状态的获取和修改。
  - 传递方式：通过 $ 符号（如 $isOn）将 @State 转换为 Binding，传递给子视图。
  - 自动更新：当子视图通过 Binding 修改值时，父视图的 @State 会更新，触发视图层级更新。

 伪代码实现：
 @propertyWrapper
 struct Binding<Value> {
     let get: () -> Value
     let set: (Value) -> Void

     var wrappedValue: Value {
         get { get() }
         nonmutating set { set(newValue) }
     }

     // 通过 $ 访问的 projectedValue
     var projectedValue: Binding<Value> { self }
 }

 双向绑定流程：
  1. 父视图的 @State 通过 $ 生成 Binding。
  2. 子视图通过 Binding 修改值时，实际调用父视图的 set 闭包。
  3. 父视图状态更新后，触发视图树更新。

 */

struct State_BindingSampleView: View {

    @State private var isOn: Bool = false
    @State private var text = "" /*
                                  这里（结构体的body内）之所以能改变text变量值，是因为： @State 的值实际由 SwiftUI 的框架层托管，存储在视图外部的某个独立内存区域（非视图结构体内部）
                                  所以text为：var text: String { get nonmutating set }
                                  如果这里不使用 @State，则text为 var text: String { get set }， 则body内无法改变text的值（body为some view类型的只读计算属性），编辑器会报错:Cannot assign to property: 'self' is immutable
                                  同时须知道：SwiftUI 遵循 Single Source of Truth 的原则，只有修改 View 所订阅的状态，才能改变 view tree 并触发对 body 的重新求值，进而刷新 UI。
                                  */

    var body: some View {
        Text("开关状态: \(isOn ? "开" : "关")") // 注意： 状态数据改变（例如，这里的isOn改变），会导致视图从新计算，有可能会导致非预期更新(例如，下一行代码会重新渲染。原因看下方的“S  UI差异化更新”)。 为了避免重新计算，我们可以拆分视图。如下 StaticView()。
        Text("Parent更新次数: \(Date().timeIntervalSince1970)")
        /*
         SwiftUI会进行"差异化更新"。
         三层机制
           1. 依赖标记阶段
                 当 View所订阅的状态变化时(如 @State)，SwiftUI 会标记 *整个* View(eg: 这里的State_BindingSampleView) 为脏状态（因为包含该状态的视图层级需要重新计算）
         ✅
           2. 差异化计算阶段
                 ✅ 我们可以打断点测试
                 SwiftUI会重新计算body，逐行访问body内的每一个View，会走View的init方法(拓展：须知道，每次差异化计算，会访问body内每个view的init方法，但是相应View的onApear，和onDisapear是不会再走的，只走一次。)，去对比View的属性或状态属性（拓展：须知道，状态修饰的属性的存储区域在View之外）的值是否发生改变，若发生改变，就去访问（计算）当前View的Body。
                 ❌ 小心出现预期外的更新。 例如这里，比较新旧树时发现Text("Parent更新次数...")的内容实际已变化（因为重新计算了Date()）
           3. 渲染阶段
                 最终只更新了屏幕上 *真正变化的部分（属性值变化的部分）*（例如：这里的开关状态文本和日期文本）
                 不会重新布局/绘制未变化的部分
         结论:
         SwiftUI会根据状态值的改变，进行差异化更新，需要主意重新计算导致了内容变化（ 例如这里的`Date()` ）。
         性能影响：计算body ≠ 重新渲染整个界面, 大量复杂视图的body计算仍会消耗CPU资源。
         */
        StaticView()
        ChildView(isOn: $isOn, text: $text) // 传递 Binding.
    }
}

// 静态子视图（不会更新）
fileprivate struct StaticView: View {
    var body: some View {
        Text("Parent更新次数: \(Date().timeIntervalSince1970)")
    }
//    static func == (lhs: Self, rhs: Self) -> Bool { true } // 也可以准寻Equatable，永远不更新。
}


fileprivate struct ChildView: View {
    @Binding var isOn: Bool
    @Binding var text: String

    var body: some View {
        Toggle("开关", isOn: $isOn)
        TextField("输入", text: $text)
    }
}

struct State_Binding_Previews: PreviewProvider {
    static var previews: some View {
        /*
         底层行为模拟:
         @State 初始化：isOn 被 SwiftUI 托管存储。
         Binding 传递：$isOn 生成一个 Binding<Bool>，内部包含读取和修改 isOn 的闭包。
         子视图修改值：当 Toggle 切换时，通过 Binding 的 set 闭包修改父视图的 @State。
         视图更新：父视图的 @State 变化触发 ParentView.body 重新计算，更新 Text 显示。
         */
        State_BindingSampleView()
    }
}
