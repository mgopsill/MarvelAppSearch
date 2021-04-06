//
//  FavouritesManager.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import Foundation

protocol FavouritesManagerProtocol {
    var favouriteCharacters: [MarvelCharacter] { get }
    func saveFavourite(character: MarvelCharacter)
    func removeFavourite(character: MarvelCharacter)
}

struct FavouritesManager: FavouritesManagerProtocol {
    let defaults: Defaults
    private let key = "favourites"
    
    var favouriteCharacters: [MarvelCharacter] {
        guard let data = defaults.value(forKey: key) as? Data,
              let favourites = try? JSONDecoder().decode([MarvelCharacter].self, from: data) else { return [] }
        return favourites
    }
    
    func saveFavourite(character: MarvelCharacter) {
        var favourites: [MarvelCharacter] = []
        if let data = defaults.value(forKey: key) as? Data,
           let savedFavourites = try? JSONDecoder().decode([MarvelCharacter].self, from: data) {
            favourites = savedFavourites
        }
        favourites.append(character)
        guard let encodedFavourites = try? JSONEncoder().encode(favourites) else { return }
        defaults.setValue(encodedFavourites, forKey: key)
    }
    
    func removeFavourite(character: MarvelCharacter) {
        guard let data = defaults.value(forKey: key) as? Data,
              var favourites = try? JSONDecoder().decode([MarvelCharacter].self, from: data) else { return }
        favourites.removeAll(where: { $0 == character })
        
        guard let encodedFavourites = try? JSONEncoder().encode(favourites) else { return }
        defaults.setValue(encodedFavourites, forKey: key)
    }
}
