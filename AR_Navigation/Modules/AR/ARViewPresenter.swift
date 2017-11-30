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
    
    var isARSessionReady = false
    
    override init() {
        super.init()
        setupKeyboardManager()
    }
}

//MARK: - Nodes managing logic
extension ARViewPresenter {
    func displayNodesIfNeeded() {
        print(#function)
    }
    
    func removeAndCacheNodesIfNeeded() {
        print(#function)
    }
}

//MARK: - Keyboard handler
extension ARViewPresenter {
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

//MARK: - ARSceneViewManagerDelegate
extension ARViewPresenter: ARSceneViewManagerDelegate {
    func manager(_ manager: ARSceneViewManager, didUpdateState newState: ARSceneViewState) {
        view.displayNotification(message: newState.hint)
        
        switch newState {
        case .normal, .normalEmptyAnchors:
            isARSessionReady = true
            displayNodesIfNeeded()
        default:
            isARSessionReady = false
            removeAndCacheNodesIfNeeded()
        }
    }
}

//MARK: - ARViewViewOutput
extension ARViewPresenter: ARViewViewOutput {
    func viewDidLoad() {
        let sceneManager = ARSceneViewManager(with: view.sceneView)
        sceneManager.delegate = self
        sceneViewManager = sceneManager
        
        mapModule = try? MapViewRouter.moduleInput()
        mapModule.moduleOutput = self
        
        view.embedToContainer(viewController: mapModule.viewController)
        view.toggleContainer(open: true, animated: true)
        
        interactor.lastRecognizedCameraTransform = sceneManager.currentCameraTransform()
    }
    
    func viewDidAppear() {
        sceneViewManager?.launchSession()
    }
    
    func viewWillDisappear() {
        sceneViewManager?.pauseSession()
    }
}

//MARK: - ARViewPresenter
extension ARViewPresenter: MapViewModuleOutput {
    func handleMapModuleError(_ error: Error) {
        view.displayNotification(message: error.localizedDescription)
    }
    
    func handleMapContainerChanges() {
        //print(#function)
        //find diffs between current nodes and all and apply changes
        
        guard let currentLocation = interactor.lastRecognizedLocation else { return }
        guard let cameraTransform = sceneViewManager.currentCameraTransform() else { return }
        
        let container = mapModule.moduleContainer
        container.selectedLocations.forEach { (container) in
            let box = SCNBox(width: 5, height: 10, length: 20, chamferRadius: 1)
            let node = SCNNode(geometry: box)
            
            
            view.sceneView.scene.rootNode.addChildNode(node)
            
            let bearing = currentLocation.coordinate.bearing(to: container.element)
            let distance = currentLocation.coordinate.distance(to: container.element)
            let scale = Float(distance * 0.3)
            
            let translated = SCNMatrix4Translate(SCNMatrix4Identity, 0, 0, Float(distance))
            let rotated = SCNMatrix4Rotate(translated, Float(bearing), 0, 1, 0)
            
            let transform = cameraTransform.translationVector.transform(initialCoordinates: currentLocation.coordinate,
                                                                        destination: container.element)
            
            node.simdTransform = transform
        }
        
    }
    
    func handleHeadingUpdate(_ newHeading: CLHeading) {
        // print(#function)
    }
    
    func handleLocationUpdate(_ newLocation: CLLocation, previous: CLLocation?) {
        guard let cameraTransform = sceneViewManager.currentCameraTransform() else { return }
        interactor.handleLocationUpdate(newLocation: newLocation, currentCameraTransform: cameraTransform)
    }
    
    func handleAnnotationTap(for container: Container<CLLocationCoordinate2D>, isSelected: Bool) {
        //  print(#function)
    }
}

//MARK: - ARViewInteractorOutput
extension ARViewPresenter: ARViewInteractorOutput {
    func handleInitialPositioning() {
        print(#function)
        // take camera translation and according to current location calculate positions for all existing nodes
    }
    
    func handlePositionUpdate(locationDiff: Difference<CLLocation>, cameraDiff: Difference<matrix_float4x4>) {
        let locationTranslation = locationDiff.bias()
        let cameraTranslation = cameraDiff.bias()
        
        let accuracy = Double(Int(abs(locationTranslation - cameraTranslation) * 1000)) / 1000
        view.displatDebugMessage("Accuracy: ±\(accuracy)(m)")
        
        // iterate all displayed nodes and update: 1. distance to them; 2. Their positions if needed
    }
    
    func handleReset() {
        removeAndCacheNodesIfNeeded()
        sceneViewManager.reloadSession()
    }
}

