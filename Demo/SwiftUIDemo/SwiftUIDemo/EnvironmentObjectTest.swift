//
//  EnvironmentObjectTest.swift
//  SwiftUIDemo
//
//  Created by Hunter on 2025/7/10.
//

import SwiftUI

// MARK: EnvironmentObject

// 1. 定义可观察对象
class AppSettings: ObservableObject {
    @Published var themeColor: Color = .blue
}

// 2. 在根视图注入
struct EnvironmentObjectTest: View {
    @StateObject var settings = AppSettings()

    var body: some View {
        ThemeView()
            .environmentObject(settings) // 注入
    }
}

// 3. 任意子视图直接访问
struct ThemeView: View {
    @EnvironmentObject var settings: AppSettings // 无需传递

    var body: some View {
        ColorPicker("主题色", selection: $settings.themeColor)
    }
}

struct EnvironmentObjectTest_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentObjectTest()
    }
}


// MARK: EnvironmentKey

// 1. 定义环境键
struct ThemeColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue
}

extension EnvironmentValues {
    var themeColor: Color {
        get { self[ThemeColorKey.self] }
        set { self[ThemeColorKey.self] = newValue }
    }
}

// 2. 在父视图设置
struct EnvironmentKeySuperView: View {
    @State private var color = Color.red

    var body: some View {
        EnvironmentKeyChildView()
            .environment(\.themeColor, color) // 设置环境值
    }
}

// 3. 子视图直接读取
struct EnvironmentKeyChildView: View {
    @Environment(\.themeColor) var color // 直接获取

    var body: some View {
        Rectangle()
            .fill(color)
    }
}
