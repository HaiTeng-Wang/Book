//
//  ViewmodifierTest.swift
//  CoreDataDemo
//
//  Created by Hunter on 2025/7/10.
//

import SwiftUI

struct ViewmodifierTest: View {
    // 测试查看修饰符的顺序会影响最终的效果。每个修饰符都会创建一个新视图（原始视图不会被修改）。顺序敏感。
    var body: some View {
        Text("Debug")
            .border(Color.green)
            .frame(width: 100)
            .border(Color.red)
            .padding(.all, 10)
            .border(Color.orange)
            .frame(width:200)
            .border(Color.black)

    }
}

struct ViewmodifierTest_Previews: PreviewProvider {
    static var previews: some View {
        ViewmodifierTest()
    }
}
