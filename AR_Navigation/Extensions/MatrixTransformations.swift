//
//  MatrixTransformations.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/12/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

extension matrix_float4x4 {
    var translationVector: SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
    
    func translated(for vector: vector_float4) -> matrix_float4x4 {
        var translation = matrix_identity_float4x4
        translation.columns.3 = vector
        return simd_mul(self, translation)
    }
    
    
    //    column 0  column 1  column 2  column 3
    //        cosθ      0       sinθ      0    
    //         0        1         0       0    
    //       −sinθ      0       cosθ      0    
    //         0        0         0       1    
    func rotatedAroundY(by radians: Float) -> matrix_float4x4 {
        var rotation = matrix_identity_float4x4
        
        rotation.columns.0.x = cos(radians)
        rotation.columns.0.z = -sin(radians)
        
        rotation.columns.2.x = sin(radians)
        rotation.columns.2.z = cos(radians)
        
        return simd_mul(self, rotation.inverse)
    }
    
    func transformedWithCoordinates(current: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> matrix_float4x4 {
        let distance = current.distance(to: destination)
        let bearing = current.bearing(to: destination)
        
        let position = vector_float4(0, 0, -Float(distance), 1)
        
        return translated(for: position).rotatedAroundY(by: Float(bearing))
    }
}
