//
//  SCNTransaction+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/30/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

public enum SCNTransactionTimingFunction {
    case linear, easeIn, easeOut, easeInOut, `default`
    
    var value: String {
        switch self {
        case .linear:
            return kCAMediaTimingFunctionLinear
        case .easeIn:
            return kCAMediaTimingFunctionEaseIn
        case .easeOut:
            return kCAMediaTimingFunctionEaseOut
        case .easeInOut:
            return kCAMediaTimingFunctionEaseInEaseOut
        case .default:
            return kCAMediaTimingFunctionDefault
        }
    }
}

extension SCNTransaction {
    public static func animate(with duration: TimeInterval,
                               timingFunction: SCNTransactionTimingFunction = .default,
                               _ animation: @escaping () -> Void,
                               _ completion: (() -> Void)? = nil) {
        
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: timingFunction.value)
        SCNTransaction.animationDuration = duration
        
        animation()
        
        SCNTransaction.completionBlock = completion
        
        SCNTransaction.commit()
    }
}
