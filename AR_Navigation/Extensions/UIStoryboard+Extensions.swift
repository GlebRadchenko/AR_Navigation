//
//  UIStoryboard+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

enum StoryboardError: Error {
    case wrongView
}

extension UIStoryboard {
    static func extractView<T: View>() throws -> T {
        guard let view = UIStoryboard(name: T.storyboardName, bundle: nil).instantiateInitialViewController() as? T else {
            throw StoryboardError.wrongView
        }
        
        return view
    }
}

