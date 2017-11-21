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


enum MapModuleError: Error {
    case invalidRoute
}

protocol MapViewModuleInput: ModuleInput {
    var moduleOutput: MapViewModuleOutput? { get set }
    var viewController: UIViewController! { get }
    var moduleContainer: MapModuleContainer { get set }
}

protocol MapViewModuleOutput: class {
    func handleMapModuleError(_ error: Error)
    func handleMapContainerChanges()
    func handleHeadingUpdate(_ newHeading: CLHeading)
    func handleLocationUpdate(_ newLocation: CLLocation, previous: CLLocation?)
}

class MapViewPresenter: NSObject, Presenter, MapViewModuleInput {
    
    typealias View = MapViewViewInput
    typealias Router = MapViewRouterInput
    typealias Interactor = MapViewInteractorInput
    
    var interactor: Interactor!
    var router: Router!
    var view: View!
    
    weak var moduleOutput: MapViewModuleOutput?
    
    var viewController: UIViewController! {
        return view as? UIViewController
    }
    
    var state: MapAction = .pin
    var moduleContainer = MapModuleContainer()
}

extension MapViewPresenter: MapViewViewOutput {
    
    func viewDidLoad() {
        view.updateViews(for: state, animated: false)
        view.updateActions(with: MapAction.actions(except: state))
        
        interactor.launchUpdatingLocationAndHeading()
    }
    
    func handleLocationAction() {
        guard let lastLocation = interactor.lastLocation else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: lastLocation.coordinate, span: span)
        
        view.mapView.setRegion(region, animated: true)
    }
    
    func handleActionSelection(at index: Int) {
        state = MapAction.actions(except: state)[index]
        view.updateViews(for: state, animated: true)
        view.updateActions(with: MapAction.actions(except: state))
        
        if state == .clear {
            view.clearAllPins()
            clearRoutes()
            moduleContainer.clear()
            moduleOutput?.handleMapContainerChanges()
        }
    }
    
    func handleGoAction() {
        view.endEditing()
        
        var lastLocationContainer: LocationContainer? = nil
        if let lastLocation = interactor.lastLocation {
            lastLocationContainer = LocationContainer(coordinate: lastLocation.coordinate)
        }
        
        switch state {
        case .pin, .searchPin:
            moduleContainer.prepareForRoute(with: lastLocationContainer)
        case .searchRoute: break
        case .clear: return
        }
        
        buildRouteIfNeeded()
    }
    
    func handleDragAction(for container: LocationContainer) {
        processAddAnnotation(for: container)
        
        if moduleContainer.routes.isEmpty {
            moduleOutput?.handleMapContainerChanges()
        } else {
            buildRouteIfNeeded()
        }
    }
    
    func handleLongPressAction(for location: CLLocationCoordinate2D) {
        switch state {
        case .pin:
            let container = LocationContainer(coordinate: location)
            moduleContainer.add(new: container)
            processAddAnnotation(for: container)
            moduleOutput?.handleMapContainerChanges()
        default:
            break
        }
    }
    
    fileprivate func processAddAnnotation(for container: LocationContainer) {
        interactor.requestPlaces(for: container.coordinate) { [weak self] (placemark) in
            guard let wSelf = self else { return }
            
            DispatchQueue.main.async {
                guard let placemark = placemark else { wSelf.view.removeAnnotation(for: container); return }
                wSelf.view.addOrUpdateAnnotation(for: container, decoratorBlock: { (annotation) in
                    annotation.title = placemark.mainInfo
                    annotation.subtitle = placemark.subInfo
                })
            }
        }
    }
    
    fileprivate func handleMapItemSelection(item: MKMapItem, searchBarType: SearchBarType?) {
        let container = LocationContainer(coordinate: item.placemark.coordinate)
        
        if let searchBarType = searchBarType {
            switch state {
            case .searchPin:
                if let old = moduleContainer.selectedLocations.first {
                    view.removeAnnotation(for: old)
                }
                moduleContainer.add(new: container)
            case .searchRoute:
                switch searchBarType {
                case .source:
                    if let old = moduleContainer.startLocation {
                        view.removeAnnotation(for: old)
                    }
                    moduleContainer.startLocation = container
                case .destination:
                    if let old = moduleContainer.endLocation {
                        view.removeAnnotation(for: old)
                    }
                    moduleContainer.endLocation = container
                default:
                    break
                }
            default:
                break
            }
        } else {
            moduleContainer.add(new: container)
        }
        
        moduleOutput?.handleMapContainerChanges()
        
        view.addOrUpdateAnnotation(for: container) { (annotation) in
            annotation.title = item.mainInfo
            annotation.subtitle = item.subInfo
        }
    }
}

