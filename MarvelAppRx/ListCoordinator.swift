//
//  ListCoordinator.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import RxSwift
import UIKit

final class ListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    private let disposeBag = DisposeBag()
    private let router: Router
    private let characterListViewModel: CharacterListViewModelProtocol
    private let characterDetailViewModel: DetailViewModelBuilder
    private let urlOpener: URLOpener
    
    init(router: Router,
         characterListViewModel: CharacterListViewModelProtocol = CharacterListViewModel(),
         characterDetailViewModel: @escaping DetailViewModelBuilder = { character in CharacterDetailViewModel(character: character) },
         urlOpener: URLOpener = UIApplication.shared) {
        self.router = router
        self.characterListViewModel = characterListViewModel
        self.characterDetailViewModel = characterDetailViewModel
        self.urlOpener = urlOpener
    }
    
    func start() {
        let listViewController = CharacterListViewController(viewModel: characterListViewModel)

        characterListViewModel.outputs.didSelectCharacter
            .drive(onNext: { [unowned self] character in
                self.presentCharacterDetail(for: character) {
                    listViewController.reloadData()
                }
            }).disposed(by: disposeBag)
        
        router.pushViewController(listViewController, animated: false)
    }
    
    func presentCharacterDetail(for character: MarvelCharacter, onDismiss: (() -> Void)? = nil) {
        let viewModel = characterDetailViewModel(character)
        
        viewModel.output.buttonTapped.drive(onNext: { [unowned self] url in
            guard let url = url else { return }
            if self.urlOpener.canOpenURL(url) {
                self.urlOpener.open(url, options: [:], completionHandler: nil)
            }
        }).disposed(by: disposeBag)
        
        let viewController = CharacterDetailViewController(viewModel: viewModel, onDismiss: onDismiss)
        router.present(viewController, animated: true, completion: nil)
    }
}
