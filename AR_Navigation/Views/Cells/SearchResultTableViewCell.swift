//
//  SearchResultTableViewCell.swift
//  AR_Navigation
//
//  Created by Gleb on 10/2/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

protocol SearchResultDisplayable {
    var mainInfo: String { get }
    var subInfo: String { get }
}

class SearchResultTableViewCell: UITableViewCell, Reusable {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: SearchResultDisplayable) {
        mainLabel.text = item.mainInfo
        subLabel.text = item.subInfo
    }
}
