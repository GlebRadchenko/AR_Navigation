//
//  MapViewInteractor.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol MapViewInteractorInput: class {
    var lastLocation: CLLocation? { get }
    
    func launchUpdatingLocationAndHeading()
    func requestPlaces(for text: String, callback: @escaping (_ region: MKCoordinateRegion, _ items: [MKMapItem]) -> Void)
}

protocol MapViewInteractorOutput: class {
    func handleLocationUpdate(newLocation: CLLocation, previous: CLLocation?)
    func handleHeadingUpdate(newHeading: CLHeading)
}

class MapViewInteractor: Interactor {
    typealias Presenter = MapViewInteractorOutput
    weak var output: Presenter!
    
    var storedLocations: [CLLocation] = []
    lazy var navigationManager: NavigationManager = NavigationManager()
}

extension MapViewInteractor: MapViewInteractorInput {
    var lastLocation: CLLocation? {
        return storedLocations.last
    }
    
    func launchUpdatingLocationAndHeading() {
        navigationManager.delegate = self
        navigationManager.launchUpdating()
    }
    
    func requestPlaces(for text: String, callback: @escaping (_ region: MKCoordinateRegion, _ items: [MKMapItem]) -> Void) {
        navigationManager.requestPlaces(for: text, from: storedLocations.last, callback: callback)
    }
}

extension MapViewInteractor: NavigationManagerDelegate {
    func navigationManager(_ manager: NavigationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        output.handleLocationUpdate(newLocation: location, previous: storedLocations.last)
        
        storedLocations.append(location)
    }
    
    func navigationManager(_ manager: NavigationManager, didUpdateHeading newHeading: CLHeading) {
        output.handleHeadingUpdate(newHeading: newHeading)
    }
    
    func navigationManager(_ manager: NavigationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func navigationManager(_ manager: NavigationManager, didReceiveNoAuthorization state: CLAuthorizationStatus) {
        print(state)
    }
}
