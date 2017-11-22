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
        embed(other: view, insets: .zero)
    }
    
    func embed(other view: UIView, insets: UIEdgeInsets) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
                                     view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
                                     view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
                                     view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)])
    }
    
    func subview<T: UIView>() -> T? {
        return subviews.first(where: { $0 is T }) as? T
    }
}

