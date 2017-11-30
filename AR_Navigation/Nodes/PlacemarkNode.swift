//
//  PlacemarkNode.swift
//  TestNodes
//
//  Created by Gleb Radchenko on 11/29/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

class PlacemarkNode: SCNNode {
    
    var bannerNode: BannerNode!
    
    override init() {
        bannerNode = BannerNode()
        super.init()
        addChildNode(bannerNode)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
