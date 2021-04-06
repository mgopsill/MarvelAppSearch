//
//  CharacterCellViewModelTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 04/04/2021.
//

import RxSwift
import RxTest
import XCTest

@testable import MarvelAppRx

final class CharacterCellViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    func testName() {
        let outputs = test(character: .mock(name: "Test"))
        XCTAssertEqual(outputs.name.events, [.next(0, "Test")])
    }
    
    func testImage() {
        let image = UIImage()
        let imageProvider = MockImageProvider()
        let outputs = test(character: .mock(thumbnail: .init(path: "www.marvel.com/image", thumbnailExtension: .jpg)),
                           imageEvent: [.next(0, nil),
                                        .next(10, image)],
                           imageProvider: imageProvider)
        XCTAssertEqual(outputs.image.events, [.next(0, nil),
                                              .next(10, image)])
        XCTAssertEqual(imageProvider.imageURL, URL(string: "www.marvel.com/image.jpg"))
    }
    
    func testIsFavourite() {
        let favouritesManager = FakeFavouritesManager()
        favouritesManager.favouriteCharacters = [.mock(name: "Test")]
        var outputs = test(character: .mock(name: "Test"), favouritesManager: favouritesManager)
        XCTAssertEqual(outputs.isFavourite.events, [.next(0, true)])
        
        outputs = test(character: .mock())
        XCTAssertEqual(outputs.isFavourite.events, [.next(0, false)])
    }
    
    private typealias Outputs = (name: TestableObserver<String>,
                                 image: TestableObserver<UIImage?>,
                                 isFavourite: TestableObserver<Bool>)
        
    private func test(character: MarvelCharacter,
                      imageEvent: [Recorded<Event<UIImage?>>] = [],
                      imageProvider: MockImageProvider = MockImageProvider(),
                      favouritesManager: FavouritesManagerProtocol = FakeFavouritesManager()) -> Outputs {
        let scheduler = TestScheduler(initialClock: 0)

        let nameObserver = scheduler.createObserver(String.self)
        let imageObserver = scheduler.createObserver(UIImage?.self)
        let isFavouriteObserver = scheduler.createObserver(Bool.self)
        
        scheduler.createColdObservable(imageEvent)
            .bind(to: imageProvider.imagePublishSubject)
            .disposed(by: disposeBag)

        let subject = CharacterCellViewModel(character: character,
                                             imageProvider: imageProvider,
                                             favourites: favouritesManager)
        
        subject.output.name.drive(nameObserver).disposed(by: disposeBag)
        subject.output.image.drive(imageObserver).disposed(by: disposeBag)
        subject.output.isFavourite.drive(isFavouriteObserver).disposed(by: disposeBag)

        scheduler.start()
        
        return (name: nameObserver,
                image: imageObserver,
                isFavourite: isFavouriteObserver)
    }
}

final class MockImageProvider: ImageProviderProtocol {
    var imagePublishSubject = PublishSubject<UIImage?>()
    var imageURL: URL?
    func image(for url: URL?) -> Observable<UIImage?> {
        imageURL = url
        return imagePublishSubject.asObservable()
    }
}

final class FakeFavouritesManager: FavouritesManagerProtocol {
    var favouriteCharacters: [MarvelCharacter] = []
    
    var savedFavourite: MarvelCharacter?
    func saveFavourite(character: MarvelCharacter) {
        savedFavourite = character
        favouriteCharacters.append(character)
    }
    
    var removedFavourite: MarvelCharacter?
    func removeFavourite(character: MarvelCharacter) {
        removedFavourite = character
        favouriteCharacters.removeAll(where: { $0 == character })
    }
}
