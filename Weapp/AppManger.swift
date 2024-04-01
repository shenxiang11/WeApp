//
//  AppManger.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import UIKit

// 管理多个小程序

class AppManger {
    static var appStack: [MiniAppSandbox] = []

    static func openApp(info: AppInfo) {
//        guard let url = URL(string: info.path), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
//        print(components.queryItems)

        let miniApp = MiniAppSandbox(appInfo: info)
        appStack.append(miniApp)

    }

    static func closeApp() {
        
    }
}

