//
//  State&ObservedObject.swift
//  CoreDataDemo
//
//  Created by Hunter on 2025/7/10.
//

import SwiftUI
import Combine

/*
 核心区别

 特性    @StateObject    @ObservedObject
 所有权    视图拥有对象    视图仅观察外部传入的对象
 生命周期    与视图生命周期一致    依赖外部所有者
 初始化位置    在视图内部创建    由外部传入
 视图重建时行为    对象保持不变    可能重新创建对象
 适用场景    视图需要长期持有的数据模型    观察父视图传入的数据模型
 */

// 遵循 ObservableObject 的计时器模型
class TimerData: ObservableObject {
    @Published var count: Int = 0
    @Published var name = "Hunter"
    private var timer: AnyCancellable?

    init() {
        print("TimerData 初始化")
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.count += 1
            }
    }

    deinit {
        timer?.cancel()
        print("TimerData 销毁")
    }
}

struct StateObjectExample: View {
    // 视图创建并拥有 TimerData 实例
    @StateObject private var timerData = TimerData() // 视图重建时（重新求值）（重新求值拓展：如果视图的状态值改变，SwfitUI会对Body进行刷新，进行差异化求值，此时会对body内的View进行重建，每个View都会再次进行初始化，如果此View的属性值有变化，此View也会继续重建，会继续走body体进行重新求值。）， @StateObject修饰的实例不会重新创建，**只初始化一次（和 @State 一样，其存储区域在Struct之外，所以会在视图的第一次出现初始化时，只初始化一次。像 View 的 appear, disapear一样，视图重建不会受到影响。）**。适用场景：视图需要长期持有的数据模型。
    @State private var toggleState = false

    init() {
        print("StateObject 视图init")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("StateObject 示例")
                .font(.title)

            Text("计数:fdsfsd")
                .font(.largeTitle)

            Button("切换视图状态") {
                toggleState.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            // 状态变化时重建子视图
            if toggleState {
                Text("视图状态已改变")
                    .transition(.opacity)
            }
        }
        .padding()
        .onAppear {
            print("StateObject 视图出现")
        }
        .onDisappear {
            print("StateObject 视图消失")
        }
    }
}

struct ObservedObjectExample: View {
    init(timerData: TimerData) {
        self.timerData = timerData
        print("ObservedObject 视图init(timerData:)")
    }
    // 从外部接收 TimerData 实例
    @ObservedObject var timerData: TimerData // ObservedObject 视图重建时，会重新创建(初始化)对象。适用场景：观察父视图传入的数据模型，实例生命周期所有权依赖外部所有者。（在这个示例中，如果这里View自己创建timerData的话，View的重建同时timerData也会重建。可以把以上代码换成 `@ObservedObject var timerData = TimerData() ` 试试。）
    @State private var toggleState = false

    var body: some View {
        VStack(spacing: 20) {
            Text("ObservedObject 示例")
                .font(.title)

            Text("计数: \(timerData.count)")
                .font(.largeTitle)

            Button("切换视图状态") {
                toggleState.toggle()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

            // 状态变化时重建子视图
            if toggleState {
                Text("视图状态已改变")
                    .transition(.opacity)
            }
        }
        .padding()
        .onAppear {
            print("ObservedObject 视图出现")
        }
        .onDisappear {
            print("ObservedObject 视图消失")
        }
    }
}

fileprivate struct NameView: View {
    @ObservedObject var timerData: TimerData // 注意：使用Combine的ObservableObject观察机制会有性能问题（ObservableObject无法提供属性粒度的订阅，在 SwiftUI 的 View 中，对 ObservableObject 的订阅是基于整个实例的，任何一个 @Published 属性发生改变，都会触发整个实例的 objectWillChange 发布者发出变化，进而导致所有订阅了这个对象的 View 进行重新求值。）。例如：这里TimerData实例拥有一个 @Published name属性，NameView 依赖TimerData，虽有TimerData 的 name属性没有改变，但是count属性改变也触发NameView的body进行重新求值。

    init(timerData: TimerData) { // init方法不断地打印，这是因为SwiftUI的差异化更新机制（没性能问题）。差异化更新不会无差别渲染。
        self.timerData = timerData
        print("NameView 视图init(timerData:)")
    }

    var body: some View {
        VStack {
            Text("NameView - name: \(timerData.name)") // 这里没有使用变化的属性（timerData的count），body还是会不断地计算。解决方案: 将 View 的 model 进行细粒度拆分(eg: NameView只接收name字符串)，或者使用  Observation 框架（ @Observable 语法简洁，且可以直接把观察对象向下传递，其只更新变化的属性相对应的View。但是要注意此API支持iOS17+）。关于这可参考：[深入理解 Observation - 原理，back porting 和性能]（https://onevcat.com/2023/08/observation-framework/）
            /*
             [@StateObject 和 @ObservedObject 的区别和使用](https://onevcat.com/2020/06/stateobject/)
             [iOS 17：告别ObservableObject，迎来@Observable](https://www.cnblogs.com/ZJT7098/p/17780166.html)
             [iOS26适配指南之@Observable Object](https://jishuzhan.net/article/1937067385332215810)
             [Swift 5.9 新 @Observable 对象在 SwiftUI 使用中的陷阱与解决](https://zhuanlan.zhihu.com/p/1919696366772424862)
             */
        } .onAppear {
            print("NameView 视图出现")
        }
        .onDisappear {
            print("NameView 视图消失")
        }
    }
}

struct State_ObservedObject: View {
    @StateObject private var sharedTimer = TimerData()
    @State private var showExamples = false {
        didSet {
            print("showExamples changed to \(showExamples)")
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Button(showExamples ? "隐藏示例" : "显示示例") {
                    withAnimation {
                        showExamples.toggle()
                    }
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(8)

                if showExamples {
                    VStack(spacing: 40) {
                        // StateObject 示例 - 自己创建实例
                        StateObjectExample()
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)

                        Divider()

                        // ObservedObject 示例 - 传入共享实例
                        ObservedObjectExample(timerData: sharedTimer)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .transition(.move(edge: .bottom))
                }

                Spacer()

                NameView(timerData: sharedTimer)

                Spacer()
            }
            .padding()
            .navigationTitle("状态管理对比")
        }
    }
}

struct State_ObservedObject_Previews: PreviewProvider {
    static var previews: some View {
        State_ObservedObject()
    }
}
