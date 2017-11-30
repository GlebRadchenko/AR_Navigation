//
//  FloatingPoint+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    static var goldenSection: CGFloat { return 1.62 }
}

extension Double {
    func relativeHeight() -> Double {
        return sqrt(self) * 5
    }
}

extension FloatingPoint {
    var degToRad: Self { return self / 180 * .pi }
    var radToDeg: Self { return self * 180 / .pi }
}

