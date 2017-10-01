//
//  NavigationManager.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import MapKit
import CoreLocation

class NavigationManager {
    func requestDirections(from source: CLLocationCoordinate2D,
                           to destination: CLLocationCoordinate2D,
                           type: MKDirectionsTransportType,
                           completion: @escaping (_ route: MKRoute?, _ error: Error?) -> Void) {
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: source.placemark)
        request.destination = MKMapItem(placemark: destination.placemark)
        request.transportType = type
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            completion(response?.routes.first, error)
        }
    }
}

extension CLLocationCoordinate2D {
    var placemark: MKPlacemark {
        return MKPlacemark(coordinate: self)
    }
}

extension Array where Element == Double {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self[0], longitude: self[1])
    }
}
