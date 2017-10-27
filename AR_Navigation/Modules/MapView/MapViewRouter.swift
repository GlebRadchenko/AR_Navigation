//
//  MapViewRouter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

protocol MapViewRouterInput {
    
}

class MapViewRouter: MapViewRouterInput, Router {
    typealias ModuleView = MapViewController
    
    static func moduleInput<T>() throws -> T {
        let view: ModuleView = try UIStoryboard.extractView()
        let presenter = MapViewPresenter()
        let interactor = MapViewInteractor()
        let router = MapViewRouter()
        
        view.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        return try presenter.specific()
    }
}

