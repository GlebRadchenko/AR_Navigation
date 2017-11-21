//
//  ARSceneViewManager.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

open class ARSceneViewManager: NSObject {
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "scene-update-queue")
    
    public weak var scene: ARSCNView!
    var state: ARSceneViewState = .limitedInitializing
    
    var session: ARSession {
        return scene.session
    }
    
    public init(with scene: ARSCNView) {
        self.scene = scene
        
        super.init()
        
        if ARWorldTrackingConfiguration.isSupported {
            setup()
        }
    }
    
    //MARK: - Setup
    func setup() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
    }
    
    func setupScene() {
        scene.delegate = self
        session.delegate = self
        
        scene.scene = SCNScene()
        scene.automaticallyUpdatesLighting = true
        
        scene.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                              ARSCNDebugOptions.showFeaturePoints]
    }
    
    //MARK: - Session Managing
    public func launchSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        clearStoredDate()
        let configuration = state.configuration
        session.run(configuration)
    }
    
    public func pauseSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        session.pause()
    }
    
    public func updateSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        let options: ARSession.RunOptions =  []

        let configuration = state.configuration
        session.run(configuration, options: options)
    }
    
    func clearStoredDate() {
        //platforms = [:]
    }
}

//MARK: - Logic
extension ARSceneViewManager {
    
}

//MARK: - ARSCNViewDelegate
extension ARSceneViewManager: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
    }
}

//MARK: - ARSessionDelegate
extension ARSceneViewManager: ARSessionDelegate {
    func updateState(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        switch trackingState {
        case .normal
            where frame.anchors.isEmpty:
            state = .normalEmptyAnchors
        case .normal:
            state = .normal
        case .notAvailable:
            state = .notAvailable
        case .limited(.excessiveMotion):
            state = .limitedExcessiveMotion
        case .limited(.insufficientFeatures):
            state = .limitedInsufficientFeatures
        case .limited(.initializing):
            state = .limitedInitializing
        }
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    public func sessionWasInterrupted(_ session: ARSession) {
        state = .interrupted
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        state = .interruptionEnded
        
        updateSession()
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        state = .failed(error)
        
        updateSession()
    }
}

public enum ARSceneViewState {
    case normal
    case normalEmptyAnchors
    case notAvailable
    case limitedExcessiveMotion
    case limitedInsufficientFeatures
    case limitedInitializing
    
    case interrupted
    case interruptionEnded
    case failed(Error)
    
    var configuration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = .horizontal
        
        return configuration
    }
    
    public var hint: String {
        switch self {
        case .normal:
            return ""
        case .normalEmptyAnchors:
            return "Move the device around to detect horizontal surfaces."
        case .notAvailable:
            return "Tracking unavailable."
        case .limitedExcessiveMotion:
            return "Tracking limited - Move the device more slowly."
        case .limitedInsufficientFeatures:
            return "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limitedInitializing:
            return "Initializing AR session."
        case .interrupted:
            return "Session was interrupted"
        case .interruptionEnded:
            return "Session interruption ended"
        case .failed(let error):
            return "Session failed: \(error.localizedDescription)"
        }
    }
}
