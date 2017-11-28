//
//  Difference.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

struct Difference<T> {
    var oldValue: T
    var newValue: T
}

extension Difference where T: CLLocation {
    func bias() -> Double {
        return oldValue.distance(from: newValue)
    }
}

extension Difference where T == matrix_float4x4 {
    func bias() -> Double {
        return Double(oldValue.translationVector.distance(to: newValue.translationVector))
    }
}

