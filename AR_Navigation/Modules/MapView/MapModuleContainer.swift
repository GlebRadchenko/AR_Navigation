//
//  MapModuleContainer.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/13/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class MapModuleContainer {
    
    var startLocation: LocationContainer?
    var endLocation: LocationContainer?
    var selectedLocations: [LocationContainer] = []
    
    var routes: [MKRoute] = []
    
    func clear() {
        startLocation = nil
        endLocation = nil
        selectedLocations = []
        routes = []
    }
    
    func add(new container: LocationContainer) {
        selectedLocations.append(container)
    }
    
    func prepareForRoute(with start: LocationContainer?) {
        if let start = start {
            startLocation = start
        } else if !selectedLocations.isEmpty {
            startLocation = selectedLocations.removeFirst()
        }
        
        if endLocation == nil && !selectedLocations.isEmpty {
            endLocation = selectedLocations.removeLast()
        }
    }
}

class LocationContainer: Hashable {
    var id = UUID().uuidString
    var hashValue: Int { return id.hashValue }
    
    static func ==(lhs: LocationContainer, rhs: LocationContainer) -> Bool {
        return lhs.id == rhs.id
    }
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
