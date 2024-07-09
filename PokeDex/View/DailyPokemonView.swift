//
//  DailyPokemonView.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

struct DailyPokemonView: View {
    @EnvironmentObject var viewModel: PokemonViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 20) {
                        if let pokemon = viewModel.dailyPokemon {
                            HStack {
                                Spacer()
                                if let typeImageName = getTypeImageName(for: pokemon.type) {
                                    Image(typeImageName)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .padding()
                                }
                            }
                            
                            if let url = URL(string: pokemon.sprites.frontDefault) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150, height: 150)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.blue, lineWidth: 2)
                                            )
                                            .shadow(radius: 10)
                                    case .failure:
                                        Image(systemName: "xmark.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150, height: 150)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.red, lineWidth: 2)
                                            )
                                            .shadow(radius: 10)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            Text("\(pokemon.name.capitalized)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            HStack(spacing: 30) {
                                VStack {
                                    Text("HP")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(pokemon.hp)")
                                        .font(.headline)
                                }
                                
                                VStack {
                                    Text("Type")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(pokemon.type.capitalized)
                                        .font(.headline)
                                }
                                
                                VStack {
                                    Text("Weight")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f kg", pokemon.weight))
                                        .font(.headline)
                                }
                                
                                VStack {
                                    Text("Height")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(String(format: "%.1f m", pokemon.height))
                                        .font(.headline)
                                }
                            }
                            .padding(.vertical)
                            
                            VStack(spacing: 20) {
                                HStack(spacing: 30) {
                                    VStack {
                                        Text("Defense")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(pokemon.defense)")
                                            .font(.headline)
                                    }
                                    
                                    VStack {
                                        Text("Special Attack")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(pokemon.specialAttack)")
                                            .font(.headline)
                                    }
                                }
                                
                                HStack(spacing: 30) {
                                    VStack {
                                        Text("Special Defense")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(pokemon.specialDefense)")
                                            .font(.headline)
                                    }
                                    
                                    VStack {
                                        Text("Speed")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("\(pokemon.speed)")
                                            .font(.headline)
                                    }
                                }
                            }
                            
                            VStack(spacing: 20) {
                                Text("Abilities")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                                Text(pokemon.abilities.map { $0.ability.name.capitalized }.joined(separator: ", "))
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        } else {
                            Text("載入中...")
                                .font(.largeTitle)
                                .padding()
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                }
                .navigationTitle("每日寶可夢")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if let pokemon = viewModel.dailyPokemon {
                            Button(action: {
                                if viewModel.isFavorite(pokemon: pokemon) {
                                    viewModel.removeFromFavorites(pokemon: pokemon)
                                } else {
                                    viewModel.addToFavorites(pokemon: pokemon)
                                }
                            }) {
                                Image(systemName: viewModel.isFavorite(pokemon: pokemon) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchDailyPokemon()
                }
            }
        }
    }
    
    func getTypeImageName(for type: String) -> String? {
        switch type.lowercased() {
        case "fire":
            return "fireTypeIcon"
        case "water":
            return "waterTypeIcon"
        case "grass":
            return "grassTypeIcon"
        // 增加其他屬性對應的圖案
        default:
            return nil
        }
    }
}
