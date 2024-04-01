//
//  WeWrapper.swift
//  Weapp
//
//  Created by 香饽饽zizizi on 2024/3/30.
//

import SwiftUI

struct WeWrapper<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 0) {
                    Button {

                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .frame(width: 44)
                    .foregroundStyle(.black)

                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 1, height: 18)

                    Button {
                        WeNavigation.getCurrentNavigationController()?.dismiss(animated: true)
                    } label: {
                        Image(systemName: "smallcircle.filled.circle")
                    }
                    .frame(width: 44)
                    .foregroundStyle(.black)
                }
                .frame(height: 32)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                        .stroke(.secondary)
                }
                .padding(6)
            }
    }
}

#Preview {
    WeWrapper {
        Text("123123")
    }
}
