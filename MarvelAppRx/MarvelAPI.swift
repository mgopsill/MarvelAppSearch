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
    static func searchCharacters(with searchString: String,
                                 configuration: ConfigurationProtocol = Configuration()) -> Observable<[MarvelCharacter]> {
        charactersRequest(for: searchString, configuration: configuration)
            .asObservable()
            .flatMap { request in
                URLSession.shared.rx.data(request: request)
            }
            .map { try JSONDecoder().decode(CharacterResponseModel.self, from: $0) }
            .map(\.data.characters)
    }
    
    static func charactersRequest(for string: String,
                                  configuration: ConfigurationProtocol = Configuration()) -> Single<URLRequest> {
        let key: String
        do {
            key = try configuration.apiKey()
        } catch {
            print(log)
            return Observable.error(error).asSingle()
        }
        
        let baseURL = URL(string: "https://gateway.marvel.com/v1/public/characters")!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "orderBy", value: "name"),
            .init(name: "apikey", value: key),
            .init(name: "hash", value: "3198f9adf083cfa42049f8e6cb4fdfb9"),
            .init(name: "ts", value: "1617340573"),
            .init(name: "nameStartsWith", value: string)
        ]
        let request = URLRequest(url: components.url!)
        return Single.just(request)
    }
    
    static let log: String =
                """
                ===
                Please add an API_KEY into Development.xcconfig file e.g. API_KEY = "key"
                Available here: https://www.marvel.com/signin?referer=https%3A%2F%2Fdeveloper.marvel.com%2Faccount
                ===
                """
}
