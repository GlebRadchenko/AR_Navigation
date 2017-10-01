//
//  ARViewInteractor.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

protocol ARViewInteractorInput: class {
    
}

protocol ARViewInteractorOutput: class {
    
}

class ARViewInteractor: ARViewInteractorInput, Interactor {
    typealias Presenter = ARViewInteractorOutput
    
    weak var output: Presenter!
}
