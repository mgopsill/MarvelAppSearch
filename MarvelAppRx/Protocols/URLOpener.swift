//
//  URLOpener.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 05/04/2021.
//

import UIKit

protocol URLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: URLOpener { }
