//
//  Container.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 11/21/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

class Container<Element>: Hashable {
    var id = UUID().uuidString
    var hashValue: Int { return id.hashValue }
    
    static func ==(lhs: Container, rhs: Container) -> Bool {
        return lhs.id == rhs.id
    }
    
    var element: Element
    
    init(element: Element) {
        self.element = element
    }
    
    static func container<T>(for element: T) -> Container<T> {
        return Container<T>(element: element)
    }
    
    static func containers<T>(for elements: [T]) -> [Container<T>] {
        return elements.map { container(for: $0) }
    }
}

