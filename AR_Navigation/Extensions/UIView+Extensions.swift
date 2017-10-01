//
//  UIView+Extensions.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func embed(other view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        [view.leadingAnchor.constraint(equalTo: leadingAnchor),
         view.trailingAnchor.constraint(equalTo: trailingAnchor),
         view.topAnchor.constraint(equalTo: topAnchor),
         view.bottomAnchor.constraint(equalTo: bottomAnchor)].forEach { $0.isActive = true }
    }
}

