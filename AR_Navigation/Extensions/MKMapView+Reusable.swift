//
//  MKMapView+Reusable.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func dequeueReusableAnnotationView<T: Reusable>() -> T? {
        return dequeueReusableAnnotationView(withIdentifier: T.reuseIdentifier) as? T
    }
    
    func dequeueReusableAnnotationView<T: Reusable>(for annotation: MKAnnotation) -> T? {
        return dequeueReusableAnnotationView(withIdentifier: T.reuseIdentifier, for: annotation) as? T
    }
}

extension MKAnnotationView: Reusable {
    convenience init(annotation: MKAnnotation?) {
        self.init(annotation: annotation, reuseIdentifier: type(of: self).reuseIdentifier)
    }
}

