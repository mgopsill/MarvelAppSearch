//
//  FavouritesListViewControllerTests.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 05/04/2021.
//

import RxCocoa
import RxSwift
import SnapshotTesting
import XCTest

@testable import MarvelAppRx

final class FavouritesListViewControllerTests: XCTestCase {
    func testEmptyList() {
        let subject = FavouritesListViewController(viewModel: MockFavouritesListViewModel(), imageProvider: MockImageProvider())
        let navigationController = UINavigationController(rootViewController: subject)
        assertSnapshot(matching: navigationController, as: .image)
    }
    
    func testEmptyListDarkMode() {
        let subject = FavouritesListViewController(viewModel: MockFavouritesListViewModel(), imageProvider: MockImageProvider())
        subject.overrideUserInterfaceStyle = .dark
        let navigationController = UINavigationController(rootViewController: subject)
        navigationController.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: navigationController, as: .image)
    }
    
    func testCharactersInList() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)")}
        let mockViewModel = MockFavouritesListViewModel(characters: .just(characters))
        let subject = FavouritesListViewController(viewModel: mockViewModel, imageProvider: MockImageProvider())
        let navigationController = UINavigationController(rootViewController: subject)
        assertSnapshot(matching: navigationController, as: .image)
    }
    
    func testCharactersInListDarkMode() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)") }
        let mockViewModel = MockFavouritesListViewModel(characters: .just(characters))
        let subject = FavouritesListViewController(viewModel: mockViewModel, imageProvider: MockImageProvider())
        subject.overrideUserInterfaceStyle = .dark
        let navigationController = UINavigationController(rootViewController: subject)
        navigationController.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: navigationController, as: .image)
    }
}

final class MockFavouritesListViewModel: FavouritesListViewModelProtocol {
    let inputs: FavouritesListViewModel.Inputs
    let outputs: FavouritesListViewModel.Outputs
    
    init(characters: Driver<[MarvelCharacter]> = .just([]),
         didSelectCharacter: Driver<MarvelCharacter> = .never()) {
        inputs = FavouritesListViewModel.Inputs(selectCharacter: PublishSubject<MarvelCharacter>().asObserver(),
                                                deleteIndexPath: PublishSubject<IndexPath>().asObserver(),
                                                viewWillAppear: PublishSubject<Void>().asObserver())
        outputs = FavouritesListViewModel.Outputs(characters: characters,
                                                  didSelectCharacter: didSelectCharacter)
    }
}
