//
//  FavouritesManagerTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 05/04/2021.
//

import XCTest

@testable import MarvelAppRx

final class FavouritesManagerTests: XCTestCase {
    
    func testSavedFavourites() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)") }
        let encodedCharacters = try! JSONEncoder().encode(characters)
        let mockDefaults = MockDefaults()
        mockDefaults.getValue = encodedCharacters
        let subject = FavouritesManager(defaults: mockDefaults)
        XCTAssertEqual(subject.favouriteCharacters, characters)
    }
    
    func testNoSavedFavourites() {
        let mockDefaults = MockDefaults()
        let subject = FavouritesManager(defaults: mockDefaults)
        XCTAssertEqual(subject.favouriteCharacters, [])
    }
    
    func testSaveFavourite() {
        let mockDefaults = MockDefaults()
        let subject = FavouritesManager(defaults: mockDefaults)
        let character = MarvelCharacter.mock(name: "Thor")
        subject.saveFavourite(character: character)
        let savedFavourite = try? JSONDecoder().decode([MarvelCharacter].self, from: mockDefaults.setValue as! Data)
        XCTAssertEqual(savedFavourite, [character])
        XCTAssertEqual(mockDefaults.setKey, "favourites")
    }
    
    func testSaveFavouriteWithExistingFavourites() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)") }
        let encodedCharacters = try! JSONEncoder().encode(characters)
        let mockDefaults = MockDefaults()
        mockDefaults.getValue = encodedCharacters
        
        let subject = FavouritesManager(defaults: mockDefaults)
        let character = MarvelCharacter.mock(name: "Thor")
        subject.saveFavourite(character: character)
        
        let savedFavourite = try? JSONDecoder().decode([MarvelCharacter].self, from: mockDefaults.setValue as! Data)
        XCTAssertEqual(savedFavourite, characters + [character])
        XCTAssertEqual(mockDefaults.setKey, "favourites")
    }
    
    func testRemoveFavourite() {
        let characters = (0..<10).map { i in MarvelCharacter.mock(name: "Character \(i)") }
        let encodedCharacters = try! JSONEncoder().encode(characters)
        let mockDefaults = MockDefaults()
        mockDefaults.getValue = encodedCharacters

        let subject = FavouritesManager(defaults: mockDefaults)
        let character = characters[0]
        subject.removeFavourite(character: character)

        let savedFavourites = try? JSONDecoder().decode([MarvelCharacter].self, from: mockDefaults.setValue as! Data)
        XCTAssertEqual(savedFavourites, Array(characters.dropFirst()))
        XCTAssertEqual(mockDefaults.setKey, "favourites")
    }
    
}

final class MockDefaults: Defaults {
    var setValue: Any?
    var setKey: String?
    func setValue(_ value: Any?, forKey key: String) {
        setValue = value
        setKey = key
    }
    
    var getValue: Any?
    var getKey: String?
    func value(forKey key: String) -> Any? {
        getKey = key
        return getValue
    }
}
