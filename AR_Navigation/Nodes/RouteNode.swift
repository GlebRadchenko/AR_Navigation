//
//  RouteNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import MapKit

class RouteNode: GlobalNode<Container<MKRoute>> {
    
    var spheres: [SphereNode] = []
    
    override init(element: Container<MKRoute>) {
        super.init(element: element)
        sourceId = element.id
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateWith(currentCameraTransform: matrix_float4x4, currentCoordinates: CLLocationCoordinate2D, thresholdDistance: Double) {
        
    }
    
    func applyColor(_ color: UIColor) {
        
    }
}
