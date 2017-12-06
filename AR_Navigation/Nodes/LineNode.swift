//
//  LineNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/5/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

class LineNode: SCNNode, ColorApplicable {
    
    var cylinder: SCNNode!
    
    init(from initialNode: SCNNode, to destinationNode: SCNNode, radius: CGFloat) {
        super.init()
        transform = initialNode.transform
        
        let length = initialNode.position.distance(to: destinationNode.position)
        
        let rotatedNode = SCNNode()
        rotatedNode.eulerAngles.x = -.pi / 2
        
        let cylinderGeometry = SCNCylinder(radius: radius, height: CGFloat(length))
        cylinderGeometry.firstMaterial?.lightingModel = .physicallyBased
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        
        rotatedNode.addChildNode(cylinderNode)
        cylinder = cylinderNode
        cylinder.position.y = length / 2
        
        addChildNode(rotatedNode)
        constraints = [SCNLookAtConstraint(target: destinationNode)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyColor(_ color: UIColor) {
        cylinder?.geometry?.firstMaterial?.diffuse.contents = color
    }
}
