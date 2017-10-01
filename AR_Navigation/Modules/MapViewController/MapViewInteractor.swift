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
    
}

protocol MapViewInteractorOutput: class {
    
}

class MapViewInteractor: MapViewInteractorInput {
    weak var output: MapViewInteractorOutput!
    
    init() {
        
    }
}
