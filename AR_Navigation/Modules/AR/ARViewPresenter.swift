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
    lazy var keyboardManager: KeyboardEventsManager = KeyboardEventsManager()
    
    override init() {
        super.init()
        setupKeyboardManager()
    }
    
    func setupKeyboardManager() {
        keyboardManager.onWillShow = onWillShowKeyboard()
        keyboardManager.onWillChange = onWillChangeKeyboard()
        keyboardManager.onWillHide = onWillHideKeyboard()
    }
    
    func onWillShowKeyboard() -> (CGRect, TimeInterval) -> Void {
        return { [weak self] (keyboardFrame, duration) in
            guard let wSelf = self else { return }
            wSelf.view.updateViews(for: keyboardFrame, duration: duration)
        }
    }
    
    func onWillChangeKeyboard() -> (CGRect, TimeInterval) -> Void {
        return { [weak self] (keyboardFrame, duration) in
            guard let wSelf = self else { return }
            wSelf.view.updateViews(for: keyboardFrame, duration: duration)
        }
    }
    
    func onWillHideKeyboard() -> (TimeInterval) -> Void {
        return { [weak self] (duration) in
            guard let wSelf = self else { return }
            wSelf.view.updateViews(for: nil, duration: duration)
        }
    }
}

extension ARViewPresenter: ARViewViewOutput {
    func viewDidLoad() {
        sceneViewManager = ARSceneViewManager(with: view.sceneView)
        mapModule = try? MapViewRouter.module()
        
        view.embedToContainer(viewController: mapModule.view)
        view.toggleContainer(open: true, animated: true)
    }
    
    func viewDidAppear() {
        sceneViewManager?.launchSession()
    }
    
    func viewWillDisappear() {
        sceneViewManager?.pauseSession()
    }
}

extension ARViewPresenter: ARViewInteractorOutput {
    
}
