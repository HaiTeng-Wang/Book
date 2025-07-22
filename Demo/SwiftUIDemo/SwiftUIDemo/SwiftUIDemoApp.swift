//
//  SwiftUIDemoApp.swift
//  SwiftUIDemo
//
//  Created by Hunter on 2025/7/10.
//

import SwiftUI

@main
struct SwiftUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Model())
        }
    }
}
