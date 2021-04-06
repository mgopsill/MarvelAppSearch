//
//  CharacterListViewModel.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import RxSwift
import RxCocoa

protocol CharacterListViewModelProtocol {
    var inputs: CharacterListViewModel.Inputs { get }
    var outputs: CharacterListViewModel.Outputs { get }
}

struct CharacterListViewModel: CharacterListViewModelProtocol {
    let inputs: Inputs
    let outputs: Outputs
    
    struct Inputs {
        let search: AnyObserver<String?>
        let selectCharacter: AnyObserver<MarvelCharacter>
    }
    
    struct Outputs {
        let marvelCharacters: Driver<[MarvelCharacter]>
        let didSelectCharacter: Driver<MarvelCharacter>
    }
    
    init(marvelAPI: @escaping (String) -> Observable<[MarvelCharacter]> = MarvelAPI.searchCharacters,
         scheduler: SchedulerType = MainScheduler.instance) {
        let searchInput = PublishSubject<String?>()
        let selectCharacterInput = PublishSubject<MarvelCharacter>()
        
        let characters = searchInput
            .compactMap { $0 }
            .debounce(.milliseconds(400), scheduler: scheduler)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .flatMapLatest { string in
                marvelAPI(string)
                    .startWith([]) // clears results on new search term
                    .asDriver(onErrorJustReturn: [])
            }
            .asDriver(onErrorJustReturn: [])
        
        inputs = Inputs(search: searchInput.asObserver(),
                        selectCharacter: selectCharacterInput.asObserver())
        outputs = Outputs(marvelCharacters: characters,
                          didSelectCharacter: selectCharacterInput.asDriver(onErrorJustReturn: .empty))
    }
}
