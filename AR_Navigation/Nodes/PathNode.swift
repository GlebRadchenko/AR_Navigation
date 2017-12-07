//
//  PathNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/5/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

class PathNode: SCNNode, ColorApplicable {
    
    var path: SCNNode!
    
    init(from initialNode: SCNNode, to destinationNode: SCNNode) {
        super.init()
        transform = initialNode.transform
        
        let length = initialNode.position.distance(to: destinationNode.position)
        let pathGeometry = SCNBox(width: 1, height: 0.2, length: CGFloat(length), chamferRadius: 0.01)
        
        let pathNode = SCNNode(geometry: pathGeometry)
        
        path = pathNode
        path.position.z = -length / 2
        addChildNode(pathNode)
        constraints = [SCNLookAtConstraint(target: destinationNode)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyColor(_ color: UIColor) {
        path?.geometry?.firstMaterial?.diffuse.contents = color
    }
}
