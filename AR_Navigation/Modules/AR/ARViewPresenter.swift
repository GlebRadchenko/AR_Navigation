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
    
    var mapModule: Module!
    var sceneViewManager: ARSceneViewManager!
}

extension ARViewPresenter: ARViewViewOutput {
    func viewDidLoad() {
        sceneViewManager = ARSceneViewManager(with: view.sceneView)
        mapModule = try? MapViewRouter.module()
        view.embedToContainer(viewController: mapModule.view)
    }
    
    func viewDidAppear() {
        sceneViewManager?.launchSession()
    }
    
    func viewWillDisappear() {
        sceneViewManager.pauseSession()
    }
}

extension ARViewPresenter: ARViewInteractorOutput {
    
}
