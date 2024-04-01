//
//  LoadingView.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/29.
//

import SwiftUI

struct LoadingView: View {
    @State var appInfo: AppInfo

    @State private var isloading = false

    var body: some View {
        VStack(spacing: 30) {

            ZStack {
                AsyncImage(url: URL(string: appInfo.logo)) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                } placeholder: {
                    Circle().fill(.placeholder)
                        .frame(width: 60, height: 60)
                }

                Circle()
                    .stroke(.secondary)
                    .frame(width: 72, height: 72)
                    .overlay(alignment: .top) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                            .offset(y: -4)
                    }
                    .rotationEffect(isloading ? .degrees(360) : .degrees(0))
            }

            Text(appInfo.name)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                isloading.toggle()
            }
        }
    }
}

#Preview {
    LoadingView(appInfo: AppInfo(appId: "", name: "App", logo: "", path: ""))
}
