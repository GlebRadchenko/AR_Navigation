//
//  Presenter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

enum PresenterError: Error {
    case wrongInput
}

protocol ModuleInput: class { }

extension ModuleInput {
    func specific<T>() throws -> T {
        guard let specified = self as? T else {
            throw PresenterError.wrongInput
        }
        
        return specified
    }
}

protocol Presenter: ModuleInput {
    associatedtype View
    associatedtype Router
    associatedtype Interactor
    
    var view: View! { get set }
    var interactor: Interactor! { get set }
    var router: Router! { get set }
}
