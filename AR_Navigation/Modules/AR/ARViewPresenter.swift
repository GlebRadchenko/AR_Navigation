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
import PromiseSwift

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
        let container = mapModule.moduleContainer
        updateNodes(for: container.selectedLocations)
        updateNodes(for: container.routes)
//        view.sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
//
//        container.selectedLocations.forEach { (c) in
//            let dest = c.element
//
//            let node = PlacemarkNode()
//            view.sceneView.scene.rootNode.addChildNode(node)
//
//            let bearing = currentLocation.coordinate.bearing(to: dest)
//            let distance = currentLocation.coordinate.distance(to: dest)
//            node.bannerNode.updateInfo("distance: \(distance) meters", backgroundColor: .randomPrettyColor)
//
//            var transform = node.transform
//            let translation = SCNMatrix4MakeTranslation(0, 0, -Float(distance))
//            transform = SCNMatrix4Mult(transform, translation)
//            let rotate = SCNMatrix4MakeRotation(Float(bearing), 0, 1, 0)
//            transform = SCNMatrix4Mult(transform, SCNMatrix4Invert(rotate))
//
//            matrix_identity_float4x4.transformedWithCoordinates(current: currentLocation.coordinate, destination: dest)
//
//            let s = Float(5 / distance)
//            let scale = SCNMatrix4MakeScale(s, s, s)
//            transform = SCNMatrix4Mult(transform, scale)
//
//            node.transform = transform
//        }
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

//MARK: - Nodes Managing
extension ARViewPresenter {
    func updateNodes(for routes: [Container<MKRoute>]) {
        guard let currentLocation = interactor.lastRecognizedLocation else { return }
        guard let cameraTransform = sceneViewManager.currentCameraTransform() else { return }
        
        
    }
    
    func updateNodes(for placeMarks: [Container<CLLocationCoordinate2D>]) {
        guard let currentLocation = interactor.lastRecognizedLocation else { return }
        guard let cameraTransform = sceneViewManager.currentCameraTransform() else { return }
        
        
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

