//
//  CharacterListViewModelTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 06/04/2021.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

@testable import MarvelAppRx

final class CharacterListViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    func testSearchNilOrEmptyText() {
        let outputs = test(search: [.next(0, nil), .next(10, "")])
        XCTAssertEqual(outputs.marvelCharacters.events, [])
        XCTAssertTrue(outputs.searchedStrings.isEmpty)
        XCTAssertEqual(outputs.isLoading.events, [.next(0, false)])
    }
    
    func testSearchDistinctUntilChanged() {
        let outputs = test(search: [.next(0, "Th"),
                                    .next(10, "Th"),
                                    .next(20, "Th"),
                                    .next(30, "Th")])
        XCTAssertEqual(outputs.marvelCharacters.events, [.next(1, [])])
        XCTAssertEqual(outputs.searchedStrings[0], "Th")
        XCTAssertEqual(outputs.searchedStrings.count, 1)
        XCTAssertEqual(outputs.isLoading.events, [.next(0, false),
                                                  .next(1, true)])
    }
    
    func testSelectCharacter() {
        let outputs = test(selectCharacter: [.next(0, MarvelCharacter.mock(name: "Thor"))])
        XCTAssertEqual(outputs.didSelectCharacter.events, [.next(0, MarvelCharacter.mock(name: "Thor"))])
    }
    
    func testAPIReturns() {
        let character = MarvelCharacter.mock(name: "Thor")
        let outputs = test(search: [.next(0, "Th")],
                           apiResult: .just([character]))
        XCTAssertEqual(outputs.marvelCharacters.events, [.next(1, []),
                                                         .next(1, [character])])
        XCTAssertEqual(outputs.isLoading.events, [.next(0, false),
                                                  .next(1, true),
                                                  .next(1, false)])
    }
    
    func testAPIFails() {
        struct MockError: Error { }
        let outputs = test(search: [.next(0, "Th")],
                           apiResult: .error(MockError()))
        XCTAssertEqual(outputs.marvelCharacters.events, [.next(1, []),
                                                         .next(1, []),
                                                         .completed(1)])
        XCTAssertEqual(outputs.isLoading.events, [.next(0, false),
                                                  .next(1, true),
                                                  .next(1, false)])
    }
    
    private typealias Outputs = (marvelCharacters: TestableObserver<[MarvelCharacter]>,
                                 didSelectCharacter: TestableObserver<MarvelCharacter>,
                                 isLoading: TestableObserver<Bool>,
                                 searchedStrings: [String])
    
    private func test(search: [Recorded<Event<String?>>] = [],
                      selectCharacter: [Recorded<Event<MarvelCharacter>>] = [],
                      apiResult: Observable<[MarvelCharacter]> = .never()) -> Outputs {
        let scheduler: TestScheduler = TestScheduler(initialClock: 0)

        let charactersObserver = scheduler.createObserver([MarvelCharacter].self)
        let didSelectCharacterObserver = scheduler.createObserver(MarvelCharacter.self)
        let isLoadingObserver = scheduler.createObserver(Bool.self)
        
        var searchedStrings: [String] = []
        let mockAPI: (String, ConfigurationProtocol) -> Observable<[MarvelCharacter]> = { search, _ in
            searchedStrings.append(search)
            return apiResult
        }
        
        let subject = CharacterListViewModel(marvelAPI: mockAPI,
                                             scheduler: scheduler,
                                             configuration: MockConfiguration(shouldError: false))
        
        scheduler.createColdObservable(search).bind(to: subject.inputs.search).disposed(by: disposeBag)
        scheduler.createColdObservable(selectCharacter).bind(to: subject.inputs.selectCharacter).disposed(by: disposeBag)
    
        subject.outputs.marvelCharacters.drive(charactersObserver).disposed(by: disposeBag)
        subject.outputs.didSelectCharacter.drive(didSelectCharacterObserver).disposed(by: disposeBag)
        subject.outputs.isLoading.drive(isLoadingObserver).disposed(by: disposeBag)

        scheduler.start()
        
        return (charactersObserver,
                didSelectCharacterObserver,
                isLoadingObserver,
                searchedStrings)
    }
}
