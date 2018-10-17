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
            return convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.linear)
        case .easeIn:
            return convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            return convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            return convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeInEaseOut)
        case .default:
            return convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.default)
        }
    }
}

extension SCNTransaction {
    public static func animate(with duration: TimeInterval,
                               timingFunction: SCNTransactionTimingFunction = .default,
                               _ animation: @escaping () -> Void,
                               _ completion: (() -> Void)? = nil) {
        
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: convertToCAMediaTimingFunctionName(timingFunction.value))
        SCNTransaction.animationDuration = duration
        
        animation()
        
        SCNTransaction.completionBlock = completion
        
        SCNTransaction.commit()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFunctionName(_ input: CAMediaTimingFunctionName) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFunctionName(_ input: String) -> CAMediaTimingFunctionName {
	return CAMediaTimingFunctionName(rawValue: input)
}
