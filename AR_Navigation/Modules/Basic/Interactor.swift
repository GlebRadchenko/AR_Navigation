//
//  Interactor.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

protocol Interactor: class {
    associatedtype Presenter
    var output: Presenter! { get set }
}
