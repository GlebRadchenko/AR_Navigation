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
    static var shared = ApplicationManager()
    
    var window: UIWindow?
    
    @IBOutlet weak var initialViewController: UIViewController! {
        didSet { configure() }
    }
    
    var initialModule: ModuleInput!
    
    func configure() {
        do {
            initialModule = try ARViewRouter.moduleInput(with: initialViewController)
        } catch {
            debugPrint(error)
        }
    }
    
    override public func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return ApplicationManager.shared
    }
}

extension ApplicationManager: UIApplicationDelegate {
    
}

