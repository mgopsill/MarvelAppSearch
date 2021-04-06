//
//  CharacterDetailViewModel.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxSwift
import RxCocoa

typealias DetailViewModelBuilder = (MarvelCharacter) -> CharacterDetailViewModelProtocol

protocol CharacterDetailViewModelProtocol {
    var input: CharacterDetailViewModel.Input { get }
    var output: CharacterDetailViewModel.Output { get }
}

struct CharacterDetailViewModel: CharacterDetailViewModelProtocol {
    let input: Input
    let output: Output
    
    struct Input {
        let buttonTap: AnyObserver<Void>
        let favouriteTap: AnyObserver<Bool>
    }
    
    struct Output {
        let characterImage: Driver<UIImage?>
        let characterName: Driver<String>
        let characterDescription: Driver<String>
        let buttonText: Driver<String>
        let buttonTapped: Driver<URL?>
        let isFavourite: Driver<Bool>
    }
    
    init(character: MarvelCharacter,
         imageProvider: ImageProviderProtocol = ImageProvider(),
         favouritesManager: FavouritesManagerProtocol = FavouritesManager(defaults: UserDefaults.standard)) {
        let buttonTapSubject = PublishSubject<Void>()
        let favouriteSubject = PublishSubject<Bool>()
        
        let characterImage = imageProvider.image(for: character.imageURL).asDriver(onErrorJustReturn: nil)
        let buttonTapped = buttonTapSubject.map { character.websiteURL }.asDriver(onErrorJustReturn: nil)
        
        let favourite = favouriteSubject
            .do(onNext: { isFavourite in
                if isFavourite {
                    favouritesManager.removeFavourite(character: character)
                } else {
                    favouritesManager.saveFavourite(character: character)
                }
            })
            .map { _ in favouritesManager.favouriteCharacters.contains(character) }
            .startWith(favouritesManager.favouriteCharacters.contains(character))
            .asDriver(onErrorJustReturn: true)
                
        input = Input(buttonTap: buttonTapSubject.asObserver(),
                      favouriteTap: favouriteSubject.asObserver())
        output = Output(characterImage: characterImage,
                        characterName: .just(character.name),
                        characterDescription: .just(character.description),
                        buttonText: .just("View Website for \(character.name)"),
                        buttonTapped: buttonTapped,
                        isFavourite: favourite)
    }
}
