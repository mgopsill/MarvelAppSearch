//
//  Defaults.swift
//  MarvelAppRx
//
//  Created by Mike Gopsill on 05/04/2021.
//

import Foundation

protocol Defaults {
    func setValue(_ value: Any?, forKey key: String)
    func value(forKey key: String) -> Any?
}

extension UserDefaults: Defaults { }
