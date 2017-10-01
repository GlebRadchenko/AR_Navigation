//
//  Presenter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

protocol ModuleInput { }

protocol Presenter: class, ModuleInput {
    associatedtype View
    associatedtype Router
    associatedtype Interactor
    
    var view: View! { get set }
    var interactor: Interactor! { get set }
    var router: Router! { get set }
}
