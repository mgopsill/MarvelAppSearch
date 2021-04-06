//
//  FavouritesListViewModel.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxCocoa
import RxSwift

protocol FavouritesListViewModelProtocol {
    var inputs: FavouritesListViewModel.Inputs { get }
    var outputs: FavouritesListViewModel.Outputs { get }
}

struct FavouritesListViewModel: FavouritesListViewModelProtocol {
    let inputs: Inputs
    let outputs: Outputs
    
    struct Inputs {
        let selectCharacter: AnyObserver<MarvelCharacter>
        let deleteIndexPath: AnyObserver<IndexPath>
        let viewWillAppear: AnyObserver<Void>
    }
    
    struct Outputs {
        let characters: Driver<[MarvelCharacter]>
        let didSelectCharacter: Driver<MarvelCharacter>
    }
    
    init(favouritesManager: FavouritesManagerProtocol = FavouritesManager(defaults: UserDefaults.standard)) {
        let selectCharacterSubject = PublishSubject<MarvelCharacter>()
        let deleteSubject = PublishSubject<IndexPath>()
        let viewWillAppearSubject = PublishSubject<Void>()
        
        let deleted = deleteSubject
            .map { favouritesManager.favouriteCharacters[$0.row] }
            .do { character in
                favouritesManager.removeFavourite(character: character)
            }
        
        let refreshCharacters = Observable
            .merge(viewWillAppearSubject, deleted.map { _ in })
            .map { _ in favouritesManager.favouriteCharacters }
        
        inputs = Inputs(selectCharacter: selectCharacterSubject.asObserver(),
                        deleteIndexPath: deleteSubject.asObserver(),
                        viewWillAppear: viewWillAppearSubject.asObserver())
        outputs = Outputs(characters: refreshCharacters.asDriver(onErrorJustReturn: []),
                          didSelectCharacter: selectCharacterSubject.asDriver(onErrorJustReturn: .empty))
    }
}
