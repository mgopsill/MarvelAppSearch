//
//  FavouritesCoordinator.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import RxSwift
import UIKit

final class FavouritesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    private let disposeBag = DisposeBag()
    private let router: Router
    private let favouritesListViewModel: FavouritesListViewModelProtocol
    private let characterDetailViewModel: DetailViewModelBuilder
    private let urlOpener: URLOpener
    
    init(router: Router,
         favouritesListViewModel: FavouritesListViewModelProtocol = FavouritesListViewModel(),
         characterDetailViewModel: @escaping DetailViewModelBuilder = { character in CharacterDetailViewModel(character: character) },
         urlOpener: URLOpener = UIApplication.shared) {
        self.router = router
        self.favouritesListViewModel = favouritesListViewModel
        self.characterDetailViewModel = characterDetailViewModel
        self.urlOpener = urlOpener
    }
    
    func start() {
        favouritesListViewModel.outputs.didSelectCharacter
            .drive(onNext: { [unowned self] character in
                self.pushCharacterDetail(for: character)
            }).disposed(by: disposeBag)
        
        let listViewController = FavouritesListViewController(viewModel: favouritesListViewModel)
        router.pushViewController(listViewController, animated: false)
    }
    
    func pushCharacterDetail(for character: MarvelCharacter) {
        let detailViewModel = characterDetailViewModel(character)
        
        detailViewModel.output.buttonTapped.drive(onNext: { [unowned self] url in
            guard let url = url else { return }
            if self.urlOpener.canOpenURL(url) {
                self.urlOpener.open(url, options: [:], completionHandler: nil)
            }
        }).disposed(by: disposeBag)
        
        let detailViewController =  CharacterDetailViewController(viewModel: detailViewModel)
        router.pushViewController(detailViewController, animated: true)
    }
}
