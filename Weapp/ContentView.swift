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
                    let appInfo = AppInfo(appId: "meituan", name: "美团", logo: "https://s3plus.meituan.net/v1/mss_e2821d7f0cfe4ac1bf9202ecf9590e67/cdn-prod/file:9528bfdf/20201023%E7%94%A8%E6%88%B7%E6%9C%8D%E5%8A%A1logo/%E7%BE%8E%E5%9B%A2app.png", path: "pages/home/index?a=1&b=2")
                    // path 后续支持参数
                    AppManger.openApp(info: appInfo)
                } label: {
                    Text("打开美团小程序")
                }

                Button {
                    let appInfo = AppInfo(appId: "jingdong", name: "京东", logo: "https://ts1.cn.mm.bing.net/th/id/R-C.8e130498abf4685d15ecb977869a5a39?rik=%2f%2bLRdQM48y8y0A&riu=http%3a%2f%2fwww.xiue.cc%2fwp-content%2fuploads%2f2017%2f09%2fjd.jpg&ehk=hUzDTV9xjw%2flaGD5eZcKGl%2fN7UkzBSHRjo73I%2bMeVvo%3d&risl=&pid=ImgRaw&r=0", path: "pages/home/index")
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
