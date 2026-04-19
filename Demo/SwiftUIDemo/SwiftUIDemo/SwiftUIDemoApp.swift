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
//            ContentView().environmentObject(Model())
            InfiniteBannerView()
        }
    }
}


struct InfiniteBannerView: View {
    let images = ["banner1", "banner2", "banner3"]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .clipped()
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
}

