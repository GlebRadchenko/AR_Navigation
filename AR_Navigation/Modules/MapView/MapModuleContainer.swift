//
//  MapModuleContainer.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/13/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import CoreLocation

class MapModuleContainer {
    
    var startLocation: LocationContainer?
    var endLocation: LocationContainer?
    
    var selectedLocations: [LocationContainer] = []
    
    func clear() {
        startLocation = nil
        endLocation = nil
        selectedLocations = []
    }
    
    func add(new container: LocationContainer) {
        guard !selectedLocations.contains(container) else { return }
        selectedLocations.append(container)
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
