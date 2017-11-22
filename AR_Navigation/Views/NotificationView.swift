//
//  NotificationView.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/22/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    weak var effectView: UIVisualEffectView!
    weak var label: UILabel!
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        backgroundColor = .clear
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectView.clipsToBounds = true
        effectView.layer.cornerRadius = 5
        embed(other: effectView, insets: UIEdgeInsets(top: 4, left: 4, bottom: -4, right: -4))
        
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.contentMode = .center
        label.numberOfLines = 0
        label.textColor = .lightGray
        effectView.embed(other: label)
        
        
        self.effectView = effectView
        self.label = label
    }
    
    func setText(_ text: String, color: UIColor = .lightGray) {
        label?.text = text
        label?.textColor = color
    }
}

