//
//  SphereNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/12/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import CoreLocation

class SphereNode: SCNNode {
    
    var sphereGeometry: SCNSphere? {
        return geometry as? SCNSphere
    }
    
    init(radius: CGFloat, color: UIColor) {
        super.init()
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        
        geometry = sphere
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

