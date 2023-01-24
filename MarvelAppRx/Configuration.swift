//
//  Configuration.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 24/01/2023.
//

import Foundation

protocol ConfigurationProtocol {
    func apiKey() throws -> String
}

struct Configuration: ConfigurationProtocol {
    enum Error: Swift.Error {
        case missingKey, keyEmpty
    }

    let keyProvider: (String) -> Any?
    
    init(keyProvider: @escaping (String) -> Any? = { Bundle.main.object(forInfoDictionaryKey: $0) }) {
        self.keyProvider = keyProvider
    }
    
    func apiKey() throws -> String {
        guard let object = keyProvider("API_KEY") else {
            throw Error.missingKey
        }
        
        guard let string = object as? String, !string.isEmpty else {
            throw Error.keyEmpty
        }
        
        return string
    }
}
