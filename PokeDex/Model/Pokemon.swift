//
//  Pokemon.swift
//  PokeDex
//
//  Created by 翁廷豪 on 2024/6/13.
//

import Foundation

struct Pokemon: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    var weight: Float
    var height: Float
    let types: [TypeElement]
    let stats: [Stat]
    let abilities: [Ability]
    let sprites: Sprites
    let species: Species
    
    var type: String {
        types.map { $0.type.name }.joined(separator: ", ")
    }
    
    var hp: Int {
        stats.first { $0.stat.name == "hp" }?.baseStat ?? 0
    }
    
    var attack: Int {
        stats.first { $0.stat.name == "attack" }?.baseStat ?? 0
    }

    var defense: Int {
        stats.first { $0.stat.name == "defense" }?.baseStat ?? 0
    }

    var specialAttack: Int {
        stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0
    }

    var specialDefense: Int {
        stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 0
    }

    var speed: Int {
        stats.first { $0.stat.name == "speed" }?.baseStat ?? 0
    }

    // 默認初始化方法
    init() {
        self.id = 0
        self.name = ""
        self.weight = 0.0
        self.height = 0.0
        self.types = []
        self.stats = []
        self.abilities = []
        self.sprites = Sprites(frontDefault: "")
        self.species = Species(name: "", url: "")
    }

    static func ==(lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.weight == rhs.weight
            && lhs.height == rhs.height
            && lhs.types == rhs.types
            && lhs.stats == rhs.stats
            && lhs.abilities == rhs.abilities
            && lhs.sprites == rhs.sprites
            && lhs.species == rhs.species
    }

    struct TypeElement: Codable, Equatable {
        let type: NamedAPIResource
    }

    struct NamedAPIResource: Codable, Equatable {
        let name: String
    }

    struct Stat: Codable, Equatable {
        let baseStat: Int
        let stat: NamedAPIResource
        
        enum CodingKeys: String, CodingKey {
            case baseStat = "base_stat"
            case stat
        }
    }

    struct Ability: Codable, Equatable {
        let ability: NamedAPIResource
    }

    struct Sprites: Codable, Equatable {
        let frontDefault: String
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }

    struct Species: Codable, Equatable {
        let name: String
        let url: String
    }
}

struct PokemonResponse: Codable {
    let results: [PokemonResult]
    
    struct PokemonResult: Codable {
        let name: String
        let url: String
    }
}
