//
//  FavouritesListViewModelTests.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 05/04/2021.
//

import RxSwift
import RxTest
import XCTest

@testable import MarvelAppRx

final class FavouritesListViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    func testViewWillAppearDeleteCharacterSelectCharacter() {
        let fakeFavouritesManager = FakeFavouritesManager()
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)") }
        fakeFavouritesManager.favouriteCharacters = characters
        
        let outputs = test(selectCharacter: [.next(10, characters[0])],
                           deleteIndexPath: [.next(20, IndexPath(row: 0, section: 0))],
                           viewWillAppear: [.next(0, ())],
                           favouritesManager: fakeFavouritesManager)
        XCTAssertEqual(outputs.characters.events, [.next(0, characters),
                                                   .next(20, Array(characters.dropFirst()))])
        XCTAssertEqual(outputs.didSelectCharacter.events, [.next(10, characters[0])])
    }
    
    private typealias Outputs = (characters: TestableObserver<[MarvelCharacter]>,
                                 didSelectCharacter: TestableObserver<MarvelCharacter>)
    
    private func test(selectCharacter: [Recorded<Event<MarvelCharacter>>] = [],
                      deleteIndexPath: [Recorded<Event<IndexPath>>] = [],
                      viewWillAppear: [Recorded<Event<Void>>] = [],
                      favouritesManager: FavouritesManagerProtocol = FakeFavouritesManager()) -> Outputs {
        let scheduler = TestScheduler(initialClock: 0)

        let charactersObserver = scheduler.createObserver([MarvelCharacter].self)
        let didSelectCharacterObserver = scheduler.createObserver(MarvelCharacter.self)
        
        let subject = FavouritesListViewModel(favouritesManager: favouritesManager)
        
        scheduler.createColdObservable(selectCharacter).bind(to: subject.inputs.selectCharacter).disposed(by: disposeBag)
        scheduler.createColdObservable(deleteIndexPath).bind(to: subject.inputs.deleteIndexPath).disposed(by: disposeBag)
        scheduler.createColdObservable(viewWillAppear).bind(to: subject.inputs.viewWillAppear).disposed(by: disposeBag)
    
        subject.outputs.characters.drive(charactersObserver).disposed(by: disposeBag)
        subject.outputs.didSelectCharacter.drive(didSelectCharacterObserver).disposed(by: disposeBag)
        
        scheduler.start()
        
        return (charactersObserver, didSelectCharacterObserver)
    }
}
