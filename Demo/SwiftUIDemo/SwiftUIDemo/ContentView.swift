//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Hunter on 2025/7/10.
//

import SwiftUI

/*
 查看以下View：
 State_BindingSampleView
 State_ObservedObject
 EnvironmentObjectTest

 会了解到
 @State @Binding @StateObject @ObservedObject @EnvironmentObject @Environment 的差别，底层机制以及使用场景。
 同时了解到SwiftUI 遵循 Single Source of Truth 的原则以及View的差异化更新机制，同时会了解到Combine的ObservableObject观察机制性能问题以及替代方案。

 使用场景总结，简单说：
 场景    推荐使用
 视图需要创建并管理自己的数据模型    @StateObject
 从父视图接收已存在的数据模型       @ObservedObject
 在整个视图层级中共享数据模型       @EnvironmentObject
 访问系统或框架预定义的环境值       @Environment
 管理简单的视图内部状态            @State
 父子视图双向通信                 @Binding
 当项目支持iOS17+以后，可以使用 @Observable 去代替 ObservableObject。

 以上参考deepseek和自己debug以及部分博客总结。
 */

struct ContentView: View {
    @State private var showRealName = false
    var body: some View {
      NavigationView {
        VStack {
          Button("Toggle Name") {
            showRealName.toggle()
          }
          Text("Current User: \(showRealName ? "Wei Wang" : "onevcat")")
          NavigationLink("Next", destination: ScorePlate().padding(.top, 20))
        }
      }
    }
}

class Model: ObservableObject {
    init() { print("Model Created") }
    @Published var score: Int = 0
}

struct ScorePlate: View {

    @EnvironmentObject var model: Model
    @State private var niceScore = false

    var body: some View {
        VStack {
            Button("+1") {
                if model.score > 3 {
                    niceScore = true
                }
                model.score += 1
            }
            Text("Score: \(model.score)")
            Text("Nice? \(niceScore ? "YES" : "NO")")
            ScoreText(model: model).padding(.top, 20)
        }
    }
}

struct ScoreText: View {
    @ObservedObject var model: Model

    var body: some View {
        if model.score > 10 {
            return Text("Fantastic")
        } else if model.score > 3 {
            return Text("Good")
        } else {
            return Text("Ummmm...")
        }
    }
}
