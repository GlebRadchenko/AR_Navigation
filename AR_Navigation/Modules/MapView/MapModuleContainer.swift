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
    
    var startLocation: Container<CLLocationCoordinate2D>?
    var endLocation: Container<CLLocationCoordinate2D>?
    var selectedLocations: [Container<CLLocationCoordinate2D>] = []
    
    var routeColors: [String: UIColor] = [:]
    var routes: [Container<MKRoute>] = [] {
        didSet { updateRouteColors() }
    }
    
    func clear() {
        startLocation = nil
        endLocation = nil
        selectedLocations = []
        routes = []
    }
    
    func add(new container: Container<CLLocationCoordinate2D>) {
        selectedLocations.append(container)
    }
    
    func prepareForRoute(with start: Container<CLLocationCoordinate2D>?) {
        if let start = start {
            startLocation = start
        } else if !selectedLocations.isEmpty {
            startLocation = selectedLocations.removeFirst()
        }
    }
    
    func extractColor(for route: Container<MKRoute>) -> UIColor {
        let color = routeColors[route.id] ?? UIColor.randomPrettyColor
        routeColors[route.id] = color
        return color
    }
    
    func updateRouteColors() {
        routeColors.removeAll()
        routes.forEach { routeColors[$0.id] = UIColor.randomPrettyColor }
    }
}

class Container<Element>: Hashable {
    var id = UUID().uuidString
    var hashValue: Int { return id.hashValue }
    
    static func ==(lhs: Container, rhs: Container) -> Bool {
        return lhs.id == rhs.id
    }
    
    var element: Element
    
    init(element: Element) {
        self.element = element
    }
    
    static func container<T>(for element: T) -> Container<T> {
        return Container<T>(element: element)
    }
    
    static func containers<T>(for elements: [T]) -> [Container<T>] {
        return elements.map { container(for: $0) }
    }
}
