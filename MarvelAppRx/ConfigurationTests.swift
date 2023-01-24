//
//  ConfigurationTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 24/01/2023.
//

import XCTest

@testable import MarvelAppRx

final class ConfigurationTests: XCTestCase {
    func testApiKey_whenKeyIsPresent_returnsKey() {
        let key = "API_KEY"
        let keyProvider = { (key: String) -> Any? in return key }
        let configuration = Configuration(keyProvider: keyProvider)
        
        do {
            let returnedKey = try configuration.apiKey()
            XCTAssertEqual(returnedKey, key)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testApiKey_whenKeyIsMissing_throwsMissingKeyError() {
        let keyProvider = { (key: String) -> Any? in return nil }
        let configuration = Configuration(keyProvider: keyProvider)
        
        XCTAssertThrowsError(try configuration.apiKey()) { error in
            XCTAssertEqual(error as? Configuration.Error, Configuration.Error.missingKey)
        }
    }
    
    func testApiKey_whenKeyIsEmpty_throwsKeyEmptyError() {
        let keyProvider = { (key: String) -> Any? in return "" }
        let configuration = Configuration(keyProvider: keyProvider)
        
        XCTAssertThrowsError(try configuration.apiKey()) { error in
            XCTAssertEqual(error as? Configuration.Error, Configuration.Error.keyEmpty)
        }
    }
}

