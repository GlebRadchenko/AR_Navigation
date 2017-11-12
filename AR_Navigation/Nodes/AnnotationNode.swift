//
//  AnnotationNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/12/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import CoreLocation

class AnnotationNode: SCNNode {
    
    var textGeometry: SCNText? {
        return geometry as? SCNText
    }
    
    init(text: String, color: UIColor, size: CGFloat) {
        super.init()
        let text = SCNText(string: text, extrusionDepth: 0.5)
        text.font = UIFont(name: "HelveticaNeue", size: size)
        text.firstMaterial?.diffuse.contents = color
        
        geometry = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

