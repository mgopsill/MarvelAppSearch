//
//  CharacterResponseModelTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 04/04/2021.
//

import XCTest

@testable import MarvelAppRx

final class CharacterResponseModelTests: XCTestCase {
    func testModel() {
        let model = try? JSONDecoder().decode(CharacterResponseModel.self, from: MarvelAPI.sampleResponse)
        XCTAssertEqual(model?.data.characters.count, 20)
        XCTAssertEqual(model?.data.characters[0].name, "3-D Man")
        XCTAssertEqual(model?.data.characters[0].description, "")
        XCTAssertEqual(model?.data.characters[1].name, "A-Bomb (HAS)")
    }
    
    func testImageURL() {
        let thumbnail = Thumbnail(path: "www.marvel.com", thumbnailExtension: .jpg)
        let character = MarvelCharacter.mock(thumbnail: thumbnail)
        XCTAssertEqual(character.imageURL, URL(string: "www.marvel.com.jpg"))
    }
    
    func testWebsiteURL() {
        let marvelURL = MarvelURL(type: .detail, url: "www.marvel.com")
        let character = MarvelCharacter.mock(urls: [marvelURL])
        XCTAssertEqual(character.websiteURL, URL(string: "www.marvel.com"))
    }

    func testWebsiteURLFails() {
        var marvelURL = MarvelURL(type: .comiclink, url: "www.marvel.com")
        var character = MarvelCharacter.mock(urls: [marvelURL])
        XCTAssertNil(character.websiteURL)
        
        marvelURL = MarvelURL(type: .wiki, url: "www.marvel.com")
        character = MarvelCharacter.mock(urls: [marvelURL])
        XCTAssertNil(character.websiteURL)
        
        character = MarvelCharacter.mock(urls: [])
        XCTAssertNil(character.websiteURL)
    }
}

extension MarvelCharacter {
    static func mock(name: String = "",
                     description: String = "",
                     thumbnail: Thumbnail = .init(path: "", thumbnailExtension: .jpg),
                     urls: [MarvelURL] = []) -> MarvelCharacter {
        MarvelCharacter(name: name,
                        description: description,
                        thumbnail: thumbnail,
                        urls: urls)
    }
}
