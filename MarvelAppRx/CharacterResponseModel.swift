//
//  CharacterResponseModel.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import Foundation

struct CharacterResponseModel: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let characters: [MarvelCharacter]
    
    enum CodingKeys: String, CodingKey {
        case characters = "results"
    }
}

struct MarvelCharacter: Codable, Equatable {
    let name, description: String
    let thumbnail: Thumbnail
    let urls: [MarvelURL]
    
    static let empty = MarvelCharacter(name: "",
                                       description: "",
                                       thumbnail: .init(path: "", thumbnailExtension: .jpg),
                                       urls: [])
}

struct Thumbnail: Codable, Equatable {
    let path: String
    let thumbnailExtension: Extension
    
    enum CodingKeys: String, CodingKey {
        case path
        case thumbnailExtension = "extension"
    }
}

enum Extension: String, Codable, Equatable {
    case jpg = "jpg"
    case gif = "gif"
}

struct MarvelURL: Codable, Equatable {
    let type: URLType
    let url: String
}

enum URLType: String, Codable, Equatable {
    case comiclink = "comiclink"
    case detail = "detail"
    case wiki = "wiki"
}

extension MarvelCharacter {
    var imageURL: URL? {
        let urlString = String("\(thumbnail.path).\(thumbnail.thumbnailExtension.rawValue)")
        return URL(string: urlString)
    }
    
    var websiteURL: URL? {        
        let websiteURL = urls.filter { $0.type == .detail }
        guard let urlString = websiteURL.first?.url else { return nil }
        return URL(string: urlString)
    }
}
