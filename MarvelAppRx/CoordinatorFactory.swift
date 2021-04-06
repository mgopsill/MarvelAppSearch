//
//  CoordinatorFactory.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 03/04/2021.
//

import Foundation

protocol CoordinatorFactoryProtocol {
    func makeListCoordinator(router: Router) -> Coordinator
    func makeFavouritesCoordinator(router: Router) -> Coordinator
}

final class CoordinatorFactory: CoordinatorFactoryProtocol {
    func makeListCoordinator(router: Router) -> Coordinator {
        ListCoordinator(router: router)
    }
    
    func makeFavouritesCoordinator(router: Router) -> Coordinator {
        FavouritesCoordinator(router: router)
    }
}
