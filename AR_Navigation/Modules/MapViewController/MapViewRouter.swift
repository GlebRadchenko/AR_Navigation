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

enum MapViewRouterError: Error {
    case wrongView
}

class MapViewRouter: MapViewRouterInput {
    
    static func module() throws -> Module {
        guard let view = UIStoryboard(name: "MapView", bundle: nil).instantiateInitialViewController() as? MapViewController else {
            throw MapViewRouterError.wrongView
        }
        
        let presenter = MapViewPresenter()
        let interactor = MapViewInteractor()
        let router = MapViewRouter()
        
        view.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        return Module(view: view, input: presenter)
    }
}
