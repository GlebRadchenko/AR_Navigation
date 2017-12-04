//
//  UIColor+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/21/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.contains("#") ? hex.components(separatedBy: "#")[1] : hex
        let hexValue = Int(hexString, radix: 16)!
        
        let red = CGFloat((hexValue >> 16) & 0xff) / 255
        let green = CGFloat((hexValue >> 8) & 0xff) / 255
        let blue = CGFloat(hexValue & 0xff) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    static var prettyColors: [UIColor] {
        return [UIColor(hex: "#FADC6B"),
                UIColor(hex: "#E67757"),
                UIColor(hex: "#A6415B"),
                UIColor(hex: "#58E9AD"),
                UIColor(hex: "#2D727F"),
                UIColor(hex: "#1A3D6A"),
                UIColor(hex: "#523258")]
    }
    
    static var randomPrettyColor: UIColor {
        let randomIndex = Int(arc4random_uniform(UInt32(prettyColors.count)))
        return prettyColors[randomIndex]
    }
    
    static var defaultPinColor: UIColor {
        return UIColor(hex: "#E67757")
    }
}

