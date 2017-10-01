//
//  NSAttributedString+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    func estimatedSize(width: CGFloat) -> CGSize {
        return boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                            context: nil).size
    }
    
    func estimatedSize(height: CGFloat) -> CGSize {
        return boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height),
                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                            context: nil).size
    }
}

