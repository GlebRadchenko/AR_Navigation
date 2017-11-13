//
//  MapAnnotation.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var locationContainer: LocationContainer
    
    init(container: LocationContainer) {
        self.locationContainer = container
        self.coordinate = container.coordinate
    }
}

