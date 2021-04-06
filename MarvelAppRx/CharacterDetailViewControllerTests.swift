//
//  CharacterDetailViewControllerTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 04/04/2021.
//

import RxCocoa
import RxSwift
import SnapshotTesting
import XCTest

@testable import MarvelAppRx

final class CharacterDetailViewControllerTests: XCTestCase {
        
    func testInNavigationController() {
        let mockViewModel = MockCharacterDetailViewModel()
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        let navigationController = UINavigationController(rootViewController: subject)
        assertSnapshot(matching: navigationController, as: .image)
    }
    
    func testIsFavourite() {
        let mockViewModel = MockCharacterDetailViewModel(isFavourite: .just(false))
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testIsNotFavourite() {
        let mockViewModel = MockCharacterDetailViewModel()
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testInNavigationControllerDarkMode() {
        let mockViewModel = MockCharacterDetailViewModel()
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        subject.overrideUserInterfaceStyle = .dark
        let navigationController = UINavigationController(rootViewController: subject)
        navigationController.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: navigationController, as: .image)
    }
    
    func testIsFavouriteDarkMode() {
        let mockViewModel = MockCharacterDetailViewModel(isFavourite: .just(false))
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        subject.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testIsNotFavouriteDarkMode() {
        let mockViewModel = MockCharacterDetailViewModel()
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        subject.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testLongButtonText() {
        let mockViewModel = MockCharacterDetailViewModel(buttonText: .just("Long Button Text To See What Word Wrapping is Like"))
        let subject = CharacterDetailViewController(viewModel: mockViewModel)
        assertSnapshot(matching: subject, as: .image)
    }
}

final class MockCharacterDetailViewModel: CharacterDetailViewModelProtocol {
    let input: CharacterDetailViewModel.Input
    let output: CharacterDetailViewModel.Output
    
    init(name: Driver<String> = .just("Thor"),
         description: Driver<String> = .just("Description"),
         image: Driver<UIImage?> = .just(UIImage(systemName: "person")),
         buttonText: Driver<String> = .just("Button"),
         buttonTapped: Driver<URL?> = .never(),
         isFavourite: Driver<Bool> = .just(true)) {
        input = CharacterDetailViewModel.Input(buttonTap: PublishSubject<Void>().asObserver(),
                                               favouriteTap: PublishSubject<Bool>().asObserver())
        output = CharacterDetailViewModel.Output(characterImage: image,
                                                 characterName: name,
                                                 characterDescription: description,
                                                 buttonText: buttonText,
                                                 buttonTapped: buttonTapped,
                                                 isFavourite: isFavourite)
    }
}
