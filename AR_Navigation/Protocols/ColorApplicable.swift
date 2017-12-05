//
//  ColorApplicable.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/5/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

protocol ColorApplicable {
    func applyColor(_ color: UIColor)
}

extension ColorApplicable where Self: SCNNode {
    func applyColor(_ color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
    }
}
