//
//  ApplicationManager.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class ApplicationManager: NSObject {
    var window: UIWindow?
    
    @IBOutlet weak var initialViewController: UIViewController! {
        didSet {
            configure()
        }
    }
    
    var initialModule: Module!
    
    func configure() {
        initialModule = try? ARViewRouter.module(with: initialViewController)
    }
}

extension ApplicationManager: UIApplicationDelegate {
    
}
