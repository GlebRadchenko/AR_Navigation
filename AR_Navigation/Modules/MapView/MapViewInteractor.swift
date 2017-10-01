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

class MapViewInteractor: MapViewInteractorInput, Interactor {
    typealias Presenter = MapViewInteractorOutput
    weak var output: Presenter!
    
    init() {
        
    }
}
