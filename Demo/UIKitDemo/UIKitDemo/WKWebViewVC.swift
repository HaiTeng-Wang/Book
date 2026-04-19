//
//  WKWebViewVC.swift
//  UIKitDemo
//
//  Created by Hunter on 2025/8/4.
//

import Foundation
import WebKit
/*
WKWebView与JS交互
ref: https://juejin.cn/post/7232299098242105403

-  JavaScript调用Swift, 可通过WKWebView提供了WKScriptMessageHandler协议，
 开发者可以通过实现该协议的userContentController(_:didReceive:)方法，来接收JavaScript代码通过postMessage方法发送过来的消息
    - JS给ios发消息`webkit.messageHandlers.nativeCallback.postMessage('js调用ios');`
    - iOS中，通过 通过WKUserContentController类调用add方法，通过js函数名去添加js函数；
      然后，将UserContentController赋值给WKWebViewConfiguration，webview使用这个配置；
      然后通过WKScriptMessageHandler中的`userContentController(didReceive message)`代理回调方法，接收JS相应函数调用的消息以及传递的数据。

- WKWebView提供了evaluateJavaScript(_:completionHandler:)方法，开发者可以通过这个方法执行JavaScript代码，并通过completionHandler获取执行结果
    - iOS中调用JS函数`webView.evaluateJavaScript("displayDate()")`
 */

class WKWebViewVC: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
     var webView: WKWebView!

    override func loadView() {
        let contentController = WKUserContentController();
        contentController.add(self, name: "nativeCallback")

        let config = WKWebViewConfiguration();
        config.userContentController = contentController;
        webView = WKWebView(frame: .zero, configuration: config);
        webView.navigationDelegate = self;
        view = webView;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: "http://127.0.0.1:8080")
        // luanch local server:
        //  1. cd /path/to/your/index.html folder
        //  2. python3 -m http.server 8080
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeCallback" {
//            if let msg = message.body as? String {
//                showAlert(message: msg)
//            }
            handleMessageFromJS(message.body)
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("displayDate()") { (any, error) in
            if (error != nil) {
                print(error ?? "err")
            }
        }
        let userInfo = ["name": "张三", "age": 30] as [String: Any]
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let js = "receiveUserInfo(\(jsonString))"
            webView.evaluateJavaScript(js) { (result, error) in
                if let error = error {
                    print("JS执行错误: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleMessageFromJS(_ message: Any) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) else {
            print("无法将消息转换为JSON数据")
            return
        }

        do {
            // 如果预期是特定结构，可以解码为模型对象
            let decoder = JSONDecoder()
            let user = try decoder.decode(JsUserData.self, from: jsonData)
            print("解码后的用户ID:", user.userId)
            print("用户名:", user.profile.name)

            // 更新UI必须在主线程
            DispatchQueue.main.async {
//                self.nameLabel.text = user.profile.name

                self.showAlert(message: "userID: \(user.userId) \n userName:\(user.profile.name)")
            }
        } catch {
            print("JSON解码错误:", error)
        }
    }

}

// 定义对应的模型结构
struct JsUserData: Codable {
    let userId: String
    let profile: Profile
    let settings: Settings
    let timestamp: TimeInterval

    struct Profile: Codable {
        let name: String
        let age: Int
        let hobbies: [String]
    }

    struct Settings: Codable {
        let darkMode: Bool
        let fontSize: Int
    }
}
