//
//  ARViewRouter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

protocol ARViewRouterInput: class { }

class ARViewRouter: Router, ARViewRouterInput {
    typealias ModuleView = ARViewController
    
    static func moduleInput<T>(with view: UIViewController) throws -> T {
        guard let view = view as? ModuleView else {
            throw RouterError.wrongView
        }
        
        let presenter = ARViewPresenter()
        let interactor = ARViewInteractor()
        let router = ARViewRouter()
        
        view.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        return try presenter.specific()
    }
    
    static func moduleInput<T>() throws -> T {
        let view: ModuleView = try UIStoryboard.extractView()
        let presenter = ARViewPresenter()
        let interactor = ARViewInteractor()
        let router = ARViewRouter()
        
        view.output = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        return try presenter.specific()
    }
}

