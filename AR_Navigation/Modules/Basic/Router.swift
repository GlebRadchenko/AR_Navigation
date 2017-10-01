//
//  Router.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

protocol Router: class {
    associatedtype ModuleView: View
    static func module() throws -> Module
}

enum RouterError: Error {
    case wrongView
}
