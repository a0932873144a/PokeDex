//
//  ProfileView.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: PokemonViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("volume") private var volume = 0.5
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("喜愛寶可夢")) {
                        ForEach(viewModel.favoritePokemons) { pokemon in
                            NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                                HStack {
                                    if let url = URL(string: pokemon.sprites.frontDefault) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 50, height: 50)
                                            case .failure:
                                                Image(systemName: "xmark.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 50, height: 50)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                    Text(pokemon.name.capitalized)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("寶可夢挑戰成績")) {
                        Text("最高答對題數: \(viewModel.challengeScore)")
                            .font(.headline)
                    }
                    
                    Section(header: Text("設定")) {
                        Toggle("暗色模式", isOn: $isDarkMode)
                            .onChange(of: isDarkMode) { value in
                                UIApplication.shared.windows.first?.rootViewController?.view.overrideUserInterfaceStyle = value ? .dark : .light
                            }
                        
                        HStack {
                            Text("音量")
                            Slider(value: $volume, in: 0...1)
                        }
                        
                        Button(action: {
                            viewModel.resetFavoritePokemons()
                        }) {
                            Text("清除喜愛寶可夢紀錄")
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            viewModel.resetChallengeScore()
                        }) {
                            Text("清除寶可夢挑戰成績紀錄")
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("個人資料")
            }
        }
    }
}
