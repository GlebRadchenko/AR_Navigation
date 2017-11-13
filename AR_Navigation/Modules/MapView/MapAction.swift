//
//  MapState.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

enum MapAction {
    case pin
    case searchPin
    case searchRoute
    case clear
    
    static var actions: [MapAction] {
        return [pin, searchPin, searchRoute, clear]
    }
    
    static func actions(except: MapAction) -> [MapAction] {
        return actions.filter { $0 != except }
    }
    
    var stringValue: String {
        switch self {
        case .pin:
            return "Select places"
        case .searchPin:
            return "Find place"
        case .searchRoute:
            return "Search route"
        case .clear:
            return "Clear"
        }
    }
    
    var shouldDisplaySearchPanel: Bool {
        switch self {
        case .pin, .clear:
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
