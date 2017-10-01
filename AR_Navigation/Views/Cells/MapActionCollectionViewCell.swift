//
//  MapActionCollectionViewCell.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import Foundation

protocol MapActionDisplayable {
    var imageName: String { get }
}

extension MapState: MapActionDisplayable { }

class MapActionCollectionViewCell: UICollectionViewCell, Reusable {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
    }
    
    func configure(with item: MapActionDisplayable) {
        label.text = item.stringValue
    }
    
    static func estimatedWidth(for text: String, height: CGFloat) -> CGFloat {
        let font = UIFont(name: "HelveticaNeue", size: 15)
        
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [NSAttributedStringKey.font: font!])
        
        return attributedString.estimatedSize(height: height).width + 16
    }
}