//MARK: - Routes managing
extension MapViewPresenter {
    func buildRouteIfNeeded() {
        guard let start = moduleContainer.startLocation ?? moduleContainer.selectedLocations.first else {
            moduleOutput?.handleMapContainerChanges()
            moduleOutput?.handleMapModuleError(MapModuleError.invalidRoute)
            return
        }
        
        guard let end = moduleContainer.endLocation ?? moduleContainer.selectedLocations.last else {
            moduleOutput?.handleMapContainerChanges()
            moduleOutput?.handleMapModuleError(MapModuleError.invalidRoute)
            return
        }
        
        var locationContainers: [LocationContainer] = []
        
        if moduleContainer.startLocation != nil { locationContainers.append(start) }
        locationContainers.append(contentsOf: moduleContainer.selectedLocations)
        if moduleContainer.endLocation != nil { locationContainers.append(end) }
        
        view.showActivityIndicator()
        interactor.requestRoutes(for: locationContainers.map { $0.coordinate },
                                 routes: [],
                                 type: .walking) { [weak self] (routes, error) in
                                    guard let wSelf = self else { return }
                                    wSelf.view.hideActivityIndicator()
                                    
                                    if let error = error { wSelf.moduleOutput?.handleMapModuleError(error) }
                                    
                                    let routes = routes ?? []
                                    print(routes.count)
                                    DispatchQueue.main.async {
                                        wSelf.handleReceiveNewRoutes(routes)
                                        wSelf.moduleOutput?.handleMapContainerChanges()
                                    }
        }
    }
    
    func handleReceiveNewRoutes(_ newRoutes: [MKRoute]) {
        updateRoutes(newRoutes)
        view.showAllAnnotations()
    }
    
    func clearRoutes() {
        let oldOverlays = view.mapView.overlays
        view.mapView.removeOverlays(oldOverlays)
    }
    
    func updateRoutes(_ newRoutes: [MKRoute]) {
        clearRoutes()
        moduleContainer.routes = newRoutes
        moduleContainer.routes.forEach { (route) in
            view.mapView.add(route.polyline, level: .aboveRoads)
        }
    }
}

extension MapViewPresenter: MapViewInteractorOutput {
    func handleHeadingUpdate(newHeading: CLHeading) {
        view.updateUserHeading(newHeading)
        moduleOutput?.handleHeadingUpdate(newHeading)
    }
    
    func handleLocationUpdate(newLocation: CLLocation, previous: CLLocation?) {
        if previous == nil {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: newLocation.coordinate, span: span)
            
            view.mapView.setRegion(region, animated: true)
        }
        
        moduleOutput?.handleLocationUpdate(newLocation, previous: previous)
    }
}

extension MapViewPresenter: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { return }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing()
        
        let searchBarType = view.type(for: searchBar)
        guard let text = searchBar.text else { return }
        guard !text.isEmpty else { return }
        
        view.showActivityIndicator()
        interactor.requestPlaces(for: text) { [weak self] (region, mapItems) in
            guard let wSelf = self else { return }
            
            DispatchQueue.main.async {
                let vc = wSelf.preparedTableViewController(items: mapItems)
                vc.onSelectItem = { [weak vc] (mapItem) in
                    guard let controller = vc else { return }
                    wSelf.handleMapItemSelection(item: mapItem, searchBarType: searchBarType)
                    
                    wSelf.view.mapView.setRegion(region, animated: true)
                    wSelf.view.mapView.setCenter(mapItem.placemark.coordinate, animated: true)
                    
                    controller.dismiss(animated: true, completion: nil)
                }
                
                wSelf.view.present(vc: vc,
                                   popoverSize: CGSize(width: 300, height: 200 * .goldenSection),
                                   from: searchBar,
                                   arrowDirections: [.down, .left, .right]) {
                                    vc.tableView.reloadData()
                }
            }
        }
    }
    
    func preparedTableViewController(items: [MKMapItem]) -> SearchTableViewController<MKMapItem> {
        let tableViewController = SearchTableViewController<MKMapItem>()
        tableViewController.multipleSelectionEnabled = false
        tableViewController.reload(with: items)
        
        tableViewController.onHide = { [weak self] in
            guard let wSelf = self else { return }
            wSelf.view.hideActivityIndicator()
        }
        
        return tableViewController
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}


