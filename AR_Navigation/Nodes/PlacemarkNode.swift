//
//  PlacemarkNode.swift
//  TestNodes
//
//  Created by Gleb Radchenko on 11/29/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import MapKit
import ARKit

class PlacemarkNode: GlobalNode<Container<CLLocationCoordinate2D>> {
    
    var bannerNode: BannerNode!
    
    override init(element: Container<CLLocationCoordinate2D>) {
        super.init(element: element)
        sourceId = element.id
        bannerNode = BannerNode()
        addChildNode(bannerNode)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateWith(currentCameraTransform: matrix_float4x4, currentCoordinates: CLLocationCoordinate2D) {
        transform = currentCameraTransform.transformedWithCoordinates(current: currentCoordinates, destination: element.element).toSCNMatrix4()
        
    }
    
    override func applyScale(_ scaleFactor: Float) {
        bannerNode.applyScale(scaleFactor)
    }
}
