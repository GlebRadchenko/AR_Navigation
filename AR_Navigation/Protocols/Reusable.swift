//
//  Reusable.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable: class {
    
    static var reuseIdentifier: String { get }
    static var nibName: String { get }
    
    func concrete<T>() -> T?
}

extension Reusable {
    static var reuseIdentifier: String { get { return String(describing: Self.self) } }
    static var nibName: String { get { return String(describing: Self.self) } }
    
    func concrete<T>() -> T? {
        return self as? T
    }
}
