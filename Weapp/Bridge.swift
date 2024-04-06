//
//  Bridge.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import UIKit
import SwiftUI
import JavaScriptCore
import WebKit

class Bridge: NSObject {
    let isRoot: Bool
    let id = UUID().uuidString
    let webView: WKWebView
    let jscore: JSCore
    weak var parent: MiniAppSandbox?
    let page: String
    let pages: [String]
    let appInfo: [String: Any]

    var uiLoaded = false
    var logicLoaded = false

    init(isRoot: Bool, webview: WKWebView, jscore: JSCore, parent: MiniAppSandbox, pages: [String], page: String, appInfo: [String: Any]) {
        self.isRoot = isRoot
        self.webView = webview
        self.jscore = jscore
        self.parent = parent
        self.pages = pages
        self.page = page
        self.appInfo = appInfo

        super.init()

        webview.configuration.userContentController.add(self, name: "ui")
    }

    func start() {
        guard let parent = parent else { return }

        if isRoot {
            guard let url = URL(string: parent.appInfo.path), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

            sendUIMessage(payload: [
                "type": "loadResource",
                "body": [
                    "appId": parent.appInfo.appId,
                    "pagePath": components.path,
                    "query": components.query
                ]
            ])

            sendLogicMessage(payload: [
                "type": "loadResource",
                "body": [
                    "appId": parent.appInfo.appId,
                    "pages": self.pages,
                    "bridgeId": id
                ]
            ])
        } else {
            guard let url = URL(string: page), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

            sendUIMessage(payload: [
                "type": "loadResource",
                "body": [
                    "appId": parent.appInfo.appId,
                    "pagePath": components.path,
                    "query": components.query
                ]
            ])
        }
    }

    func sendLogicMessage(payload: [String: Any]) {
        jscore.sendMessage(payload: payload)
    }

    func sendUIMessage(payload: [String: Any]) {
        guard let json = try? JSONSerialization.data(withJSONObject: payload), let jsonStr = String(data: json, encoding: .utf8) else {
            return
        }
//        print("send ui message:", jsonStr)
        webView.evaluateJavaScript("onMessage(\(jsonStr))")
    }

    func onReceveUIMessage(payload: [String: Any]) {
        guard let type = payload["type"] as? String, let body = payload["body"] as? [String: Any] else { return }

        if type == "uiResourceLoaded" {
            uiLoaded = true

            if isRoot && logicLoaded || !isRoot {
                createApp()
            }
        } else if type == "moduleCreated" {
            createPageInstance(body)
        } else if type == "moduleMounted" {
            sendLogicMessage(payload: payload)
        } else if type == "triggerEvent" {
            sendLogicMessage(payload: payload)
        }
    }

    func onReceiveLogicMessage(payload: [String: Any]) {
        guard let parent = parent else { return }
        guard let type = payload["type"] as? String, let body = payload["body"] as? [String: Any] else { return }

        if let bridgeId = (body["bridgeId"] as? String), bridgeId == id {
            if type == "logicResourceLoaded" {
                logicLoaded = true

                if uiLoaded {
                    createApp()
                }
            } else if type == "appIsCreated" {
                notifyMakeInitialData()
            } else if type == "initialDataIsReady" {
                if let initialData = body["initialData"] as? [String: Any], let pagePath = body["pagePath"] as? String {
                    let pagePath = isRoot ? pagePath : page
                    guard let url = URL(string: pagePath), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

                    sendUIMessage(payload: [
                        "type": "setInitialData",
                        "body": [
                            "initialData": initialData, // 自定义组件时，考虑不一样的数据
                            "pagePath": components.path,
                            "query": components.queryItems?.convert(),
                            "bridgeId": bridgeId
                        ]
                    ])
                }
            } else if type == "updateModule" {
                sendUIMessage(payload: payload)
            } else if type == "pauseVideo" {
                sendUIMessage(payload: payload)
            } else if type == "playVideo" {
                sendUIMessage(payload: payload)
            }
        }

        if type == "triggerWXAPI" {
            if let lastBridge = parent.bridgeList.last, lastBridge == self {
                parent.handleWXAPI(body)
            }
        }
    }

    func createApp() {
        guard let parent = parent else { return }

        let pagePath = isRoot ? parent.appInfo.path : page
        guard let url = URL(string: pagePath), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        sendLogicMessage(payload: [
            "type": "createApp",
            "body": [
                "bridgeId": id,
                "pagePath": components.path,
                "query": components.query
            ]
        ])
    }

    func createPageInstance(_ body: [String: Any]) {
        guard let id = body["id"] as? String, let path = body["path"] as? String, let query = body["query"] else { return }

        sendLogicMessage(payload: [
            "type": "createPageInstance",
            "body": [
                "id": id,
                "path": path,
                "query": query,
                "bridgeId": self.id
            ]
        ])
    }

    func notifyMakeInitialData() {
        guard let parent = parent else { return }

        guard let url = URL(string: parent.appInfo.path), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        sendLogicMessage(payload: [
            "type": "makePageInitialData",
            "body": [
                "bridgeId": id,
                "pagePath": components.path,
                "query": components.query
            ]
        ])
    }
}

extension Bridge: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "ui":
            if let payload = message.body as? [String: Any] {
                onReceveUIMessage(payload: payload)
            }
        default:
            break
        }
    }
}

extension Bridge: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == self.webView {
            openView()
        }
    }
}

extension Bridge {
    private func openView() {
        guard let parent = parent else { return }
        
        let view = WeWebView(webView: self.webView).ignoresSafeArea()
        let vc = UIHostingController(rootView: view, ignoreSafeArea: true)

        vc.additionalSafeAreaInsets = .zero

        let path = isRoot ? parent.appInfo.path : page

        guard let url = URL(string: path), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        guard let pages = appInfo["modules"] as? [String: Any] else { return }

        guard let config = pages[components.path] as? [String: Any] else { return }

        vc.navigationItem.backBarButtonItem?.tintColor = .black
        vc.navigationItem.backButtonTitle = ""
        vc.navigationItem.title = config["navigationBarTitleText"] as? String ?? ""

        if isRoot {
            parent.miniNavigationController?.setViewControllers([vc], animated: false)
        } else {
            parent.miniNavigationController?.pushViewController(vc, animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webView.evaluateJavaScript("""
                            const viewportWidth = window.innerWidth || document.documentElement.clientWidth;
                            const rootFontSize = viewportWidth / 750;
                            const rootTag = document.querySelector('html');
                            rootTag.style.fontSize = rootFontSize + 'px';
            """)
        }

        self.start()
    }
}


extension Bridge: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sendLogicMessage(payload: [
            "type": "pageScroll",
            "body": [
                "bridgeId": id,
                "offsetY": scrollView.contentOffset.y
            ]
        ])
    }
}

extension [URLQueryItem] {
    func convert() -> [String: Any] {
        var dict: [String: Any] = [:]

        for item in self {
            dict[item.name] = item.value
        }

        return dict
    }
}

// 网上找来的，这可以忽略安全区域
extension UIHostingController {
    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)

        if ignoreSafeArea {
            disableSafeArea()
        }
    }

    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }

        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }

            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }

            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
