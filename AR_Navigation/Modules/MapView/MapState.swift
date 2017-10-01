//
//  MapState.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

enum MapState {
    case pin
    case searchPin
    case route
    case searchRoute
    
    static var actions: [MapState] {
        return [pin, searchPin, route, searchRoute]
    }
    
    static func actions(except: MapState) -> [MapState] {
        return actions.filter { $0 != except }
    }
    
    var stringValue: String {
        switch self {
        case .pin:
            return "Select place"
        case .searchPin:
            return "Find place"
        case .route:
            return "Select route"
        case .searchRoute:
            return "Search route"
        }
    }
    
    var shouldDisplaySearchPanel: Bool {
        switch self {
        case .pin, .route:
            return false
        default:
            return true
        }
    }
    
    var bothTextFieldsAreDisplayed: Bool {
        switch self {
        case .searchRoute:
            return true
        default:
            return false
        }
    }
    
    var firstPlaceholder: String {
        switch self {
        case .searchPin:
            return "Enter Location"
        case .searchRoute:
            return "Enter Source"
        default:
            return ""
        }
    }
    
    var secondPlaceholder: String {
        switch self {
        case .searchRoute:
            return "Enter Destination"
        default:
            return ""
        }
    }
}
