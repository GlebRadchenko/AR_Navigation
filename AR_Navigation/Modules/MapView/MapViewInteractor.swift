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
    func requestPlaces(for coordinate: CLLocationCoordinate2D, callback: @escaping (CLPlacemark?) -> Void)
    func requestDirections(from source: CLLocationCoordinate2D,
                           to destination: CLLocationCoordinate2D,
                           type: MKDirectionsTransportType,
                           completion: @escaping (_ route: MKRoute?, _ error: Error?) -> Void)
    func requestRoutes(for locations: [CLLocationCoordinate2D],
                       routes: [MKRoute],
                       type: MKDirectionsTransportType,
                       completion: @escaping (_ routes: [MKRoute]?, _ error: Error?) -> Void)
}

protocol MapViewInteractorOutput: class {
    func handleLocationUpdate(newLocation: CLLocation, previous: CLLocation?)
    func handleHeadingUpdate(newHeading: CLHeading)
    func handleError(_ error: Error)
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
    
    func requestPlaces(for coordinate: CLLocationCoordinate2D, callback: @escaping (CLPlacemark?) -> Void) {
        navigationManager.requestPlaces(for: coordinate) { (placemark, error) in
            if let error = error { debugPrint(error) }
            callback(placemark)
        }
    }
    
    func requestDirections(from source: CLLocationCoordinate2D,
                           to destination: CLLocationCoordinate2D,
                           type: MKDirectionsTransportType,
                           completion: @escaping (_ route: MKRoute?, _ error: Error?) -> Void) {
        navigationManager.requestDirections(from: source, to: destination, type: type, completion: completion)
    }
    
    func requestRoutes(for locations: [CLLocationCoordinate2D],
                       routes: [MKRoute],
                       type: MKDirectionsTransportType,
                       completion: @escaping (_ routes: [MKRoute]?, _ error: Error?) -> Void) {
        
        var routes = routes
        var locations = locations
        if locations.count < 2 { completion(routes, nil); return }
        
        let source = locations.removeFirst()
        let destination = locations[0]
        
        requestDirections(from: source, to: destination, type: type) { [weak self] (route, error) in
            guard let wSelf = self else { return }
            
            guard let route = route else { completion(nil, error); return }
            routes.append(route)
            wSelf.requestRoutes(for: locations, routes: routes, type: type, completion: completion)
        }
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
        output.handleError(error)
    }
    
    func navigationManager(_ manager: NavigationManager, didReceiveNoAuthorization state: CLAuthorizationStatus) {
        print(state)
    }
}
