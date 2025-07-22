//
//  AppDelegate.swift
//  UIKitDemo
//
//  Created by Hunter on 2025/6/24.
//

import UIKit

// iOS开发UI篇—程序启动原理和UIApplication https://www.cnblogs.com/wendingding/p/3766347.html
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

// iOS开发UI篇—UIWindow简单介绍 https://www.cnblogs.com/wendingding/p/3770052.html

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

