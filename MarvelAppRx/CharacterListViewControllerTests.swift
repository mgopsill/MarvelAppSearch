//
//  CharacterListViewControllerTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 04/04/2021.
//

import RxCocoa
import RxSwift
import SnapshotTesting
import XCTest

@testable import MarvelAppRx

final class CharacterListViewControllerTests: XCTestCase {
    func testEmptyList() {
        let subject = CharacterListViewController(viewModel: MockCharacterListViewModel(), imageProvider: MockImageProvider())
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testEmptyListDarkMode() {
        let subject = CharacterListViewController(viewModel: MockCharacterListViewModel(), imageProvider: MockImageProvider())
        subject.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testCharactersInList() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)")}
        let mockViewModel = MockCharacterListViewModel(marvelCharacters: .just(characters))
        let subject = CharacterListViewController(viewModel: mockViewModel, imageProvider: MockImageProvider())
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testCharactersInListDarkMode() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)") }
        let mockViewModel = MockCharacterListViewModel(marvelCharacters: .just(characters))
        let subject = CharacterListViewController(viewModel: mockViewModel, imageProvider: MockImageProvider())
        subject.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testSearchBar() {
        let subject = CharacterListViewController(viewModel: MockCharacterListViewModel(), imageProvider: MockImageProvider())
        let navigationController = UINavigationController(rootViewController: subject)
        assertSnapshot(matching: navigationController, as: .image)
    }
    
    func testSearchBarDarkMode() {
        let subject = CharacterListViewController(viewModel: MockCharacterListViewModel(), imageProvider: MockImageProvider())
        subject.overrideUserInterfaceStyle = .dark
        let navigationController = UINavigationController(rootViewController: subject)
        navigationController.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: navigationController, as: .image)
    }
}

final class MockCharacterListViewModel: CharacterListViewModelProtocol {
    let inputs: CharacterListViewModel.Inputs
    let outputs: CharacterListViewModel.Outputs
    
    init(marvelCharacters: Driver<[MarvelCharacter]> = .just([]),
         didSelectCharacter: Driver<MarvelCharacter> = .never()) {
        inputs = CharacterListViewModel.Inputs(search: BehaviorSubject<String?>(value: nil).asObserver(),
                                               selectCharacter: PublishSubject<MarvelCharacter>().asObserver())
        outputs = CharacterListViewModel.Outputs(marvelCharacters: marvelCharacters,
                                                 didSelectCharacter: didSelectCharacter)
    }
}
