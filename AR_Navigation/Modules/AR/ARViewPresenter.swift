//
//  ARViewPresenter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit
import CoreLocation
import MapKit

class ARViewPresenter: NSObject, Presenter {
    typealias View = ARViewViewInput
    typealias Router = ARViewRouterInput
    typealias Interactor = ARViewInteractorInput
    
    var view: View!
    var interactor: Interactor!
    var router: Router!
    
    var mapModule: MapViewModuleInput!
    var sceneViewManager: ARSceneViewManagerInput!
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

extension ARViewPresenter: ARSceneViewManagerDelegate {
    func manager(_ manager: ARSceneViewManager, didUpdateState newState: ARSceneViewState) {
        view.displayNotification(message: newState.hint)
    }
}

extension ARViewPresenter: ARViewViewOutput {
    func viewDidLoad() {
        let sceneManager = ARSceneViewManager(with: view.sceneView)
        sceneManager.delegate = self
        sceneViewManager = sceneManager
        
        mapModule = try? MapViewRouter.moduleInput()
        mapModule.moduleOutput = self
        
        view.embedToContainer(viewController: mapModule.viewController)
        view.toggleContainer(open: true, animated: true)
    }
    
    func viewDidAppear() {
        sceneViewManager?.launchSession()
    }
    
    func viewWillDisappear() {
        sceneViewManager?.pauseSession()
    }
}

extension ARViewPresenter: MapViewModuleOutput {
    func handleMapModuleError(_ error: Error) {
        view.displayNotification(message: error.localizedDescription)
    }
    
    func handleMapContainerChanges() {
        print(#function)
    }
    
    func handleHeadingUpdate(_ newHeading: CLHeading) {
        print(#function)
    }
    
    func handleLocationUpdate(_ newLocation: CLLocation, previous: CLLocation?) {
        print(#function)
    }
    
    func handleAnnotationTap(for container: Container<CLLocationCoordinate2D>, isSelected: Bool) {
        print(#function)
    }
}

extension ARViewPresenter: ARViewInteractorOutput {
    
}

