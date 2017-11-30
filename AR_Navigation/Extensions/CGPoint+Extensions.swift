//
//  CGPoint+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/30/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func translated(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}
