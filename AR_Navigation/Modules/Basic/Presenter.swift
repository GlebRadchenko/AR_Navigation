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

protocol Presenter: ModuleInput {
    associatedtype View
    associatedtype Router
    associatedtype Interactor
    
    var view: View! { get }
    var interactor: Interactor! { get }
    var router: Router! { get }
}
