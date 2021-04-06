//
//  ListCoordinatorTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 05/04/2021.
//

import RxCocoa
import RxSwift
import XCTest

@testable import MarvelAppRx

final class ListCoordinatorTests: XCTestCase {
    
    func testStart() {
        let mockRouter = MockRouter()
        let subject = ListCoordinator(router: mockRouter,
                                      characterListViewModel: MockCharacterListViewModel())
        subject.start()
        XCTAssertTrue(mockRouter.pushedViewController is CharacterListViewController)
    }
    
    func testPresentCharacterDetail() {
        let mockRouter = MockRouter()
        let didSelectCharacter = PublishSubject<MarvelCharacter>()
        let mockCharacterListViewModel = MockCharacterListViewModel(didSelectCharacter: didSelectCharacter.asDriver(onErrorJustReturn: .empty))
        let subject = ListCoordinator(router: mockRouter,
                                      characterListViewModel: mockCharacterListViewModel)
        subject.start()
        didSelectCharacter.onNext(.mock())
        XCTAssertTrue(mockRouter.presentedViewController is CharacterDetailViewController)
    }
    
    func testOpenURL() {
        let mockRouter = MockRouter()
        let mockURLOpener = MockURLOpener()
        let buttonTapped = PublishSubject<URL?>()
        let subject = ListCoordinator(router: mockRouter,
                                      characterListViewModel:  MockCharacterListViewModel(),
                                      characterDetailViewModel: { _ in
                                        MockCharacterDetailViewModel(buttonTapped: buttonTapped.asDriver(onErrorJustReturn: nil))
                                      },
                                      urlOpener: mockURLOpener)
        subject.presentCharacterDetail(for: .mock())
        
        let url = URL(string: "www.marvel.com")
        buttonTapped.onNext(url)
        XCTAssertEqual(url, mockURLOpener.openedURL)
    }
    
    func testCantOpenURL() {
        let mockRouter = MockRouter()
        let mockURLOpener = MockURLOpener()
        let buttonTapped = PublishSubject<URL?>()
        let subject = ListCoordinator(router: mockRouter,
                                      characterListViewModel:  MockCharacterListViewModel(),
                                      characterDetailViewModel: { _ in
                                        MockCharacterDetailViewModel(buttonTapped: buttonTapped.asDriver(onErrorJustReturn: nil))
                                      },
                                      urlOpener: mockURLOpener)
        subject.presentCharacterDetail(for: .mock())
        
        mockURLOpener.canOpenURL = false
        buttonTapped.onNext(URL(string: "www.marvel.com"))
        
        XCTAssertNil(mockURLOpener.openedURL)
    }
}

final class MockURLOpener: URLOpener {
    var canOpenURL = true
    func canOpenURL(_ url: URL) -> Bool {
        canOpenURL
    }
    
    var openedURL: URL?
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        openedURL = url
    }
}
