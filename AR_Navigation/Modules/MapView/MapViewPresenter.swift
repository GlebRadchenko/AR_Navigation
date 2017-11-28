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

enum MapModuleError: LocalizedError {
    case invalidRoute
    
    var errorDescription: String? {
        switch self {
        case .invalidRoute: return "Please, select start and end point of your route"
        }
    }
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
    func handleAnnotationTap(for container: Container<CLLocationCoordinate2D>, isSelected: Bool)
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
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
        
        var lastLocationContainer: Container<CLLocationCoordinate2D>? = nil
        if let lastLocation = interactor.lastLocation {
            lastLocationContainer = Container(element: lastLocation.coordinate)
        }
        
        switch state {
        case .pin, .searchPin:
            moduleContainer.prepareForRoute(with: lastLocationContainer)
        case .searchRoute: break
        case .clear: return
        }
        
        buildRouteIfNeeded()
    }
    
    func handleDragAction(for container: Container<CLLocationCoordinate2D>) {
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
            let container = Container(element: location)
            moduleContainer.add(new: container)
            processAddAnnotation(for: container)
            moduleOutput?.handleMapContainerChanges()
        default:
            break
        }
    }
    
    func handleAnnotationTap(for container: Container<CLLocationCoordinate2D>, isSelected: Bool) {
        moduleOutput?.handleAnnotationTap(for: container, isSelected: isSelected)
    }
    
    fileprivate func processAddAnnotation(for container: Container<CLLocationCoordinate2D>) {
        interactor.requestPlaces(for: container.element) { [weak self] (placemark) in
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
        let container = Container(element: item.placemark.coordinate)
        
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
    
    func color(for overlay: MKOverlay) -> UIColor {
        guard let routeContainer = moduleContainer.routes.first(where: { (container) -> Bool in
            return container.element.polyline === overlay
        }) else {
            return .randomPrettyColor
        }
        
        return moduleContainer.extractColor(for: routeContainer)
    }
}

//MARK: - Routes managing
extension MapViewPresenter {
    func buildRouteIfNeeded() {
        guard let start = moduleContainer.startLocation ?? moduleContainer.selectedLocations.first,
            let end = moduleContainer.endLocation ?? moduleContainer.selectedLocations.last else {
                moduleOutput?.handleMapContainerChanges()
                moduleOutput?.handleMapModuleError(MapModuleError.invalidRoute)
                return
        }
        
        var locationContainers: [Container<CLLocationCoordinate2D>] = []
        
        if moduleContainer.startLocation != nil { locationContainers.append(start) }
        locationContainers.append(contentsOf: moduleContainer.selectedLocations)
        if moduleContainer.endLocation != nil { locationContainers.append(end) }
        
        view.showActivityIndicator()
        
        let locations = locationContainers.map { $0.element }
        interactor.requestRoutes(for: locations, routes: [], type: .walking) { [weak self] (routes, error) in
            guard let wSelf = self else { return }
            wSelf.view.hideActivityIndicator()
            
            let routes = routes ?? []
            if let error = error { wSelf.moduleOutput?.handleMapModuleError(error) }
            
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
        moduleContainer.routes = Container<MKRoute>.containers(for: newRoutes)
        moduleContainer.routes.forEach { (container) in
            view.mapView.add(container.element.polyline, level: .aboveRoads)
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
    
    func handleError(_ error: Error) {
        moduleOutput?.handleMapModuleError(error)
    }
}

extension MapViewPresenter: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { return }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        defer { view.endEditing() }
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        view.showActivityIndicator()
        interactor.requestPlaces(for: text) { [weak self] (region, mapItems) in
            guard let wSelf = self else { return }
            DispatchQueue.main.async {
                wSelf.presentSearchResults(for: mapItems, region: region, searchBar: searchBar)
            }
        }
    }
    
    func presentSearchResults(for items: [MKMapItem], region: MKCoordinateRegion, searchBar: UISearchBar) {
        let searchBarType = view.type(for: searchBar)
        let vc = preparedTableViewController(items: items)
        
        vc.onSelectItem = { [weak self, weak vc] (mapItem) in
            guard let wSelf = self else { return }
            guard let controller = vc else { return }
            
            wSelf.handleMapItemSelection(item: mapItem, searchBarType: searchBarType)
            
            wSelf.view.mapView.setRegion(region, animated: true)
            wSelf.view.mapView.setCenter(mapItem.placemark.coordinate, animated: true)
            
            controller.dismiss(animated: true, completion: nil)
        }
        
        vc.onHide = { [weak self] in
            guard let wSelf = self else { return }
            wSelf.view.hideActivityIndicator()
        }
        
        view.present(vc: vc,
                     popoverSize: CGSize(width: 300, height: 200 * .goldenSection),
                     from: searchBar,
                     arrowDirections: [.down, .left, .right],
                     completion: nil)
        
    }
    
    func preparedTableViewController(items: [MKMapItem]) -> SearchTableViewController<MKMapItem> {
        let tableViewController = SearchTableViewController<MKMapItem>()
        tableViewController.multipleSelectionEnabled = false
        tableViewController.reload(with: items)
        
        return tableViewController
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

