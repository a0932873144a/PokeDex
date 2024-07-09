//
//  PokemonViewModel.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import SwiftUI

enum SortOption {
    case idAscending, idDescending, weightAscending, weightDescending, heightAscending, heightDescending
}

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var favoritePokemons: [Pokemon] = []
    @Published var dailyPokemon: Pokemon?
    @Published var challengeScore: Int = 0
    @Published var isDarkMode: Bool = false
    @Published var volume: Double = 0.5
    @Published var searchText: String = "" {
        didSet {
            updateFilteredPokemons()
        }
    }
    @Published var sortOption: SortOption = .idAscending {
        didSet {
            updateFilteredPokemons()
        }
    }
    
    @Published private(set) var filteredPokemons: [Pokemon] = []
    @Published var isLoading: Bool = false
    
    init() {
        fetchPokemons()
    }
    
    func updateFilteredPokemons() {
        let sortedPokemons = sortPokemons(pokemons, by: sortOption)
        if searchText.isEmpty {
            filteredPokemons = sortedPokemons
        } else {
            let filtered = sortedPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            filteredPokemons = filtered.sorted(by: { $0.id < $1.id })
        }
    }
    
    func fetchPokemons() {
        guard !isLoading else { return }
        isLoading = true
        pokemons.removeAll()
        filteredPokemons.removeAll()
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=300") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(PokemonResponse.self, from: data)
                    print("Fetched Pokemon list: \(result.results)")
                    let group = DispatchGroup()
                    for pokemon in result.results {
                        group.enter()
                        self.fetchPokemonDetail(url: pokemon.url) {
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        self.dailyPokemon = self.pokemons.randomElement()
                        self.updateFilteredPokemons()
                        self.isLoading = false
                        print("Finished fetching all Pokemon details")
                    }
                } catch {
                    print("Error decoding Pokemon list: \(error)")
                    self.isLoading = false
                }
            } else if let error = error {
                print("Error fetching Pokemon list: \(error)")
                self.isLoading = false
            }
        }.resume()
    }
    
    func fetchPokemonDetail(url: String, completion: @escaping () -> Void) {
        guard let detailUrl = URL(string: url) else { return }
        URLSession.shared.dataTask(with: detailUrl) { data, response, error in
            if let data = data {
                do {
                    var pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                    pokemon.weight = pokemon.weight / 10.0  // 將weight轉換為正確單位
                    pokemon.height = pokemon.height / 10.0  // 將height轉換為正確單位
                    DispatchQueue.main.async {
                        self.pokemons.append(pokemon)
                        print("Fetched Pokemon details: \(pokemon.name)")
                        completion()
                    }
                } catch {
                    print("Error decoding Pokemon details: \(error)")
                    completion()
                }
            } else if let error = error {
                print("Error fetching Pokemon details: \(error)")
                completion()
            }
        }.resume()
    }
    
    func fetchDailyPokemon() {
        self.dailyPokemon = pokemons.randomElement()
    }
    
    func addToFavorites(pokemon: Pokemon) {
        if !favoritePokemons.contains(where: { $0.id == pokemon.id }) {
            favoritePokemons.append(pokemon)
        }
    }
    
    func removeFromFavorites(pokemon: Pokemon) {
        if let index = favoritePokemons.firstIndex(where: { $0.id == pokemon.id }) {
            favoritePokemons.remove(at: index)
        }
    }
    
    func isFavorite(pokemon: Pokemon) -> Bool {
        return favoritePokemons.contains(where: { $0.id == pokemon.id })
    }
    
    func resetFavoritePokemons() {
        favoritePokemons.removeAll()
    }
    
    func resetChallengeScore() {
        challengeScore = 0
    }
    
    func sortPokemons(_ pokemons: [Pokemon], by option: SortOption) -> [Pokemon] {
        switch option {
        case .idAscending:
            return pokemons.sorted { $0.id < $1.id }
        case .idDescending:
            return pokemons.sorted { $0.id > $1.id }
        case .weightAscending:
            return pokemons.sorted { $0.weight < $1.weight }
        case .weightDescending:
            return pokemons.sorted { $0.weight > $1.weight }
        case .heightAscending:
            return pokemons.sorted { $0.height < $1.height }
        case .heightDescending:
            return pokemons.sorted { $0.height > $1.height }
        }
    }
    
    func clearData() {
        pokemons.removeAll()
        filteredPokemons.removeAll()
    }
}
