//
//  HomeView.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: PokemonViewModel
    @State private var showingSortOptions = false
    @State private var isFirstLoad = true

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("搜尋寶可夢", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button(action: {
                        showingSortOptions.toggle()
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .padding()
                    }
                    .actionSheet(isPresented: $showingSortOptions) {
                        ActionSheet(
                            title: Text("排序方式"),
                            buttons: [
                                .default(Text("圖鑑編號由小至大")) { viewModel.sortOption = .idAscending },
                                .default(Text("圖鑑編號由大至小")) { viewModel.sortOption = .idDescending },
                                .default(Text("重量由輕至重")) { viewModel.sortOption = .weightAscending },
                                .default(Text("重量由重至輕")) { viewModel.sortOption = .weightDescending },
                                .default(Text("身高由低至高")) { viewModel.sortOption = .heightAscending },
                                .default(Text("身高由高至低")) { viewModel.sortOption = .heightDescending },
                                .cancel()
                            ]
                        )
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView("資料下載中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(viewModel.filteredPokemons) { pokemon in
                                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                                        VStack {
                                            if let url = URL(string: pokemon.sprites.frontDefault) {
                                                PokemonImageView(url: url)
                                                    .frame(width: 100, height: 100)
                                                    .background(Color.white)
                                                    .cornerRadius(10)
                                                    .shadow(radius: 5)
                                            } else {
                                                Image(systemName: "xmark.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 100, height: 100)
                                                    .background(Color.white)
                                                    .cornerRadius(10)
                                                    .shadow(radius: 5)
                                            }
                                            Text(pokemon.name.capitalized)
                                                .foregroundColor(.blue)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    }
                                    .id(pokemon.id)
                                }
                            }
                            .padding(.horizontal)
                            .refreshable {
                                viewModel.clearData()
                                viewModel.fetchPokemons()
                            }
                        }
                        .navigationTitle("寶可夢圖鑑")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            proxy.scrollTo(viewModel.filteredPokemons.first?.id, anchor: .top)
                                        }
                                    }) {
                                        Image(systemName: "arrow.up.to.line")
                                    }
                                    Button(action: {
                                        viewModel.clearData()
                                        viewModel.fetchPokemons()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                if isFirstLoad {
                    viewModel.fetchPokemons()
                    isFirstLoad = false
                }
                print("Pokemon list appeared with \(viewModel.pokemons.count) items")
            }
            .onChange(of: viewModel.searchText) { _ in
                viewModel.updateFilteredPokemons()
            }
            .onChange(of: viewModel.sortOption) { _ in
                viewModel.updateFilteredPokemons()
            }
        }
    }
}

struct PokemonImageView: View {
    @StateObject private var imageLoader: PokemonImageLoader
    
    init(url: URL) {
        _imageLoader = StateObject(wrappedValue: PokemonImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
        }
    }
}

class PokemonImageLoader: ObservableObject {
    @Published var image: Image? = nil
    private var url: URL
    
    init(url: URL) {
        self.url = url
        loadImage()
    }
    
    func loadImage() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
            }
        }.resume()
    }
}
