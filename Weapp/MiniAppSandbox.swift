//
//  MiniAppSandbox.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import UIKit
import SwiftUI
import WebKit

struct WeWebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Do nothing
    }
}

class MiniAppSandbox: NSObject {

    var jscore: JSCore?

    let appInfo: AppInfo
    var bridgeList: [Bridge] = []

    var miniNavigationController: UINavigationController?

    var detailInfo: [String: Any]?

    init(appInfo: AppInfo) {
        self.appInfo = appInfo
        super.init()

        let jscore = JSCore(parent: self)
        self.jscore = jscore

        let view = LoadingView(appInfo: appInfo)

        let miniNavigationController = WeNavigation.showFullScreen(view) {
            self.initApp()
        }
        self.miniNavigationController = miniNavigationController
    }

    func viewDidLoad() {
        initPageFrame()
    }

    func initApp() {
        // 拉去小程序资源
        // 读取配置文件
        // 设置状态栏颜色模式
        // 创建通信桥
        // 触发应用的初始化逻辑
        // 隐藏加载页面

        Task {
            let info = await readFile(appId: appInfo.appId)
            self.detailInfo = info

            DispatchQueue.main.async {
                self.createWebView(info)
            }
        }
    }

    func createWebView(_ info: [String: Any]) {
        guard let appInfo = info["app"] as? [String: Any] else { return }
        guard let pages = appInfo["pages"] as? [String] else { return }

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.isInspectable = true

        let url = URL(string: "https://weapp-frame.oss-cn-shanghai.aliyuncs.com/ui/pageframe.html")
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webview.load(request)

        guard let jscore = jscore else { return }
        let entryPageBridge = Bridge(isRoot: true, webview: webview, jscore: jscore, parent: self, pages: pages, page: "", appInfo: info)
        webview.navigationDelegate = entryPageBridge
        webview.scrollView.delegate = entryPageBridge

        self.bridgeList.append(entryPageBridge)
    }

    func onMessage(payload: [String: Any]) {
        for bridge in bridgeList {
            bridge.onReceiveLogicMessage(payload: payload)
        }
    }

    func sendMessage(payload: [String: Any]) {
        self.jscore?.sendMessage(payload: payload)
    }

    func initPageFrame() {

    }

    private func readFile(appId: String) async -> [String: Any] {
        // 1. 指定API的URL
        let urlString = "https://weapp-frame.oss-cn-shanghai.aliyuncs.com/\(appId)/config.json"

        // 2. 创建URL对象
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return [:]
        }

        do {
            // 3. 创建URLSession对象
            let (data, response) = try await URLSession.shared.data(from: url)

            // 4. 检查响应是否为HTTP响应
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return [:]
            }

            // 5. 检查响应状态码是否为200（成功）
            guard httpResponse.statusCode == 200 else {
                print("HTTP status code: \(httpResponse.statusCode)")
                return [:]
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Failed to convert JSON data")
                return [:]
            }

            return json
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }

        return [:]
    }
}

extension MiniAppSandbox {
    func handleWXAPI(_ body: [String: Any]) {
        guard let apiName = body["apiName"] as? String else { return }

        if apiName == "navigateTo" {
            guard let params = body["params"] as? [String: Any] else { return }
            navigateTo(params: params)
        } else if apiName == "navigateBack" {
            navigateBack()
        }
    }

    func navigateTo(params: [String: Any]) {
        guard let urlStr = params["url"] as? String else { return }

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.isInspectable = true

        let url = URL(string: "https://raw.githubusercontent.com/shenxiang11/WeApp/main/Weapp/ui/pageframe.html")
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webview.load(request)

        guard let jscore = jscore, let detailInfo = detailInfo else { return }
        let bridge = Bridge(isRoot: false, webview: webview, jscore: jscore, parent: self, pages: [], page: urlStr, appInfo: detailInfo)
        webview.navigationDelegate = bridge
        webview.scrollView.delegate = bridge
        self.bridgeList.append(bridge)
    }

    func navigateBack() {
        let bridge = self.bridgeList.last

        bridge?.webView.stopLoading()
        bridge?.webView.navigationDelegate = nil
        bridge?.webView.scrollView.delegate = nil
        bridge?.webView.removeFromSuperview()

        self.bridgeList.removeLast()

        miniNavigationController?.popViewController(animated: true)
    }
}
