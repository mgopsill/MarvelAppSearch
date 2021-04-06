//
//  CoordinatorFactoryTests.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 05/04/2021.
//

import XCTest

@testable import MarvelAppRx

final class CoordinatorFactoryTests: XCTestCase {
    func testMakeListCoordinator() {
        let subject = CoordinatorFactory()
        let listCoordinator = subject.makeListCoordinator(router: UINavigationController())
        XCTAssertTrue(listCoordinator is ListCoordinator)
    }
    
    func testMakeFavouritesCoordinator() {
        let subject = CoordinatorFactory()
        let favouritesCoordinator = subject.makeFavouritesCoordinator(router: UINavigationController())
        XCTAssertTrue(favouritesCoordinator is FavouritesCoordinator)
    }
}
