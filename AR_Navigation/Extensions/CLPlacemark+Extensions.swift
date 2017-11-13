//
//  CLPlacemark+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/13/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    var mainInfo: String {
        return name ?? ""
    }
    
    var subInfo: String {
        var info = ""
        
        if let locality = locality { info += locality }
        if let subLocality = subLocality { info += ", \(subLocality)" }
        if let administrativeArea = administrativeArea { info += ", \(administrativeArea)" }
        if let country = country { info += ", \(country)" }
        
        return info
    }
}
