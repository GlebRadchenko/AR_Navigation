//
//  SCNNode+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    func childs<T>(matching predicate: ((T) -> Bool)? = nil) -> [T] {
        let fitting = childNodes.filter { $0 is T }.flatMap { $0 as? T }
        
        guard let predicate = predicate else { return fitting }
        return fitting.filter(predicate)
    }
}

