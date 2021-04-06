//
//  CharacterCellViewModel.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxCocoa
import RxSwift
import UIKit

final class CharacterCellViewModel {
    let output: Output
    
    struct Output {
        let name: Driver<String>
        let image: Driver<UIImage?>
        let isFavourite: Driver<Bool>
    }
    
    init(character: MarvelCharacter,
         imageProvider: ImageProviderProtocol = ImageProvider(),
         favourites: FavouritesManagerProtocol = FavouritesManager(defaults: UserDefaults.standard)) {
        output = Output(name: Driver.of(character.name),
                        image: imageProvider.image(for: character.imageURL).asDriver(onErrorJustReturn: nil),
                        isFavourite: Driver.of(favourites.favouriteCharacters.contains(character)))
    }
}
