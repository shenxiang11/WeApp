//
//  JSCore.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import UIKit
import JavaScriptCore


@objc protocol NativeAPIExport: JSExport {
    func request(_ url: String, _ completionHandler: JSValue)

    // 接受 JS 消息
    func sendMessage(_ message: [String: Any])
}

class NativeAPI: NSObject, NativeAPIExport {
    var callback: ((_ message: [String: Any]) -> Void)?

    func sendMessage(_ message: [String: Any]) {
        callback?(message)
    }

    func request(_ url: String, _ completionHandler: JSValue) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    completionHandler.call(withArguments: [responseString, nil])
                } else if let error = error {
                    completionHandler.call(withArguments: [JSValue(undefinedIn: JSContext.current()), error.localizedDescription])
                }
            }.resume()
        } else {
            completionHandler.call(withArguments: [JSValue(undefinedIn: JSContext.current()), "Invalid URL"])
        }
    }
}

class JSCore {
    weak var parent: MiniAppSandbox?
    var worker: JSContext?

    deinit {
        print("\(self) 销毁")
    }

    init(parent: MiniAppSandbox) {
        self.parent = parent

        let context = JSContext()
        context?.isInspectable = true
        let nativeApi = NativeAPI()
        nativeApi.callback = onMessage
        context?.setObject(nativeApi, forKeyedSubscript: "NativeAPI" as NSString)
        self.worker = context

        // 请求 JS 文件内容
        Task {
            let jscontent = await getLogicSdk()
            context?.evaluateScript(jscontent)
        }
    }

    func onMessage(payload: [String: Any]) {
        self.parent?.onMessage(payload: payload)
    }

    func sendMessage(payload: [String: Any]) {
        // 给 JS 发送消息
        let sendMessage = worker?.objectForKeyedSubscript("nativeCall")
        sendMessage?.call(withArguments: [payload])
    }

    private func getLogicSdk() async -> String {
        guard let url = Bundle.main.url(forResource: "logic", withExtension: "js") else { return "" }
        guard let filecontent = try? String(contentsOf: url) else {
            print("!!!", "nonono")
            return ""
        }
        
        return filecontent
    }
}
