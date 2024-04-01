//
//  ContentView.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import SwiftUI

struct AppInfo {
    let appId: String
    let name: String
    let logo: String
    let path: String
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 80) {
                Button {
                    let appInfo = AppInfo(appId: "douyin", name: "抖音", logo: "https://img.zcool.cn/community/0173a75b29b349a80121bbec24c9fd.jpg@1280w_1l_2o_100sh.jpg", path: "pages/home/index")
                    // path 后续支持参数
                    AppManger.openApp(info: appInfo)
                } label: {
                    Text("打开抖音小程序")
                }

                Button {
                    let appInfo = AppInfo(appId: "meituan", name: "美团", logo: "https://img.zcool.cn/community/0173a75b29b349a80121bbec24c9fd.jpg@1280w_1l_2o_100sh.jpg", path: "pages/home/index?a=1&b=2")
                    // path 后续支持参数
                    AppManger.openApp(info: appInfo)
                } label: {
                    Text("打开美团小程序")
                }

                Button {
                    let appInfo = AppInfo(appId: "jingdong", name: "京东", logo: "https://img.zcool.cn/community/0173a75b29b349a80121bbec24c9fd.jpg@1280w_1l_2o_100sh.jpg", path: "pages/home/index")
                    // path 后续支持参数
                    AppManger.openApp(info: appInfo)
                } label: {
                    Text("打开京东小程序")
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
