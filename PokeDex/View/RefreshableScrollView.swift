//
//  RefreshableScrollView.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    let content: () -> Content
    let onRefresh: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                // Refresh Control
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    if frame.origin.y > 150 {
                        DispatchQueue.main.async {
                            onRefresh()
                        }
                    }
                    return Color.clear
                }
                .frame(height: 0)
                
                // Content
                content()
            }
        }
    }
}
