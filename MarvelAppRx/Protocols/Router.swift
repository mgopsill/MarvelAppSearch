//
//  Router.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 02/04/2021.
//

import UIKit

protocol Router: AnyObject {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

extension UINavigationController: Router { }
