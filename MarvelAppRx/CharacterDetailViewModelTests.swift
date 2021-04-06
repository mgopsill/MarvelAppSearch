//
//  CharacterDetailViewModelTests.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 04/04/2021.
//

import RxSwift
import RxTest
import XCTest

@testable import MarvelAppRx

final class CharacterDetailViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    func testName() {
        let outputs = test(character: .mock(name: "Test"))
        XCTAssertEqual(outputs.characterName.events, [.next(0, "Test"), .completed(0)])
    }
    
    func testDescription() {
        let outputs = test(character: .mock(description: "Description Text"))
        XCTAssertEqual(outputs.characterDescription.events, [.next(0, "Description Text"), .completed(0)])
    }
    
    func testButtonText() {
        let outputs = test(character: .mock(name: "Thor"))
        XCTAssertEqual(outputs.buttonText.events, [.next(0, "View Website for Thor"), .completed(0)])
    }
    
    func testImage() {
        let image = UIImage()
        let imageProvider = MockImageProvider()
        let outputs = test(character: .mock(thumbnail: .init(path: "www.marvel.com/image", thumbnailExtension: .jpg)),
                           imageEvent: [.next(0, nil),
                                        .next(10, image)],
                           imageProvider: imageProvider)
        XCTAssertEqual(outputs.characterImage.events, [.next(0, nil),
                                              .next(10, image)])
        XCTAssertEqual(imageProvider.imageURL, URL(string: "www.marvel.com/image.jpg"))
    }
    
    func testButtonTap() {
        let outputs = test(character: .mock(urls: [.init(type: .detail, url: "www.marvel.com")]),
                           buttonTap: [.next(10, ())])
        XCTAssertEqual(outputs.buttonTapped.events, [.next(10, URL(string: "www.marvel.com"))])
    }
    
    func testIsInitiallyFavouriteRemoveFavourite() {
        let character = MarvelCharacter.mock(name: "Iron Man")
        let fakeFavouritesManager = FakeFavouritesManager()
        fakeFavouritesManager.favouriteCharacters = [character]
        let outputs = test(character: character,
                           favouritesManager: fakeFavouritesManager,
                           favouriteTap: [.next(10, true)])
        XCTAssertEqual(outputs.isFavourite.events, [.next(0, true),
                                                    .next(10, false)])
        XCTAssertEqual((fakeFavouritesManager.removedFavourite), character)
    }
    
    func testIsInitiallyNotFavouriteSaveFavourite() {
        let character = MarvelCharacter.mock(name: "Iron Man")
        let fakeFavouritesManager = FakeFavouritesManager()
        let outputs = test(character: character,
                           favouritesManager: fakeFavouritesManager,
                           favouriteTap: [.next(10, false)])
        XCTAssertEqual(outputs.isFavourite.events, [.next(0, false),
                                                    .next(10, true)])
        XCTAssertEqual((fakeFavouritesManager.savedFavourite), character)
    }
    
    private typealias Outputs = (characterImage: TestableObserver<UIImage?>,
                                 characterName: TestableObserver<String>,
                                 characterDescription: TestableObserver<String>,
                                 buttonText: TestableObserver<String>,
                                 buttonTapped: TestableObserver<URL?>,
                                 isFavourite: TestableObserver<Bool>)
        
    private func test(character: MarvelCharacter,   
                      imageEvent: [Recorded<Event<UIImage?>>] = [],
                      imageProvider: MockImageProvider = MockImageProvider(),
                      favouritesManager: FavouritesManagerProtocol = FakeFavouritesManager(),
                      buttonTap: [Recorded<Event<Void>>] = [],
                      favouriteTap: [Recorded<Event<Bool>>] = []) -> Outputs {
        let scheduler = TestScheduler(initialClock: 0)

        let characterImageObserver = scheduler.createObserver(UIImage?.self)
        let characterNameObserver = scheduler.createObserver(String.self)
        let characterDescriptionObserver = scheduler.createObserver(String.self)
        let buttonTextObserver = scheduler.createObserver(String.self)
        let buttonTappedObserver = scheduler.createObserver(URL?.self)
        let isFavouriteObserver = scheduler.createObserver(Bool.self)
        
        scheduler.createColdObservable(imageEvent).bind(to: imageProvider.imagePublishSubject).disposed(by: disposeBag)
        
        let subject = CharacterDetailViewModel(character: character,
                                               imageProvider: imageProvider,
                                               favouritesManager: favouritesManager)
        
        scheduler.createColdObservable(buttonTap).bind(to: subject.input.buttonTap).disposed(by: disposeBag)
        scheduler.createColdObservable(favouriteTap).bind(to: subject.input.favouriteTap).disposed(by: disposeBag)
    
        subject.output.characterImage.drive(characterImageObserver).disposed(by: disposeBag)
        subject.output.characterName.drive(characterNameObserver).disposed(by: disposeBag)
        subject.output.characterDescription.drive(characterDescriptionObserver).disposed(by: disposeBag)
        subject.output.buttonText.drive(buttonTextObserver).disposed(by: disposeBag)
        subject.output.buttonTapped.drive(buttonTappedObserver).disposed(by: disposeBag)
        subject.output.isFavourite.drive(isFavouriteObserver).disposed(by: disposeBag)
    
        scheduler.start()
        
        return (characterImage: characterImageObserver,
                characterName: characterNameObserver,
                characterDescription: characterDescriptionObserver,
                buttonText: buttonTextObserver,
                buttonTapped: buttonTappedObserver,
                isFavourite: isFavouriteObserver)
    }
}
