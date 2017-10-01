//
//  View.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

protocol View: class {
    associatedtype Presenter
    var output: Presenter! { get set }
    
    static var storyboardName: String { get }
}
