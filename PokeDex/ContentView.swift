//
//  ContentView.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("主頁", systemImage: "house")
                }
            DailyPokemonView()
                .tabItem {
                    Label("每日寶可夢", systemImage: "star")
                }
            ChallengeView()
                .tabItem {
                    Label("寶可夢挑戰", systemImage: "gamecontroller")
                }
            ProfileView()
                .tabItem {
                    Label("個人", systemImage: "person")
                }
        }
        .environmentObject(viewModel)
    }
}


#Preview {
    ContentView()
}
