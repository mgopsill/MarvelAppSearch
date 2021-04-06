//
//  AppTabBarControllerTests.swift
//  MarvelAppRxTests
//
//  Created by Mike Gopsill on 02/04/2021.
//

import SnapshotTesting
import XCTest

@testable import MarvelAppRx

final class AppTabBarControllerTests: XCTestCase {
    var mockCoordinatorFactory: MockCoordinatorFactory!
    var subject: AppTabBarController!
    
    override func setUp() {
        super.setUp()
        mockCoordinatorFactory = MockCoordinatorFactory()
        subject = AppTabBarController(coordinatorFactory: mockCoordinatorFactory)
    }
    
    override func tearDown() {
        mockCoordinatorFactory = nil
        subject = nil
        super.tearDown()
    }
    
    func testInitialSetupLightMode() {
        subject.overrideUserInterfaceStyle = .light
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testInitialSetupDarkMode() {
        subject.overrideUserInterfaceStyle = .dark
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testSelectedFavouriteLightMode() {
        subject.overrideUserInterfaceStyle = .light
        subject.selectedIndex = 1
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testSelectedFavouriteDarkMode() {
        subject.overrideUserInterfaceStyle = .dark
        subject.selectedIndex = 1
        assertSnapshot(matching: subject, as: .image)
    }
    
    func testListCoordinatorSetup() {
        let listCoordinator = subject.coordinators.compactMap { $0 as? MockListCoordinator }.first
        XCTAssertNotNil(listCoordinator)
        XCTAssertTrue(listCoordinator?.startCalled == true)
        XCTAssertTrue(subject.viewControllers?.first === mockCoordinatorFactory.listRouter)
    }
    
    func testFavouritesCoordinatorSetup() {
        let favouriteCoordinator = subject.coordinators.compactMap { $0 as? MockFavouriteCoordinator }.first
        XCTAssertNotNil(favouriteCoordinator)
        XCTAssertTrue(favouriteCoordinator?.startCalled == true)
        XCTAssertTrue(subject.viewControllers?.last === mockCoordinatorFactory.favouriteRouter)
    }
}

final class MockCoordinatorFactory: CoordinatorFactoryProtocol {
    var listRouter: Router?
    func makeListCoordinator(router: Router) -> Coordinator {
        listRouter = router
        return MockListCoordinator()
    }
    
    var favouriteRouter: Router?
    func makeFavouritesCoordinator(router: Router) -> Coordinator {
        favouriteRouter = router
        return MockFavouriteCoordinator()
    }
}

class MockCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var startCalled: Bool = false
    func start() {
        startCalled = true
    }
}

final class MockListCoordinator: MockCoordinator { }
final class MockFavouriteCoordinator: MockCoordinator { }
