//
//  FavouritesCoordinatorTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 05/04/2021.
//

import RxCocoa
import RxSwift
import XCTest

@testable import MarvelAppRx

final class FavouritesCoordinatorTests: XCTestCase {
    
    func testStart() {
        let mockRouter = MockRouter()
        let subject = FavouritesCoordinator(router: mockRouter,
                                            favouritesListViewModel: MockFavouritesListViewModel())
        subject.start()
        XCTAssertTrue(mockRouter.pushedViewController is FavouritesListViewController)
    }
    
    func testPushCharacterDetail() {
        let mockRouter = MockRouter()
        let didSelectCharacter = PublishSubject<MarvelCharacter>()
        let mockFavouritesListViewModel = MockFavouritesListViewModel(didSelectCharacter: didSelectCharacter.asDriver(onErrorJustReturn: .empty))
        let subject = FavouritesCoordinator(router: mockRouter,
                                            favouritesListViewModel: mockFavouritesListViewModel)
        subject.start()
        didSelectCharacter.onNext(.mock())
        XCTAssertTrue(mockRouter.pushedViewController is CharacterDetailViewController)
    }
    
    func testOpenURL() {
        let mockRouter = MockRouter()
        let mockURLOpener = MockURLOpener()
        let buttonTapped = PublishSubject<URL?>()
        let subject = FavouritesCoordinator(router: mockRouter,
                                            favouritesListViewModel: MockFavouritesListViewModel(),
                                            characterDetailViewModel: { _ in
                                                MockCharacterDetailViewModel(buttonTapped: buttonTapped.asDriver(onErrorJustReturn: nil))
                                            },
                                            urlOpener: mockURLOpener)
        subject.pushCharacterDetail(for: .mock())

        let url = URL(string: "www.marvel.com")
        buttonTapped.onNext(url)
        XCTAssertEqual(url, mockURLOpener.openedURL)
    }
    
    func testCantOpenURL() {
        let mockRouter = MockRouter()
        let mockURLOpener = MockURLOpener()
        let buttonTapped = PublishSubject<URL?>()
        let subject = FavouritesCoordinator(router: mockRouter,
                                            favouritesListViewModel: MockFavouritesListViewModel(),
                                            characterDetailViewModel: { _ in
                                                MockCharacterDetailViewModel(buttonTapped: buttonTapped.asDriver(onErrorJustReturn: nil))
                                            },
                                            urlOpener: mockURLOpener)
        subject.pushCharacterDetail(for: .mock())
        
        mockURLOpener.canOpenURL = false
        buttonTapped.onNext(URL(string: "www.marvel.com"))
        
        XCTAssertNil(mockURLOpener.openedURL)
    }
}

final class MockRouter: Router {
    var pushedViewController: UIViewController?
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
    }
    
    var presentedViewController: UIViewController?
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentedViewController = viewControllerToPresent
    }
}
