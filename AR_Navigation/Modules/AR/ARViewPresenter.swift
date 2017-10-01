//
//  ARViewPresenter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

class ARViewPresenter: NSObject, Presenter {
    typealias View = ARViewViewInput
    typealias Router = ARViewRouterInput
    typealias Interactor = ARViewInteractorInput
    
    weak var view: View!
    var interactor: Interactor!
    var router: Router!
}

extension ARViewPresenter: ARViewViewOutput {
    
}

extension ARViewPresenter: ARViewInteractorOutput {
    
}
