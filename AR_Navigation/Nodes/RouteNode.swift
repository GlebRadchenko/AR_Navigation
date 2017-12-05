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
    
    var stepNodes: [StepNode] = []
    
    override init(element: Container<MKRoute>) {
        super.init(element: element)
        sourceId = element.id
        initialNodesPrepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialNodesPrepare() {
        stepNodes = element.element.steps.map { StepNode(element: $0) }
        stepNodes.forEach { addChildNode($0) }
    }
    
    override func updateWith(currentCameraTransform: matrix_float4x4, currentCoordinates: CLLocationCoordinate2D, thresholdDistance: Double) {
        stepNodes.forEach { $0.updateWith(currentCameraTransform: currentCameraTransform,
                                          currentCoordinates: currentCoordinates,
                                          thresholdDistance: thresholdDistance) }
    }
    
    func applyColor(_ color: UIColor) {
        stepNodes.forEach { $0.applyColor(color) }
    }
}
