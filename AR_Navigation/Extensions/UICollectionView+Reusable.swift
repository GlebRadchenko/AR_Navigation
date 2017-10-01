//
//  UICollectionView+Reusable.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register(_ cellType: Reusable.Type) {
        let nib = UINib.nib(for: cellType)
        register(nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func registerHeaderFooter(_ viewType: Reusable.Type, suplementaryViewOfKind: String) {
        let nib = UINib.nib(for: viewType)
        self.register(nib, forSupplementaryViewOfKind: suplementaryViewOfKind, withReuseIdentifier: viewType.reuseIdentifier)
    }
    
    func registerCellClass(_ cellType: Reusable.Type) {
        self.register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell(forCell type: Reusable.Type, indexPath: IndexPath) -> Reusable {
        return dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath) as! Reusable
    }
    
    func dequeueReusableCell<T: Reusable>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

extension UINib {
    static func nib(for cellType: Reusable.Type) -> UINib {
        return UINib(nibName: cellType.nibName, bundle: Bundle(for: cellType))
    }
}

