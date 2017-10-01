//
//  MapViewPresenter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapViewPresenter: NSObject, Presenter {
    typealias View = MapViewViewInput
    typealias Router = MapViewRouterInput
    typealias Interactor = MapViewInteractorInput
    
    var interactor: Interactor!
    var router: Router!
    weak var view: View!
    
    var state: MapState = .pin
    var storedLocations: [CLLocation] = []
    lazy var navigationManager: NavigationManager = NavigationManager()
    
    func addNewLocation(_ location: CLLocation) {
        if storedLocations.isEmpty {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            view.mapView.setRegion(region, animated: true)
        }
        
        storedLocations.append(location)
    }
}

extension MapViewPresenter: MapViewViewOutput {
    
    func viewDidLoad() {
        view.updateViews(for: state, animated: false)
        view.updateActions(with: MapState.actions(except: state))
        
        navigationManager.delegate = self
        navigationManager.launchUpdating()
    }
    
    func handleActionSelection(at index: Int) {
        state = MapState.actions(except: state)[index]
        view.updateViews(for: state, animated: true)
        view.updateActions(with: MapState.actions(except: state))
    }
    
    func handleGoAction() {
        view.endEditing()
    }
    
    func handleLocationAction() {
        guard let lastLocation = storedLocations.first else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: lastLocation.coordinate, span: span)
        
        view.mapView.setRegion(region, animated: true)
    }
    
    func textFieldDidChange(_ textFieldType: TextFieldType, text: String) {
        switch textFieldType {
        case .source:
            break
        case .destination:
            break
        default: break
        }
    }
}

extension MapViewPresenter: NavigationManagerDelegate {
    func navigationManager(_ manager: NavigationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        addNewLocation(location)
    }
    
    func navigationManager(_ manager: NavigationManager, didUpdateHeading newHeading: CLHeading) {
       // print(newHeading)
    }
    
    func navigationManager(_ manager: NavigationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func navigationManager(_ manager: NavigationManager, didReceiveNoAuthorization state: CLAuthorizationStatus) {
        print(state)
    }
}

extension MapViewPresenter: MapViewInteractorOutput {
    
}

extension MapViewPresenter: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}


