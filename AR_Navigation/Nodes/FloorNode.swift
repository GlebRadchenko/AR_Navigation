//
//  FloorNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/7/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class FloorNode: SCNNode, ColorApplicable {
    var anchor: ARPlaneAnchor
    
    var surfaceGeometry: SCNPlane? {
        return geometry as? SCNPlane
    }
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        
        geometry = SCNPlane(width: 0, height: 0)
        eulerAngles = SCNVector3(-.pi / 2, 0.0, 0.0)
        
        updatePostition(anchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePostition(_ anchor: ARPlaneAnchor) {
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        surfaceGeometry?.width = CGFloat(anchor.extent.x)
        surfaceGeometry?.height = CGFloat(anchor.extent.z)
    }
}

