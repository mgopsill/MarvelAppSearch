//
//  MarvelAPI.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import Foundation
import RxCocoa
import RxSwift

enum MarvelAPI {
    static func searchCharacters(with searchString: String) -> Observable<[MarvelCharacter]> {
        return URLSession.shared.rx.data(request: charactersRequest(for: searchString))
            .map { try JSONDecoder().decode(CharacterResponseModel.self, from: $0) }
            .map(\.data.characters)
    }
    
    static func charactersRequest(for string: String) -> URLRequest {
        let baseURL = URL(string: "https://gateway.marvel.com/v1/public/characters")!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "orderBy", value: "name"),
            .init(name: "apikey", value: "***REMOVED***"),
            .init(name: "hash", value: "3198f9adf083cfa42049f8e6cb4fdfb9"),
            .init(name: "ts", value: "1617340573"),
            .init(name: "nameStartsWith", value: string)
        ]
        return URLRequest(url: components.url!)
    }
}
