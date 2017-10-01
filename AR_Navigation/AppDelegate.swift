//
//  AppDelegate.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 9/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        let manager = NavigationManager()
        let source: [Double] = [50.047762, 36.190652] 
        let destination: [Double] = [50.012935, 36.226978]
        
        manager.requestDirections(from: source.coordinate,
                                  to: destination.coordinate,
                                  type: .walking) { (route, error) in
                                    print(route ?? error ?? "No values")
        }
        
        return true
    }
}

