//
//  MapAnnotationView.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        isDraggable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(annotation: nil, reuseIdentifier: type(of: self).reuseIdentifier)
    }
}
