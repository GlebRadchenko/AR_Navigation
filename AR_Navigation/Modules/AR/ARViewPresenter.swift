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
        let nodesToDisplay = interactor.restoreNodes()
        if nodesToDisplay.isEmpty { return }
        sceneViewManager.addNodes(nodesToDisplay)
    }
    
    func removeAndCacheNodesIfNeeded() {
        let nodesToCache = sceneViewManager.removeAllNodes()
        if nodesToCache.isEmpty { return }
        interactor.cacheNodes(nodesToCache)
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
        let existingNodes: [RouteNode] = view.sceneView.scene.rootNode.childs()
        var nodesTable: [String: RouteNode] = [:]
        existingNodes.forEach { nodesTable[$0.element.id] = $0 }
        
        let existingRoutes = existingNodes.map { $0.element }
        
        let existingIds = Set(nodesTable.keys)
        let currentIds = Set(routes.map { $0.id })
        
        let routesToAdd = routes.filter { !existingIds.contains($0.id) }
        let routesToUpdate = routes.filter { existingIds.contains($0.id) }
        let routesToRemove = existingRoutes.filter { !currentIds.contains($0.id) }
        
        addRouteNodes(routesToAdd)
        updateRouteNodes(routesToUpdate)
        removeRouteNodes(routesToRemove)
    }
    
    internal func addRouteNodes(_ routes: [Container<MKRoute>]) {
        let nodes = routes.map { RouteNode(element: $0) }
        
        nodes.forEach { view.sceneView.scene.rootNode.addChildNode($0) }
        updateRouteNodes(routes)
    }
    
    internal func updateRouteNodes(_ placemarks: [Container<MKRoute>]) {
        guard let currentLocation = interactor.lastRecognizedLocation else { return }
        guard let cameraTransform = sceneViewManager.currentCameraTransform() else { return }
        
        let idsToUpdate = Set(placemarks.map { $0.id })
        let nodesToUpdate: [RouteNode] = view.sceneView.scene.rootNode.childs { idsToUpdate.contains($0.element.id) }
        
        nodesToUpdate.forEach { $0.updateWith(currentCameraTransform: cameraTransform,
                                              currentCoordinates: currentLocation.coordinate,
                                              thresholdDistance: .greatestFiniteMagnitude) }
        
        let estimatedFloorHeight = sceneViewManager.estimatedHeight()
        
        nodesToUpdate.forEach { (node) in
            node.applyHeight(estimatedFloorHeight)
            node.applyColor(mapModule.moduleContainer.extractColor(for: node.element))
        }
    }
    
    internal func removeRouteNodes(_ routes: [Container<MKRoute>]) {
        let idsToRemove = Set(routes.map { $0.id })
        let nodesToRemove: [RouteNode] = view.sceneView.scene.rootNode.childs { idsToRemove.contains($0.element.id) }
        nodesToRemove.forEach { $0.removeFromParentNode() }
    }
    
    func updateNodes(for placeMarks: [Container<CLLocationCoordinate2D>]) {
        let existingNodes: [PlacemarkNode] = view.sceneView.scene.rootNode.childs()
        var nodesTable: [String: PlacemarkNode] = [:]
        existingNodes.forEach { nodesTable[$0.element.id] = $0 }
        
        let existingPlacemarks = existingNodes.map { $0.element }
        
        let existingIds = Set(nodesTable.keys)
        let currentIds = Set(placeMarks.map { $0.id })
        
        let placemarksToAdd = placeMarks.filter { !existingIds.contains($0.id) }
        let placemarksToUpdate = placeMarks.filter { existingIds.contains($0.id) }
        let placemarksToRemove = existingPlacemarks.filter { !currentIds.contains($0.id) }
        
        addPlacemarkNodes(placemarksToAdd)
        updatePlacemarkNodesPosition(placemarksToUpdate)
        updatePlacemarkNodesContent(placemarksToAdd + placemarksToUpdate)
        removePlacemarkNodes(placemarksToRemove)
    }
    
    internal func addPlacemarkNodes(_ placemarks: [Container<CLLocationCoordinate2D>]) {
        let nodes = placemarks.map { PlacemarkNode(element: $0) }
        
        nodes.forEach { view.sceneView.scene.rootNode.addChildNode($0) }
        updatePlacemarkNodesPosition(placemarks)
    }
    
    internal func updatePlacemarkNodesPosition(_ placemarks: [Container<CLLocationCoordinate2D>]) {
        guard let currentLocation = interactor.lastRecognizedLocation else { return }
        guard let cameraTransform = sceneViewManager.currentCameraTransform() else { return }
        
        let idsToUpdate = Set(placemarks.map { $0.id })
        let nodesToUpdate: [PlacemarkNode] = view.sceneView.scene.rootNode.childs { idsToUpdate.contains($0.element.id) }
        
        nodesToUpdate.forEach { $0.updateWith(currentCameraTransform: cameraTransform,
                                              currentCoordinates: currentLocation.coordinate,
                                              thresholdDistance: DeveloperSettings.maxSceneRadius) }
        
        let estimatedFloorHeight = sceneViewManager.estimatedHeight()
        SCNTransaction.animate(with: 0.25, { [weak self] in
            guard let wSelf = self else { return }
            
            nodesToUpdate.forEach { (node) in
                let distance = currentLocation.coordinate.distance(to: node.element.element)
                let projectedDistance = distance > DeveloperSettings.maxSceneRadius ? DeveloperSettings.maxSceneRadius : distance
                
                node.applyScale(wSelf.scaleForDistance(projectedDistance))
                node.applyHeight(wSelf.heightForDistance(distance, floorHeight: estimatedFloorHeight))
            }
        }) {
            
            nodesToUpdate.forEach { (node) in
                let distance = currentLocation.coordinate.distance(to: node.element.element)
                
                if distance < 100 {
                    node.stopAnimatedMoving()
                } else {
                    node.startAnimatedMoving()
                }
            }
        }
    }
    
    internal func heightForDistance(_ distance: Double, floorHeight: Float) -> Float {
        if distance > DeveloperSettings.maxSceneRadius {
            return 100 * Float((DeveloperSettings.maxSceneRadius / distance)) + floorHeight
        }
        
        return 5 + floorHeight
    }
    
    internal func scaleForDistance(_ distance: Double) -> Float {
        var scale = Float(distance) * 0.3
        
        if scale < 2 {
            scale = 2
        }
        
        return scale
    }
    
    internal func updatePlacemarkNodesContent(_ placemarks: [Container<CLLocationCoordinate2D>]) {
        guard let currentLocation = interactor.lastRecognizedLocation else { return }
        let idsToUpdate = Set(placemarks.map { $0.id })
        let nodesToUpdate: [PlacemarkNode] = view.sceneView.scene.rootNode.childs { idsToUpdate.contains($0.element.id) }
        
        nodesToUpdate.forEach { (node) in
            interactor.requestPlaces(for: node.element.element) { [weak self] (placemark) in
                guard let wSelf = self else { return }
                
                guard let placemark = placemark else { return }
                let distance = currentLocation.coordinate.distance(to: node.element.element)
                
                let description = wSelf.formAttributedDescription(for: placemark, distance: distance)
                DispatchQueue.main.async {
                    node.updateContent(description)
                }
            }
        }
    }
    
    internal func formAttributedDescription(for placemark: CLPlacemark, distance: Double) -> NSAttributedString {
        
        return NSAttributedString(string: "")
    }
    
    internal func removePlacemarkNodes(_ placemarks: [Container<CLLocationCoordinate2D>]) {
        let idsToRemove = Set(placemarks.map { $0.id })
        let nodesToRemove: [PlacemarkNode] = view.sceneView.scene.rootNode.childs { idsToRemove.contains($0.element.id) }
        nodesToRemove.forEach { $0.removeFromParentNode() }
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
        
        updatePlacemarkNodesContent(mapModule.moduleContainer.selectedLocations)
        if accuracy <= 1 && accuracy >= 0.0001 {
            updatePlacemarkNodesPosition(mapModule.moduleContainer.selectedLocations)
        }
    }
    
    func handleReset() {
        removeAndCacheNodesIfNeeded()
        sceneViewManager.reloadSession()
    }
}
