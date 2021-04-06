//
//  Coordinator.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

protocol Coordinator {
    var childCoordinators: [Coordinator] { get }
    func start()
}
