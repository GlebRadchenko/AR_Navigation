//
//  ARViewController.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 9/24/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView! {
        didSet {
            sceneView.delegate = self
            sceneView.session.delegate = self
            
            sceneView.scene = SCNScene()
            
            sceneView.showsStatistics = true
            sceneView.automaticallyUpdatesLighting = true
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                      ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func launchSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration)
    }
    
    func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0)
        
        planeNode.opacity = 0.1

        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        resetSession()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        resetSession()
    }
}
