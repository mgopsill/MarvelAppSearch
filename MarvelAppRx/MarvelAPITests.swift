//
//  MarvelAPITests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 02/04/2021.
//

import RxBlocking
import XCTest

@testable import MarvelAppRx

final class MarvelAPITests: XCTestCase {
    let endpointURL = URL(string: "https://gateway.marvel.com/v1/public/characters")!
    
    override class func setUp() {
        super.setUp()
        URLProtocol.registerClass(TestURLProtocol.self)
    }
    
    override class func tearDown() {
        URLProtocol.unregisterClass(TestURLProtocol.self)
        super.tearDown()
    }
    
    func testURLRequestComposition() throws {
        let request = MarvelAPI.charactersRequest(for: "Thor")
        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        
        XCTAssertEqual(components.queryItems?["orderBy"], "name")
        XCTAssertEqual(components.queryItems?["apikey"], "933caddc5bdf0e824bf1d938241ba6d9")
        XCTAssertEqual(components.queryItems?["hash"], "3198f9adf083cfa42049f8e6cb4fdfb9")
        XCTAssertEqual(components.queryItems?["ts"], "1617340573")
        XCTAssertEqual(components.host, "gateway.marvel.com")
        XCTAssertEqual(components.path, "/v1/public/characters")
        XCTAssertEqual(components.scheme, "https")
    }
    
    func testSuccessfulFetch() throws {
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.success(MarvelAPI.sampleResponse), 200) }

        let result = try MarvelAPI.searchCharacters(with: "Thor").toBlocking().single()
        XCTAssertEqual(result.count, 20)
        XCTAssertEqual(result[0].name, "3-D Man")
        XCTAssertEqual(result[0].description, "")
        XCTAssertEqual(result[0].imageURL, URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg"))
    }
    
    func testSuccessfulFetchErroneousData() throws {
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.success(Data()), 200) }
    
        XCTAssertThrowsError(try MarvelAPI.searchCharacters(with: "Thor").toBlocking().single())
    }
    
    func testFailedFetch() throws {
        struct MockError: Error {}
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.failure(MockError()), 440) }
        
        XCTAssertThrowsError(try MarvelAPI.searchCharacters(with: "Thor").toBlocking().single())
    }
}

extension MarvelAPI {
    static let sampleResponse: Data = {
        let bundle = Bundle(for: MarvelAPITests.self)
        let url = bundle.url(forResource: "SampleResponse", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
}

extension Array where Element == URLQueryItem {
  fileprivate subscript(_ name: String) -> String? {
    first(where: { $0.name == name }).flatMap { $0.value }
  }
}
