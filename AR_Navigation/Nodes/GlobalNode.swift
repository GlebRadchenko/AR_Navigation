//
//  GlobalNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import MapKit

//MARK: - Abstact class
class GlobalNode<Source>: SCNNode {
    var sourceId: String = ""
    var element: Source
    
    init(element: Source) {
        self.element = element
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(currentCameraTransform: matrix_float4x4, currentCoordinates: CLLocationCoordinate2D) {
        fatalError("Not implemented")
    }
    
    func applyScale(_ scaleFactor: Float) {
        fatalError("Not implemented")
    }
}
