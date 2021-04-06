//
//  SceneDelegate.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appTabBarController: AppTabBarController!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        appTabBarController = AppTabBarController()
        window.rootViewController = appTabBarController
        window.makeKeyAndVisible()
    }
}
